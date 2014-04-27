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

#import "objc/message.h"

#import "cocos2d.h"
#import "CCRenderer_private.h"
#import "CCCache.h"
#import "CCTexture_Private.h"
#import "CCShader_private.h"
#import "CCDirector_Private.h"
#import "CCGL.h"


//MARK Forward Declarations.


@class CCVertexArray;

@interface CCRenderer()
-(void)bindVertexArray:(CCVertexArray *)array;
-(void)setRenderState:(CCRenderState *)renderState;
@end


//MARK: NSValue Additions.


@implementation NSValue(CCRenderer)

+(NSValue *)valueWithGLKVector2:(GLKVector2)vector
{
	return [NSValue valueWithBytes:&vector objCType:@encode(GLKVector2)];
}

+(NSValue *)valueWithGLKVector3:(GLKVector3)vector
{
	return [NSValue valueWithBytes:&vector objCType:@encode(GLKVector3)];
}

+(NSValue *)valueWithGLKVector4:(GLKVector4)vector
{
	return [NSValue valueWithBytes:&vector objCType:@encode(GLKVector4)];
}

+(NSValue *)valueWithGLKMatrix4:(GLKMatrix4)matrix
{
	return [NSValue valueWithBytes:&matrix objCType:@encode(GLKMatrix4)];
}

@end

//MARK: Option Keys.


const NSString *CCRenderStateBlendMode = @"CCRenderStateBlendMode";
const NSString *CCRenderStateShader = @"CCRenderStateShader";
const NSString *CCRenderStateShaderUniforms = @"CCRenderStateShaderUniforms";

const NSString *CCBlendFuncSrcColor = @"CCBlendFuncSrcColor";
const NSString *CCBlendFuncDstColor = @"CCBlendFuncDstColor";
const NSString *CCBlendEquationColor = @"CCBlendEquationColor";
const NSString *CCBlendFuncSrcAlpha = @"CCBlendFuncSrcAlpha";
const NSString *CCBlendFuncDstAlpha = @"CCBlendFuncDstAlpha";
const NSString *CCBlendEquationAlpha = @"CCBlendEquationAlpha";


//MARK: Blend Modes.


@interface CCBlendMode()

-(instancetype)initWithOptions:(NSDictionary *)options;

@end


@interface CCBlendModeCache : CCCache
@end


@implementation CCBlendModeCache

-(id)objectForKey:(id<NSCopying>)options
{
	CCBlendMode *blendMode = [self rawObjectForKey:options];
	if(blendMode) return blendMode;
	
	// Normalize the blending mode to use for the key.
	id src = (options[CCBlendFuncSrcColor] ?: @(GL_ONE));
	id dst = (options[CCBlendFuncDstColor] ?: @(GL_ZERO));
	id equation = (options[CCBlendEquationColor] ?: @(GL_FUNC_ADD));
	
	NSDictionary *normalized = @{
		CCBlendFuncSrcColor: src,
		CCBlendFuncDstColor: dst,
		CCBlendEquationColor: equation,
		
		// Assume they meant non-separate blending if they didn't fill in the keys.
		CCBlendFuncSrcAlpha: (options[CCBlendFuncSrcAlpha] ?: src),
		CCBlendFuncDstAlpha: (options[CCBlendFuncDstAlpha] ?: dst),
		CCBlendEquationAlpha: (options[CCBlendEquationAlpha] ?: equation),
	};
	
	// Create the key using the normalized blending mode.
	blendMode = [super objectForKey:normalized];
	
	// Make an alias for the unnormalized version
	[self makeAlias:options forKey:normalized];
	
	return blendMode;
}

-(id)createSharedDataForKey:(NSDictionary *)options
{
	return options;
}

-(id)createPublicObjectForSharedData:(NSDictionary *)options
{
	return [[CCBlendMode alloc] initWithOptions:options];
}

// Nothing special
-(void)disposeOfSharedData:(id)data {}

-(void)flush
{
	// Since blending modes are used for keys, need to wrap the flush call in a pool.
	@autoreleasepool {
		[super flush];
	}
}

@end


@implementation CCBlendMode {
	@public
	NSDictionary *_options;
}

-(instancetype)initWithOptions:(NSDictionary *)options
{
	if((self = [super init])){
		_options = options;
	}
	
	return self;
}

CCBlendModeCache *CCBLENDMODE_CACHE = nil;

// Default modes
static CCBlendMode *CCBLEND_DISABLED = nil;
static CCBlendMode *CCBLEND_ALPHA = nil;
static CCBlendMode *CCBLEND_PREMULTIPLIED_ALPHA = nil;
static CCBlendMode *CCBLEND_ADD = nil;
static CCBlendMode *CCBLEND_MULTIPLY = nil;

static NSDictionary *CCBLEND_DISABLED_OPTIONS = nil;

+(void)initialize
{
	CCBLENDMODE_CACHE = [[CCBlendModeCache alloc] init];
	
	// Add the default modes
	CCBLEND_DISABLED = [self blendModeWithOptions:@{}];
	CCBLEND_DISABLED_OPTIONS = CCBLEND_DISABLED.options;
	
	CCBLEND_ALPHA = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_SRC_ALPHA),
		CCBlendFuncDstColor: @(GL_ONE_MINUS_SRC_ALPHA),
	}];
	
	CCBLEND_PREMULTIPLIED_ALPHA = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_ONE),
		CCBlendFuncDstColor: @(GL_ONE_MINUS_SRC_ALPHA),
	}];
	
	CCBLEND_ADD = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_ONE),
		CCBlendFuncDstColor: @(GL_ONE),
	}];
	
	CCBLEND_MULTIPLY = [self blendModeWithOptions:@{
		CCBlendFuncSrcColor: @(GL_DST_COLOR),
		CCBlendFuncDstColor: @(GL_ZERO),
	}];
}

+(CCBlendMode *)blendModeWithOptions:(NSDictionary *)options
{
	return [CCBLENDMODE_CACHE objectForKey:options];
}

+(CCBlendMode *)disabledMode
{
	return CCBLEND_DISABLED;
}

+(CCBlendMode *)alphaMode
{
	return CCBLEND_ALPHA;
}

+(CCBlendMode *)premultipliedAlphaMode
{
	return CCBLEND_PREMULTIPLIED_ALPHA;
}

+(CCBlendMode *)addMode
{
	return CCBLEND_ADD;
}

+(CCBlendMode *)multiplyMode
{
	return CCBLEND_MULTIPLY;
}

@end


//MARK: Render States.


@interface CCRenderState() {
	@public
	CCBlendMode *_blendMode;
	CCShader *_shader;
	NSDictionary *_shaderUniforms;
}

-(instancetype)initWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader shaderUniforms:(NSDictionary *)shaderUniforms;

@end


@interface CCRenderStateCache : CCCache
@end


@implementation CCRenderStateCache

-(id)createSharedDataForKey:(CCRenderState *)renderState
{
	return renderState;
}

-(id)createPublicObjectForSharedData:(CCRenderState *)renderState
{
	return [[CCRenderState alloc] initWithBlendMode:renderState->_blendMode shader:renderState->_shader shaderUniforms:renderState->_shaderUniforms];
}

// Nothing special
-(void)disposeOfSharedData:(id)data {}

-(void)flush
{
	// Since render states are used for keys, need to wrap the flush call in a pool.
	@autoreleasepool {
		[super flush];
	}
}

@end


@implementation CCRenderState {
	CCTexture *_mainTexture;
}

CCRenderStateCache *CCRENDERSTATE_CACHE = nil;
CCRenderState *CCRENDERSTATE_DEBUGCOLOR = nil;

+(void)initialize
{
	CCRENDERSTATE_CACHE = [[CCRenderStateCache alloc] init];
	CCRENDERSTATE_DEBUGCOLOR = [[self alloc] initWithBlendMode:CCBLEND_DISABLED shader:[CCShader positionColorShader] shaderUniforms:@{}];
}

-(instancetype)initWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader shaderUniforms:(NSDictionary *)shaderUniforms
{
	if((self = [super init])){
		_blendMode = blendMode;
		_shader = shader;
		_shaderUniforms = shaderUniforms;
	}
	
	return self;
}

+(instancetype)renderStateWithBlendMode:(CCBlendMode *)blendMode shader:(CCShader *)shader mainTexture:(CCTexture *)mainTexture;
{
	if(mainTexture == nil){
		CCLOGWARN(@"nil Texture passed to CCRenderState");
		mainTexture = [CCTexture none];
	}
	
	CCRenderState *renderState = [[self alloc] initWithBlendMode:blendMode shader:shader shaderUniforms:@{CCShaderUniformMainTexture: mainTexture}];
	renderState->_mainTexture = mainTexture;
	
	return [CCRENDERSTATE_CACHE objectForKey:renderState];
}

-(id)copyWithZone:(NSZone *)zone
{
	if([_shaderUniforms isKindOfClass:[NSMutableDictionary class]]){
		return [[CCRenderState allocWithZone:zone] initWithBlendMode:_blendMode shader:_shader shaderUniforms:[_shaderUniforms copy]];
	} else {
		return self;
	}
}

-(NSUInteger)hash
{
	NSAssert(_mainTexture, @"Attempting to cache a renderstate without a mainTexture value.");
	
	// Not great, but acceptable. All values are unique by pointer.
	return ((NSUInteger)_blendMode ^ (NSUInteger)_shader ^ (NSUInteger)_mainTexture);
}

-(BOOL)isEqual:(id)object
{
	CCRenderState *other = object;
	
	return (
		[other isKindOfClass:[CCRenderState class]] &&
		_blendMode == other->_blendMode &&
		_shader == other->_shader &&
		_mainTexture == other->_mainTexture
	);
}

+(instancetype)debugColor
{
	return CCRENDERSTATE_DEBUGCOLOR;
}

@end


//MARK: Render Command Protocol


@protocol CCRenderCommand <NSObject>
-(void)invoke:(CCRenderer *)renderer;
@end


//MARK: Draw Command.


@interface CCRenderCommandDraw : NSObject<CCRenderCommand>
@property(nonatomic, readonly) GLint first;
@property(nonatomic, readonly) GLsizei elements;
@end


@implementation CCRenderCommandDraw {
	GLenum _mode;
	
	@public
	CCRenderState *_renderState;
	CCVertexArray *_array;
}

-(instancetype)initWithMode:(GLenum)mode renderState:(CCRenderState *)renderState array:(CCVertexArray *)array first:(GLint)first elements:(GLsizei)elements
{
	if((self = [super init])){
		_mode = mode;
		_renderState = [renderState copy];
		_array = array;
		_first = first;
		_elements = elements;
	}
	
	return self;
}

-(void)batchElements:(GLsizei)elements
{
	_elements += elements;
}

-(void)invoke:(CCRenderer *)renderer
{
	glPushGroupMarkerEXT(0, "CCRendererCommandDraw: Invoke");
	
	[renderer bindVertexArray:_array];
	[renderer setRenderState:_renderState];
	glDrawElements(_mode, _elements, GL_UNSIGNED_SHORT, (GLvoid *)(_first*sizeof(GLushort)));
	
	glPopGroupMarkerEXT();
}

@end


//MARK: Custom Block Command.


@interface CCRenderCommandCustom : NSObject<CCRenderCommand>
@end


@implementation CCRenderCommandCustom
{
	void (^_block)();
	NSString *_debugLabel;
}

-(instancetype)initWithBlock:(void (^)())block debugLabel:(NSString *)debugLabel
{
	if((self = [super init])){
		_block = block;
		_debugLabel = debugLabel;
	}
	
	return self;
}

-(void)invoke:(CCRenderer *)renderer
{
	glPushGroupMarkerEXT(0, [NSString stringWithFormat:@"CCRenderCommandCustom(%@): Invoke", _debugLabel].UTF8String);
	
	[renderer bindVertexArray:nil];
	_block();
	
	glPopGroupMarkerEXT();
}

@end


//MARK: Vertex Array


@interface CCVertexArray : NSObject @end
@implementation CCVertexArray {
	@public
	GLuint _vbo;
	GLuint _ebo;
	GLuint _vao;
	
	GLsync _sync;
	
	CCVertex *_vertexes;
	GLsizei _vertexCount, _vertexCapacity;
	
	GLushort *_elements;
	GLsizei _elementCount, _elementCapacity;
}

-(id)initWithVertexes:(NSUInteger)vertexes elements:(NSUInteger)elements
{
	if((self = [super init])){
		_vertexCapacity = (GLsizei)vertexes;
		_elementCapacity = (GLsizei)elements;
//		NSLog(@"CCVertexArray: Initialized with %d vertexes and %d elements.", _vertexCapacity, _elementCapacity);
		
		glPushGroupMarkerEXT(0, "CCVertexArray: Init");
		
		glGenVertexArrays(1, &_vao);
		glBindVertexArray(_vao);
		
		glEnableVertexAttribArray(CCShaderAttributePosition);
		glEnableVertexAttribArray(CCShaderAttributeTexCoord1);
		glEnableVertexAttribArray(CCShaderAttributeTexCoord2);
		glEnableVertexAttribArray(CCShaderAttributeColor);
		
		glGenBuffers(1, &_vbo);
		glBindBuffer(GL_ARRAY_BUFFER, _vbo);
		glBufferData(GL_ARRAY_BUFFER, _vertexCapacity*sizeof(*_vertexes), NULL, GL_DYNAMIC_DRAW);
		
		glVertexAttribPointer(CCShaderAttributePosition, 4, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, position));
		glVertexAttribPointer(CCShaderAttributeTexCoord1, 2, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, texCoord1));
		glVertexAttribPointer(CCShaderAttributeTexCoord2, 2, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, texCoord2));
		glVertexAttribPointer(CCShaderAttributeColor, 4, GL_FLOAT, GL_FALSE, sizeof(CCVertex), (void *)offsetof(CCVertex, color));
		
		glGenBuffers(1, &_ebo);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ebo);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, _elementCapacity*sizeof(*_elements), NULL, GL_DYNAMIC_DRAW);
		
		glBindVertexArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		
		glPopGroupMarkerEXT();
		CC_CHECK_GL_ERROR_DEBUG();
		
		[self map];
	}
	
	return self;
}

-(void)dealloc
{
	glPushGroupMarkerEXT(0, "CCVertexArray: Dealloc");
	
//	NSLog(@"Deleting %d %d %d", _vao, _vbo, _ebo);
	glDeleteVertexArrays(1, &_vao);
	glDeleteBuffers(1, &_vbo);
	glDeleteBuffers(1, &_ebo);
	
	glPopGroupMarkerEXT();
}

-(CCRenderBuffer)bufferVertexes:(NSUInteger)vertexCount elementCount:(NSUInteger)elementCount;
{
	NSAssert(_vertexes && _elements, @"CCVertexArray Error: Buffers are not mapped.");
	CCRenderBuffer buffer = {
		_vertexes + _vertexCount,
		_elements + _elementCount,
		_vertexCount
	};
	
	_vertexCount += vertexCount;
	_elementCount += elementCount;
	
	return buffer;
}

-(void)unmap
{
	_vertexes = NULL;
	_elements = NULL;
	
	glPushGroupMarkerEXT(0, "CCVertexArray: Unmapping buffers.");
	
	glBindBuffer(GL_ARRAY_BUFFER, _vbo);
	glFlushMappedBufferRangeEXT(GL_ARRAY_BUFFER, 0, _vertexCount*sizeof(*_vertexes));
	glUnmapBufferOES(GL_ARRAY_BUFFER);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ebo);
	glFlushMappedBufferRangeEXT(GL_ELEMENT_ARRAY_BUFFER, 0, _elementCount*sizeof(*_elements));
	glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	
	glPopGroupMarkerEXT();
	CC_CHECK_GL_ERROR_DEBUG();
}

-(void)sync
{
	_sync = glFenceSyncAPPLE(GL_SYNC_GPU_COMMANDS_COMPLETE_APPLE, 0);
}

-(BOOL)map
{
	if(_sync == NULL || glClientWaitSyncAPPLE(_sync, GL_SYNC_FLUSH_COMMANDS_BIT_APPLE, 0) == GL_ALREADY_SIGNALED_APPLE){
		NSAssert(!_vertexes && !_elements, @"CCVertexArray Error: Buffers are already mapped.");
		
		_vertexCount = 0;
		_elementCount = 0;
		
		const GLbitfield accessModifiers = 
			GL_MAP_WRITE_BIT_EXT |
			GL_MAP_INVALIDATE_BUFFER_BIT_EXT |
			GL_MAP_FLUSH_EXPLICIT_BIT_EXT |
			GL_MAP_UNSYNCHRONIZED_BIT_EXT;
		
		glPushGroupMarkerEXT(0, "CCVertexArray: Mapping buffers.");
		
		glBindBuffer(GL_ARRAY_BUFFER, _vbo);
		_vertexes = glMapBufferRangeEXT(GL_ARRAY_BUFFER, 0, _vertexCapacity*sizeof(*_vertexes), accessModifiers);
		//_vertexes = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ebo);
		_elements = glMapBufferRangeEXT(GL_ELEMENT_ARRAY_BUFFER, 0, _elementCapacity*sizeof(*_elements), accessModifiers);
		//_elements = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		
		glPopGroupMarkerEXT();
		CC_CHECK_GL_ERROR_DEBUG();
		
		glDeleteSyncAPPLE(_sync);
		_sync = NULL;
		return YES;
	} else {
		return NO;
	}
}

@end


//MARK: Render Queue


@implementation CCRenderer {
	CCRenderState *_renderState;
	NSDictionary *_blendOptions;
	
	CCShader *_shader;
	NSDictionary *_shaderUniforms;
	
	CCVertexArray *_currentArray;
	NSMutableArray *_pooledArrays;
	NSMutableArray *_queuedArrays;
	NSMutableArray *_busyArrays;
	
	CCVertexArray *_boundArray;
	
	NSMutableArray *_queue;
	__unsafe_unretained CCRenderCommandDraw *_lastDrawCommand;
	
	NSUInteger _statDrawCommands;
}

-(void)invalidateState
{
	_lastDrawCommand = nil;
	_renderState = nil;
	_blendOptions = nil;
	_shader = nil;
	_shaderUniforms = nil;
	_boundArray = nil;
}

-(instancetype)init
{
	if((self = [super init])){
		_queue = [NSMutableArray array];
		
		_pooledArrays = [NSMutableArray array];
		_queuedArrays = [NSMutableArray array];
		_busyArrays = [NSMutableArray array];
	}
	
	return self;
}

static NSString *CURRENT_RENDERER_KEY = @"CCRendererCurrent";

+(instancetype)currentRenderer
{
	return [NSThread currentThread].threadDictionary[CURRENT_RENDERER_KEY];
}

+(void)bindRenderer:(CCRenderer *)renderer
{
	if(renderer){
		NSAssert(self.currentRenderer == nil, @"Internal Error: Already have a renderer bound.");
		[NSThread currentThread].threadDictionary[CURRENT_RENDERER_KEY] = renderer;
	} else {
		[[NSThread currentThread].threadDictionary removeObjectForKey:CURRENT_RENDERER_KEY];
	}
}

-(void)setGlobalShaderUniforms:(NSDictionary *)globalShaderUniforms
{
	_globalShaderUniforms = [globalShaderUniforms copy];
	[self invalidateState];
}

#if defined(__CC_PLATFORM_IOS)
#define glBindVertexArray glBindVertexArrayOES
#endif

-(void)bindVertexArray:(CCVertexArray *)array
{
	if(array != _boundArray){
		glInsertEventMarkerEXT(0, "CCRenderer: Bind VAO");
		glBindVertexArray(array ? array->_vao : 0);
		
		_boundArray = array;
	}
}

-(void)setRenderState:(CCRenderState *)renderState
{
	if(renderState == _renderState) return;
	
	glPushGroupMarkerEXT(0, "CCRenderer: Render State");
	
	// Set the blending state.
	__unsafe_unretained NSDictionary *blendOptions = renderState->_blendMode->_options;
	if(blendOptions != _blendOptions){
		glInsertEventMarkerEXT(0, "Blending mode");
		
		if(blendOptions == CCBLEND_DISABLED_OPTIONS){
			if(_blendOptions != CCBLEND_DISABLED_OPTIONS) glDisable(GL_BLEND);
		} else {
			if(_blendOptions == nil || _blendOptions == CCBLEND_DISABLED_OPTIONS) glEnable(GL_BLEND);
			
			glBlendFuncSeparate(
				[blendOptions[CCBlendFuncSrcColor] unsignedIntValue],
				[blendOptions[CCBlendFuncDstColor] unsignedIntValue],
				[blendOptions[CCBlendFuncSrcAlpha] unsignedIntValue],
				[blendOptions[CCBlendFuncDstAlpha] unsignedIntValue]
			);
			
			glBlendEquationSeparate(
				[blendOptions[CCBlendEquationColor] unsignedIntValue],
				[blendOptions[CCBlendEquationAlpha] unsignedIntValue]
			);
		}
		
		_blendOptions = blendOptions;
	}
	
	// Bind the shader.
	__unsafe_unretained CCShader *shader = renderState->_shader;
	if(shader != _shader){
		glInsertEventMarkerEXT(0, "Shader");
		
		glUseProgram(shader->_program);
		
		_shader = shader;
		_shaderUniforms = nil;
	}
	
	// Set the shader's uniform state.
	__unsafe_unretained NSDictionary *shaderUniforms = renderState->_shaderUniforms;
	if(shaderUniforms != _shaderUniforms){
		glInsertEventMarkerEXT(0, "Uniforms");
		
		__unsafe_unretained NSDictionary *setters = shader->_uniformSetters;
		for(NSString *uniformName in setters){
			__unsafe_unretained CCUniformSetter setter = setters[uniformName];
			setter(self, shaderUniforms[uniformName] ?: _globalShaderUniforms[uniformName]);
		}
		_shaderUniforms = shaderUniforms;
	}
	
	CC_CHECK_GL_ERROR_DEBUG();
	glPopGroupMarkerEXT();
	
	_renderState = renderState;
	return;
}

-(void)enqueueClear:(GLbitfield)mask color:(GLKVector4)color4 depth:(GLclampf)depth stencil:(GLint)stencil
{
	[self enqueueBlock:^{
		if(mask & GL_COLOR_BUFFER_BIT) glClearColor(color4.r, color4.g, color4.b, color4.a);
		if(mask & GL_DEPTH_BUFFER_BIT) glClearDepth(depth);
		if(mask & GL_STENCIL_BUFFER_BIT) glClearStencil(stencil);
		
		glClear(mask);
	} debugLabel:@"CCRenderer: Clear"];
}

-(CCVertexArray *)arrayForVertexes:(GLsizei)vertexes andElements:(GLsizei)elements
{
	if(_currentArray == nil){
		// Search for an empty array large enough in the pool.
		for(CCVertexArray *array in _pooledArrays){
			if(array->_vertexCapacity >= vertexes && array->_elementCapacity >= elements){
				_currentArray = array;
				break;
			}
		}
		
		if(_currentArray){
			// Remove the found array from the pool.
			[_pooledArrays removeObject:_currentArray];
		} else {
			// No empty array found that was large enough.
			const NSUInteger sprites = 1024;
			NSUInteger vertexCapacity = MAX(sprites*4, vertexes);
			NSUInteger elementCapacity = MAX(sprites*8, elements);
			_currentArray = [[CCVertexArray alloc] initWithVertexes:vertexCapacity elements:elementCapacity];
		}
	} else if(_currentArray->_vertexCount + vertexes > _currentArray->_vertexCapacity || _currentArray->_elementCount + elements > _currentArray->_elementCapacity){
		// Current array is not large enough. Reset and try again.
		[_queuedArrays addObject:_currentArray];
		_currentArray = nil;
		[self arrayForVertexes:vertexes andElements:elements];
		
		// Also reset the last command to force the next drawing op to be un-batched.
		_lastDrawCommand = nil;
	}
	
	return _currentArray;
}

-(CCRenderBuffer)enqueueTriangles:(NSUInteger)triangleCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState;
{
	GLsizei elementCount = 3*(GLsizei)triangleCount;
	__unsafe_unretained CCVertexArray *array = [self arrayForVertexes:(GLsizei)vertexCount andElements:elementCount];
	__unsafe_unretained CCRenderCommandDraw *previous = _lastDrawCommand;
	
	//TODO doesn't check array
	if(previous && previous->_renderState == renderState){
		// Batch with the previous command.
		[previous batchElements:(GLsizei)(3*triangleCount)];
	} else {
		// Start a new command.
		CCRenderCommandDraw *command = [[CCRenderCommandDraw alloc] initWithMode:GL_TRIANGLES renderState:renderState array:array first:(GLint)array->_elementCount elements:elementCount];
		[_queue addObject:command];
		_lastDrawCommand = command;
	}
	
	_statDrawCommands++;
	return [array bufferVertexes:vertexCount elementCount:elementCount];
}

-(CCRenderBuffer)enqueueLines:(NSUInteger)lineCount andVertexes:(NSUInteger)vertexCount withState:(CCRenderState *)renderState;
{
	GLsizei elementCount = 3*(GLsizei)lineCount;
	__unsafe_unretained CCVertexArray *array = [self arrayForVertexes:(GLsizei)vertexCount andElements:elementCount];
	__unsafe_unretained CCRenderCommandDraw *previous = _lastDrawCommand;
	
	CCRenderCommandDraw *command = [[CCRenderCommandDraw alloc] initWithMode:GL_TRIANGLES renderState:renderState array:array first:(GLint)array->_elementCount elements:elementCount];
	[_queue addObject:command];
	
	// Line drawing commands are currently intended for debugging and cannot be batched.
	_lastDrawCommand = nil;
	
	_statDrawCommands++;
	return [array bufferVertexes:vertexCount elementCount:elementCount];
}

-(void)enqueueBlock:(void (^)())block debugLabel:(NSString *)debugLabel
{
	[_queue addObject:[[CCRenderCommandCustom alloc] initWithBlock:block debugLabel:debugLabel]];
	_lastDrawCommand = nil;
}

-(void)enqueueMethod:(SEL)selector target:(id)target
{
	[self enqueueBlock:^{
    typedef void (*Func)(id, SEL);
    ((Func)objc_msgSend)(target, selector);
	} debugLabel:NSStringFromSelector(selector)];
}

-(void)flush
{
//	NSLog(@"Flush");
	
	[_queuedArrays addObject:_currentArray];
	_currentArray = nil;
	
	// Unbind the arrays.
	for(CCVertexArray *array in _queuedArrays) [array unmap];
	
	glPushGroupMarkerEXT(0, "CCRenderer: Flush");
	
	// Execute rendering commands.
	for(CCRenderCommandDraw *command in _queue) [command invoke:self];
	[_queue removeAllObjects];
	
	// Need to unbind the VAO before fiddling with the buffers.
	[self bindVertexArray:nil];
	
	// Add a fence sync object to all of the newly queued arrays so we know when they are ready again.
	for(CCVertexArray *array in _queuedArrays) [array sync];
	
	// Attempt to remap some of the busy array.
	for(CCVertexArray *array in [_busyArrays copy]){
		if([array map]){
			[_pooledArrays addObject:array];
			[_busyArrays removeObject:array];
		}
	}
	
	glPopGroupMarkerEXT();
	CC_CHECK_GL_ERROR_DEBUG();
	
	// Mark the queued arrays as busy since we just submitted them to the GPU
	[_busyArrays addObjectsFromArray:_queuedArrays];
	[_queuedArrays removeAllObjects];
	
	_statDrawCommands = 0;
	
//	CC_INCREMENT_GL_DRAWS(1);
}

@end
