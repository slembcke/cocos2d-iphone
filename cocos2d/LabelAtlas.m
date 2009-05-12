/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "LabelAtlas.h"


@implementation LabelAtlas

#pragma mark LabelAtlas - Creation & Init
+(id) labelAtlasWithString:(NSString*) string charMapFile: (NSString*) charmapfile itemWidth:(int)w itemHeight:(int)h startCharMap:(char)c
{
	return [[[self alloc] initWithString:string charMapFile:charmapfile itemWidth:w itemHeight:h startCharMap:c] autorelease];
}


-(id) initWithString:(NSString*) theString charMapFile: (NSString*) charmapfile itemWidth:(int)w itemHeight:(int)h startCharMap:(char)c
{

	if (! (self=[super initWithTileFile:charmapfile tileWidth:w tileHeight:h itemsToRender:[theString length] ]) )
		return nil;

	string = [theString retain];
	mapStartChar = c;	
	
	[self updateAtlasValues];

	return self;
}

-(void) dealloc
{
	[string release];

	[super dealloc];
}

#pragma mark LabelAtlas - Atlas generation

-(void) updateAtlasValues
{
	int n = [string length];
	
	ccQuad2 texCoord;
	ccQuad3 vertex;

	const char *s = [string UTF8String];

	for( int i=0; i<n; i++) {
		char a = s[i] - mapStartChar;
		float row = (a % itemsPerRow) * texStepX;
		float col = (a / itemsPerRow) * texStepY;
		
		texCoord.bl.x = row;						// A - x
		texCoord.bl.y = col;						// A - y
		texCoord.br.x = row + texStepX;				// B - x
		texCoord.br.y = col;						// B - y
		texCoord.tl.x = row;						// C - x
		texCoord.tl.y = col + texStepY;				// C - y
		texCoord.tr.x = row + texStepX;				// D - x
		texCoord.tr.y = col + texStepY;				// D - y
		
		vertex.bl.x = (int)(i * itemWidth);			// A - x
		vertex.bl.y = 0;							// A - y
		vertex.bl.z = 0;							// A - z
		vertex.br.x = (int)(i * itemWidth + itemWidth);	// B - x
		vertex.br.y = 0;							// B - y
		vertex.br.z = 0;							// B - z
		vertex.tl.x = (int)(i * itemWidth);			// C - x
		vertex.tl.y = (int)itemHeight;				// C - y
		vertex.tl.z = 0;							// C - z
		vertex.tr.x = (int)(i * itemWidth + itemWidth);	// D - x
		vertex.tr.y = (int)itemHeight;				// D - y
		vertex.tr.z = 0;							// D - z
		
		[textureAtlas_ updateQuadWithTexture:&texCoord vertexQuad:&vertex atIndex:i];
	}
}

- (void) setString:(NSString*) newString
{
	if( newString.length > textureAtlas_.totalQuads )
		[textureAtlas_ resizeCapacity: newString.length];

	[string release];
	string = [newString retain];
	[self updateAtlasValues];
}


#pragma mark LabelAtlas - draw
- (void) draw
{
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	
	glEnable( GL_TEXTURE_2D);
	
	glColor4ub( r, g, b, opacity);
	
	[textureAtlas_ drawNumberOfQuads: string.length];
	
	// is this chepear than saving/restoring color state ?
	glColor4ub( 255, 255, 255, 255);
	
	glDisable( GL_TEXTURE_2D);
	
	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}


#pragma mark LabelAtlas - protocol related

-(CGSize) contentSize
{
	CGSize s;
	s.width = [string length] * itemWidth;
	s.height = itemHeight;
	return s;
}
@end
