/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2014 Cocos2D Authors
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
 */

#import <ccTypes.h>


@class CCTexture;

// Standard vertex struct for rendering in v3.1+.
typedef struct CCVertex {
	GLKVector4 position;
	GLKVector2 texCoord1, texCoord2;
	GLKVector4 color;
} CCVertex;

// Apply a transform to a CCVertex's position.
static inline CCVertex
CCVertexApplyTransform(CCVertex v, const GLKMatrix4 *transform)
{
	return (CCVertex){
		GLKMatrix4MultiplyVector4(*transform, v.position),
		v.texCoord1, v.texCoord2, v.color,
	};
}

// Interpolate all components of two CCVertex values.
static inline CCVertex
CCVertexLerp(CCVertex a, CCVertex b, float t)
{
	return (CCVertex){
		GLKVector4Lerp(a.position, b.position, t),
		GLKVector2Lerp(a.texCoord1, b.texCoord1, t),
		GLKVector2Lerp(a.texCoord2, b.texCoord2, t),
		GLKVector4Lerp(a.color, b.color, t),
	};
}

typedef struct CCRenderBuffer {
	CCVertex *vertexes;
	GLushort *elements;
	GLushort startIndex;
} CCRenderBuffer;

static inline void
CCRenderBufferSetVertex(CCRenderBuffer buffer, int index, CCVertex vertex)
{
	buffer.vertexes[index] = vertex;
}

static inline void
CCRenderBufferSetTriangle(CCRenderBuffer buffer, int index, GLushort a, GLushort b, GLushort c)
{
	uint16_t offset = buffer.startIndex;
	buffer.elements[3*index + 0] = a + offset;
	buffer.elements[3*index + 1] = b + offset;
	buffer.elements[3*index + 2] = c + offset;
}

static inline void
CCRenderBufferSetLine(CCRenderBuffer buffer, int index, GLushort a, GLushort b)
{
	uint16_t offset = buffer.startIndex;
	buffer.elements[2*index + 0] = a + offset;
	buffer.elements[2*index + 1] = b + offset;
}


	
static inline BOOL
CCRenderCheckVisbility(const GLKMatrix4 *transform, GLKVector2 center, GLKVector2 extents)
{
	// Clip space center point.
	GLKVector4 csc = GLKMatrix4MultiplyVector4(*transform, GLKVector4Make(center.x, center.y, 0.0f, 1.0f));
	
	// x, y extents in clip space.
	float cshx = fmaxf(fabsf(extents.x*transform->m00 + extents.y*transform->m10), fabsf(extents.x*transform->m00 - extents.y*transform->m10));
	float cshy = fmaxf(fabsf(extents.x*transform->m01 + extents.y*transform->m11), fabsf(extents.x*transform->m01 - extents.y*transform->m11));
	
	// Check the bounds against the viewport [-1, 1] using a conservative perspective divide value.
	float w = fabs(csc.w) + fmaxf(fabsf(extents.x*transform->m03 + extents.y*transform->m13), fabsf(extents.x*transform->m03 - extents.y*transform->m13));
	return ((fabs(csc.x) - cshx < w) && (fabs(csc.y) - cshy < w));
}


@interface NSValue(CCRenderer)

+(NSValue *)valueWithGLKVector2:(GLKVector2)vector;
+(NSValue *)valueWithGLKVector3:(GLKVector3)vector;
+(NSValue *)valueWithGLKVector4:(GLKVector4)vector;

+(NSValue *)valueWithGLKMatrix4:(GLKMatrix4)matrix;

@end


extern const NSString *CCRenderStateBlendMode;
extern const NSString *CCRenderStateShader;
extern const NSString *CCRenderStateShaderUniforms;

extern const NSString *CCBlendFuncSrcColor;
extern const NSString *CCBlendFuncDstColor;
extern const NSString *CCBlendEquationColor;
extern const NSString *CCBlendFuncSrcAlpha;
extern const NSString *CCBlendFuncDstAlpha;
extern const NSString *CCBlendEquationAlpha;


@interface CCBlendMode : NSObject

@property(nonatomic, readonly) NSDictionary *options;

+(CCBlendMode *)blendModeWithOptions:(NSDictionary *)options;

+(CCBlendMode *)disabledMode;
+(CCBlendMode *)alphaMode;
+(CCBlendMode *)premultipliedAlphaMode;
+(CCBlendMode *)addMode;
+(CCBlendMode *)multiplyMode;

@end


@interface CCRenderState : NSObject<NSCopying>

+(instancetype)debugColor;

+(instancetype)renderStateWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader mainTexture:(CCTexture *)mainTexture;

-(instancetype)initWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader shaderUniforms:(NSDictionary *)shaderUniforms;

@end


@interface CCRenderer : NSObject

/// Mark the renderer's cached GL state as invalid.
-(void)invalidateState;

-(void)enqueueClear:(GLbitfield)mask color:(GLKVector4)color4 depth:(GLclampf)depth stencil:(GLint)stencil;

-(CCRenderBuffer)enqueueTriangles:(NSUInteger)triangleCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState;
-(CCRenderBuffer)enqueueLines:(NSUInteger)lineCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState;

/// Enqueue a block that performs GL commands.
-(void)enqueueBlock:(void (^)())block debugLabel:(NSString *)debugLabel;

/// Enqueue a method that performs GL commands.
-(void)enqueueMethod:(SEL)selector target:(id)target;

@end
