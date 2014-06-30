//
// Texture loading tests
// http://www.cocos2d-iphone.org
//
//  Created by Andy Korth on 12/10/13.
//

#import "cocos2d.h"
#import "TestBase.h"

@interface TextureTest : TestBase @end

// Included images generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TextureTest

- (CCSprite *) loadAndDisplayImageNamed:(NSString*) fileName withTitle:(NSString*) title{

	self.subTitle = title;
	
	CGSize s = [[CCDirector sharedDirector] viewSize];
	
	CCSprite *img = [CCSprite spriteWithImageNamed:fileName];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self.contentNode addChild:img];
	return img;
}

-(void) setupPNGLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image.png" withTitle: @"PNG loading example (has alpha)"];
}

-(void) setupPNGLoadingRedoverlayTest
{
	CCSprite * img = [self loadAndDisplayImageNamed: @"test_image.png" withTitle: @"PNG loading example (With red color overlay)"];
	[img setColor:[CCColor redColor]];
}

-(void) setupBMPLoadingTest
{
	[self loadAndDisplayImageNamed:	@"test_image.bmp" withTitle: @"BMP loading example (no alpha)"];
}

-(void) setupJPEGLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image.jpeg" withTitle: @"JPEG loading example (no alpha, white spots)"];
}

-(void) setupTIFFLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image.tiff" withTitle: @"TIFF loading example (has alpha)"];
}

#ifdef __CC_PLATFORM_IOS
// PVR on iOS only.

-(void) setupPVRLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image.pvr" withTitle: @"PVR loading example (no alpha)"];
}

-(void) setupPVRa8LoadingTest
{
	// Doesn't seem to work?
	CCSprite * img = [self loadAndDisplayImageNamed: @"test_image_a8.pvr" withTitle: @"8 bit PVR, alpha only. (With red color overlay)"];
	[img setColor:[CCColor redColor]];
}

-(void) setupPVRa8v3LoadingTest
{
	// Doesn't seem to work?
	CCSprite * img = [self loadAndDisplayImageNamed: @"test_image_a8_v3.pvr" withTitle: @"8 bit PVR v3, alpha only. (With red color overlay)"];
	[img setColor:[CCColor redColor]];
}

-(void) setupPVRa88LoadingTest
{
	// I expected an alpha channel..?
	[self loadAndDisplayImageNamed: @"test_image_ai88.pvr" withTitle: @"8+8 bit PVR, greyscale."];

}
-(void) setupPVRa88v3LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_ai88_v3.pvr" withTitle: @"8+8 bit PVR v3, alpha + greyscale."];
}

-(void) setupPvrtc2bppLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_pvrtc2bpp.pvr" withTitle: @"pvrtc 2 bits per pixel"];
}

-(void) setupPvrtc2bpp_v3LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_pvrtc2bpp_v3.pvr" withTitle: @"pvrtc 2 bits per pixel formatVersion 3 (with alpha)"];
}

-(void) setupPvrtc4bppLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_pvrtc4bpp.pvr" withTitle: @"pvrtc 4 bits per pixel"];
}

-(void) setupPvrtc4bpp_v3LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_pvrtc4bpp_v3.pvr" withTitle: @"pvrtc 4 bits per pixel formatVersion 3  (with alpha)"];
}

// TODO: PVRTC2 currently unsupported.
//-(void) setupTest_image_pvrtcii2bpp_v3LoadingTest
//{
//	[self loadAndDisplayImageNamed: @"test_image_pvrtcii2bpp_v3.pvr" withTitle: @"PVRTCII (PVRTC2) 2 bits per pixel"];
//}
//
//-(void) setupTest_image_pvrtcii4bpp_v3LoadingTest
//{
//	[self loadAndDisplayImageNamed: @"test_image_pvrtcii4bpp_v3.pvr" withTitle: @"PVRTCII (PVRTC2) 4 bits per pixel"];
//}

-(void) setupPvr_rgb565_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgb565.pvr" withTitle: @"PVR uncompressed rgb565"];
}
-(void) setupPvr_rgb565_v3_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgb565_v3.pvr" withTitle: @"PVR uncompressed rgb565 v3"];
}
-(void) setupPvr_rgb888_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgb888.pvr" withTitle: @"PVR uncompressed rgb888"];
}
-(void) setupPvr_rgb888_v3_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgb888_v3.pvr" withTitle: @"PVR uncompressed rgb888 v3"];
}
-(void) setupPvr_rgba4444_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgba4444.pvr" withTitle: @"PVR uncompressed rgba4444"];
}
-(void) setupPvr_rgba4444_v3_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgba4444_v3.pvr" withTitle: @"PVR uncompressed rgba4444 v3"];
}
-(void) setupPvr_rgba4444_mipmapped_oadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgba4444_mipmap.pvr" withTitle: @"PVR uncompressed rgba4444 mipmapped"];
}
-(void) setupPvr_rgba4444_gzipped_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgba4444.pvr.gz" withTitle: @"PVR gzipped rgba4444"];
}
-(void) setupPvr_rgba4444_ccz_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgba4444.pvr.ccz" withTitle: @"PVR gzipped.ccz rgba4444"];
}
#endif

//-(void) setupNonPowerOfTwoTextureTest
//{
//	[self loadAndDisplayImageNamed: @"test_1021x1024.png" withTitle: @"1021x1024 png. Watch for memory leaks with Instruments. See http://www.cocos2d-iphone.org/forum/topic/31092"];
//}

-(void) setupTestTextureAntialiasModesTest
{
	self.subTitle = @"Nearest filtering on the left, linear on the right.";
	
	{
		CCTextureInfo *info = [CCTextureInfo infoWithTextureNamed:@"powered.png"];
		info.filterMode = CCTextureInfoFilterModeNearest;
		
		CCSprite *sprite = [CCSprite spriteWithTexture:[CCTexture textureForInfo:info]];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = ccp(0.3, 0.5);
		[self.contentNode addChild:sprite];
	}
	
	{
		CCSprite *sprite = [CCSprite spriteWithImageNamed:@"powered.png"];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = ccp(0.7, 0.5);
		[self.contentNode addChild:sprite];
	}
	
	self.subTitle = @"";

}

-(void) setupGLRepeatTest
{
	self.subTitle = @"Repeating textures";
	
	CGSize s = [[CCDirector sharedDirector] viewSize];
	
	CCTextureInfo *info = [CCTextureInfo infoWithTextureNamed:@"test_image.png"];
	info.wrapMode = CCTextureInfoWrapModeRepeat;
	
	CCSprite *img = [CCSprite spriteWithTexture:[CCTexture textureForInfo:info] rect:CGRectMake(0, 0, 800, 600)];
	img.position = ccp( s.width/2.0f, s.height/2.0f);

	[self.contentNode addChild:img];
}

-(void)setupAutoRescaleTest
{
	self.subTitle = @"Image should be rescaled.";
	
	CCSprite *sprite = [CCSprite spriteWithImageNamed:@"test_image_scaled.png"];
	sprite.positionType = CCPositionTypeNormalized;
	sprite.position = ccp(0.5, 0.5);
	sprite.scale = 2.0;
	[self.contentNode addChild:sprite];
	
	CCTexture *texture = sprite.texture;
	NSString *info = texture.description;
	
	CCLabelTTF *label = [CCLabelTTF labelWithString:info fontName:nil fontSize:12];
	label.positionType = CCPositionTypeNormalized;
	label.position = ccp(0.5, 0.2);
	[self.contentNode addChild:label];
}


@end
