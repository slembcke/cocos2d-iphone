//
// Scene demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

#import "SceneTest.h"

#pragma mark -
#pragma mark Layer1

@implementation Layer1
-(id) init
{
	if( (self=[super initWithColor: ccc4(0,255,0,255)]) ) {


		CCMenuItemFont *item1 = [CCMenuItemFont itemWithString: @"Test pushScene" target:self selector:@selector(onPushScene:)];
		CCMenuItemFont *item2 = [CCMenuItemFont itemWithString: @"Test pushScene w/transition" target:self selector:@selector(onPushSceneTran:)];
		CCMenuItemFont *item3 = [CCMenuItemFont itemWithString: @"Quit" target:self selector:@selector(onQuit:)];

		CCMenu *menu = [CCMenu menuWithItems: item1, item2, item3, nil];
		[menu alignItemsVertically];

		[self addChild: menu];

		CGSize s = [CCDirector sharedDirector].winSize;
		CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
		[self addChild:sprite];
		sprite.position = ccp(s.width-40, s.height/2);
		id rotate = [CCRotateBy actionWithDuration:2 angle:360];
		id repeat = [CCRepeatForever actionWithAction:rotate];
		[sprite runAction:repeat];


		[self schedule:@selector(testDealloc:)];
	}

	return self;
}

-(void) onEnter
{
	NSLog(@"Layer1#onEnter");
	[super onEnter];
}

-(void) onEnterTransitionDidFinish
{
	NSLog(@"Layer1#onEnterTransitionDidFinish");
	[super onEnterTransitionDidFinish];
}

-(void) cleanup
{
	NSLog(@"Layer1#cleanup");
	[super cleanup];
}

-(void) testDealloc:(ccTime) dt
{
	NSLog(@"Layer1:testDealloc");
}

-(void) dealloc
{
	NSLog(@"Layer1 - dealloc");
	[super dealloc];
}

-(void) onPushScene: (id) sender
{
	CCScene * scene = [CCScene node];
	[scene addChild: [Layer2 node] z:0];
	[[CCDirector sharedDirector] pushScene: scene];
//	[[Director sharedDirector] replaceScene:scene];
}

-(void) onPushSceneTran: (id) sender
{
	CCScene * scene = [CCScene node];
	[scene addChild: [Layer2 node] z:0];
	[[CCDirector sharedDirector] pushScene: [CCTransitionSlideInT transitionWithDuration:1 scene:scene]];
}


-(void) onQuit: (id) sender
{
	[[CCDirector sharedDirector] popScene];
	[[CCDirector sharedDirector] end];
}

-(void) onVoid: (id) sender
{
}
@end

#pragma mark -
#pragma mark Layer2

@implementation Layer2
-(id) init
{
	if( (self=[super initWithColor: ccc4(255,0,0,255)]) ) {

		timeCounter = 0;

		CCMenuItemFont *item1 = [CCMenuItemFont itemWithString: @"replaceScene" target:self selector:@selector(onReplaceScene:)];
		CCMenuItemFont *item2 = [CCMenuItemFont itemWithString: @"replaceScene w/transition" target:self selector:@selector(onReplaceSceneTran:)];
		CCMenuItemFont *item3 = [CCMenuItemFont itemWithString: @"Go Back" target:self selector:@selector(onGoBack:)];

		CCMenu *menu = [CCMenu menuWithItems: item1, item2, item3, nil];
		[menu alignItemsVertically];

		[self addChild: menu];

		[self schedule:@selector(testDealloc:)];

		CGSize s = [CCDirector sharedDirector].winSize;
		CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
		[self addChild:sprite];
		sprite.position = ccp(40, s.height/2);
		id rotate = [CCRotateBy actionWithDuration:2 angle:360];
		id repeat = [CCRepeatForever actionWithAction:rotate];
		[sprite runAction:repeat];
	}

	return self;
}

-(void) dealloc
{
	NSLog(@"Layer2 - dealloc");
	[super dealloc];
}

-(void) testDealloc:(ccTime) dt
{
	NSLog(@"Layer2:testDealloc");

	timeCounter += dt;
	if( timeCounter > 10 )
		[self onReplaceScene:self];
}

-(void) onGoBack:(id) sender
{
	[[CCDirector sharedDirector] popScene];
}

-(void) onReplaceScene:(id) sender
{
	CCScene *scene = [CCScene node];
	[scene addChild: [Layer3 node] z:0];
	[[CCDirector sharedDirector] replaceScene: scene];
}
-(void) onReplaceSceneTran:(id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [Layer3 node] z:0];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFlipX transitionWithDuration:2 scene:s]];
}
@end

#pragma mark -
#pragma mark Layer3

@implementation Layer3
-(id) init
{
	if( (self=[super initWithColor: ccc4(0,0,255,255)]) ) {
		
#if defined(__CC_PLATFORM_IOS)
		self.isTouchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.isMouseEnabled = YES;
#endif

		id label = [CCLabelTTF labelWithString:@"Touch to popScene" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label];
		CGSize s = [[CCDirector sharedDirector] winSize];
		[label setPosition:ccp(s.width/2, s.height/2)];

		[self schedule:@selector(testDealloc:)];

		CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
		[self addChild:sprite];
		sprite.position = ccp(s.width/2, 40);
		id rotate = [CCRotateBy actionWithDuration:2 angle:360];
		id repeat = [CCRepeatForever actionWithAction:rotate];
		[sprite runAction:repeat];

	}
	return self;
}

- (void) dealloc
{
	NSLog(@"Layer3 - dealloc");
	[super dealloc];
}

-(void) testDealloc:(ccTime)dt
{
	NSLog(@"Layer3:testDealloc");
}

#if defined(__CC_PLATFORM_IOS)
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[CCDirector sharedDirector] popScene];
}
#elif defined(__CC_PLATFORM_MAC)
- (BOOL) ccMouseUp:(NSEvent *)event
{
	[[CCDirector sharedDirector] popScene];
	return YES;
}
#endif
@end


#pragma mark - AppController - iOS

#if defined(__CC_PLATFORM_IOS)

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Turn on display FPS
	[director_ setDisplayStats:YES];


	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// When in iPhone RetinaDisplay, iPad, iPad RetinaDisplay mode, CCFileUtils will append the "-hd", "-ipad", "-ipadhd" to all loaded files
	// If the -hd, -ipad, -ipadhd files are not found, it will load the non-suffixed version
	[CCFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[CCFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "" (empty string)
	[CCFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	CCScene *scene = [CCScene node];

	[scene addChild: [Layer1 node] z:0];

	[director_ pushScene: scene];

	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end

#pragma mark - AppController - Mac

#elif defined(__CC_PLATFORM_MAC)

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];
	
	CCScene *scene = [CCScene node];
	
	[scene addChild: [Layer1 node] z:0];
	
	[director_ runWithScene:scene];
}
@end
#endif

