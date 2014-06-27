/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013-2014 Cocos2D Authors
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
 */

#import "CCTexture.h"

// -------------------------------------------------------------

@interface CCBitmap : NSObject

-(instancetype)initWithData:(NSData *)pixelData pixelFormat:(CCTexturePixelFormat)pixelFormat
	width:(NSUInteger)width height:(NSUInteger)height
	contentWidth:(NSUInteger)contentWidth contentHeight:(NSUInteger)contentHeight;

@property(nonatomic, readonly) NSUInteger width;
@property(nonatomic, readonly) NSUInteger height;

@property(nonatomic, readonly) NSUInteger contentWidth;
@property(nonatomic, readonly) NSUInteger contentHeight;

@property(nonatomic, readonly) CCTexturePixelFormat pixelFormat;
@property(nonatomic, readonly) NSData *pixelData;

@property(nonatomic, assign) BOOL premultipliedAlpha;

@end


@interface CCTexture ()

/// Remove all textures from the cache.
+(void)resetTextureCache;

/* texture max S */
@property(nonatomic,readwrite) GLfloat maxS;
/* texture max T */
@property(nonatomic,readwrite) GLfloat maxT;

/* Initializes a texture from a PVR file.
 
 Supported PVR formats:
 - BGRA 8888
 - RGBA 8888
 - RGBA 4444
 - RGBA 5551
 - RBG 565
 - A 8
 - I 8
 - AI 8
 - PVRTC 2BPP
 - PVRTC 4BPP
 
 By default PVR images are treated as if they alpha channel is NOT premultiplied. You can override this behavior with this class method:
 - PVRImagesHavePremultipliedAlpha:(BOOL)haveAlphaPremultiplied;
 
 IMPORTANT: This method is only defined on iOS. It is not supported on the Mac version.
 
 */
-(id) initWithPVRFile: (NSString*) file;

/// Create a texture from a bitmap a texture info object.
-(instancetype)initWithBitmap:(CCBitmap *)bitmap info:(CCTextureInfo *)info;

/* treats (or not) PVR files as if they have alpha premultiplied.
 Since it is impossible to know at runtime if the PVR images have the alpha channel premultiplied, it is
 possible load them as if they have (or not) the alpha channel premultiplied.
 
 By default it is disabled.
 
 */
+(void) PVRImagesHavePremultipliedAlpha:(BOOL)haveAlphaPremultiplied;

@end

/*
 Extension to set the Min / Mag filter
 */
typedef struct _ccTexParams {
	GLuint	minFilter;
	GLuint	magFilter;
	GLuint	wrapS;
	GLuint	wrapT;
} ccTexParams;

@interface CCTextureGL : CCTexture

/* texture name */
@property(nonatomic,readonly) GLuint name;

/* sets the min filter, mag filter, wrap s and wrap t texture parameters.
 If the texture size is NPOT (non power of 2), then in can only use GL_CLAMP_TO_EDGE in GL_TEXTURE_WRAP_{S,T}.
 
 @warning Calling this method could allocate additional texture memory.
 
 */
-(void) setTexParameters: (ccTexParams*) texParams;


/* sets antialias texture parameters:
 - GL_TEXTURE_MIN_FILTER = GL_LINEAR
 - GL_TEXTURE_MAG_FILTER = GL_LINEAR
 
 @warning Calling this method could allocate additional texture memory.
 
 */
- (void) setAntiAliasTexParameters;

/* sets alias texture parameters:
 - GL_TEXTURE_MIN_FILTER = GL_NEAREST
 - GL_TEXTURE_MAG_FILTER = GL_NEAREST
 
 @warning Calling this method could allocate additional texture memory.
 
 */
- (void) setAliasTexParameters;


/* Generates mipmap images for the texture.
 It only works if the texture size is POT (power of 2).
 */
-(void) generateMipmap;

@end
