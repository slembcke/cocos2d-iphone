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

#import "CCResponder.h"

// -----------------------------------------------------------------

@implementation CCResponder
{
    
}

// -----------------------------------------------------------------

+ (id)responder
{
    return([[self alloc] init]);
}

// -----------------------------------------------------------------

- (id)init
{
    self = [super init];
    NSAssert(self != nil, @"Unable to create class");

    // initialize
    
    // done
    return(self);
}

// -----------------------------------------------------------------

#if ( TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR )

/** touchesBegan will be called if touch handler passed touch on to super ( next in chain )
 @since v2.5
 */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    _responderManager.eventProcessed = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _responderManager.eventProcessed = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _responderManager.eventProcessed = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _responderManager.eventProcessed = NO;
}

// -----------------------------------------------------------------

#else

- (void)mouseDown:(NSEvent *)theEvent
{
    _responderManager.eventProcessed = NO;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    _responderManager.eventProcessed = NO;
}

- (void)mouseUp:(NSEvent *)theEvent
{
    _responderManager.eventProcessed = NO;
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    _responderManager.eventProcessed = NO;
}

- (void)rightMouseDragged:(NSEvent *)theEvent
{
    _responderManager.eventProcessed = NO;
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    _responderManager.eventProcessed = NO;
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
    _responderManager.eventProcessed = NO;
}

- (void)otherMouseDragged:(NSEvent *)theEvent
{
    _responderManager.eventProcessed = NO;
}

- (void)otherMouseUp:(NSEvent *)theEvent
{
    _responderManager.eventProcessed = NO;
}
 
#endif

// -----------------------------------------------------------------

@end










































