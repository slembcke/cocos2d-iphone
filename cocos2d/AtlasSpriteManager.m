/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2009 Matt Oswald
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <assert.h>
#import "AtlasSprite.h"
#import "AtlasSpriteManager.h"

const int defaultCapacity = 10;

#pragma mark AtlasSprite

@interface AtlasSprite (Remove)
-(void)setIndex:(int)index;
@end

@implementation AtlasSprite (Remove)
-(void)setIndex:(int)index
{
	mAtlasIndex = index;
	[self updateAtlas];
}
@end


#pragma mark AtlasSpriteManager
@implementation AtlasSpriteManager

@synthesize atlas = mAtlas;

-(void)dealloc
{	
	[mAtlas release];

	[super dealloc];
}

/*
 * creation with Texture2D
 */
+(id)spriteManagerWithTexture:(Texture2D *)tex
{
	return [[[AtlasSpriteManager alloc] initWithTexture:tex capacity:defaultCapacity] autorelease];
}

+(id)spriteManagerWithTexture:(Texture2D *)tex capacity:(NSUInteger)capacity
{
	return [[[AtlasSpriteManager alloc] initWithTexture:tex capacity:capacity] autorelease];
}

/*
 * creation with File Image
 */
+(id)spriteManagerWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity
{
	return [[[AtlasSpriteManager alloc] initWithFile:fileImage capacity:capacity] autorelease];
}

+(id)spriteManagerWithFile:(NSString*) imageFile
{
	return [[[AtlasSpriteManager alloc] initWithFile:imageFile capacity:defaultCapacity] autorelease];
}


/*
 * init with Texture2D
 */
-(id)initWithTexture:(Texture2D *)tex capacity:(NSUInteger)capacity
{
	if( (self=[super init])) {
		mTotalSprites = 0;
		mAtlas = [[TextureAtlas alloc] initWithTexture:tex capacity:capacity];
		
		// no lazy alloc in this node
		children = [[NSMutableArray alloc] initWithCapacity:capacity];
	}

	return self;
}

/*
 * init with FileImage
 */
-(id)initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity
{
	if( (self=[super init]) ) {
		mTotalSprites = 0;
		mAtlas = [[TextureAtlas alloc] initWithFile:fileImage capacity:capacity];
		
		// no lazy alloc in this node
		children = [[NSMutableArray alloc] initWithCapacity:capacity];
	}
	
	return self;
}


#pragma mark AtlasSpriteManager - composition

-(int)indexForNewChild
{
	// if we're going beyond the current TextureAtlas's capacity,
	// all the previously initialized sprites will need to redo their texture coords
	// this is likely computationally expensive
	if(mTotalSprites == mAtlas.totalQuads)
	{
		CCLOG(@"Resizing TextureAtlas capacity, from [%d] to [%d].", mAtlas.totalQuads, mAtlas.totalQuads * 3 / 2);

		[mAtlas resizeCapacity:mAtlas.totalQuads * 3 / 2];
		
		for(AtlasSprite *sprite in children)
		{
			[sprite updateAtlas];
		}
	}

	return mTotalSprites;
}

-(AtlasSprite*) createSpriteWithRect:(CGRect)rect
{
	return [AtlasSprite spriteWithRect:rect spriteManager:self];
}

-(id) addChild:(AtlasSprite*) node
{
	[node setIndex: [self indexForNewChild] ];

	mTotalSprites++;
	return [super add:node];
}

-(void)removeChild: (AtlasSprite *)sprite
{
	int index= sprite.atlasIndex;
	[super remove:sprite];

	// update all sprites beyond this one
	int count = [children count];
	for(; index < count; index++)
	{
		AtlasSprite *other = (AtlasSprite *)[children objectAtIndex:index];
		NSAssert([other atlasIndex] == index + 1, @"AtlasSpriteManager: index failed");
		[other setIndex:index];
	}	
	mTotalSprites--;
}

-(void)removeChildAtIndex:(NSUInteger)index
{
	[self removeChild:(AtlasSprite *)[children objectAtIndex:index]];
}

-(void)removeAllChildren
{
	[super removeAll];
	mTotalSprites = 0;
}

#pragma mark AtlasSpriteManager - draw
-(void)draw
{
	if(mTotalSprites > 0)
	{
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);

		glEnable(GL_TEXTURE_2D);

		[mAtlas drawNumberOfQuads:mTotalSprites];

		glDisable(GL_TEXTURE_2D);

		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
}

@end
