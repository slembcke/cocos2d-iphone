/*

File: PVRTexture.m
Abstract: The PVRTexture class is responsible for loading .pvr files.

Version: 1.0

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
 * Extended PVR formats for cocos2d project ( http://www.cocos2d-iphone.org )
 *	- RGBA8888
 *	- BGRA8888
 *  - RGB888
 *  - RGBA4444
 *  - RGBA5551
 *  - RGB565
 *  - A8
 *  - I8
 *  - AI88
 */

#import <zlib.h>

#import "CCTexturePVR.h"
#import "ccMacros.h"
#import "CCConfiguration.h"
#import "ccGLStateCache.h"
#import "Support/ccUtils.h"
#import "Support/CCFileUtils.h"
#import "Support/ZipUtils.h"
#import "Support/OpenGL_Internal.h"

#pragma mark -
#pragma mark CCTexturePVR

#define PVR_TEXTURE_FLAG_TYPE_MASK	0xff

#pragma mark PVR File format - common

//
// XXX DO NO ALTER THE ORDER IN THIS LIST XXX
//
static const ccPVRTexturePixelFormatInfo PVRTableFormats[] = {
	
	// 0: BGRA_8888
	{GL_RGBA, GL_BGRA, GL_UNSIGNED_BYTE, 32, NO, YES, kCCTexture2DPixelFormat_RGBA8888},
	// 1: RGBA_8888
	{GL_RGBA, GL_RGBA, GL_UNSIGNED_BYTE, 32, NO, YES, kCCTexture2DPixelFormat_RGBA8888},
	// 2: RGBA_4444
	{GL_RGBA, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, 16, NO, YES, kCCTexture2DPixelFormat_RGBA4444},
	// 3: RGBA_5551
	{GL_RGBA, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, 16, NO, YES, kCCTexture2DPixelFormat_RGB5A1},
	// 4: RGB_565
	{GL_RGB, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, 16, NO, NO, kCCTexture2DPixelFormat_RGB565},
	// 5: RGB_888
	{GL_RGB, GL_RGB, GL_UNSIGNED_BYTE, 24, NO, NO, kCCTexture2DPixelFormat_RGB888},
	// 6: A_8
	{GL_ALPHA, GL_ALPHA, GL_UNSIGNED_BYTE, 8, NO, NO, kCCTexture2DPixelFormat_A8},
	// 7: L_8
	{GL_LUMINANCE, GL_LUMINANCE, GL_UNSIGNED_BYTE, 8, NO, NO, kCCTexture2DPixelFormat_I8},
	// 8: LA_88
	{GL_LUMINANCE_ALPHA, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 16, NO, YES, kCCTexture2DPixelFormat_AI88},
	
#ifdef __CC_PLATFORM_IOS
	// 9: PVRTC 2BPP RGB
	{GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG, -1, -1, 2, YES, NO, kCCTexture2DPixelFormat_PVRTC2},
	// 10: PVRTC 2BPP RGBA
	{GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG, -1, -1, 2, YES, YES, kCCTexture2DPixelFormat_PVRTC2},
	// 11: PVRTC 4BPP RGB
	{GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, -1, -1, 4, YES, NO, kCCTexture2DPixelFormat_PVRTC4},
	// 12: PVRTC 4BPP RGBA
	{GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG, -1, -1, 4, YES, YES, kCCTexture2DPixelFormat_PVRTC4},
#endif // #__CC_PLATFORM_IOS
};

struct _pixelformat_hash {
	uint32_t pixelFormat;
	const ccPVRTexturePixelFormatInfo * pixelFormatInfo;
};


#pragma  mark PVR File format - v2

// Values taken from PVRTexture.h from http://www.imgtec.com
enum {
	kPVRTextureFlagMipmap		= (1<<8),		// has mip map levels
	kPVRTextureFlagTwiddle		= (1<<9),		// is twiddled
	kPVRTextureFlagBumpmap		= (1<<10),		// has normals encoded for a bump map
	kPVRTextureFlagTiling		= (1<<11),		// is bordered for tiled pvr
	kPVRTextureFlagCubemap		= (1<<12),		// is a cubemap/skybox
	kPVRTextureFlagFalseMipCol	= (1<<13),		// are there false coloured MIP levels
	kPVRTextureFlagVolume		= (1<<14),		// is this a volume texture
	kPVRTextureFlagAlpha		= (1<<15),		// v2.1 is there transparency info in the texture
	kPVRTextureFlagVerticalFlip	= (1<<16),		// v2.1 is the texture vertically flipped
};


static char gPVRTexIdentifier[4] = "PVR!";

enum
{
	kPVR2TexturePixelFormat_RGBA_4444= 0x10,
	kPVR2TexturePixelFormat_RGBA_5551,
	kPVR2TexturePixelFormat_RGBA_8888,
	kPVR2TexturePixelFormat_RGB_565,
	kPVR2TexturePixelFormat_RGB_555,				// unsupported
	kPVR2TexturePixelFormat_RGB_888,
	kPVR2TexturePixelFormat_I_8,
	kPVR2TexturePixelFormat_AI_88,
	kPVR2TexturePixelFormat_PVRTC_2,
	kPVR2TexturePixelFormat_PVRTC_4,
	kPVR2TexturePixelFormat_BGRA_8888,
	kPVR2TexturePixelFormat_A_8,
};

static struct _pixelformat_hash v2_pixelformat_hash[] = {

	{ kPVR2TexturePixelFormat_BGRA_8888,	&PVRTableFormats[0] },
	{ kPVR2TexturePixelFormat_RGBA_8888,	&PVRTableFormats[1] },
	{ kPVR2TexturePixelFormat_RGBA_4444,	&PVRTableFormats[2] },
	{ kPVR2TexturePixelFormat_RGBA_5551,	&PVRTableFormats[3] },
	{ kPVR2TexturePixelFormat_RGB_565,		&PVRTableFormats[4] },
	{ kPVR2TexturePixelFormat_RGB_888,		&PVRTableFormats[5] },
	{ kPVR2TexturePixelFormat_A_8,			&PVRTableFormats[6] },
	{ kPVR2TexturePixelFormat_I_8,			&PVRTableFormats[7] },
	{ kPVR2TexturePixelFormat_AI_88,		&PVRTableFormats[8] },

#ifdef __CC_PLATFORM_IOS
	{ kPVR2TexturePixelFormat_PVRTC_2,		&PVRTableFormats[10] },
	{ kPVR2TexturePixelFormat_PVRTC_4,		&PVRTableFormats[12] },
#endif // iphone only
};

#define PVR2_MAX_TABLE_ELEMENTS (sizeof(v2_pixelformat_hash) / sizeof(v2_pixelformat_hash[0]))


enum {
	kCCInternalPVRTextureFormat,
	kCCInternalOpenGLInternalFormat,
	kCCInternalOpenGLFormat,
	kCCInternalOpenGLType,
	kCCInternalBPP,
	kCCInternalCompressedImage,
	kCCInternalCCTexture2DPixelFormat,
};

typedef struct _PVRTexHeader
{
	uint32_t headerLength;
	uint32_t height;
	uint32_t width;
	uint32_t numMipmaps;
	uint32_t flags;
	uint32_t dataLength;
	uint32_t bpp;
	uint32_t bitmaskRed;
	uint32_t bitmaskGreen;
	uint32_t bitmaskBlue;
	uint32_t bitmaskAlpha;
	uint32_t pvrTag;
	uint32_t numSurfs;
} PVRTexHeader;

#pragma  mark PVR File format - v3

typedef enum {
	/* supported predefined formats */
	kPVR3TexturePixelFormat_PVRTC_2BPP_RGB = 0,
	kPVR3TexturePixelFormat_PVRTC_2BPP_RGBA = 1,
	kPVR3TexturePixelFormat_PVRTC_4BPP_RGB = 2,
	kPVR3TexturePixelFormat_PVRTC_4BPP_RGBA = 3,
	
	/* supported channel type formats */
	kPVR3TexturePixelFormat_PVR_BGRA_8888 = 9999,
	kPVR3TexturePixelFormat_PVR_RGBA_8888,
	kPVR3TexturePixelFormat_PVR_RGBA_4444,
	kPVR3TexturePixelFormat_PVR_RGBA_5551,
	kPVR3TexturePixelFormat_PVR_RGB_565,
	kPVR3TexturePixelFormat_PVR_RGB_888,
	kPVR3TexturePixelFormat_PVR_A_8,
	kPVR3TexturePixelFormat_PVR_L_8,
	kPVR3TexturePixelFormat_PVR_LA_8,
} CCPVR3TexturePixelFormat;

struct _pixelformat_hash v3_pixelformat_hash[] = {

	{kPVR3TexturePixelFormat_PVR_BGRA_8888,	&PVRTableFormats[0] },
	{kPVR3TexturePixelFormat_PVR_RGBA_8888,	&PVRTableFormats[1] },
	{kPVR3TexturePixelFormat_PVR_RGBA_4444, &PVRTableFormats[2] },
	{kPVR3TexturePixelFormat_PVR_RGBA_5551, &PVRTableFormats[3] },
	{kPVR3TexturePixelFormat_PVR_RGB_565,	&PVRTableFormats[4] },
	{kPVR3TexturePixelFormat_PVR_RGB_888,	&PVRTableFormats[5] },
	{kPVR3TexturePixelFormat_PVR_A_8,		&PVRTableFormats[6] },
	{kPVR3TexturePixelFormat_PVR_L_8,		&PVRTableFormats[7] },
	{kPVR3TexturePixelFormat_PVR_LA_8,		&PVRTableFormats[8] },

#ifdef __CC_PLATFORM_IOS
	{kPVR3TexturePixelFormat_PVRTC_2BPP_RGB,	&PVRTableFormats[9] },
	{kPVR3TexturePixelFormat_PVRTC_2BPP_RGBA,	&PVRTableFormats[10] },
	{kPVR3TexturePixelFormat_PVRTC_4BPP_RGB,	&PVRTableFormats[11] },
	{kPVR3TexturePixelFormat_PVRTC_4BPP_RGBA,	&PVRTableFormats[12] },
#endif // #__CC_PLATFORM_IOS
};

#define PVR3_MAX_TABLE_ELEMENTS (sizeof(v3_pixelformat_hash) / sizeof(v3_pixelformat_hash[0]))


typedef struct {
	uint32_t version;
	uint32_t flags;
	uint64_t pixelFormat;
	uint32_t colorSpace;
	uint32_t channelType;
	uint32_t height;
	uint32_t width;
	uint32_t depth;
	uint32_t numberOfSurfaces;
	uint32_t numberOfFaces;
	uint32_t numberOfMipmaps;
	uint32_t metadataLength;
} CCPVR3TextureHeader;

@implementation CCTexturePVR
@synthesize name = name_;
@synthesize width = width_;
@synthesize height = height_;
@synthesize hasAlpha = hasAlpha_;
@synthesize numberOfMipmaps = numberOfMipmaps_;

// cocos2d integration
@synthesize retainName = retainName_;
@synthesize format = format_;


- (BOOL)unpackPVRv2Data:(unsigned char*)data PVRLen:(NSUInteger)len
{
	BOOL success = FALSE;
	PVRTexHeader *header = NULL;
	uint32_t flags, pvrTag;
	uint32_t dataLength = 0, dataOffset = 0, dataSize = 0;
	uint32_t blockSize = 0, widthBlocks = 0, heightBlocks = 0;
	uint32_t width = 0, height = 0, bpp = 4;
	uint8_t *bytes = NULL;
	uint32_t formatFlags;

	header = (PVRTexHeader *)data;

	pvrTag = CFSwapInt32LittleToHost(header->pvrTag);

	if ((uint32_t)gPVRTexIdentifier[0] != ((pvrTag >>  0) & 0xff) ||
		(uint32_t)gPVRTexIdentifier[1] != ((pvrTag >>  8) & 0xff) ||
		(uint32_t)gPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
		(uint32_t)gPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xff))
	{
		return FALSE;
	}

	CCConfiguration *configuration = [CCConfiguration sharedConfiguration];

	flags = CFSwapInt32LittleToHost(header->flags);
	formatFlags = flags & PVR_TEXTURE_FLAG_TYPE_MASK;
	BOOL flipped = flags & kPVRTextureFlagVerticalFlip;
	if( flipped )
		CCLOGWARN(@"cocos2d: WARNING: Image is flipped. Regenerate it using PVRTexTool");

	if( ! [configuration supportsNPOT] &&
	   ( header->width != ccNextPOT(header->width) || header->height != ccNextPOT(header->height ) ) ) {
		CCLOGWARN(@"cocos2d: ERROR: Loding an NPOT texture (%dx%d) but is not supported on this device", header->width, header->height);
		return FALSE;
	}

	for( NSUInteger i=0; i < (unsigned int)PVR2_MAX_TABLE_ELEMENTS ; i++) {
		if( v2_pixelformat_hash[i].pixelFormat == formatFlags ) {

			_pixelFormatInfo = v2_pixelformat_hash[i].pixelFormatInfo;
			numberOfMipmaps_ = 0;

			width_ = width = CFSwapInt32LittleToHost(header->width);
			height_ = height = CFSwapInt32LittleToHost(header->height);

			if (CFSwapInt32LittleToHost(header->bitmaskAlpha))
				hasAlpha_ = TRUE;
			else
				hasAlpha_ = FALSE;

			dataLength = CFSwapInt32LittleToHost(header->dataLength);
			bytes = ((uint8_t *)data) + sizeof(PVRTexHeader);
			format_ = _pixelFormatInfo->ccPixelFormat;
			bpp = _pixelFormatInfo->bpp;

			// Calculate the data size for each texture level and respect the minimum number of blocks
			while (dataOffset < dataLength)
			{
				switch (formatFlags) {
					case kPVR2TexturePixelFormat_PVRTC_2:
						blockSize = 8 * 4; // Pixel by pixel block size for 2bpp
						widthBlocks = width / 8;
						heightBlocks = height / 4;
						break;
					case kPVR2TexturePixelFormat_PVRTC_4:
						blockSize = 4 * 4; // Pixel by pixel block size for 4bpp
						widthBlocks = width / 4;
						heightBlocks = height / 4;
						break;
					case kPVR2TexturePixelFormat_BGRA_8888:
						if( ! [[CCConfiguration sharedConfiguration] supportsBGRA8888] ) {
							CCLOG(@"cocos2d: TexturePVR. BGRA8888 not supported on this device");
							return FALSE;
						}
					default:
						blockSize = 1;
						widthBlocks = width;
						heightBlocks = height;
						break;
				}

				// Clamp to minimum number of blocks
				if (widthBlocks < 2)
					widthBlocks = 2;
				if (heightBlocks < 2)
					heightBlocks = 2;

				dataSize = widthBlocks * heightBlocks * ((blockSize  * bpp) / 8);
				unsigned int packetLength = (dataLength-dataOffset);
				packetLength = packetLength > dataSize ? dataSize : packetLength;

				mipmaps_[numberOfMipmaps_].address = bytes+dataOffset;
				mipmaps_[numberOfMipmaps_].len = packetLength;
				numberOfMipmaps_++;

				NSAssert( numberOfMipmaps_ < CC_PVRMIPMAP_MAX, @"TexturePVR: Maximum number of mimpaps reached. Increate the CC_PVRMIPMAP_MAX value");

				dataOffset += packetLength;

				width = MAX(width >> 1, 1);
				height = MAX(height >> 1, 1);
			}

			success = TRUE;
			break;
		}
	}

	if( ! success )
		CCLOGWARN(@"cocos2d: WARNING: Unsupported PVR Pixel Format: 0x%2x. Re-encode it with a OpenGL pixel format variant", formatFlags);

	return success;
}

- (BOOL)unpackPVRv3Data:(unsigned char*)dataPointer PVRLen:(NSUInteger)dataLength
{
	if(dataLength < sizeof(CCPVR3TextureHeader)) {
		return FALSE;
	}
	
	CCPVR3TextureHeader *header = (CCPVR3TextureHeader *)dataPointer;
	
	// validate version
	if(CFSwapInt32BigToHost(header->version) != 0x50565203) {
		CCLOG(@"cocos2d: WARNING: pvr file version mismatch");
		return FALSE;
	}
	
	// parse pixel format
	uint64_t pixelFormat = header->pixelFormat;
	uint32_t least = (uint32_t)(pixelFormat >> 0);
	uint32_t most = (uint32_t)(pixelFormat >> 32);
	CCPVR3TexturePixelFormat parsedPixelFormat = -1;
	NSMutableString *formatName = nil;

	// pre-defined format
	if(!most) {
		parsedPixelFormat = least;
	}
	// channel type format
	else {
		formatName = [NSMutableString stringWithCapacity:10];
		
		unichar channelsBuffer[4] = {
			((least >> 0) & 0xff),
			((least >> 8) & 0xff),
			((least >> 16) & 0xff),
			((least >> 24) & 0xff),
		};
		for(int i = 0; i < 4; i++) {
			const unichar c = channelsBuffer[i];
			if(c > 0) {
				[formatName appendString:[NSString stringWithCharacters:&c length:1]];
			}
		}
		uint8_t channelDepthsBuffer[4] = {
			((most >> 0) & 0xff),
			((most >> 8) & 0xff),
			((most >> 16) & 0xff),
			((most >> 24) & 0xff),
		};
		for(int i = 0; i < 4; i++) {
			uint8_t c = channelDepthsBuffer[i];
			if(c > 0) {
				[formatName appendFormat:@"%i", c];
			}
		}
		
		parsedPixelFormat = -1;
		if([formatName isEqualToString:@"bgra8888"])
			parsedPixelFormat = kPVR3TexturePixelFormat_PVR_BGRA_8888;
		
		else if([formatName isEqualToString:@"rgba8888"])
			parsedPixelFormat = kPVR3TexturePixelFormat_PVR_RGBA_8888;
		
		else if([formatName isEqualToString:@"rgba4444"])
			parsedPixelFormat = kPVR3TexturePixelFormat_PVR_RGBA_4444;
		
		else if([formatName isEqualToString:@"rgba5551"])
			parsedPixelFormat = kPVR3TexturePixelFormat_PVR_RGBA_5551;
		
		else if([formatName isEqualToString:@"rgb565"])
			parsedPixelFormat = kPVR3TexturePixelFormat_PVR_RGB_565;
		
		else if([formatName isEqualToString:@"rgb888"])
			parsedPixelFormat = kPVR3TexturePixelFormat_PVR_RGB_888;
		
		else if([formatName isEqualToString:@"a8"])
			parsedPixelFormat = kPVR3TexturePixelFormat_PVR_A_8;
		
		else if([formatName isEqualToString:@"l8"])
			parsedPixelFormat = kPVR3TexturePixelFormat_PVR_L_8;
		
		else if([formatName isEqualToString:@"la88"])
			parsedPixelFormat = kPVR3TexturePixelFormat_PVR_A_8;		
	}
	
	BOOL infoValid = NO;
	
	for(int i = 0; i < PVR3_MAX_TABLE_ELEMENTS; i++) {
		if( v3_pixelformat_hash[i].pixelFormat == parsedPixelFormat ) {
			_pixelFormatInfo = v3_pixelformat_hash[i].pixelFormatInfo;
			hasAlpha_ = _pixelFormatInfo->alpha;
			infoValid = YES;
			break;
		}
	}
	
	// unsupported / bad pixel format
	if(!infoValid) {
		CCLOG(@"cocos2d: WARNING: unsupported pvr pixelformat: %@", formatName);
		return FALSE;
	}
		
	// sizing
	uint32_t width = CFSwapInt32LittleToHost(header->width);
	uint32_t height = CFSwapInt32LittleToHost(header->height);
	width_ = width;
	height_ = height;
	uint32_t dataOffset = 0, dataSize = 0;
	uint32_t blockSize = 0, widthBlocks = 0, heightBlocks = 0;
	uint8_t *bytes = NULL;

	switch(parsedPixelFormat) {
		case kPVR3TexturePixelFormat_PVRTC_2BPP_RGB :
		case kPVR3TexturePixelFormat_PVRTC_2BPP_RGBA :
			blockSize = 8 * 4;
			widthBlocks = width / 8;
			heightBlocks = height / 4;
			break;
		case kPVR3TexturePixelFormat_PVRTC_4BPP_RGB :
		case kPVR3TexturePixelFormat_PVRTC_4BPP_RGBA :
			blockSize = 4 * 4;
			widthBlocks = width / 4;
			heightBlocks = height / 4;
			break;
		default :
			blockSize = 1;
			widthBlocks = width;
			heightBlocks = height;
			break;
	}
	if(widthBlocks < 2) {
		widthBlocks = 2;
	}
	if(heightBlocks < 2) {
		heightBlocks = 2;
	}
	
	dataOffset = (sizeof(CCPVR3TextureHeader) + header->metadataLength);
	bytes = dataPointer;
	
	numberOfMipmaps_ = header->numberOfMipmaps;
	NSAssert( numberOfMipmaps_ < CC_PVRMIPMAP_MAX, @"TexturePVR: Maximum number of mimpaps reached. Increate the CC_PVRMIPMAP_MAX value");

	for(int i = 0; i < numberOfMipmaps_; i++) {
		
		switch(parsedPixelFormat) {
			case kPVR3TexturePixelFormat_PVRTC_2BPP_RGB :
			case kPVR3TexturePixelFormat_PVRTC_2BPP_RGBA :
				blockSize = 8 * 4; // Pixel by pixel block size for 2bpp
				widthBlocks = width / 8;
				heightBlocks = height / 4;
				break;
			case kPVR3TexturePixelFormat_PVRTC_4BPP_RGB :
			case kPVR3TexturePixelFormat_PVRTC_4BPP_RGBA :
				blockSize = 4 * 4; // Pixel by pixel block size for 4bpp
				widthBlocks = width / 4;
				heightBlocks = height / 4;
				break;
			case kPVR3TexturePixelFormat_PVR_BGRA_8888:
				if( ! [[CCConfiguration sharedConfiguration] supportsBGRA8888] ) {
					CCLOG(@"cocos2d: TexturePVR. BGRA8888 not supported on this device");
					return FALSE;
				}
			default:
				blockSize = 1;
				widthBlocks = width;
				heightBlocks = height;
				break;
		}
			
		// Clamp to minimum number of blocks
		if (widthBlocks < 2)
			widthBlocks = 2;
		if (heightBlocks < 2)
			heightBlocks = 2;
		
		dataSize = widthBlocks * heightBlocks * ((blockSize  * _pixelFormatInfo->bpp) / 8);
		unsigned int packetLength = (dataLength-dataOffset);
		packetLength = packetLength > dataSize ? dataSize : packetLength;
		
		mipmaps_[i].address = bytes+dataOffset;
		mipmaps_[i].len = packetLength;
		
		dataOffset += packetLength;
		NSAssert( dataOffset <= dataLength, @"CCTexurePVR: Invalid lenght");
		
		
		width = MAX(width >> 1, 1);
		height = MAX(height >> 1, 1);
	}
	
	return TRUE;
}


- (BOOL)createGLTexture
{
	GLsizei width = width_;
	GLsizei height = height_;
	GLenum err;

	if (numberOfMipmaps_ > 0)
	{
		if (name_ != 0)
			ccGLDeleteTexture( name_ );

		// From PVR sources: "PVR files are never row aligned."
		glPixelStorei(GL_UNPACK_ALIGNMENT,1);

		glGenTextures(1, &name_);
		ccGLBindTexture2D( name_ );

		// Default: Anti alias.
		if( numberOfMipmaps_ == 1 )
			glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
		else
			glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
		
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
	}
	
	CHECK_GL_ERROR(); // clean possible GL error

	GLenum internalFormat = _pixelFormatInfo->internalFormat;
	GLenum format = _pixelFormatInfo->format;
	GLenum type = _pixelFormatInfo->type;
	BOOL compressed = _pixelFormatInfo->compressed;

	// Generate textures with mipmaps
	for (GLint i=0; i < numberOfMipmaps_; i++)
	{
		if( compressed && ! [[CCConfiguration sharedConfiguration] supportsPVRTC] ) {
			CCLOGWARN(@"cocos2d: WARNING: PVRTC images are not supported");
			return FALSE;
		}

		unsigned char *data = mipmaps_[i].address;
		unsigned int datalen = mipmaps_[i].len;

		if( compressed)
			glCompressedTexImage2D(GL_TEXTURE_2D, i, internalFormat, width, height, 0, datalen, data);
		else
			glTexImage2D(GL_TEXTURE_2D, i, internalFormat, width, height, 0, format, type, data);

		if( i > 0 && (width != height || ccNextPOT(width) != width ) )
			CCLOGWARN(@"cocos2d: TexturePVR. WARNING. Mipmap level %u is not squared. Texture won't render correctly. width=%u != height=%u", i, width, height);

		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			CCLOGWARN(@"cocos2d: TexturePVR: Error uploading compressed texture level: %u . glError: 0x%04X", i, err);
			return FALSE;
		}

		width = MAX(width >> 1, 1);
		height = MAX(height >> 1, 1);
	}
	
	return TRUE;
}


- (id)initWithContentsOfFile:(NSString *)path
{
	if((self = [super init]))
	{
		unsigned char *pvrdata = NULL;
		NSInteger pvrlen = 0;
		NSString *lowerCase = [path lowercaseString];

        if ( [lowerCase hasSuffix:@".ccz"])
			pvrlen = ccInflateCCZFile( [path UTF8String], &pvrdata );

		else if( [lowerCase hasSuffix:@".gz"] )
			pvrlen = ccInflateGZipFile( [path UTF8String], &pvrdata );

		else
			pvrlen = ccLoadFileIntoMemory( [path UTF8String], &pvrdata );

		if( pvrlen < 0 ) {
			[self release];
			return nil;
		}


        numberOfMipmaps_ = 0;

		name_ = 0;
		width_ = height_ = 0;
		hasAlpha_ = FALSE;
		_pixelFormatInfo = NULL;

		retainName_ = NO; // cocos2d integration
		BOOL ok = YES;
		
		ok = [self unpackPVRv2Data:pvrdata PVRLen:pvrlen];
		if( ! ok )
			ok = [self unpackPVRv3Data:pvrdata PVRLen:pvrlen];
			
		if( ok )
			ok = [self createGLTexture];
		
		if( ! ok ) {
			free(pvrdata);
			[self release];
			return nil;
		}
		
#if defined(__CC_PLATFORM_IOS) && defined(DEBUG)

		GLenum pixelFormat = _pixelFormatInfo->ccPixelFormat;
		CCConfiguration *conf = [CCConfiguration sharedConfiguration];
		
		if( [conf OSVersion] >= kCCiOSVersion_5_0 )
		{
			
			// iOS 5 BUG:
			// RGB888 textures allocate much more memory than needed on iOS 5
			// http://www.cocos2d-iphone.org/forum/topic/31092
			
			if( pixelFormat == kCCTexture2DPixelFormat_RGB888 ) {
				printf("\n");
				NSLog(@"cocos2d: WARNING. Using RGB888 texture. Convert it to RGB565 or RGBA8888 in order to reduce memory");
				NSLog(@"cocos2d: WARNING: File: %@", [path lastPathComponent] );
				NSLog(@"cocos2d: WARNING: For furhter info visit: http://www.cocos2d-iphone.org/forum/topic/31092");
				printf("\n");
			}

			
			else if( width_ != ccNextPOT(width_) ) {
				
				// XXX: Is this applicable for compressed textures ?
				// Since they are squared and POT (PVRv2) it is not an issue now. Not sure in the future.
				
				// iOS 5 BUG:
				// If width is not word aligned, then log warning.
				// http://www.cocos2d-iphone.org/forum/topic/31092
				

				NSUInteger bpp = [CCTexture2D bitsPerPixelForFormat:pixelFormat];
				NSUInteger bytes = width_ * bpp / 8;

				// XXX: Should it be 4 or sizeof(int) ??
				NSUInteger mod = bytes % 4;
				
				// Not word aligned ?
				if( mod != 0 ) {

					NSUInteger neededBytes = (4 - mod ) / (bpp/8);
					printf("\n");
					NSLog(@"cocos2d: WARNING. Current texture size=(%d,%d). Convert it to size=(%d,%d) in order to save memory", width_, height_, width_ + neededBytes, height_ );
					NSLog(@"cocos2d: WARNING: File: %@", [path lastPathComponent] );
					NSLog(@"cocos2d: WARNING: For furhter info visit: http://www.cocos2d-iphone.org/forum/topic/31092");
					printf("\n");
				}
			}
		}
#endif // iOS
		


		free(pvrdata);
	}

	return self;
}

- (id)initWithContentsOfURL:(NSURL *)url
{
	if (![url isFileURL])
	{
		CCLOG(@"cocos2d: CCPVRTexture: Only files are supported");
		[self release];
		return nil;
	}

	return [self initWithContentsOfFile:[url path]];
}


+ (id)pvrTextureWithContentsOfFile:(NSString *)path
{
	return [[[self alloc] initWithContentsOfFile:path] autorelease];
}


+ (id)pvrTextureWithContentsOfURL:(NSURL *)url
{
	if (![url isFileURL])
		return nil;

	return [CCTexturePVR pvrTextureWithContentsOfFile:[url path]];
}


- (void)dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);

	if (name_ != 0 && ! retainName_ )
		ccGLDeleteTexture( name_ );

	[super dealloc];
}

@end

