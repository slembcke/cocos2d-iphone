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


//CLASS IMPLEMENTATIONS:


@implementation CCTextureInfo

// Suppress automatic iVar creation.
@dynamic wrapMode, filterMode;

-(id)init
{
	if((self = [super init])){
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
	
	CCTextureInfo *info = [[self alloc] init];
	info->_textureName = [name copy];
	
	return info;
}

+(instancetype)infoWithImage:(CGImageRef)image;
{
	NSAssert(image, @"Texture image cannot be NULL.");
	
	CCTextureInfo *info = [[self alloc] init];
	info->_image = CGImageRetain(image);
	
	return info;
}

-(id)copyWithZone:(NSZone *)zone
{
	CCTextureInfo *copy = [[self.class alloc] init];
	copy->_textureName = _textureName;
	copy->_contentScale = _contentScale;
	copy->_image = CGImageRetain(_image);
	copy->_wrapModeX = _wrapModeX;
	copy->_wrapModeY = _wrapModeY;
	copy->_filterModeMin = _filterModeMin;
	copy->_filterModeMag = _filterModeMag;
	copy->_generateMipmaps = _generateMipmaps;
	
	return copy;
}

-(void)dealloc
{
	if(_image) CGImageRelease(_image);
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
			[_textureName isEqualToString:other.textureName] &&
			_image == other->_image &&
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
		(NSUInteger)_textureName ^
		(NSUInteger)_image ^ (
			(_wrapModeX << 0) | (_wrapModeY << 8) | (_filterModeMin << 16) | (_filterModeMag << 24)
		)
	);
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
	if(info.image){
		#warning Should the texture info allow you to override the scale?
		return [[CCTexture alloc] initWithCGImage:info.image contentScale:1.0];
	} else {
		CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
		
		CGFloat contentScale = 1.0;
		NSString *path = [fileUtils standarizePath:info.textureName];
		NSString *fullpath = [fileUtils fullPathForFilename:path contentScale:&contentScale];
		NSAssert(fullpath, @"Could not find file %@", path);
		
		NSString *lowerCase = [fullpath lowercaseString];
		
		if([lowerCase hasSuffix:@".pvr"] || [lowerCase hasSuffix:@".pvr.gz"] || [lowerCase hasSuffix:@".pvr.ccz"]){
			return [[CCTexture alloc] initWithPVRFile:path];
		} else {
			NSURL *url = [NSURL fileURLWithPath:fullpath];
			CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
			NSAssert(imageSource, @"Could not create image source for %@", path);
			
			CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
			NSAssert(image, @"Could not load image for %@", path);
			
			CCTexture *texture = [[CCTexture alloc] initWithCGImage:image contentScale:contentScale];
			NSAssert(texture, @"Could not create texture for %@", path);
			
			CGImageRelease(image);
			CFRelease(imageSource);
			
			CCLOGINFO(@"Texture loaded: %@", path);
			return texture;
		}
	}
}

// Don't need to do anything.
- (void)disposeOfSharedData:(id)data {}

@end



// If the image has alpha, you can create RGBA8 (32-bit) or RGBA4 (16-bit) or RGB5A1 (16-bit)
// Default is: RGBA8888 (32-bit textures)
static CCTexturePixelFormat defaultAlphaPixel_format = CCTexturePixelFormat_Default;

#pragma mark -
#pragma mark CCTexture2D - Main

@implementation CCTexture

@synthesize contentSizeInPixels = _sizeInPixels, pixelFormat = _format, pixelWidth = _width, pixelHeight = _height, name = _name, maxS = _maxS, maxT = _maxT;
@synthesize premultipliedAlpha = _premultipliedAlpha;
@synthesize contentScale = _contentScale;
@synthesize antialiased = _antialiased;

static CCTextureCache *CC_TEXTURE_CACHE;
static CCTexture *CC_TEXTURE_NONE = nil;

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
		
		NSLog( @"cocos2d: \"%@\"\tid=%lu\t%lu x %lu\t@ %ld bpp =>\t%lu KB",
			key,
			(long)tex.name,
			(long)tex.pixelWidth,
			(long)tex.pixelHeight,
			(long)bpp,
			(long)bytes / 1024
		);
	}
	
	NSLog( @"cocos2d: CCTextureCache dumpDebugInfo:\t%ld textures,\tfor %lu KB (%.2f MB)", (long)count, (long)totalBytes / 1024, totalBytes / (1024.0f*1024.0f));
}

+(void)initialize
{
	[self resetTextureCache];
	
	CC_TEXTURE_NONE = [self alloc];
	CC_TEXTURE_NONE->_name = 0;
	CC_TEXTURE_NONE->_format = CCTexturePixelFormat_RGBA8888;
	CC_TEXTURE_NONE->_contentScale = 1.0;
}

+(instancetype)none
{
	return CC_TEXTURE_NONE;
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
		CCTextureInfo *info = [CCTextureInfo infoWithImage:image];
		texture = [CC_TEXTURE_CACHE objectForKey:info];
		
		[CC_TEXTURE_CACHE makeAlias:name forKey:info];
	}
	
	
	return texture;
}

- (id) initWithData:(const void*)data pixelFormat:(CCTexturePixelFormat)pixelFormat pixelSize:(CGSize)pixelSize contentSizeInPixels:(CGSize)sizeInPixels textureInfo:(CCTextureInfo *)info
{
	if((self = [super init])) {
		NSUInteger width = pixelSize.width;
		NSUInteger height = pixelSize.height;
		
		glPushGroupMarkerEXT(0, "CCTexture: Init");
		
		// XXX: 32 bits or POT textures uses UNPACK of 4 (is this correct ??? )
		if(pixelFormat == CCTexturePixelFormat_RGBA8888 || (CCNextPOT(width) == width && CCNextPOT(height) == height)){
			glPixelStorei(GL_UNPACK_ALIGNMENT,4);
		} else {
			glPixelStorei(GL_UNPACK_ALIGNMENT,1);
		}

		glGenTextures(1, &_name);
		glBindTexture(GL_TEXTURE_2D, _name);
		
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );

		// Specify OpenGL texture image

		switch(pixelFormat)
		{
			case CCTexturePixelFormat_RGBA8888:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei) width, (GLsizei) height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
				break;
			case CCTexturePixelFormat_RGBA4444:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei) width, (GLsizei) height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data);
				break;
			case CCTexturePixelFormat_RGB5A1:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei) width, (GLsizei) height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
				break;
			case CCTexturePixelFormat_RGB565:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (GLsizei) width, (GLsizei) height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
				break;
			case CCTexturePixelFormat_RGB888:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (GLsizei) width, (GLsizei) height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
				break;
			case CCTexturePixelFormat_AI88:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, (GLsizei) width, (GLsizei) height, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, data);
				break;
			case CCTexturePixelFormat_A8:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, (GLsizei) width, (GLsizei) height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
				break;
			default:
				[NSException raise:NSInternalInconsistencyException format:@""];

		}

		_sizeInPixels  = sizeInPixels;
		_width = width;
		_height = height;
		_format = pixelFormat;
		_maxS = sizeInPixels.width / (float)width;
		_maxT = sizeInPixels.height / (float)height;
		_contentScale = info.contentScale;
		
		_premultipliedAlpha = NO;
		_hasMipmaps = NO;
		_antialiased = YES;
		
		glPopGroupMarkerEXT();
	}
	return self;
}

- (id) initWithData:(const void*)data pixelFormat:(CCTexturePixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSizeInPixels:(CGSize)sizeInPixels contentScale:(CGFloat)contentScale
{
	// Create a dummy texture info object with the content scale and default wrap/filter settings.
	CCTextureInfo *info = [[CCTextureInfo alloc] init];
	info.contentScale = contentScale;
	
	CGSize pixelSize = CGSizeMake(width, height);
	return [self initWithData:data pixelFormat:pixelFormat pixelSize:pixelSize contentSizeInPixels:sizeInPixels textureInfo:info];
}

// -------------------------------------------------------------

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

	if( _name ){
		glPushGroupMarkerEXT(0, "CCTexture: Dealloc");
		glDeleteTextures(1, &_name);
		glPopGroupMarkerEXT();
	}
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Name = %i | Dimensions = %lux%lu | Pixel format = %@ | Coordinates = (%.2f, %.2f)>", [self class], self, _name, (unsigned long)_width, (unsigned long)_height, [self stringForFormat], _maxS, _maxT];
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
	CGRect rectInPixels = {CGPointZero, _sizeInPixels};
	return [CCSpriteFrame frameWithTexture:self rectInPixels:rectInPixels rotated:NO offset:CGPointZero originalSize:_sizeInPixels];
}

- (void) setAntialiased:(BOOL)antialiased
{
    _antialiased = antialiased;
    if (antialiased) [self setAntiAliasTexParameters];
    else [self setAliasTexParameters];
}

@end

#pragma mark -
#pragma mark CCTexture2D - Image

@implementation CCTexture (Image)

- (id) initWithCGImage:(CGImageRef)cgImage contentScale:(CGFloat)contentScale
{
	NSAssert(cgImage, @"Image is NULL.");

	CCTexturePixelFormat pixelFormat = defaultAlphaPixel_format;
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage);

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
			if(defaultAlphaPixel_format == CCTexturePixelFormat_RGBA8888){
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

	NSUInteger pixelWidth = CGImageGetWidth(cgImage);
	NSUInteger pixelHeight = CGImageGetHeight(cgImage);
	
	NSUInteger maxTextureSize = [CCConfiguration sharedConfiguration].maxTextureSize;
	if(pixelWidth > maxTextureSize || pixelHeight > maxTextureSize ) {
		CCLOGWARN(@"cocos2d: WARNING: Image (%lu x %lu) is larger than the maximum %ld size", (long)pixelWidth, (long)pixelHeight, (long)maxTextureSize);
		return nil;
	}
   
	// Create the bitmap graphics context
	
	CGContextRef context = nil;
	void *data = nil;
	
	switch(pixelFormat) {
		case CCTexturePixelFormat_RGBA8888:
		case CCTexturePixelFormat_RGBA4444:
		case CCTexturePixelFormat_RGB5A1:
		case CCTexturePixelFormat_RGB565:
		case CCTexturePixelFormat_RGB888:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(pixelHeight * pixelWidth * 4);
			context = CGBitmapContextCreate(data, pixelWidth, pixelHeight, 8, 4 * pixelWidth, colorSpace, alphaInfo | kCGBitmapByteOrder32Big);
			break;
		case CCTexturePixelFormat_A8:
			data = malloc(pixelHeight * pixelWidth);
			alphaInfo = kCGImageAlphaOnly;
			context = CGBitmapContextCreate(data, pixelWidth, pixelHeight, 8, pixelWidth, NULL, (CGBitmapInfo)alphaInfo);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}
	
	CGColorSpaceRelease(colorSpace);
	
	CGContextClearRect(context, CGRectMake(0, 0, pixelWidth, pixelHeight));
	CGContextTranslateCTM(context, 0, pixelHeight);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextDrawImage(context, CGRectMake(0, 0, pixelWidth, pixelHeight), cgImage);
	CGContextRelease(context);
	
	#warning These should be moved to a function.
	// Repack the pixel data into the right format
//	if(pixelFormat == CCTexturePixelFormat_RGB565) {
//		//Convert "RRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
//		tempData = malloc(textureHeight * textureWidth * 2);
//		inPixel32 = (unsigned int*)data;
//		outPixel16 = (unsigned short*)tempData;
//		for(unsigned int i = 0; i < textureWidth * textureHeight; ++i, ++inPixel32)
//			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
//		free(data);
//		data = tempData;
//
//	}
//
//	else if(pixelFormat == CCTexturePixelFormat_RGB888) {
//		//Convert "RRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRRRRGGGGGGGGBBBBBBB"
//		tempData = malloc(textureHeight * textureWidth * 3);
//		char *inData = (char*)data;
//		char *outData = (char*)tempData;
//		int j=0;
//		for(unsigned int i = 0; i < textureWidth * textureHeight *4; i++) {
//			outData[j++] = inData[i++];
//			outData[j++] = inData[i++];
//			outData[j++] = inData[i++];
//		}
//		free(data);
//		data = tempData;
//		
//	}
//
//	else if (pixelFormat == CCTexturePixelFormat_RGBA4444) {
//		//Convert "RRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRGGGGBBBBAAAA"
//		tempData = malloc(textureHeight * textureWidth * 2);
//		inPixel32 = (unsigned int*)data;
//		outPixel16 = (unsigned short*)tempData;
//		for(unsigned int i = 0; i < textureWidth * textureHeight; ++i, ++inPixel32)
//			*outPixel16++ =
//			((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | // R
//			((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | // G
//			((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | // B
//			((((*inPixel32 >> 24) & 0xFF) >> 4) << 0); // A
//
//
//		free(data);
//		data = tempData;
//
//	}
//	else if (pixelFormat == CCTexturePixelFormat_RGB5A1) {
//		//Convert "RRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGBBBBBA"
//		/*
//		 Here was a bug.
//		 When you convert RGBA8888 texture to RGB5A1 texture and then render it on black background, you'll see a "ghost" image as if the texture is still RGBA8888. 
//		 On background lighter than the pixel color this effect disappers.
//		 This happens because the old convertion function doesn't premultiply old RGB with new A.
//		 As Result = sourceRGB + destination*(1-source A), then
//		 if Destination = 0000, then Result = source. Here comes the ghost!
//		 We need to check new alpha value first (it may be 1 or 0) and depending on it whether convert RGB values or just set pixel to 0 
//		 */
//		tempData = malloc(textureHeight * textureWidth * 2);
//		inPixel32 = (unsigned int*)data;
//		outPixel16 = (unsigned short*)tempData;
//		for(unsigned int i = 0; i < textureWidth * textureHeight; ++i, ++inPixel32) {
//			if ((*inPixel32 >> 31))// A can be 1 or 0
//				*outPixel16++ =
//				((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | // R
//				((((*inPixel32 >> 8) & 0xFF) >> 3) << 6) | // G
//				((((*inPixel32 >> 16) & 0xFF) >> 3) << 1) | // B
//				1; // A
//			else
//				*outPixel16++ = 0;
//		}
//		
//		free(data);
//		data = tempData;
//	}
	
	CGSize size = CGSizeMake(pixelWidth, pixelHeight);
	if((self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:pixelWidth pixelsHigh:pixelHeight contentSizeInPixels:size contentScale:contentScale])){
		// should be after calling super init
		_premultipliedAlpha = (alphaInfo == kCGImageAlphaPremultipliedLast || alphaInfo == kCGImageAlphaPremultipliedFirst);
	}
	
	free(data);
	
	return self;
}
@end

#pragma mark -
#pragma mark CCTexture2D - PVRSupport

@implementation CCTexture (PVRSupport)

// By default PVR images are treated as if they have the alpha channel premultiplied
static BOOL _PVRHaveAlphaPremultiplied = YES;

-(id) initWithPVRFile: (NSString*) relPath
{
	CGFloat contentScale;
	NSString *fullpath = [[CCFileUtils sharedFileUtils] fullPathForFilename:relPath contentScale:&contentScale];

	if( (self = [super init]) ) {
		CCTexturePVR *pvr = [[CCTexturePVR alloc] initWithContentsOfFile:fullpath];
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

+(void) PVRImagesHavePremultipliedAlpha:(BOOL)haveAlphaPremultiplied
{
	_PVRHaveAlphaPremultiplied = haveAlphaPremultiplied;
}
@end

#pragma mark -
#pragma mark CCTexture2D - Drawing

#pragma mark -
#pragma mark CCTexture2D - GLFilter

//
// Use to apply MIN/MAG filter
//
@implementation CCTexture (GLFilter)

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


#pragma mark -
#pragma mark CCTexture2D - Pixel Format

//
// Texture options for images that contains alpha
//
@implementation CCTexture (PixelFormat)
+(void) setDefaultAlphaPixelFormat:(CCTexturePixelFormat)format
{
	defaultAlphaPixel_format = format;
}

+(CCTexturePixelFormat) defaultAlphaPixelFormat
{
	return defaultAlphaPixel_format;
}

+(NSUInteger) bitsPerPixelForFormat:(CCTexturePixelFormat)format
{
	NSUInteger ret=0;
	
	switch (format) {
		case CCTexturePixelFormat_RGBA8888:
			ret = 32;
			break;
		case CCTexturePixelFormat_RGB888:
			// It is 32 and not 24, since its internal representation uses 32 bits.
			ret = 32;
			break;
		case CCTexturePixelFormat_RGB565:
			ret = 16;
			break;
		case CCTexturePixelFormat_RGBA4444:
			ret = 16;
			break;
		case CCTexturePixelFormat_RGB5A1:
			ret = 16;
			break;
		case CCTexturePixelFormat_AI88:
			ret = 16;
			break;
		case CCTexturePixelFormat_A8:
			ret = 8;
			break;
		case CCTexturePixelFormat_I8:
			ret = 8;
			break;
		case CCTexturePixelFormat_PVRTC4:
			ret = 4;
			break;
		case CCTexturePixelFormat_PVRTC2:
			ret = 2;
			break;
		default:
			ret = -1;
			NSAssert1(NO , @"bitsPerPixelForFormat: %ld, unrecognised pixel format", (long)format);
			CCLOG(@"bitsPerPixelForFormat: %ld, cannot give useful result", (long)format);
			break;
	}
	return ret;
}

-(NSUInteger) bitsPerPixelForFormat
{
	return [[self class] bitsPerPixelForFormat:_format];
}

-(NSString*) stringForFormat
{
	
	switch (_format) {
		case CCTexturePixelFormat_RGBA8888:
			return  @"RGBA8888";

		case CCTexturePixelFormat_RGB888:
			return  @"RGB888";

		case CCTexturePixelFormat_RGB565:
			return  @"RGB565";

		case CCTexturePixelFormat_RGBA4444:
			return  @"RGBA4444";

		case CCTexturePixelFormat_RGB5A1:
			return  @"RGB5A1";

		case CCTexturePixelFormat_AI88:
			return  @"AI88";

		case CCTexturePixelFormat_A8:
			return  @"A8";

		case CCTexturePixelFormat_I8:
			return  @"I8";
			
		case CCTexturePixelFormat_PVRTC4:
			return  @"PVRTC4";
			
		case CCTexturePixelFormat_PVRTC2:
			return  @"PVRTC2";

		default:
			NSAssert1(NO , @"stringForFormat: %ld, unrecognised pixel format", (long)_format);
			CCLOG(@"stringForFormat: %ld, cannot give useful result", (long)_format);
			break;
	}
	
	return  nil;
}
@end

