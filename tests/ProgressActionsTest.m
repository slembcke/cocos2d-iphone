//
// Ease Demo
// a cocos2d example
//

// local import
#import "cocos2d.h"
#import "ProgressActionsTest.h"

#import "RootViewController.h"

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"SpriteProgressToRadial",
	@"SpriteProgressToHorizontal",
	@"SpriteProgressToVertical",
	@"SpriteProgressBarVarious",
	@"SpriteProgressBarTintAndFade",
	
};

enum {
	kTagAction1 = 1,
	kTagAction2 = 2,
	kTagSlider = 1,
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

Class nextAction()
{
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	if( sceneIdx < 0 )
		sceneIdx = sizeof(transitions) / sizeof(transitions[0]) -1;	
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}



@implementation SpriteDemo
-(id) init
{
	if( (self=[super init])) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:1];
		
		
		CCLayerColor *background = [CCLayerColor layerWithColor:(ccColor4B){255,0,0,255}];
		[self addChild:background z:-10];
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}


-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [restartAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}


-(NSString*) title
{
	return @"No title";
}
@end

#pragma mark -
#pragma mark SpriteProgressToRadial

@implementation SpriteProgressToRadial
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCProgressTo *to1 = [CCProgressTo actionWithDuration:2 percent:100];
	CCProgressTo *to2 = [CCProgressTo actionWithDuration:2 percent:100];
	
	CCProgressTimer *left = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister1.png"]];
	left.type = kCCProgressTimerTypeRadial;
	[self addChild:left];
	[left setPosition:ccp(100, s.height/2)];
	[left runAction: [CCRepeatForever actionWithAction:to1]];
	
	CCProgressTimer *right = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"blocks.png"]];
	right.type = kCCProgressTimerTypeRadial;
	//	Makes the radial CCW
	right.reverseDirection = YES;
	[self addChild:right];
	[right setPosition:ccp(s.width-100, s.height/2)];
	[right runAction: [CCRepeatForever actionWithAction:to2]];
}

-(NSString *) title
{
	return @"ProgressTo Radial";
}
@end

#pragma mark -
#pragma mark SpriteProgressToHorizontal

@implementation SpriteProgressToHorizontal
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCProgressTo *to1 = [CCProgressTo actionWithDuration:2 percent:100];
	CCProgressTo *to2 = [CCProgressTo actionWithDuration:2 percent:100];
	
	CCProgressTimer *left = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister1.png"]];
	left.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the left since the midpoint is 0 for the x
	left.midpoint = ccp(0, 0);
	//	Setup for a horizontal bar since the bar change rate is 0 for y meaning no vertical change
	left.barChangeRate = ccp(1,0);
	[self addChild:left];
	[left setPosition:ccp(100, s.height/2)];
	[left runAction: [CCRepeatForever actionWithAction:to1]];
	
	CCProgressTimer *right = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister2.png"]];
	right.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the left since the midpoint is 1 for the x
	right.midpoint = ccp(1,0);
	//	Setup for a horizontal bar since the bar change rate is 0 for y meaning no vertical change
	right.barChangeRate = ccp(1,0);
	[self addChild:right];
	[right setPosition:ccp(s.width-100, s.height/2)];
	[right runAction: [CCRepeatForever actionWithAction:to2]];
}

-(NSString *) title
{
	return @"ProgressTo Horizontal";
}
@end

#pragma mark -
#pragma mark SpriteProgressToVertical

@implementation SpriteProgressToVertical
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCProgressTo *to1 = [CCProgressTo actionWithDuration:2 percent:100];
	CCProgressTo *to2 = [CCProgressTo actionWithDuration:2 percent:100];
	
	CCProgressTimer *left = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister1.png"]];
	left.type = kCCProgressTimerTypeBar;
	
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	left.midpoint = ccp(0,0);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	left.barChangeRate = ccp(0,1);
	[self addChild:left];
	[left setPosition:ccp(100, s.height/2)];
	[left runAction: [CCRepeatForever actionWithAction:to1]];
	
	CCProgressTimer *right = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister2.png"]];
	right.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	right.midpoint = ccp(0,1);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	right.barChangeRate = ccp(0,1);
	[self addChild:right];
	[right setPosition:ccp(s.width-100, s.height/2)];
	[right runAction: [CCRepeatForever actionWithAction:to2]];
}

-(NSString *) title
{
	return @"ProgressTo Vertical";
}
@end


@implementation SpriteProgressBarVarious
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCProgressTo *to = [CCProgressTo actionWithDuration:2 percent:100];
	
	CCProgressTimer *left = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister1.png"]];
	left.type = kCCProgressTimerTypeBar;
	
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	left.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	left.barChangeRate = ccp(1,0);
	[self addChild:left];
	[left setPosition:ccp(100, s.height/2)];
	[left runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];
	
	CCProgressTimer *middle = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister2.png"]];
	middle.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	middle.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	middle.barChangeRate = ccp(1, 1);
	[self addChild:middle];
	[middle setPosition:ccp(s.width/2, s.height/2)];
	[middle runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];
	
	CCProgressTimer *right = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister2.png"]];
	right.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	right.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	right.barChangeRate = ccp(0, 1);
	[self addChild:right];
	[right setPosition:ccp(s.width-100, s.height/2)];
	[right runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];
}

-(NSString *) title
{
	return @"ProgressTo Bar Mid";
}
@end

@implementation SpriteProgressBarTintAndFade
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCProgressTo *to = [CCProgressTo actionWithDuration:6 percent:100];
    CCAction *tint = [CCSequence actions:[CCTintTo actionWithDuration:1 red:255 green:0 blue:0], 
                      [CCTintTo actionWithDuration:1 red:0 green:255 blue:0],
                      [CCTintTo actionWithDuration:1 red:0 green:0 blue:255], nil];
    CCAction *fade = [CCSequence actions:[CCFadeTo actionWithDuration:1.f opacity:0],
                      [CCFadeTo actionWithDuration:1.f opacity:255], nil];
	
	CCProgressTimer *left = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister1.png"]];
	left.type = kCCProgressTimerTypeBar;
	
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	left.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	left.barChangeRate = ccp(1,0);
	[self addChild:left];
	[left setPosition:ccp(100, s.height/2)];
	[left runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];
	[left runAction:[CCRepeatForever actionWithAction:[[tint copy]autorelease]]];
    
    [left addChild:[CCLabelTTF labelWithString:@"Tint" fontName:@"Marker Felt" fontSize:20.f]];
	
	CCProgressTimer *middle = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister2.png"]];
	middle.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	middle.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	middle.barChangeRate = ccp(1, 1);
	[self addChild:middle];
	[middle setPosition:ccp(s.width/2, s.height/2)];
	[middle runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];
	[middle runAction:[CCRepeatForever actionWithAction:[[fade copy]autorelease]]];
    
    [middle addChild:[CCLabelTTF labelWithString:@"Fade" fontName:@"Marker Felt" fontSize:20.f]];
	CCProgressTimer *right = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister2.png"]];
	right.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	right.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	right.barChangeRate = ccp(0, 1);
	[self addChild:right];
	[right setPosition:ccp(s.width-100, s.height/2)];
	[right runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];
	[right runAction:[CCRepeatForever actionWithAction:[[tint copy]autorelease]]];
	[right runAction:[CCRepeatForever actionWithAction:[[fade copy]autorelease]]];
    
    [right addChild:[CCLabelTTF labelWithString:@"Tint and Fade" fontName:@"Marker Felt" fontSize:20.f]];
}

-(NSString *) title
{
	return @"ProgressTo Bar Mid";
}
@end

#pragma mark -
#pragma mark AppController

// CLASS IMPLEMENTATIONS
@implementation AppController

@synthesize window=window_, viewController=viewController_, navigationController=navigationController_;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Turn on display FPS
	[director setDisplayStats:kCCDirectorStatsFPS];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];	
	
	[director pushScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[viewController_ release];
	[window_ release];
	[super dealloc];
}

@end
