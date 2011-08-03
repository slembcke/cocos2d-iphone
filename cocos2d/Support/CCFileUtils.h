/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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
 *
 */


#import <Foundation/Foundation.h>


/** Helper class to handle file operations */
@interface CCFileUtils : NSObject
{
}

/** Returns the fullpath of an filename.
 
 If this method is when Retina Display is enabled, then the
 Retina Display suffix will be appended to the file (See ccConfig.h).
 
 If the Retina Display image doesn't exist, then it will return the "non-Retina Display" image
 
 */
+(NSString*) fullPathFromRelativePath:(NSString*) relPath;

/** Sets the RetinaDisplay suffix to load resources.
 By default it is "-hd".
 Only valid on iOS. Not valid for OS X.
 
 @since v1.1
 */
+(void) setRetinaDisplaySuffix:(NSString*)suffix;

/** Sets the iPad suffix to load resources.
 By default it is "".
 Only valid on iOS. Not valid for OS X.
 
 @since v1.1
 */
+(void) setiPadSuffix:(NSString*)suffix;

/** Returns whether or not a given filename exists with the iPad suffix.
 Only available on iOS. Not supported on OS X.
 @since v1.1
 */
+(BOOL) iPadFileExistsAtPath:(NSString*)filename;

/** Returns whether or not a given path exists with the RetinaDisplay suffix.
 Only available on iOS. Not supported on OS X.
 @since v1.1
 */
+(BOOL) retinaDisplayFileExistsAtPath:(NSString*)filename;

@end

/** loads a file into memory.
 the caller should release the allocated buffer.
 
 @returns the size of the allocated buffer
 @since v0.99.5
 */
NSInteger ccLoadFileIntoMemory(const char *filename, unsigned char **out);


/** removes the Device suffix from a path
  * On RetinaDisplay it will remove the -hd suffix
  * On iPad it will remove the -ipad suffix
  * On iPhone it will remove the (empty) suffx
 
 @returns NSString * without the HD suffix
 @since v0.99.5
 */
NSString *ccRemoveDeviceSuffixFromFile( NSString *path );

