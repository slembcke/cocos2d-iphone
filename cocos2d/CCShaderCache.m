/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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

#import "CCShaderCache.h"
#import "GLProgram.h"
#import "Support/OpenGL_Internal.h"

static CCShaderCache *_sharedShaderCache;

@implementation CCShaderCache

#pragma mark CCShaderCache - Alloc, Init & Dealloc

+ (CCShaderCache *)sharedShaderCache
{
	if (!_sharedShaderCache)
		_sharedShaderCache = [[CCShaderCache alloc] init];
	
	return _sharedShaderCache;
}

+(id)alloc
{
	NSAssert(_sharedShaderCache == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

+(void)purgeSharedTextureCache
{
	[_sharedShaderCache release];
	_sharedShaderCache = nil;
}

-(id) init
{
	if( (self=[super init]) ) {
		programs_ = [[NSMutableDictionary alloc ] initWithCapacity: 10];
		
		[self loadDefaultShaders];
	}
	
	return self;
}

-(void) loadDefaultShaders
{
	// Position Texture Color shader
	GLProgram *p = [[GLProgram alloc] initWithVertexShaderFilename:@"Shaders/PositionTextureColor.vert"
											fragmentShaderFilename:@"Shaders/PositionTextureColor.frag"];
	
	[p addAttribute:kCCAttributeNamePosition index:kCCAttribPosition];
	[p addAttribute:kCCAttributeNameColor index:kCCAttribColor];
	[p addAttribute:kCCAttributeNameTexCoord index:kCCAttribTexCoords];
	
	[p link];
	[p updateUniforms];
	
	[programs_ setObject:p forKey:kCCShader_PositionTextureColor];
	[p release];

	//
	// Position Color shader
	//
	p = [[GLProgram alloc] initWithVertexShaderFilename:@"Shaders/PositionColor.vert"
								 fragmentShaderFilename:@"Shaders/PositionColor.frag"];
	
	[p addAttribute:kCCAttributeNamePosition index:kCCAttribPosition];
	[p addAttribute:kCCAttributeNameColor index:kCCAttribColor];
	
	[p link];
	[p updateUniforms];
	
	[programs_ setObject:p forKey:kCCShader_PositionColor];
	[p release];

	//
	// Position Texture shader
	//
	p = [[GLProgram alloc] initWithVertexShaderFilename:@"Shaders/PositionTexture.vert"
								 fragmentShaderFilename:@"Shaders/PositionTexture.frag"];
	
	[p addAttribute:kCCAttributeNamePosition index:kCCAttribPosition];
	[p addAttribute:kCCAttributeNameTexCoord index:kCCAttribTexCoords];
	
	[p link];
	[p updateUniforms];
	
	[programs_ setObject:p forKey:kCCShader_PositionTexture];
	[p release];	

	//
	// Position Texture A8 Color shader
	//
	p = [[GLProgram alloc] initWithVertexShaderFilename:@"Shaders/PositionTextureA8Color.vert"
								 fragmentShaderFilename:@"Shaders/PositionTextureA8Color.frag"];
	
	[p addAttribute:kCCAttributeNamePosition index:kCCAttribPosition];
	[p addAttribute:kCCAttributeNameColor index:kCCAttribColor];
	[p addAttribute:kCCAttributeNameTexCoord index:kCCAttribTexCoords];
	
	[p link];
	[p updateUniforms];
	
	[programs_ setObject:p forKey:kCCShader_PositionTextureA8Color];
	[p release];	

	//
	// Position and 1 color passed as a uniform (to similate glColor4ub )
	//
	p = [[GLProgram alloc] initWithVertexShaderFilename:@"Shaders/Position1Color.vert"
								 fragmentShaderFilename:@"Shaders/Position1Color.frag"];
	
	[p addAttribute:kCCAttributeNamePosition index:kCCAttribPosition];
	
	[p link];
	[p updateUniforms];
	
	[programs_ setObject:p forKey:kCCShader_Position1Color];
	[p release];	

	CHECK_GL_ERROR_DEBUG();
}

-(GLProgram *) programForKey:(NSString*)key
{
	return [programs_ objectForKey:key];
}

@end
