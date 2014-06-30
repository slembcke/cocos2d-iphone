/*

 ===== IMPORTANT =====

 This is sample code demonstrating API, technology or techniques in development.
 Although this sample code has been reviewed for technical accuracy, it is not
 final. Apple is supplying this information to help you plan for the adoption of
 the technologies and programming interfaces described herein. This information
 is subject to change, and software implemented based on this sample code should
 be tested with final operating system software and final documentation. Newer
 versions of this sample code may be provided with future seeds of the API or
 technology. For information about updates to this and other developer
 documentation, view the New & Updated sidebars in subsequent documentationd
 seeds.

 =====================

 File: Texture2D.m
 Abstract: Creates OpenGL 2D textures from images or text.

 Version: 1.6

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2008 Apple Inc. All Rights Reserved.

 */

/*
 * Support for RGBA_4_4_4_4 and RGBA_5_5_5_1 was copied from:
 * https://devforums.apple.com/message/37855#37855 by a1studmuffin
 */

/*
 * Added many additions for cocos2d
 */

#import "Platforms/CCGL.h"
#import "Platforms/CCNS.h"

#import "CCTexture.h"
#import "ccConfig.h"
#import "ccMacros.h"
#import "CCConfiguration.h"
#import "CCTexturePVR.h"
#import "CCShader.h"
#import "CCDirector.h"

#import "Support/ccUtils.h"
#import "Support/CCFileUtils.h"

#import "CCTexture_Private.h"
#import "CCSpriteFrame.h"

#import "ImageIO/ImageIO.h"
#import "CCCache.h"


static NSString *
NSStringFromCCTexturePixelFormat(CCTexturePixelFormat format)
{
	NSDictionary *lookup = @{
		@(CCTexturePixelFormat_RGBA8888): @"RGBA8888",
		@(CCTexturePixelFormat_RGB888): @"RGB888",
		@(CCTexturePixelFormat_RGB565): @"RGB565",
		@(CCTexturePixelFormat_RGBA4444): @"RGBA4444",
		@(CCTexturePixelFormat_RGB5A1): @"RGB5A1",
		@(CCTexturePixelFormat_AI88): @"AI88",
		@(CCTexturePixelFormat_A8): @"A8",
		@(CCTexturePixelFormat_I8): @"I8",
		@(CCTexturePixelFormat_PVRTC4): @"PVRTC4",
		@(CCTexturePixelFormat_PVRTC2): @"PVRTC2",
	};
	
	NSString *description = lookup[@(format)];
	NSCAssert(description , @"NSStringFromCCTexturePixelFormat: %lu, unrecognised pixel format", format);
	
	return  description;
}

static NSUInteger
BitsPerPixelForPixelFormat(CCTexturePixelFormat format)
{
	NSDictionary *lookup = @{
		@(CCTexturePixelFormat_RGBA8888): @32,
		@(CCTexturePixelFormat_RGB888): @32,
		@(CCTexturePixelFormat_RGB565): @16,
		@(CCTexturePixelFormat_RGBA4444): @16,
		@(CCTexturePixelFormat_RGB5A1): @16,
		@(CCTexturePixelFormat_AI88): @16,
		@(CCTexturePixelFormat_A8): @8,
		@(CCTexturePixelFormat_I8): @8,
		@(CCTexturePixelFormat_PVRTC4): @4,
		@(CCTexturePixelFormat_PVRTC2): @2,
	};
	
	NSNumber *bpp = lookup[@(format)];
	NSCAssert(bpp, @"bitsPerPixelForFormat: %ld, unrecognised pixel format", (long)format);
	
	return bpp.unsignedIntegerValue;
}

// If the image has alpha, you can create RGBA8 (32-bit) or RGBA4 (16-bit) or RGB5A1 (16-bit)
// Default is: RGBA8888 (32-bit textures)
static CCTexturePixelFormat DefaultAlphaPixelFormat = CCTexturePixelFormat_Default;

//CLASS IMPLEMENTATIONS:

@implementation CCBitmap

-(instancetype)initWithData:(NSData *)pixelData pixelFormat:(CCTexturePixelFormat)pixelFormat width:(NSUInteger)width height:(NSUInteger)height contentWidth:(NSUInteger)contentWidth contentHeight:(NSUInteger)contentHeight
{
	if((self = [super init])){
		_pixelData = pixelData;
		_pixelFormat = pixelFormat;
		
		_width = width;
		_height = height;
		
		_contentWidth = contentWidth;
		_contentHeight = contentHeight;
		
		_premultipliedAlpha = YES;
	}
	
	return self;
}

static NSMutableData *
ConvertToPixelFormat(NSMutableData *pixelData, CCTexturePixelFormat pixelFormat, NSUInteger width, NSUInteger height)
{
	// Assume data is already in the correct format. (RGBA8 or A8)
	NSMutableData *converted = pixelData;
	
	if(pixelFormat == CCTexturePixelFormat_RGB565) {
		converted = [NSMutableData dataWithLength:width*height*2];
		uint32_t *inPixel32 = (uint32_t *)pixelData.bytes;
		uint16_t *outPixel16 = (uint16_t *)converted.mutableBytes;
		for(unsigned int i = 0; i < width*height; ++i, ++inPixel32){
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		}
	} else if(pixelFormat == CCTexturePixelFormat_RGB888) {
		converted = [NSMutableData dataWithLength:width*height*3];
		uint8_t *inData = (uint8_t *)pixelData.bytes;
		uint8_t *outData = (uint8_t *)converted.mutableBytes;
		int j=0;
		for(unsigned int i = 0; i < width*height*4; i++) {
			outData[j++] = inData[i++];
			outData[j++] = inData[i++];
			outData[j++] = inData[i++];
		}
	} else if (pixelFormat == CCTexturePixelFormat_RGBA4444) {
		converted = [NSMutableData dataWithLength:width * height * 2];
		uint32_t *inPixel32 = (uint32_t *)pixelData.bytes;
		uint16_t *outPixel16 = (uint16_t *)converted.mutableBytes;
		for(unsigned int i = 0; i < width*height; ++i, ++inPixel32){
			*outPixel16++ =
				((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | // R
				((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | // G
				((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | // B
				((((*inPixel32 >> 24) & 0xFF) >> 4) << 0); // A
		}
	} else if (pixelFormat == CCTexturePixelFormat_RGB5A1) {
		/*
		 Here was a bug.
		 When you convert RGBA8888 texture to RGB5A1 texture and then render it on black background, you'll see a "ghost" image as if the texture is still RGBA8888. 
		 On background lighter than the pixel color this effect disappers.
		 This happens because the old convertion function doesn't premultiply old RGB with new A.
		 As Result = sourceRGB + destination*(1-source A), then
		 if Destination = 0000, then Result = source. Here comes the ghost!
		 We need to check new alpha value first (it may be 1 or 0) and depending on it whether convert RGB values or just set pixel to 0 
		 */
		converted = [NSMutableData dataWithLength:width*height*2];
		uint32_t *inPixel32 = (uint32_t *)pixelData.bytes;
		uint16_t *outPixel16 = (uint16_t *)converted.mutableBytes;
		for(unsigned int i = 0; i < width*height; ++i, ++inPixel32) {
			if ((*inPixel32 >> 31)){// A can be 1 or 0
				*outPixel16++ =
					((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | // R
					((((*inPixel32 >> 8) & 0xFF) >> 3) << 6) | // G
					((((*inPixel32 >> 16) & 0xFF) >> 3) << 1) | // B
					1; // A
			} else {
				*outPixel16++ = 0;
			}
		}
	}
	
	return converted;
}

-(instancetype)initWithCGImage:(CGImageRef)image rescaleFactor:(CGFloat)rescaleFactor
{
	NSAssert(image, @"Image is NULL.");

	CCTexturePixelFormat pixelFormat = DefaultAlphaPixelFormat;
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(image);

	bool hasAlpha = (
		alphaInfo == kCGImageAlphaPremultipliedLast ||
		alphaInfo == kCGImageAlphaPremultipliedFirst ||
		alphaInfo == kCGImageAlphaLast ||
		alphaInfo == kCGImageAlphaFirst
	);

	if(colorSpace){
		if(hasAlpha){
			alphaInfo = kCGImageAlphaPremultipliedLast;
		} else {
			alphaInfo = kCGImageAlphaNoneSkipLast;

			// Use RGBA8888 if default is RGBA8888, otherwise use RGB565.
			// DO NOT USE RGB888 since it is the same as RGBA8888, but it is more expensive to create it
			if(DefaultAlphaPixelFormat == CCTexturePixelFormat_RGBA8888){
				pixelFormat = CCTexturePixelFormat_RGBA8888;
			} else {
				pixelFormat = CCTexturePixelFormat_RGB565;
				CCLOG(@"cocos2d: CCTexture2D: Using RGB565 texture since image has no alpha");
			}
		}
	} else {
		// NOTE: No colorspace means a mask image
		CCLOG(@"cocos2d: CCTexture2D: Using A8 texture since image is a mask");
		pixelFormat = CCTexturePixelFormat_A8;
	}

	NSUInteger pixelWidth = ceil(CGImageGetWidth(image)*rescaleFactor);
	NSUInteger pixelHeight = ceil(CGImageGetHeight(image)*rescaleFactor);
	
	NSUInteger maxTextureSize = [CCConfiguration sharedConfiguration].maxTextureSize;
	if(pixelWidth > maxTextureSize || pixelHeight > maxTextureSize ) {
		CCLOGWARN(@"cocos2d: WARNING: Image (%lu x %lu) is larger than the maximum %ld size", (long)pixelWidth, (long)pixelHeight, (long)maxTextureSize);
		return nil;
	}
   
	// Create the bitmap graphics context
	
	CGContextRef context = nil;
	NSMutableData *data = nil;
	
	switch(pixelFormat) {
		case CCTexturePixelFormat_RGBA8888:
		case CCTexturePixelFormat_RGBA4444:
		case CCTexturePixelFormat_RGB5A1:
		case CCTexturePixelFormat_RGB565:
		case CCTexturePixelFormat_RGB888:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = [NSMutableData dataWithLength:pixelHeight*pixelWidth*4];
			context = CGBitmapContextCreate(data.mutableBytes, pixelWidth, pixelHeight, 8, 4 * pixelWidth, colorSpace, alphaInfo | kCGBitmapByteOrder32Big);
			break;
		case CCTexturePixelFormat_A8:
			data = [NSMutableData dataWithLength:pixelHeight*pixelWidth];
			alphaInfo = kCGImageAlphaOnly;
			context = CGBitmapContextCreate(data.mutableBytes, pixelWidth, pixelHeight, 8, pixelWidth, NULL, (CGBitmapInfo)alphaInfo);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}
	
	CGColorSpaceRelease(colorSpace);
	
	CGContextClearRect(context, CGRectMake(0, 0, pixelWidth, pixelHeight));
	CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, pixelHeight));
	CGContextDrawImage(context, CGRectMake(0, 0, pixelWidth, pixelHeight), image);
	CGContextRelease(context);
	
	// Convert to the correct destination pixel format.
	data = ConvertToPixelFormat(data, pixelFormat, pixelWidth, pixelHeight);
	
	CGSize size = CGSizeMake(pixelWidth, pixelHeight);
	if((self = [self initWithData:data pixelFormat:pixelFormat width:pixelWidth height:pixelHeight contentWidth:pixelWidth contentHeight:pixelHeight])){
		// should be after calling super init
		self.premultipliedAlpha = (alphaInfo == kCGImageAlphaPremultipliedLast || alphaInfo == kCGImageAlphaPremultipliedFirst);
	}
	
	return self;
}

-(NSString *)description
{
	NSString *formatString = NSStringFromCCTexturePixelFormat(_pixelFormat);
	return [NSString stringWithFormat:@"<%@ = %p | Dimensions = %lux%lu | Pixel format = %@ >", [self class], self, (unsigned long)_width, (unsigned long)_height, formatString];
}

@end


@implementation CCTextureInfo {
	CCTextureLoaderBlock _loader;
}

// Suppress automatic iVar creation.
@dynamic wrapMode, filterMode;

-(instancetype)initWithKey:(id)key loader:(CCTextureLoaderBlock)loader;
{
	if((self = [super init])){
		_key = key;
		_loader = loader;
		
		_contentScale = 1.0;
		
		_wrapModeX = CCTextureInfoWrapModeClampToEdge;
		_wrapModeY = CCTextureInfoWrapModeClampToEdge;
		_filterModeMin = CCTextureInfoFilterModeLinear;
		_filterModeMag = CCTextureInfoFilterModeLinear;
	}
	
	return self;
}

+(instancetype)infoWithTextureNamed:(NSString *)name
{
	NSAssert(name, @"Texture name cannot be nil.");
	name = [name copy];
	
	CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
	
	CGFloat contentScale = 1.0;
	NSString *path = [fileUtils standarizePath:name];
	NSString *fullpath = [fileUtils fullPathForFilename:path contentScale:&contentScale];
	NSAssert(fullpath, @"Could not find file %@", path);
		
	CCTextureInfo *obj = [[self alloc] initWithKey:name loader:^(CCTextureInfo *info){
		NSString *lowerCase = [fullpath lowercaseString];
		
		if([lowerCase hasSuffix:@".pvr"] || [lowerCase hasSuffix:@".pvr.gz"] || [lowerCase hasSuffix:@".pvr.ccz"]){
			return [[CCTexture alloc] initWithPVRFile:path];
		} else {
			NSURL *url = [NSURL fileURLWithPath:fullpath];
			CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
			NSAssert(imageSource, @"Could not create image source for %@", path);
			
			CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
			NSAssert(image, @"Could not load image for %@", path);
			
			CGFloat rescaleFactor = [fileUtils rescaleFactorForFilename:path];
			CCBitmap *bitmap = [[CCBitmap alloc] initWithCGImage:image rescaleFactor:rescaleFactor];
			NSAssert(bitmap, @"Could not load bitmap from image %@", path);
			
			CGImageRelease(image);
			CFRelease(imageSource);
			
			CCTexture *texture = [[CCTextureGL alloc] initWithBitmap:bitmap info:info];
			NSAssert(texture, @"Could not create texture for %@", path);
			
			texture.rescaleFactor = rescaleFactor;
			return texture;
		}
	}];
	
	obj.contentScale = contentScale;
	
	return obj;
}

+(instancetype)infoWithImage:(CGImageRef)image contentScale:(CGFloat)contentScale
{
	NSAssert(image, @"Texture image cannot be NULL.");
	
	// IMPORTANT: The bridged reference retains the CGImageRef for the block.
	CCTextureInfo *obj = [[self alloc] initWithKey:(__bridge id)image loader:^(CCTextureInfo *info){
		CCBitmap *bitmap = [[CCBitmap alloc] initWithCGImage:image rescaleFactor:1.0];
		NSAssert(bitmap, @"Could not create bitmap from CGImage.");
		
		return [[CCTexture alloc] initWithBitmap:bitmap info:info];
	}];
	
	obj.contentScale = contentScale;
	
	return obj;
}

-(id)copyWithZone:(NSZone *)zone
{
	CCTextureInfo *copy = [[self.class alloc] init];
	copy->_key = _key;
	copy->_loader = _loader;
	copy->_contentScale = _contentScale;
	copy->_wrapModeX = _wrapModeX;
	copy->_wrapModeY = _wrapModeY;
	copy->_filterModeMin = _filterModeMin;
	copy->_filterModeMag = _filterModeMag;
	copy->_generateMipmaps = _generateMipmaps;
	
	return copy;
}

-(void)setFilterModeMag:(CCTextureInfoFilterMode)filterModeMag
{
	NSAssert(filterModeMag == CCTextureInfoFilterModeNearest || filterModeMag == CCTextureInfoFilterModeLinear, @"Magnification filter cannot be a mipmap mode.");
	
	_filterModeMag = filterModeMag;
}

-(CCTextureInfoWrapMode)wrapMode
{
	NSAssert(_wrapModeX == _wrapModeY, @"Texture info x/y wrapping modes are not the same.");
	return _wrapModeX;
}

-(void)setWrapMode:(CCTextureInfoWrapMode)wrapMode
{
	self.wrapModeX = wrapMode;
	self.wrapModeY = wrapMode;
}

-(CCTextureInfoFilterMode)filterMode
{
	NSAssert(_filterModeMin == _filterModeMag, @"Texture info filter min/mag modes do not match.");
	return _filterModeMin;
}

-(void)setFilterMode:(CCTextureInfoFilterMode)filterMode
{
	self.filterModeMin = filterMode;
	self.filterModeMag = filterMode;
}

-(BOOL)isEqual:(id)object
{
	if(self == object){
		return true;
	} else if([object isKindOfClass:[CCTextureInfo class]]){
		CCTextureInfo *other = (CCTextureInfo *)object;
		
		return (
			[_key isEqual:other->_key] &&
			_contentScale == other->_contentScale &&
			_wrapModeX == other->_wrapModeX &&
			_wrapModeY == other->_wrapModeY &&
			_filterModeMin == other->_filterModeMin &&
			_filterModeMag == other->_filterModeMag
		);
	} else {
		return false;
	}
}

-(NSUInteger)hash
{
	return (
		(NSUInteger)_key ^ (
			(_wrapModeX << 0) | (_wrapModeY << 8) | (_filterModeMin << 16) | (_filterModeMag << 24)
		)
	);
}

-(CCTexture *)loadTexture
{
	return _loader(self);
}

@end


@interface CCTextureCache : CCCache @end
@implementation CCTextureCache

// The key is either an NSString of the texture's name or a CCTextureInfo object.
// The shared data is a CCTextureInfoObject.
- (CCTextureInfo *)createSharedDataForKey:(NSObject<NSCopying> *)key
{
	if([key isKindOfClass:[CCTextureInfo class]]){
		return [key copy];
	} else {
		return [CCTextureInfo infoWithTextureNamed:(NSString *)key];
	}
}

// The shared data is a CCTextureInfo. The public object is a CCTexture.
- (CCTexture *)createPublicObjectForSharedData:(CCTextureInfo *)info
{
	return [info loadTexture];
}

// Don't need to do anything.
- (void)disposeOfSharedData:(id)data {}

@end



#pragma mark -
#pragma mark CCTexture2D - Main

@implementation CCTexture

@synthesize contentSizeInPixels = _sizeInPixels, pixelFormat = _format, pixelWidth = _width, pixelHeight = _height;

static CCTextureCache *CC_TEXTURE_CACHE;

+(void)initialize
{
	if(self == [CCTexture class]){
		[self resetTextureCache];
	}
}

+(void)flushTextureCache;
{
	[CC_TEXTURE_CACHE flush];
}

+(void)resetTextureCache
{
	CC_TEXTURE_CACHE = [[CCTextureCache alloc] init];
}

+(void)dumpTextureCacheInfo;
{
	NSUInteger count = 0;
	NSUInteger totalBytes = 0;

	for(id key in CC_TEXTURE_CACHE.entries){
		CCTexture *tex = [CC_TEXTURE_CACHE rawObjectForKey:key];
		NSUInteger bpp = [tex bitsPerPixelForFormat];
		
		// Each texture takes up width * height * bytesPerPixel bytes.
		NSUInteger bytes = tex.pixelWidth * tex.pixelHeight * bpp / 8;
		totalBytes += bytes;
		count++;
		
		NSLog( @"cocos2d: \"%@\"\t%lu x %lu\t@ %ld bpp =>\t%lu KB",
			key,
//			(long)tex.name,
			(long)tex.pixelWidth,
			(long)tex.pixelHeight,
			(long)bpp,
			(long)bytes / 1024
		);
	}
	
	NSLog( @"cocos2d: CCTextureCache dumpDebugInfo:\t%ld textures,\tfor %lu KB (%.2f MB)", (long)count, (long)totalBytes / 1024, totalBytes / (1024.0f*1024.0f));
}

+(instancetype)none
{
	return [CCTextureGL none];
}

+ (id) textureWithFile:(NSString*)file
{
	return [CC_TEXTURE_CACHE objectForKey:file];
}

+(id)textureForInfo:(CCTextureInfo *)info
{
	return [CC_TEXTURE_CACHE objectForKey:info];
}

+(id)textureWithCGImage:(CGImageRef)image name:(NSString *)name
{
	// Bypass the usual caching mechanism.
	CCTexture *texture = [CC_TEXTURE_CACHE rawObjectForKey:name];
	
	// If the texture wasn't already present, insert it and make an alias.
	if(!texture){
		CCTextureInfo *info = [CCTextureInfo infoWithImage:image contentScale:1.0];
		texture = [CC_TEXTURE_CACHE objectForKey:info];
		
		[CC_TEXTURE_CACHE makeAlias:name forKey:info];
	}
	
	return texture;
}

+(id)cachedTextureNamed:(NSString *)name
{
	return [CC_TEXTURE_CACHE rawObjectForKey:name];
}

-(instancetype)initWithBitmap:(CCBitmap *)bitmap info:(CCTextureInfo *)info
{
	return [[CCTextureGL alloc] initWithBitmap:bitmap info:info];
}

- (id) initWithData:(const void*)data pixelFormat:(CCTexturePixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSizeInPixels:(CGSize)sizeInPixels contentScale:(CGFloat)contentScale
{
	NSUInteger bytesPerPixel = BitsPerPixelForPixelFormat(pixelFormat)/8;
	NSData *pixelData = [NSData dataWithBytesNoCopy:(void *)data length:width*height*bytesPerPixel freeWhenDone:NO];
	
	CCBitmap *bitmap = [[CCBitmap alloc] initWithData:pixelData pixelFormat:pixelFormat width:width height:height contentWidth:sizeInPixels.width contentHeight:sizeInPixels.height];
	
	// Set up a dummy info object with the default filter params and the given content scale.
	CCTextureInfo *info = [[CCTextureInfo alloc] init];
	info.contentScale = contentScale;
	
	return [[CCTextureGL alloc] initWithBitmap:bitmap info:info];
}

- (id) initWithCGImage:(CGImageRef)image contentScale:(CGFloat)contentScale
{
	// Set up a dummy info object with the default filter params and the given content scale.
	CCTextureInfo *info = [[CCTextureInfo alloc] init];
	info.contentScale = contentScale;
	
	return [[CCTextureGL alloc] initWithBitmap:[[CCBitmap alloc] initWithCGImage:image rescaleFactor:1.0] info:info];
}

-(id)initWithPVRFile:(NSString *)file
{
	return [[CCTextureGL alloc] initWithPVRFile:file];
}

// -------------------------------------------------------------

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Dimensions = %lux%lu | Pixel format = %@ | Coordinates = (%.2f, %.2f)>", [self class], self, (unsigned long)_width, (unsigned long)_height, [self stringForFormat], _maxS, _maxT];
}

-(CGSize) contentSize
{
	CGSize ret;
	ret.width = _sizeInPixels.width / _contentScale;
	ret.height = _sizeInPixels.height / _contentScale;

	return ret;
}

-(CCSpriteFrame*) createSpriteFrame
{
	// Original unscaled pixel size.
	CGRect rectInPixels = {CGPointZero, CC_SIZE_SCALE(_sizeInPixels, 1.0/_rescaleFactor)};
	return [CCSpriteFrame frameWithTexture:self rectInPixels:rectInPixels rotated:NO offset:CGPointZero originalSize:_sizeInPixels];
}

// By default PVR images are treated as if they have the alpha channel premultiplied
static BOOL _PVRHaveAlphaPremultiplied = YES;

+(void) PVRImagesHavePremultipliedAlpha:(BOOL)haveAlphaPremultiplied
{
	_PVRHaveAlphaPremultiplied = haveAlphaPremultiplied;
}
@end

//
// Texture options for images that contains alpha
//
@implementation CCTexture (PixelFormat)
+(void) setDefaultAlphaPixelFormat:(CCTexturePixelFormat)format
{
	DefaultAlphaPixelFormat = format;
}

+(CCTexturePixelFormat) defaultAlphaPixelFormat
{
	return DefaultAlphaPixelFormat;
}

+(NSUInteger) bitsPerPixelForFormat:(CCTexturePixelFormat)format
{
	return BitsPerPixelForPixelFormat(format);
}

-(NSUInteger) bitsPerPixelForFormat
{
	return BitsPerPixelForPixelFormat(_format);
}

-(NSString *) stringForFormat
{
	return NSStringFromCCTexturePixelFormat(_format);
}

@end


@implementation CCTextureGL

static CCTextureGL *CC_TEXTURE_GL_NONE = nil;

+(void)initialize
{
	if(self == [CCTextureGL class]){
		CC_TEXTURE_GL_NONE = [self alloc];
		CC_TEXTURE_GL_NONE->_name = 0;
		CC_TEXTURE_GL_NONE->_format = CCTexturePixelFormat_RGBA8888;
		CC_TEXTURE_GL_NONE->_contentScale = 1.0;
	}
}

+(instancetype)none
{
	return CC_TEXTURE_GL_NONE;
}

-(instancetype)initWithBitmap:(CCBitmap *)bitmap info:(CCTextureInfo *)info
{
	if((self = [super init])) {
		GLsizei width = (GLsizei)bitmap.width;
		GLsizei height = (GLsizei)bitmap.height;
		
		CCTexturePixelFormat pixelFormat = bitmap.pixelFormat;
		const void *pixelData = bitmap.pixelData.bytes;
		
		glPushGroupMarkerEXT(0, "CCTextureGL: Init");
		
		// XXX: 32 bits or POT textures uses UNPACK of 4 (is this correct ??? )
		if(pixelFormat == CCTexturePixelFormat_RGBA8888 || (CCNextPOT(width) == width && CCNextPOT(height) == height)){
			glPixelStorei(GL_UNPACK_ALIGNMENT,4);
		} else {
			glPixelStorei(GL_UNPACK_ALIGNMENT,1);
		}

		glGenTextures(1, &_name);
		glBindTexture(GL_TEXTURE_2D, _name);
		
		GLenum wrapModes[] = {GL_CLAMP_TO_EDGE, GL_REPEAT, GL_MIRRORED_REPEAT};
		GLenum minModes[] = {GL_NEAREST, GL_LINEAR};
		GLenum magModes[] = {
			GL_NEAREST, GL_NEAREST_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_LINEAR,
			GL_LINEAR, GL_LINEAR_MIPMAP_NEAREST, GL_LINEAR_MIPMAP_LINEAR,
		};
		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapModes[info.wrapModeX]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapModes[info.wrapModeY]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minModes[info.filterModeMin]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magModes[3*info.filterModeMag + info.filterModeMip]);

		// Specify OpenGL texture image

		switch(pixelFormat){
			case CCTexturePixelFormat_RGBA8888:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixelData);
				break;
			case CCTexturePixelFormat_RGBA4444:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, pixelData);
				break;
			case CCTexturePixelFormat_RGB5A1:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, pixelData);
				break;
			case CCTexturePixelFormat_RGB565:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, pixelData);
				break;
			case CCTexturePixelFormat_RGB888:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, pixelData);
				break;
			case CCTexturePixelFormat_AI88:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, width, height, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, pixelData);
				break;
			case CCTexturePixelFormat_A8:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, pixelData);
				break;
			default:
				[NSException raise:NSInternalInconsistencyException format:@""];
		}
		
		glPopGroupMarkerEXT();
		
		_sizeInPixels  = CGSizeMake(bitmap.contentWidth, bitmap.contentHeight);
		_width = width;
		_height = height;
		_format = pixelFormat;
		_maxS = _sizeInPixels.width / (float)width;
		_maxT = _sizeInPixels.height / (float)height;
		_contentScale = info.contentScale;
		self.rescaleFactor = 1.0;
		
		_premultipliedAlpha = NO;
		_hasMipmaps = NO;
		_antialiased = YES;
	}
	return self;
}

-(id) initWithPVRFile: (NSString*) relPath
{
	CGFloat contentScale;
	NSString *fullpath = [[CCFileUtils sharedFileUtils] fullPathForFilename:relPath contentScale:&contentScale];

	if( (self = [super init]) ) {
		CCTexturePVR *pvr = [[CCTexturePVR alloc] initWithContentsOfFile:fullpath];
		NSAssert(pvr, @"PVR file failed to load.");
		
		if( pvr ) {
			pvr.retainName = YES;	// don't dealloc texture on release

			_name = pvr.name;	// texture id
			_maxS = 1;			// only POT texture are supported
			_maxT = 1;
			_width = pvr.width;
			_height = pvr.height;
			_sizeInPixels = CGSizeMake(_width, _height);
			_premultipliedAlpha = (pvr.forcePremultipliedAlpha) ? pvr.hasPremultipliedAlpha : _PVRHaveAlphaPremultiplied;
			_format = pvr.format;

			_hasMipmaps = ( pvr.numberOfMipmaps > 1  );

		} else {

			CCLOG(@"cocos2d: Couldn't load PVR image: %@", relPath);
			return nil;
		}
		_contentScale = contentScale;
	}
	return self;
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

	if( _name ){
		glPushGroupMarkerEXT(0, "CCTexture: Dealloc");
		glDeleteTextures(1, &_name);
		glPopGroupMarkerEXT();
	}
}

-(void) generateMipmap
{
	glPushGroupMarkerEXT(0, "CCTexture: Generate Mipmap");
	
	NSAssert( _width == CCNextPOT(_width) && _height == CCNextPOT(_height), @"Mimpap texture only works in POT textures");
	glBindTexture(GL_TEXTURE_2D, _name);
	glGenerateMipmap(GL_TEXTURE_2D);
	_hasMipmaps = YES;
	
	glPopGroupMarkerEXT();
}

-(void) setTexParameters: (ccTexParams*) texParams
{
	glPushGroupMarkerEXT(0, "CCTexture: Set Texture Parameters");
	
	NSAssert( (_width == CCNextPOT(_width) && _height == CCNextPOT(_height)) ||
				(texParams->wrapS == GL_CLAMP_TO_EDGE && texParams->wrapT == GL_CLAMP_TO_EDGE),
			@"GL_CLAMP_TO_EDGE should be used in NPOT dimensions");

	glBindTexture(GL_TEXTURE_2D, _name );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, texParams->minFilter );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, texParams->magFilter );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, texParams->wrapS );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, texParams->wrapT );
	
	glPopGroupMarkerEXT();
}

-(void) setAliasTexParameters
{
	glPushGroupMarkerEXT(0, "CCTexture: Set Alias Texture Parameters");
	
	glBindTexture(GL_TEXTURE_2D, _name );
	
	if( ! _hasMipmaps )
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	else
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST );

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	
    _antialiased = NO;
	
	glPopGroupMarkerEXT();
}

-(void) setAntiAliasTexParameters
{
	glPushGroupMarkerEXT(0, "CCTexture: Set Anti-alias Texture Parameters");
	
	glBindTexture(GL_TEXTURE_2D, _name );
	
	if( ! _hasMipmaps )
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	else
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST );

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    
    _antialiased = YES;
	
	glPopGroupMarkerEXT();
}

@end
