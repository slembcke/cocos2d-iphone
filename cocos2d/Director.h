/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


// cocoa related
#import <UIKit/UIKit.h>

// OpenGL related
#import "Support/EAGLView.h"

// cocos2d related
#import "Scene.h"

enum {
	kEventHandled = YES,
	kEventIgnored = NO,
};

// Landscape is right or left ?
#define LANDSCAPE_LEFT 1

// Intervaled Director ?
// Consumes less battery but it is slower
// #define FPS_DIRECTOR 1

// Fast FPS display. FPS are updated 10 times per second without consuming resources
// uncomment this line to use the old method that updated
#define FAST_FPS_DISPLAY 1

/** Possible Pixel Formats for the EAGLView */
typedef enum {
	kRGB565,
	kRGBA8
} tPixelFormat;

/** Possible DepthBuffer Formats for the EAGLView */
typedef enum {
   kDepthBufferNone,
   kDepthBuffer16,
   kDepthBuffer24,
} tDepthBufferFormat;

@class LabelAtlas;

/**Class that creates and handle the main Window and manages how
and when to execute the Scenes
*/
@interface Director : NSObject <EAGLTouchDelegate>
{
	EAGLView	*_openGLView;

	// internal timer
	NSTimer *animationTimer;
	NSTimeInterval animationInterval;
	NSTimeInterval oldAnimationInterval;

	tPixelFormat _pixelFormat;
	tDepthBufferFormat _depthBufferFormat;

	/* landscape mode ? */
	BOOL landscape;
	
	/* display FPS ? */
	BOOL displayFPS;
	int frames;
	ccTime accumDt;
	ccTime frameRate;
#ifdef FAST_FPS_DISPLAY
	LabelAtlas *FPSLabel;
#endif
	
	/* is the running scene paused */
	BOOL paused;
	
	/* running scene */
	Scene *runningScene;
	
	/* will be the next 'runningScene' in the next frame */
	Scene *nextScene;
	
	/* event handler */
	NSMutableArray	*eventHandlers;

	/* scheduled scenes */
	NSMutableArray *scenes;
	
	/* last time the main loop was updated */
	struct timeval lastUpdate;
	/* delta time since last tick to main loop */
	ccTime dt;
	/* whether or not the next delta time will be zero */
	BOOL _nextDeltaTimeZero;
	
	/* are touch events enabled. Default is YES */
	BOOL eventsEnabled;
}

/** The current running Scene. Director can only run one Scene at the time */
@property (readonly, assign) Scene* runningScene;
/** The FPS value */
@property (readwrite, assign) NSTimeInterval animationInterval;
/** Whether or not to display the FPS on the bottom-left corner */
@property (readwrite, assign) BOOL displayFPS;
/** Whether or not to propagate the touch events to the running Scene. Default YES */
@property (readwrite, assign) BOOL eventsEnabled;
/** The OpenGL view */
@property (readonly) EAGLView *openGLView;
/** Pixel format used to create the context */
@property (readonly) tPixelFormat pixelFormat;
/** whether or not the next delta time will be zero */
@property (readwrite,assign) BOOL nextDeltaTimeZero;

/** returns a shared instance of the director */
+(Director *)sharedDirector;
/** Uses a Director that triggers the main loop as fast as it can.
 * Although it is faster, it will consume more battery
 * To use it, it must be called before calling any director function
 */
+(void) useFastDirector;
 

// iPhone Specific

/** change default pixel format.
 Call this class method before attaching it to a UIWindow/UIView
 Default pixel format: RGB565. Supported pixel formats: RGBA8 and RGB565
 */
-(void) setPixelFormat: (tPixelFormat) p;

/** change depth buffer format.
 Call this class method before attaching it to a UIWindow/UIView
 Default depth buffer: 0 (none).  Supported: DepthBufferNone, DepthBuffer16, and DepthBuffer24
 */
-(void) setDepthBufferFormat: (tDepthBufferFormat) db;

// Integration with UIKit
/** detach or attach to a view or a window */
-(BOOL)detach;

/** attach in UIWindow using the full frame */
-(BOOL)attachInWindow:(UIWindow *)window;

/** attach in UIView using the full frame */
-(BOOL)attachInView:(UIView *)view;

/** attach in UIView using the given frame */
-(BOOL)attachInView:(UIView *)view with:(CGRect)frame;

// Landscape

/** returns the size of the OpenGL view according to the landspace */
- (CGSize) winSize;
/** returns the display size of the OpenGL view */
-(CGSize) displaySize;

/** returns whether or not the screen is in landscape mode */
- (BOOL) landscape;
/** sets lanscape mode */
- (void) setLandscape: (BOOL) on;
/** converts a UIKit coordinate to an OpenGL coordinate
 Useful to convert (multi) touchs coordinates to the current layout (portrait or landscape)
 */
-(CGPoint) convertCoordinate: (CGPoint) p;

// Scene Management

/**Enters the Director's main loop with the given Scene. 
 * Call it to run only your FIRST scene.
 * Don't call it if there is already a running scene.
 */
- (void) runWithScene:(Scene*) scene;

/**Suspends the execution of the running scene, pushing it on the stack of suspended scenes.
 * The new scene will be executed.
 * Try to avoid big stacks of pushed scenes to reduce memory allocation. 
 * ONLY call it if there is a running scene.
 */
- (void) pushScene:(Scene*) scene;

/**Pops out a scene from the queue.
 * This scene will replace the running one.
 * The running scene will be deleted. If there are no more scenes in the stack the execution is terminated.
 * ONLY call it if there is a running scene.
 */
- (void) popScene;

/** Replaces the running scene with a new one. The running scene is terminated.
 * ONLY call it if there is a running scene.
 */
-(void) replaceScene: (Scene*) scene;

/** Ends the execution */
-(void) end;

/** Pauses the running scene.
 The running scene will be _drawed_ but all scheduled timers will be paused
 While paused, the draw rate will be 4 FPS to reduce CPU consuption
 */
-(void) pause;

/** Resumes the paused scene
 The scheduled timers will be activated again.
 The "delta time" will be 0 (as if the game wasn't paused)
 */
-(void) resume;

/** Hides the Director Window & stops animation */
-(void) hide;

/** UnHides the Director Window & starts animation*/
-(void) unhide;

// Events

/** adds a cocosnode object to the list of multi-touch event queue */
-(void) addEventHandler: (CocosNode*) node;
/** removes a cocosnode object from the list of multi-touch event queue */
-(void) removeEventHandler: (CocosNode*) node;

// OpenGL Helper

/** enables/disables OpenGL alpha blending */
- (void) setAlphaBlending: (BOOL) on;
/** enables/disables OpenGL depth test */
- (void) setDepthTest: (BOOL) on;
/** enables/disables OpenGL texture 2D */
- (void) setTexture2D: (BOOL) on;
/** sets Cocos OpenGL default projection */
- (void) setDefaultProjection;
/** sets a 2D projection */
-(void) set2Dprojection;
/** sets a 3D projection */
-(void) set3Dprojection;
@end

/** FastDirector is a Director that triggers the main loop
 * as fast as possible.
 * It is faster than Director but it also consumes more battery
 */
@interface FastDirector : Director
{
	BOOL isRunning;
}
@end



