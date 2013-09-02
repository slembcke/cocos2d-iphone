/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013 Lars Birkemose
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
 *
 *
 * File autogenerated with Xcode. Adapted for cocos2d needs.
 */

#import "CCResponderManager.h"
#import "CCNode.h"
#import "CCDirector.h"
#import "CCScene.h"

// -----------------------------------------------------------------
#pragma mark -
// -----------------------------------------------------------------

@implementation CCRunningResponder

@end

// -----------------------------------------------------------------
#pragma mark -
// -----------------------------------------------------------------

@implementation CCResponderManager
{
    __weak CCNode           *_responderList[CCResponderManagerBufferSize];
    int                     _responderCount;
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    NSMutableArray          *_runningResponderList;                 // list of running touches
#else
    __weak id               _runningResponder;
#endif
}

// -----------------------------------------------------------------
#pragma mark - create and destroy
// -----------------------------------------------------------------

+ (id)responderManager
{
    return([[self alloc] init]);
}

- (id)init
{
    self = [super init];
    NSAssert(self != nil, @"Unable to create class");
    
    // initalize
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    _runningResponderList = [NSMutableArray array];
#else
    _runningResponder = nil;
#endif
    // reset touch handling
    [self removeAllResponders];
    
    // done
    return(self);
}

// -----------------------------------------------------------------
#pragma mark - add and remove touch responders
// -----------------------------------------------------------------

- (void)buildResponderList
{
    // rebuild touch list
    // TODO: only rebuild if dirty
    [self removeAllResponders];
    [[CCDirector sharedDirector].runningScene buildResponderList];
}

// -----------------------------------------------------------------

- (void)addResponder:(CCNode *)responder
{
    _responderList[_responderCount] = responder;
    _responderCount ++;
    NSAssert(_responderCount < CCResponderManagerBufferSize, @"Number of touchable nodes pr. scene can not exceed <%d>", CCResponderManagerBufferSize);
}

- (void)removeAllResponders
{    
    _responderCount = 0;
}

// -----------------------------------------------------------------
#pragma mark - iOS touch handling -
// -----------------------------------------------------------------

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL responderCanAcceptTouch;
    
    [self buildResponderList];
    
    // go through all touches
    for (UITouch *touch in touches)
    {
        // scan backwards through touch responders
        for (int index = _responderCount - 1; index >= 0; index --)
        {
            CCNode *node = _responderList[index];
            
            // check for hit test
            if ([node hitTestWithWorldPos:[[CCDirector sharedDirector] convertToGL:[touch locationInView:[CCDirector sharedDirector].view]]] != NO)
            {
                // if not a multi touch node, check if node already is being touched
                responderCanAcceptTouch = YES;
                if (node.isMultipleTouchEnabled == NO)
                {
                    // scan current touch objects, and break if object already has a touch
                    for (CCRunningResponder *responderEntry in _runningResponderList) if (responderEntry.target == node)
                    {
                        responderCanAcceptTouch = NO;
                        break;
                    }
                }                
                if (responderCanAcceptTouch == NO) break;
                
                // begin the touch
                self.eventProcessed = YES;
                if ([node respondsToSelector:@selector(touchesBegan:withEvent:)] != NO)
                    [node touchesBegan:[NSSet setWithObject:touch] withEvent:event];
 
                // if touch was processed, add it and break
                if (self.eventProcessed != NO)
                {
                    [self addtouchResponder:node withTouch:touch andEvent:event];
                    break;
                }
            }
        }
    }
}

// -----------------------------------------------------------------

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self buildResponderList];

    // go through all touches
    for (UITouch *touch in touches)
    {
        // get touch object
        CCRunningResponder *touchEntry = [self touchResponderForEvent:event];
        
        // if a touch object was found
        if (touchEntry != nil)
        {
            CCNode* node = (CCNode*)touchEntry.target;
            
            // check if it locks touches
            if (node.isTouchLocked != NO)
            {
                // move the touch
                if ([node respondsToSelector:@selector(touchesMoved:withEvent:)] != NO)
                    [node touchesMoved:[NSSet setWithObject:touch] withEvent:event];
            }
            else
            {
                // as node does not lock touch, check if it was moved outside
                if ([node hitTestWithWorldPos:[[CCDirector sharedDirector] convertToGL:[touch locationInView:[CCDirector sharedDirector].view]]] == NO)
                {
                    // cancel the touch
                    if ([node respondsToSelector:@selector(touchesCancelled:withEvent:)] != NO)
                        [node touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
                    // remove from list
                    [_runningResponderList removeObject:touchEntry];
                }
                else
                {
                    // move the touch
                    if ([node respondsToSelector:@selector(touchesMoved:withEvent:)] != NO)
                        [node touchesMoved:[NSSet setWithObject:touch] withEvent:event];
                }
            }
        }
        else
        {
            // scan backwards through touch responders
            for (int index = _responderCount - 1; index >= 0; index --)
            {
                CCNode *node = _responderList[index];
            
                // if the touch responder does not lock touch, it will receive a touchesBegan if a touch is moved inside
                if ((node.isTouchLocked == NO) && ([node hitTestWithWorldPos:[[CCDirector sharedDirector] convertToGL:[touch locationInView:[CCDirector sharedDirector].view ]]] != NO))
                {
                    // begin the touch
                    self.eventProcessed = YES;
                    if ([node respondsToSelector:@selector(touchesBegan:withEvent:)] != NO)
                        [node touchesBegan:[NSSet setWithObject:touch] withEvent:event];
                    
                    // if touch was accepted, add it and break
                    if (self.eventProcessed != NO)
                    {
                        [self addtouchResponder:node withTouch:touch andEvent:event];
                        break;
                    }
                }
            }
        }
    }
}

// -----------------------------------------------------------------

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self buildResponderList];

    // go through all touches
    for (UITouch *touch in touches)
    {
        // get touch object
        CCRunningResponder *touchEntry = [self touchResponderForEvent:event];
        
        if (touchEntry != nil)
        {
            CCNode* node = (CCNode*)touchEntry.target;
            
            // end the touch
            if ([node respondsToSelector:@selector(touchesEnded:withEvent:)] != NO)
                [node touchesEnded:[NSSet setWithObject:touch] withEvent:event];
            // remove from list
            [_runningResponderList removeObject:touchEntry];
        }
    }
}

// -----------------------------------------------------------------

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self buildResponderList];

    // go through all touches
    for (UITouch *touch in touches)
    {
        // get touch object
        CCRunningResponder *touchEntry = [self touchResponderForEvent:event];
        
        if (touchEntry != nil)
        {
            CCNode* node = (CCNode*)touchEntry.target;

            // cancel the touch
            NSLog(@"Cancelled with <%d> touch responder(s)", _runningResponderList.count);
            if ([node respondsToSelector:@selector(touchesCancelled:withEvent:)] != NO)
                [node touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
            // remove from list
            [_runningResponderList removeObject:touchEntry];
        }
    }
}

// -----------------------------------------------------------------
#pragma mark - helper functions
// -----------------------------------------------------------------
// finds a touch object for an event

- (CCRunningResponder *)touchResponderForEvent:(UIEvent *)event
{
    for (CCRunningResponder *touchEntry in _runningResponderList)
    {
        if (touchEntry.event == event) return(touchEntry);
    }
    return(nil);
}

// -----------------------------------------------------------------
// finds a touch object for a node

- (NSSet *)touchSetForNode:(CCNode *)node
{
    NSMutableSet *result = [NSMutableSet set];
    for (CCRunningResponder *touchEntry in _runningResponderList)
    {
        if (touchEntry.target == node) [result addObject:touchEntry.touch];
    }
    return(result);
}

// -----------------------------------------------------------------
// adds a touch object ( running touch ) to the touch object list

- (void)addtouchResponder:(CCNode *)node withTouch:(UITouch *)touch andEvent:(UIEvent *)event
{
    CCRunningResponder *touchEntry;
    
    // create a new touch object
    touchEntry = [[CCRunningResponder alloc] init];
    touchEntry.target = node;
    touchEntry.touch = touch;
    touchEntry.event = event;
    [_runningResponderList addObject:touchEntry];
}

// -----------------------------------------------------------------

#else

// -----------------------------------------------------------------
#pragma mark - Mac mouse handling -
// -----------------------------------------------------------------

- (void)mouseDown:(NSEvent *)theEvent button:(CCMouseButton)button
{
    NSAssert(_runningResponder == nil, @"Unexpected Mouse State");
    
    [self buildResponderList];
    
    // scan backwards through mouse responders
    for (int index = _responderCount - 1; index >= 0; index --)
    {
        CCNode *node = _responderList[index];
        
        // check for hit test
        if ([node hitTestWithWorldPos:theEvent.locationInWindow] != NO)
        {
            // begin the mouse down
            self.eventProcessed = YES;
            if ([node respondsToSelector:@selector(mouseDown:)] != NO)
                [node mouseDown:theEvent];
            
            // if mouse was processed, remember it and break
            if (self.eventProcessed != NO)
            {
                _runningResponder = node;
                break;
            }
        }
    }
}

- (void)mouseDragged:(NSEvent *)theEvent button:(CCMouseButton)button
{
    [self buildResponderList];
    
    if (_runningResponder != nil)
    {
        CCNode* node = (CCNode*)_runningResponder;
        
        // check if it locks mouse
        if (node.isTouchLocked != NO)
        {
            // move the mouse
            if ([node respondsToSelector:@selector(mouseDragged:)] != NO)
                [node mouseDragged:theEvent];
        }
        else
        {
            // as node does not lock mouse, check if it was moved outside
            if ([node hitTestWithWorldPos:theEvent.locationInWindow] == NO)
            {
                _runningResponder = nil;
            }
            else
            {
                // move the mouse
                if ([node respondsToSelector:@selector(mouseDragged:)] != NO)
                    [node mouseDragged:theEvent];
            }
        }
    }
    else
    {
        // scan backwards through mouse responders
        for (int index = _responderCount - 1; index >= 0; index --)
        {
            CCNode *node = _responderList[index];
            
            // if the mouse responder does not lock mouse, it will receive a mouseDown if mouse is moved inside
            if ((node.isTouchLocked == NO) && ([node hitTestWithWorldPos:theEvent.locationInWindow] != NO))
            {
                // begin the mouse down
                self.eventProcessed = YES;
                if ([node respondsToSelector:@selector(mouseDown:)] != NO)
                    [node mouseDown:theEvent];
                
                // if mouse was accepted, add it and break
                if (self.eventProcessed != NO)
                {
                    _runningResponder = node;
                    break;
                }
            }
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent button:(CCMouseButton)button
{
    [self buildResponderList];
    
    if (_runningResponder != nil)
    {
        CCNode* node = (CCNode*)_runningResponder;
        
        // end the mouse
        if ([node respondsToSelector:@selector(mouseUp:)] != NO)
            [node mouseUp:theEvent];
        // remove 
        _runningResponder = nil;
    }
}

// -----------------------------------------------------------------

- (void)mouseDown:(NSEvent *)theEvent
{
    [self mouseDown:theEvent button:CCMouseButtonLeft];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self mouseDragged:theEvent button:CCMouseButtonLeft];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self mouseUp:theEvent button:CCMouseButtonLeft];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    [self mouseDown:theEvent button:CCMouseButtonRight];
}

- (void)rightMouseDragged:(NSEvent *)theEvent
{
    [self mouseDragged:theEvent button:CCMouseButtonRight];
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    [self mouseUp:theEvent button:CCMouseButtonRight];
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
    [self mouseDown:theEvent button:CCMouseButtonOther];
}

- (void)otherMouseDragged:(NSEvent *)theEvent
{
    [self mouseDragged:theEvent button:CCMouseButtonOther];
}

- (void)otherMouseUp:(NSEvent *)theEvent
{
    [self mouseUp:theEvent button:CCMouseButtonOther];
}

/** Moved, Entered and Exited is not supported
 @since v2.5
 */

- (void)mouseMoved:(NSEvent *)theEvent
{
    
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    
}

- (void)mouseExited:(NSEvent *)theEvent
{
    
}

// -----------------------------------------------------------------

#endif

@end






































