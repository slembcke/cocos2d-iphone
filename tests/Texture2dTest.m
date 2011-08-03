//
// Texture2D Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// local import
#import "cocos2d.h"
#import "Texture2dTest.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import "RootViewController.h"
#endif

#import "png.h"

enum {
	kTagLabel = 1,
	kTagSprite1 = 2,
	kTagSprite2 = 3,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
	
	@"FileUtilsTest",

	@"TextureAlias",
	@"TextureMipMap",
	@"TexturePVRMipMap",
	@"TexturePVRMipMap2",
	@"TexturePVRNonSquare",
	@"TexturePVRNPOT4444",
	@"TexturePVRNPOT8888",
	@"TexturePVR2BPP",
	@"TexturePVRRaw",
	@"TexturePVR",
	@"TexturePVR4BPP",
	@"TexturePVRRGBA8888",
	@"TexturePVRBGRA8888",
	@"TexturePVRRGBA4444",
	@"TexturePVRRGBA4444GZ",
	@"TexturePVRRGBA4444CCZ",
	@"TexturePVRRGBA5551",
	@"TexturePVRRGB565",
	@"TexturePVRA8",
	@"TexturePVRI8",
	@"TexturePVRAI88",
	@"TexturePVRBadEncoding",
	@"TexturePNG",
	@"TextureBMP",
	@"TextureJPEG",
	@"TextureTIFF",
	@"TextureGIF",
	@"TextureCGImage",
	@"TexturePixelFormat",
	@"TextureBlend",
	@"TextureAsync",
	@"TextureAsyncBlock",
	@"TextureLibPNGTest1",
	@"TextureLibPNGTest2",
	@"TextureLibPNGTest3",
	@"TextureGlClamp",
	@"TextureGlRepeat",
	@"TextureSizeTest",
	@"TextureCache1",
	@"FileUtilsTest",
};

#pragma mark Callbacks

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

#pragma mark -
#pragma mark TextureDemo

@implementation TextureDemo
-(id) init
{
	if( (self = [super init]) ) {

		[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
		CGSize s = [[CCDirector sharedDirector] winSize];	
		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:26];
		[self addChild:label z:1 tag:kTagLabel];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF *l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:1];
			[l setPosition:ccp(s.width/2, s.height-80)];
		}		

		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:1];	
		
		CCLayerColor *col = [CCLayerColor layerWithColor:ccc4(128,128,128,255)];
		[self addChild:col z:-10];
		
		[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
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

-(NSString*) subtitle
{
	return nil;
}
@end

#pragma mark -
#pragma mark TexturePNG

@implementation TexturePNG
-(void) onEnter
{
	[super onEnter];	

	CGSize s = [[CCDirector sharedDirector] winSize];

	CCSprite *img = [CCSprite spriteWithFile:@"test_image.png"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	
}

-(NSString *) title
{
	return @"PNG Test";
}
@end

#pragma mark -
#pragma mark TextureJPEG

@implementation TextureJPEG
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image.jpeg"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	
}

-(NSString *) title
{
	return @"JPEG Test";
}
@end

#pragma mark -
#pragma mark TextureBMP

@implementation TextureBMP
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image.bmp"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	
}

-(NSString *) title
{
	return @"BMP Test";
}
@end

#pragma mark -
#pragma mark TextureTIFF

@implementation TextureTIFF
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image.tiff"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	
}

-(NSString *) title
{
	return @"TIFF Test";
}
@end

#pragma mark -
#pragma mark TextureGIF

@implementation TextureGIF
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image.gif"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	
}

-(NSString *) title
{
	return @"GIF Test";
}
@end

#pragma mark -
#pragma mark TextureCGImage

@implementation TextureCGImage
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:[CCFileUtils fullPathFromRelativePath: @"test_image.png" ]];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	
	NSString *fullpath = [CCFileUtils fullPathFromRelativePath:@"test_image.png"];
	NSData *data = [NSData dataWithContentsOfFile:fullpath];
	NSBitmapImageRep *image = [[NSBitmapImageRep alloc] initWithData:data];
#endif
	
	CGImageRef imageref = [image CGImage];
	
	CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addCGImage:imageref forKey:@"test_image.png"];
	CCSprite *img = [CCSprite spriteWithTexture:tex];
	img.position = ccp( 3*s.width/4.0f, s.height/2.0f);
	[self addChild:img];
	
	// It shall reuse the texture
	CCSprite *sprite = [CCSprite spriteWithCGImage:imageref key:@"test_image.png"];
	sprite.position = ccp(s.width/4, s.height/2);
	[self addChild:sprite];
	
	NSAssert( img.texture.name == sprite.texture.name, @"Error: CCTextureCache is not reusing the texture");

	[image release];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}

-(NSString *) title
{
	return @"CGImage Test";
}
@end

#pragma mark -
#pragma mark TextureMipMap

@implementation TextureMipMap
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCTexture2D *texture0 = [[CCTextureCache sharedTextureCache] addImage:@"grossini_dance_atlas.png"];
	[texture0 generateMipmap];
	ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };	
	[texture0 setTexParameters:&texParams];

	CCTexture2D *texture1 = [[CCTextureCache sharedTextureCache] addImage:@"grossini_dance_atlas_nomipmap.png"];

	CCSprite *img0 = [CCSprite spriteWithTexture:texture0];
	[img0 setTextureRect:CGRectMake(85, 121, 85, 121)];
	img0.position = ccp( s.width/3.0f, s.height/2.0f);
	[self addChild:img0];
	
	CCSprite *img1 = [CCSprite spriteWithTexture:texture1];
	[img1 setTextureRect:CGRectMake(85, 121, 85, 121)];
	img1.position = ccp( 2*s.width/3.0f, s.height/2.0f);
	[self addChild:img1];
	
	
	id scale1 = [CCEaseOut actionWithAction: [CCScaleBy actionWithDuration:4 scale:0.01f] rate:3];
	id sc_back = [scale1 reverse];
	
	id scale2 = [[scale1 copy] autorelease];
	id sc_back2 = [scale2 reverse];
	
	[img0 runAction: [CCRepeatForever actionWithAction: [CCSequence actions: scale1, sc_back, nil]]];
	[img1 runAction: [CCRepeatForever actionWithAction: [CCSequence actions: scale2, sc_back2, nil]]];	
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}

-(NSString *) title
{
	return @"Texture Mipmap";
}

-(NSString *) subtitle
{
	return @"Left image uses mipmap. Right image doesn't";
}
@end

#pragma mark -
#pragma mark TexturePVRMipMap

// To generate PVR images read this article:
// http://developer.apple.com/iphone/library/qa/qa2008/qa1611.html
@implementation TexturePVRMipMap
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];

	CCSprite *imgMipMap = [CCSprite spriteWithFile:@"logo-mipmap.pvr"];
	if( imgMipMap ) {
	imgMipMap.position = ccp( s.width/2.0f-100, s.height/2.0f);
		[self addChild:imgMipMap];

		// support mipmap filtering
		ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };	
		[imgMipMap.texture setTexParameters:&texParams];
	}
	
	CCSprite *img = [CCSprite spriteWithFile:@"logo-nomipmap.pvr"];
	if( img ) {
		img.position = ccp( s.width/2.0f+100, s.height/2.0f);
		[self addChild:img];
		
		id scale1 = [CCEaseOut actionWithAction: [CCScaleBy actionWithDuration:4 scale:0.01f] rate:3];
		id sc_back = [scale1 reverse];
		
		id scale2 = [[scale1 copy] autorelease];
		id sc_back2 = [scale2 reverse];
		
		[imgMipMap runAction: [CCRepeatForever actionWithAction: [CCSequence actions: scale1, sc_back, nil]]];
		[img runAction: [CCRepeatForever actionWithAction: [CCSequence actions: scale2, sc_back2, nil]]];
	}
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}

-(NSString *) title
{
	return @"PVRTC MipMap Test";
}
-(NSString *) subtitle
{
	return @"Left image uses mipmap. Right image doesn't";
}
@end

#pragma mark -
#pragma mark TexturePVRMipMap

@implementation TexturePVRMipMap2
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *imgMipMap = [CCSprite spriteWithFile:@"test_image_rgba4444_mipmap.pvr"];
	imgMipMap.position = ccp( s.width/2.0f-100, s.height/2.0f);
	[self addChild:imgMipMap];
	
	// support mipmap filtering
	ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };	
	[imgMipMap.texture setTexParameters:&texParams];

	CCSprite *img = [CCSprite spriteWithFile:@"test_image.png"];
	img.position = ccp( s.width/2.0f+100, s.height/2.0f);
	[self addChild:img];
	
	id scale1 = [CCEaseOut actionWithAction: [CCScaleBy actionWithDuration:4 scale:0.01f] rate:3];
	id sc_back = [scale1 reverse];
	
	id scale2 = [[scale1 copy] autorelease];
	id sc_back2 = [scale2 reverse];
	
	[imgMipMap runAction: [CCRepeatForever actionWithAction: [CCSequence actions: scale1, sc_back, nil]]];
	[img runAction: [CCRepeatForever actionWithAction: [CCSequence actions: scale2, sc_back2, nil]]];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}

-(NSString *) title
{
	return @"PVR MipMap Test #2";
}
-(NSString *) subtitle
{
	return @"Left image uses mipmap. Right image doesn't";
}
@end

#pragma mark -
#pragma mark TexturePVR2BPP

// Image generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TexturePVR2BPP
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image_pvrtc2bpp.pvr"];
	
	if( img ) {
		img.position = ccp( s.width/2.0f, s.height/2.0f);
		[self addChild:img];
	}
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}

-(NSString *) title
{
	return @"PVR TC 2bpp Test";
}
@end


#pragma mark -
#pragma mark TexturePVRRaw

// To generate PVR images read this article:
// http://developer.apple.com/iphone/library/qa/qa2008/qa1611.html
@implementation TexturePVRRaw
-(void) onEnter
{
	[super onEnter];

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addPVRTCImage:@"test_image.pvrraw" bpp:4 hasAlpha:YES width:128];
	CCSprite *img = [CCSprite spriteWithTexture:tex];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	
	NSLog(@"This test is not supported by Mac");
#endif
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	
}

-(NSString *) title
{
	return @"PVR TC 4bpp Test #1 (Raw)";
}
@end

#pragma mark -
#pragma mark TexturePVR

// To generate PVR images read this article:
// http://developer.apple.com/iphone/library/qa/qa2008/qa1611.html
@implementation TexturePVR
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image.pvr"];
	
	if( img ) {
		img.position = ccp( s.width/2.0f, s.height/2.0f);
		[self addChild:img];
	} else {
		NSLog(@"This test is not supported in cocos2d-mac");
	}
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	
}

-(NSString *) title
{
	return @"PVR TC 4bpp Test #2";
}
@end

#pragma mark -
#pragma mark TexturePVR4BPP

// Image generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TexturePVR4BPP
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image_pvrtc4bpp.pvr"];
	
	if( img ) {
		img.position = ccp( s.width/2.0f, s.height/2.0f);
		[self addChild:img];
	} else {
		NSLog(@"This test is not supported in cocos2d-mac");
	}
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];

}

-(NSString *) title
{
	return @"PVR TC 4bpp Test #3";
}
@end


#pragma mark -
#pragma mark TexturePVR RGBA8888

// Image generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TexturePVRRGBA8888
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image_rgba8888.pvr"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];

}

-(NSString *) title
{
	return @"PVR + RGBA  8888 Test";
}
@end

#pragma mark -
#pragma mark TexturePVR BGRA8888

// Image generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TexturePVRBGRA8888
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image_bgra8888.pvr"];
	if( img ) {
		img.position = ccp( s.width/2.0f, s.height/2.0f);
		[self addChild:img];
	} else {
		NSLog(@"BGRA8888 images are not supported");
	}
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}

-(NSString *) title
{
	return @"PVR + BGRA 8888 Test";
}
@end


#pragma mark -
#pragma mark TexturePVR RGBA5551

// Image generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TexturePVRRGBA5551
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image_rgba5551.pvr"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	
}

-(NSString *) title
{
	return @"PVR + RGBA 5551 Test";
}
@end

#pragma mark -
#pragma mark TexturePVR RGBA4444

// Image generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TexturePVRRGBA4444
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image_rgba4444.pvr"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];

}

-(NSString *) title
{
	return @"PVR + RGBA 4444 Test";
}
@end

#pragma mark -
#pragma mark TexturePVR RGBA4444GZ

// Image generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TexturePVRRGBA4444GZ
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image_rgba4444.pvr.gz"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];

}

-(NSString *) title
{
	return @"PVR + RGBA 4444 + GZ Test";
}

-(NSString *) subtitle
{
	return @"This is a gzip PVR image";
}

@end

#pragma mark -
#pragma mark TexturePVR RGBA4444CCZ

// Image generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TexturePVRRGBA4444CCZ
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image_rgba4444.pvr.ccz"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];	
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}

-(NSString *) title
{
	return @"PVR + RGBA 4444 + CCZ Test";
}

-(NSString *) subtitle
{
	return @"This is a ccz PVR image";
}

@end


#pragma mark -
#pragma mark TexturePVR RGB565

// Image generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TexturePVRRGB565
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image_rgb565.pvr"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
	
}

-(NSString *) title
{
	return @"PVR + RGB 565 Test";
}
@end

#pragma mark -
#pragma mark TexturePVR A8

// Image generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TexturePVRA8
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image_a8.pvr"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];

}

-(NSString *) title
{
	return @"PVR + A8 Test";
}
@end

#pragma mark -
#pragma mark TexturePVR I8

// Image generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TexturePVRI8
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image_i8.pvr"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];

}

-(NSString *) title
{
	return @"PVR + I8 Test";
}
@end

#pragma mark -
#pragma mark TexturePVR AI88

// Image generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TexturePVRAI88
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image_ai88.pvr"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];

}

-(NSString *) title
{
	return @"PVR + AI88 Test";
}
@end

#pragma mark -
#pragma mark TexturePVR Bad Encoding

// Image generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TexturePVRBadEncoding
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"test_image-bad_encoding.pvr"];
	if( img ) {
		img.position = ccp( s.width/2.0f, s.height/2.0f);
		[self addChild:img];
	}
}

-(NSString *) title
{
	return @"PVR Unsupported encoding";
}
-(NSString *) subtitle
{
	return @"You should not see any image";
}

@end


#pragma mark -
#pragma mark TexturePVR Non Square

@implementation TexturePVRNonSquare
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"grossini_128x256_mipmap.pvr"];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self addChild:img];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];

}

-(NSString *) title
{
	return @"PVR + Non square texture";
}

-(NSString*) subtitle
{
	return @"Loading a 128x256 texture";
}

@end

#pragma mark -
#pragma mark TexturePVR NPOT4444

@implementation TexturePVRNPOT4444
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"grossini_pvr_rgba4444.pvr"];
	if( img ) {
		img.position = ccp( s.width/2.0f, s.height/2.0f);
		[self addChild:img];
	}
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}

-(NSString *) title
{
	return @"PVR RGBA4 + NPOT texture";
}

-(NSString*) subtitle
{
	return @"Loading a 81x121 RGBA4444 texture.";
}
@end

#pragma mark -
#pragma mark TexturePVR NPOT8888

@implementation TexturePVRNPOT8888
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *img = [CCSprite spriteWithFile:@"grossini_pvr_rgba8888.pvr"];
	if( img ) {
		img.position = ccp( s.width/2.0f, s.height/2.0f);
		[self addChild:img];
	}
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}

-(NSString *) title
{
	return @"PVR RGBA8 + NPOT texture";
}

-(NSString*) subtitle
{
	return @"Loading a 81x121 RGBA8888 texture.";
}
@end


#pragma mark -
#pragma mark TextureAlias

@implementation TextureAlias
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	//
	// Sprite 1: GL_LINEAR
	//
	// Default filter is GL_LINEAR
	
	CCSprite *sprite = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
	sprite.position = ccp( s.width/3.0f, s.height/2.0f);
	[self addChild:sprite];
	
	// this is the default filterting
	[sprite.texture setAntiAliasTexParameters];
	
	//
	// Sprite 1: GL_NEAREST
	//	
	
	CCSprite *sprite2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
	sprite2.position = ccp( 2*s.width/3.0f, s.height/2.0f);
	[self addChild:sprite2];
	
	// Use Nearest in this one
	[sprite2.texture setAliasTexParameters];

		
	// scale them to show
	id sc = [CCScaleBy actionWithDuration:3 scale:8.0f];
	id sc_back = [sc reverse];
	id scaleforever = [CCRepeatForever actionWithAction: [CCSequence actions: sc, sc_back, nil]];
	
	[sprite2 runAction:scaleforever];
	[sprite runAction: [[scaleforever copy] autorelease]];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}

-(NSString *) title
{
	return @"AntiAlias / Alias textures";
}

-(NSString *) subtitle
{
	return @"Left image is antialiased. Right image is aliases";
}
@end

#pragma mark -
#pragma mark TexturePixelFormat

@implementation TexturePixelFormat
-(void) onEnter
{
	//
	// This example displays 1 png images 4 times.
	// Each time the image is generated using:
	// 1- 32-bit RGBA8
	// 2- 16-bit RGBA4
	// 3- 16-bit RGB5A1
	// 4- 16-bit RGB565
	[super onEnter];
	
	CCLabelTTF *label = (CCLabelTTF*) [self getChildByTag:kTagLabel];
	[label setColor:ccc3(16,16,255)];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
		
	CCLayerColor *background = [CCLayerColor layerWithColor:ccc4(128,128,128,255) width:s.width height:s.height];
	[self addChild:background z:-1];
	
	// RGBA 8888 image (32-bit)
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	CCSprite *sprite1 = [CCSprite spriteWithFile:@"test-rgba1.png"];
	sprite1.position = ccp(1*s.width/6, s.height/2+32);
	[self addChild:sprite1 z:0];
	
	// remove texture from texture manager	
	[[CCTextureCache sharedTextureCache] removeTexture:sprite1.texture];

	// RGBA 4444 image (16-bit)
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	CCSprite *sprite2 = [CCSprite spriteWithFile:@"test-rgba1.png"];
	sprite2.position = ccp(2*s.width/6, s.height/2-32);
	[self addChild:sprite2 z:0];

	// remove texture from texture manager	
	[[CCTextureCache sharedTextureCache] removeTexture:sprite2.texture];

	// RGB5A1 image (16-bit)
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];
	CCSprite *sprite3 = [CCSprite spriteWithFile:@"test-rgba1.png"];
	sprite3.position = ccp(3*s.width/6, s.height/2+32);
	[self addChild:sprite3 z:0];

	// remove texture from texture manager	
	[[CCTextureCache sharedTextureCache] removeTexture:sprite3.texture];

	// RGB565 image (16-bit)
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
	CCSprite *sprite4 = [CCSprite spriteWithFile:@"test-rgba1.png"];
	sprite4.position = ccp(4*s.width/6, s.height/2-32);
	[self addChild:sprite4 z:0];

	// remove texture from texture manager	
	[[CCTextureCache sharedTextureCache] removeTexture:sprite4.texture];

	// A8 image (8-bit)
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_A8];
	CCSprite *sprite5 = [CCSprite spriteWithFile:@"test-rgba1.png"];
	sprite5.position = ccp(5*s.width/6, s.height/2+32);
	[self addChild:sprite5 z:0];
	
	// remove texture from texture manager	
	[[CCTextureCache sharedTextureCache] removeTexture:sprite5.texture];
	
	
	id fadeout = [CCFadeOut actionWithDuration:2];
	id fadein = [CCFadeIn actionWithDuration:2];
	id seq = [CCSequence actions: [CCDelayTime actionWithDuration:2], fadeout, fadein, nil];
	id seq_4ever = [CCRepeatForever actionWithAction:seq];
	
	[sprite1 runAction:seq_4ever];
	[sprite2 runAction: [[seq_4ever copy] autorelease]];
	[sprite3 runAction: [[seq_4ever copy] autorelease]];
	[sprite4 runAction: [[seq_4ever copy] autorelease]];
	[sprite5 runAction: [[seq_4ever copy] autorelease]];

	// restore default
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
	[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
}

-(NSString *) title
{
	return @"Texture Pixel Formats";
}

-(NSString *) subtitle
{
	return @"Textures: RGBA8888, RGBA4444, RGB5A1, RGB565, A8";
}
@end

#pragma mark -
#pragma mark TextureBlend

@implementation TextureBlend
-(id) init
{
	if( (self=[super init]) ) {
		
		for( int i=0;i < 15;i++ ) {
			
			// BOTTOM sprites have alpha pre-multiplied
			// they use by default GL_ONE, GL_ONE_MINUS_SRC_ALPHA
			CCSprite *cloud = [CCSprite spriteWithFile:@"test_blend.png"];
			[self addChild:cloud z:i+1 tag:100+i];
			cloud.position = ccp(50+25*i, 80);
			cloud.blendFunc = (ccBlendFunc) { GL_ONE, GL_ONE_MINUS_SRC_ALPHA};

			// CENTER sprites have also alpha pre-multiplied
			// they use by default GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA
			cloud = [CCSprite spriteWithFile:@"test_blend.png"];
			[self addChild:cloud z:i+1 tag:200+i];
			cloud.position = ccp(50+25*i, 160);
			[cloud setBlendFunc:(ccBlendFunc){GL_ONE_MINUS_DST_COLOR, GL_ZERO}];

			
			// UPPER sprites are using custom blending function
			// You can set any blend function to your sprites
			cloud = [CCSprite spriteWithFile:@"test_blend.png"];
			[self addChild:cloud z:i+1 tag:200+i];
			cloud.position = ccp(50+25*i, 320-80);
			cloud.blendFunc = (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE };  // additive blending
		}
	}
	return self;
}

-(NSString *) title
{
	return @"Texture Blending";
}

-(NSString *) subtitle
{
	return @"Testing 3 different blending modes";
}
@end

#pragma mark -
#pragma mark TextureAsync

@implementation TextureAsync
-(id) init
{
	if( (self=[super init]) ) {
		
		imageOffset = 0;
	
		CGSize size =[[CCDirector sharedDirector] winSize];

		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Loading..." fontName:@"Marker Felt" fontSize:32];
		label.position = ccp( size.width/2, size.height/2);
		[self addChild:label z:10];
		
		id scale = [CCScaleBy actionWithDuration:0.3f scale:2];
		id scale_back = [scale reverse];
		id seq = [CCSequence actions: scale, scale_back, nil];
		[label runAction: [CCRepeatForever actionWithAction:seq]];
		
		[self schedule:@selector(loadImages:) interval:1.0f];
		
	}
	return self;
}

- (void) dealloc
{
	[[CCTextureCache sharedTextureCache] removeAllTextures];
	[super dealloc];
}


-(void) loadImages:(ccTime) dt
{
	[self unschedule:_cmd];

	for( int i=0;i < 8;i++) {
		for( int j=0;j < 8; j++) {
			NSString *sprite = [NSString stringWithFormat:@"sprite-%d-%d.png", i, j];
			[[CCTextureCache sharedTextureCache] addImageAsync:sprite target:self selector:@selector(imageLoaded:)];
		}
	}	

	[[CCTextureCache sharedTextureCache] addImageAsync:@"background1.jpg" target:self selector:@selector(imageLoaded:)];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"background2.jpg" target:self selector:@selector(imageLoaded:)];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"background.png" target:self selector:@selector(imageLoaded:)];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"atlastest.png" target:self selector:@selector(imageLoaded:)];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"grossini_dance_atlas.png" target:self selector:@selector(imageLoaded:)];
}


-(void) imageLoaded: (CCTexture2D*) tex
{
	// IMPORTANT: The order on the callback is not guaranteed. Don't depend on the callback

	// This test just creates a sprite based on the Texture
	
	CCSprite *sprite = [CCSprite spriteWithTexture:tex];
	sprite.anchorPoint = ccp(0,0);
	[self addChild:sprite z:-1];
	
	CGSize size =[[CCDirector sharedDirector] winSize];
	
	int i = imageOffset * 32;
	sprite.position = ccp( i % (int)size.width, (i / (int)size.width) * 32 );
	
	imageOffset++;
	
	NSLog(@"Image loaded: %@", tex);
}

-(NSString *) title
{
	return @"Texture Async Load";
}

-(NSString *) subtitle
{
	return @"Textures should load while an animation is being run";
}
@end


#pragma mark -
#pragma mark TextureAsyncBlock

@implementation TextureAsyncBlock
-(id) init
{
	if( (self=[super init]) ) {
		
		imageOffset = 0;
		
		CGSize size =[[CCDirector sharedDirector] winSize];
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Loading..." fontName:@"Marker Felt" fontSize:32];
		label.position = ccp( size.width/2, size.height/2);
		[self addChild:label z:10];
		
		id scale = [CCScaleBy actionWithDuration:0.3f scale:2];
		id scale_back = [scale reverse];
		id seq = [CCSequence actions: scale, scale_back, nil];
		[label runAction: [CCRepeatForever actionWithAction:seq]];
		
		[self schedule:@selector(loadImages:) interval:1.0f];
		
	}
	return self;
}

- (void) dealloc
{
	[[CCTextureCache sharedTextureCache] removeAllTextures];
	[super dealloc];
}


-(void) loadImages:(ccTime) dt
{
	[self unschedule:_cmd];

	void(^block)(CCTexture2D *block) = ^(CCTexture2D* tex){
		
		CCSprite *sprite = [CCSprite spriteWithTexture:tex];
		sprite.anchorPoint = ccp(0,0);
		[self addChild:sprite z:-1];
		
		CGSize size =[[CCDirector sharedDirector] winSize];
		
		int i = imageOffset * 32;
		sprite.position = ccp( i % (int)size.width, (i / (int)size.width) * 32 );
		
		imageOffset++;
		
		NSLog(@"Image loaded: %@", tex);
		
	};

	for( int i=0;i < 8;i++) {
		for( int j=0;j < 8; j++) {
			NSString *sprite = [NSString stringWithFormat:@"sprite-%d-%d.png", i, j];
			[[CCTextureCache sharedTextureCache] addImageAsync:sprite withBlock:block];
		}
	}	
	
	[[CCTextureCache sharedTextureCache] addImageAsync:@"background1.jpg" withBlock:block];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"background2.jpg" withBlock:block];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"background.png" withBlock:block];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"atlastest.png" withBlock:block];
	[[CCTextureCache sharedTextureCache] addImageAsync:@"grossini_dance_atlas.png" withBlock:block];
}

-(NSString *) title
{
	return @"Texture Async Load with Blocks";
}

-(NSString *) subtitle
{
	return @"Textures should load while an animation is being run";
}
@end



#pragma mark -
#pragma mark TextureGlClamp

@implementation TextureGlClamp
-(id) init
{
	if( (self=[super init]) ) {
		
		CGSize size =[[CCDirector sharedDirector] winSize];

		// The .png image MUST be power of 2 in order to create a continue effect.
		// eg: 32x64, 512x128, 256x1024, 64x64, etc..
		CCSprite *sprite = [CCSprite spriteWithFile:@"pattern1.png" rect:CGRectMake(0,0,512,256)];
		[self addChild:sprite z:-1 tag:kTagSprite1];
		[sprite setPosition:ccp(size.width/2,size.height/2)];
		ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE};
		[sprite.texture setTexParameters:&params];
		
		id rotate = [CCRotateBy actionWithDuration:4 angle:360];
		[sprite runAction:rotate];
		id scale = [CCScaleBy actionWithDuration:2 scale:0.04f];
		id scaleBack = [scale reverse];
		id seq = [CCSequence actions:scale, scaleBack, nil];
		[sprite runAction:seq];
		
	}
	return self;
}

-(NSString*) title
{
	return @"Texture GL_CLAMP";
}
- (void) dealloc
{
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[super dealloc];
}
@end

#pragma mark -
#pragma mark TextureGlRepeat

@implementation TextureGlRepeat
-(id) init
{
	if( (self=[super init]) ) {
		
		CGSize size =[[CCDirector sharedDirector] winSize];
		
		// The .png image MUST be power of 2 in order to create a continue effect.
		// eg: 32x64, 512x128, 256x1024, 64x64, etc..
		CCSprite *sprite = [CCSprite spriteWithFile:@"pattern1.png" rect:CGRectMake(0, 0, 4096, 4096)];
		[self addChild:sprite z:-1 tag:kTagSprite1];
		[sprite setPosition:ccp(size.width/2,size.height/2)];
		ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
		[sprite.texture setTexParameters:&params];
		
		id rotate = [CCRotateBy actionWithDuration:4 angle:360];
		[sprite runAction:rotate];
		id scale = [CCScaleBy actionWithDuration:2 scale:0.04f];
		id scaleBack = [scale reverse];
		id seq = [CCSequence actions:scale, scaleBack, nil];
		[sprite runAction:seq];		
	}
	return self;
}

-(NSString*) title
{
	return @"Texture GL_REPEAT";
}
- (void) dealloc
{
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[super dealloc];
}
@end

#pragma mark -
#pragma mark TextureLibPNG

@implementation TextureLibPNG

#define PNG_SIG_BYTES 8
-(CCTexture2D*) loadPNG:(NSString*)name
{	
	png_uint_32 width, height, width2, height2;
	int bits = 0;
	NSString *newName = [CCFileUtils fullPathFromRelativePath:name];
	
	FILE *png_file = fopen([newName UTF8String], "rb");
	NSAssert(png_file, @"PNG doesn't exists");

	uint8_t header[PNG_SIG_BYTES];	
	fread(header, 1, PNG_SIG_BYTES, png_file);
	NSAssert(!png_sig_cmp(header, 0, PNG_SIG_BYTES), @"Unkonw file format");
	
	png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	NSAssert(png_ptr, @"No mem");
	
	png_infop info_ptr = png_create_info_struct(png_ptr);
	NSAssert(info_ptr, @"No mem");
	
	png_infop end_info = png_create_info_struct(png_ptr);
	NSAssert(end_info, @"No mem");
	
	NSAssert(!setjmp(png_jmpbuf(png_ptr)), @"setjmp error");
	png_init_io(png_ptr, png_file);
	png_set_sig_bytes(png_ptr, PNG_SIG_BYTES);
	png_read_info(png_ptr, info_ptr);
	
	width = png_get_image_width(png_ptr, info_ptr);
	height = png_get_image_height(png_ptr, info_ptr);
	
	int bit_depth, color_type;
	bit_depth = png_get_bit_depth(png_ptr, info_ptr);
	color_type = png_get_color_type(png_ptr, info_ptr);

	if( color_type == PNG_COLOR_TYPE_PALETTE )
		png_set_palette_to_rgb( png_ptr );
	
	if( color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8 )
		png_set_expand_gray_1_2_4_to_8( png_ptr );
	
	if( png_get_valid( png_ptr, info_ptr, PNG_INFO_tRNS ) )
		png_set_tRNS_to_alpha (png_ptr);
	
	if( bit_depth == 16 )
		png_set_strip_16( png_ptr );
	
	else if( bit_depth < 8 )
		png_set_packing( png_ptr );
	
	png_read_update_info(png_ptr, info_ptr);
	
	png_get_IHDR( png_ptr, info_ptr,
				&width, &height, &bit_depth, &color_type,
				 NULL, NULL, NULL );
	
	switch( color_type )
	{
		case PNG_COLOR_TYPE_GRAY:
			bits = 1;
			break;
			
		case PNG_COLOR_TYPE_GRAY_ALPHA:
			bits = 2;
			break;
			
		case PNG_COLOR_TYPE_RGB:
			bits = 3;
			break;
			
		case PNG_COLOR_TYPE_RGB_ALPHA:
			bits = 4;
			break;
	}

	// width2 and height2 are the power of 2 versions of width and height
	height2 = height;
	width2 = width;

	unsigned int i = 0;
	if((width2 != 1) && (width2 & (width2 - 1))) {
		i = 1;
		while( i < width2)
			i *= 2;
		width2 = i;
	}
	if((height2 != 1) && (height2 & (height2 - 1))) {
		i = 1;
		while(i < height2)
			i *= 2;
		height2 = i;
	}	

	png_byte* pixels = calloc( width2 * height2 * bits, sizeof(png_byte) );
	png_byte** row_ptrs = malloc(height * sizeof(png_bytep));
	
	// since Texture2D loads the image "upside-down", there's no need
	// to flip the image here
	for (i=0; i<height; i++)
		row_ptrs[i] = pixels + i*width2*bits;

	png_read_image(png_ptr, row_ptrs);	
	png_read_end( png_ptr, NULL );
	png_destroy_read_struct( &png_ptr, &info_ptr, &end_info );
	free( row_ptrs );
	
	fclose(png_file);
	
	CGSize size = CGSizeMake(width,height);
	
	CCTexture2D *tex2d = [[CCTexture2D alloc] initWithData:pixels
										 pixelFormat:kCCTexture2DPixelFormat_RGBA8888
										  pixelsWide:width2
										  pixelsHigh:height2
										 contentSize:size];
	free(pixels);
	return [tex2d autorelease];
}

-(id) init
{
	if( (self=[super init]) ) {
				
		CGSize size =[[CCDirector sharedDirector] winSize];
	
		CCLayerColor *background = [CCLayerColor layerWithColor:ccc4(128,128,128,255) width:size.width height:size.height];
		[self addChild:background z:-1];
		
		
		// PNG sprite. Loaded using UIImage
		//   - Probably it will be premultiplied image
		CCSprite *png1 = [CCSprite spriteWithFile:@"grossinis_sister1-testalpha.png"];
		[self addChild:png1 z:0];
		png1.position = ccp(size.width/5, size.height/2);
		[self transformSprite:png1];
		
		// BMP image. Loaded using UIImage
		//   - Probably it will be premultiplied image
		CCSprite *uncPNG = [CCSprite spriteWithFile:@"grossinis_sister1-testalpha.bmp"];
		[self addChild:uncPNG z:0];
		uncPNG.position = ccp(size.width/5*2, size.height/2);
		[self transformSprite:uncPNG];

		
		// PNG sprite. Loaded using UIImage
		//  - Probably it will be a premultiplied image
		//  - We are forcing a new blend function just to see if it uses premultiplied or not
		CCSprite *png3 = [CCSprite spriteWithFile:@"grossinis_sister1-testalpha.ppng"];
		[self addChild:png3 z:0];
		png3.position = ccp(size.width/5*3, size.height/2);
		[png3 setBlendFunc:(ccBlendFunc){GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA}];
		[png3 setOpacityModifyRGB:NO];
		[self transformSprite:png3];
		
		// PNG 32-bit RGBA
		//  - This is a non-premultiplied image. It is loaded using libpng
		CCTexture2D *tex2d = [self loadPNG:@"grossinis_sister1-testalpha.ppng"];
		CCSprite *rgba =[CCSprite spriteWithTexture:tex2d];
		[self addChild:rgba z:0];
		rgba.position = ccp(size.width/5*4, size.height/2);
		[self transformSprite:rgba];
	}
	return self;
}

-(void) transformSprite:(CCSprite*)sprite
{
	CCLOG(@"override me");
}
- (void) dealloc
{
	[super dealloc];
}

-(NSString *) title
{
	return @"N/A";
}
@end

#pragma mark -
#pragma mark TextureLibPNGTest1

@implementation TextureLibPNGTest1
-(void) transformSprite:(CCSprite*)sprite
{
	id fade = [CCFadeOut actionWithDuration:2];
	id dl = [CCDelayTime actionWithDuration:2];
	id fadein = [fade reverse];
	id seq = [CCSequence actions: fade, fadein, dl, nil];
	id repeat = [CCRepeatForever actionWithAction:seq];
	[sprite runAction:repeat];	
}
-(NSString*) title
{
	return @"iPhone PNG/BMP vs libpng #1";
}
-(NSString*) subtitle
{
	return @"Testing Fade. You should only see a black border in the 3rd image";
}
@end

#pragma mark -
#pragma mark TextureLibPNGTest2

@implementation TextureLibPNGTest2
-(void) transformSprite:(CCSprite*)sprite
{
	id tint = [CCTintBy actionWithDuration:2 red:-64 green:-224 blue:-255];
	id dl = [CCDelayTime actionWithDuration:2];
	id tintback = [tint reverse];
	id seq = [CCSequence actions: tint, dl, tintback, nil];
	id repeat = [CCRepeatForever actionWithAction:seq];
	[sprite runAction:repeat];
}
-(NSString*) title
{
	return @"iPhone PNG/BMP vs libpng #2";
}
-(NSString*) subtitle
{
	return @"Testing Tint. You should only see a black border in the 3rd image";
}
@end

#pragma mark -
#pragma mark TextureLibPNGTest3

@implementation TextureLibPNGTest3
-(void) transformSprite:(CCSprite*)sprite
{	
	id fade = [CCFadeOut actionWithDuration:2];
	id dl = [CCDelayTime actionWithDuration:2];
	id fadein = [fade reverse];
	id seq = [CCSequence actions: fade, fadein, dl, nil];
	id repeat = [CCRepeatForever actionWithAction:seq];
	[sprite runAction:repeat];
	
	id tint = [CCTintBy actionWithDuration:2 red:-64 green:-224 blue:-255];
	id dl2 = [CCDelayTime actionWithDuration:2];
	id tintback = [tint reverse];
	id seq2 = [CCSequence actions: tint, dl2, tintback, nil];
	id repeat2 = [CCRepeatForever actionWithAction:seq2];
	[sprite runAction:repeat2];
	
}
-(NSString*) title
{
	return @"iPhone PNG/BMP vs libpng #3";
}
-(NSString*) subtitle
{
	return @"Testing Tint+Fade. You should only see a black border in the 3rd image";
}
@end

#pragma mark -
#pragma mark TextureSizeTest

@implementation TextureSizeTest
-(id) init
{	
	if ((self=[super init]) ) {
		CCSprite *sprite = nil;
		
		printf("Loading 512x512 image...");
		sprite = [CCSprite spriteWithFile:@"texture512x512.png"];
		if( sprite )
			printf("OK\n");
		else
			printf("Error\n");

		printf("Loading 1024x1024 image...");
		sprite = [CCSprite spriteWithFile:@"texture1024x1024.png"];
		if( sprite )
			printf("OK\n");
		else
			printf("Error\n");
		
		printf("Loading 2048x2048 image...");
		sprite = [CCSprite spriteWithFile:@"texture2048x2048.png"];
		if( sprite )
			printf("OK\n");
		else
			printf("Error\n");
		
		printf("Loading 4096x4096 image...");
		sprite = [CCSprite spriteWithFile:@"texture4096x4096.png"];
		if( sprite )
			printf("OK\n");
		else
			printf("Error\n");
		
	}
	return self;
}

-(NSString*) title
{
	return @"Different Texture Sizes";
}
-(NSString *) subtitle
{
	return @"512x512, 1024x1024, 2048x2048 and 4096x4096. See the console.";
}
@end

#pragma mark -
#pragma mark TextureCache1

@implementation TextureCache1
-(id) init
{	
	if ((self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCSprite *sprite;
		
		sprite = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		[sprite setPosition:ccp(s.width/5*1, s.height/2)];
		[[sprite texture] setAliasTexParameters];
		[sprite setScale:2];
		[self addChild:sprite];

		[[CCTextureCache sharedTextureCache] removeTexture:[sprite texture]];
		
		sprite = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		[sprite setPosition:ccp(s.width/5*2, s.height/2)];
		[[sprite texture] setAntiAliasTexParameters];
		[sprite setScale:2];
		[self addChild:sprite];

		// 2nd set of sprites
		
		sprite = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		[sprite setPosition:ccp(s.width/5*3, s.height/2)];
		[[sprite texture] setAliasTexParameters];
		[sprite setScale:2];
		[self addChild:sprite];
		
		[[CCTextureCache sharedTextureCache] removeTextureForKey:@"grossinis_sister2.png"];
		
		sprite = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		[sprite setPosition:ccp(s.width/5*4, s.height/2)];
		[[sprite texture] setAntiAliasTexParameters];
		[sprite setScale:2];
		[self addChild:sprite];
		
	}
	return self;
}

-(NSString*) title
{
	return @"CCTextureCache: remove";
}
-(NSString *) subtitle
{
	return @"4 images should appear: alias, antialias, alias, antilias";
}
@end

#pragma mark - FileUtilsTest

@implementation FileUtilsTest
-(id) init
{	
	if ((self=[super init]) ) {
		
		// This test is only valid in Retinadisplay
		
		if( CC_CONTENT_SCALE_FACTOR() == 2 ) {
			
			CCSprite *sprite = [[CCSprite alloc] initWithFile:@"bugs/test_issue_1179.png"];
			if( sprite )
				NSLog(@"Test #1 issue 1179: OK");
			else
				NSLog(@"Test #1 issue 1179: FAILED");
				
			[sprite release];

			sprite = [[CCSprite alloc] initWithFile:@"only_in_hd.pvr.ccz"];
			if( sprite )
				NSLog(@"Test #2 issue 1179: OK");
			else
				NSLog(@"Test #2 issue 1179: FAILED");
			
			[sprite release];

		} else {
			NSLog(@"Test issue #1179 failed. Needs to be tested with RetinaDispaly");
		}

			
		// Testint CCFileUtils API
		BOOL ret;
		ret = [CCFileUtils retinaDisplayFileExistsAtPath:@"bugs/test_issue_1179.png"];
		if( ret )
			NSLog(@"Test #3: retinaDisplayFileExistsAtPath: OK");
		else
			NSLog(@"Test #3: retinaDisplayFileExistsAtPath: FAILED");


		ret = [CCFileUtils retinaDisplayFileExistsAtPath:@"grossini-does_no_exist.png"];
		if( !ret )
			NSLog(@"Test #4: retinaDisplayFileExistsAtPath: OK");
		else
			NSLog(@"Test #4: retinaDisplayFileExistsAtPath: FAILED");

		
	}
	return self;
}

-(NSString*) title
{
	return @"CCFileUtils: See console";
}
-(NSString *) subtitle
{
	return @"See the console";
}
@end



#pragma mark -
#pragma mark AppController - Main


// CLASS IMPLEMENTATIONS

#pragma mark -
#pragma mark AppController - iPhone

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

@implementation AppController

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
	[director setDisplayFPS:YES];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change it at anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];	
	
	// When in iPad mode, CCFileUtils will append the "-ipad" to all loaded files
	// eg: "sprite.png" -> "sprite-ipad.png",  "spritesheet.pvr.ccz" -> "spritesheet-ipad.pvr.ccz"
	// If the -ipad file is not found, it will load the non-suffixed version
	// By default the iPad suffix is: ""
	[CCFileUtils setiPadSuffix:@"-ipad"];

	// When in RetinaDisplay mode, CCFileUtils will append the "-hd" to all loaded files
	// eg: "sprite.png" -> "sprite-hd.png",  "spritesheet.pvr.ccz" -> "spritesheet-hd.pvr.ccz"
	// If the -hd file is not found, it will load the non-suffixed version
	// By default the RetinaDisplay suffix is: "-hd"
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[director runWithScene: scene];
}

// geting a call, pause the game
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

#pragma mark -
#pragma mark AppController - Mac

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

@implementation cocos2dmacAppDelegate

@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CGSize winSize = CGSizeMake(640,480);
	
	//
	// CC_DIRECTOR_INIT:
	// 1. It will create an NSWindow with a given size
	// 2. It will create a MacGLView and it will associate it with the NSWindow
	// 3. It will register the MacGLView to the CCDirector
	//
	// If you want to create a fullscreen window, you should do it AFTER calling this macro
	//	
	CC_DIRECTOR_INIT(winSize);
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setResizeMode:kCCDirectorResize_AutoScale];	
	
	// Turn on display FPS
	[director setDisplayFPS:YES];

	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[director runWithScene:scene];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
#endif
