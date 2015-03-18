/*
 * Cocos2D-SpriteBuilder: http://cocos2d.spritebuilder.com
 *
 * Copyright (c) 2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCRenderDispatch_Private.h"
#import "CCGL.h"

#if CC_RENDER_DISPATCH_ENABLED

/// Maximum number of frames that can be queued at once.
#define CC_RENDER_DISPATCH_MAX_FRAMES 3


@interface CCRenderThread : NSThread @end
@implementation CCRenderThread {
    NSMutableArray *_blocks;
    dispatch_semaphore_t _blocks_available;
    dispatch_semaphore_t _queued_frames;
    dispatch_semaphore_t _sync;
}

-(instancetype)init
{
    if((self = [super init])){
        _blocks = [NSMutableArray array];
		_blocks_available = dispatch_semaphore_create(0);
		_queued_frames = dispatch_semaphore_create(CC_RENDER_DISPATCH_MAX_FRAMES);
        _sync = dispatch_semaphore_create(0);
    }
    
    return self;
}

-(void)enqueueBlock:(dispatch_block_t)block sync:(BOOL)sync frame:(BOOL)frame
{
    if(sync){
        [self enqueueBlockSync:block frame:frame];
    } else {
        [self enqueueBlockAsync:block frame:frame];
    }
}

-(void)enqueueBlockSync:(dispatch_block_t)block frame:(BOOL)frame
{
    @synchronized(_blocks){
        dispatch_semaphore_t queued_frames = _queued_frames;
        dispatch_semaphore_t sync = _sync;
        [_blocks addObject:^{
            block();
            
            if(frame) dispatch_semaphore_signal(queued_frames);
            dispatch_semaphore_signal(sync);
        }];
    }
    
    dispatch_semaphore_signal(_blocks_available);
    dispatch_semaphore_wait(_sync, DISPATCH_TIME_FOREVER);
//    @synchronized(_blocks){
//        dispatch_semaphore_t sync = _sync;
//        [_blocks addObject:^{dispatch_semaphore_signal(sync);}];
//    }
//    
//    dispatch_semaphore_signal(_blocks_available);
//    
//    // Wait for the queue to finish.
//    dispatch_semaphore_wait(_sync, DISPATCH_TIME_FOREVER);
//    block();
//    
//    if(frame) dispatch_semaphore_signal(_queued_frames);
}

-(void)enqueueBlockAsync:(dispatch_block_t)block frame:(BOOL)frame
{
    @synchronized(_blocks){
        dispatch_semaphore_t queued_frames = _queued_frames;
        [_blocks addObject:^{
            block();
            
            if(frame) dispatch_semaphore_signal(queued_frames);
        }];
    }
    
    dispatch_semaphore_signal(_blocks_available);
}

-(BOOL)ready
{
	return !dispatch_semaphore_wait(_queued_frames, 0);
}

-(void)main
{
    for(;;){
        dispatch_semaphore_wait(_blocks_available, DISPATCH_TIME_FOREVER);
        
        dispatch_block_t block = nil;
        @synchronized(_blocks){
            block = _blocks.firstObject;
            [_blocks removeObjectAtIndex:0];
        }
        
        block();
    }
}

@end


static CCRenderThread *CC_RENDER_DISPATCH_THREAD = nil;


EAGLContext *CCRenderDispatchSetupGL(EAGLRenderingAPI api, EAGLSharegroup *sharegroup)
{
	NSCAssert(CC_RENDER_DISPATCH_ENABLED, @"Threaded rendering is not enabled.");
	
    static EAGLContext *context = nil;
    
	static dispatch_once_t once = 0;
	dispatch_once(&once, ^{
		context = [[EAGLContext alloc] initWithAPI:api sharegroup:sharegroup];
		
        CC_RENDER_DISPATCH_THREAD = [[CCRenderThread alloc] init];
        [CC_RENDER_DISPATCH_THREAD start];
        [CC_RENDER_DISPATCH_THREAD enqueueBlockAsync:^{[EAGLContext setCurrentContext:context];} frame:NO];
        
	});
	
	return context;
}

#endif


static void CCRenderDispatchExecute(BOOL threadsafe, BOOL frame, dispatch_block_t block)
{
#if CC_RENDER_DISPATCH_ENABLED
        [CC_RENDER_DISPATCH_THREAD enqueueBlock:^{block();} sync:!threadsafe frame:frame];
#else
	block();
#endif
}

BOOL CCRenderDispatchBeginFrame(void)
{
#if CC_RENDER_DISPATCH_ENABLED
	return [CC_RENDER_DISPATCH_THREAD ready];
#else
	return YES;
#endif
}

void CCRenderDispatchCommitFrame(BOOL threadsafe, dispatch_block_t block)
{
	CCRenderDispatchExecute(threadsafe, YES, block);
}

void CCRenderDispatch(BOOL threadsafe, dispatch_block_t block)
{
	CCRenderDispatchExecute(threadsafe, NO, block);
}
