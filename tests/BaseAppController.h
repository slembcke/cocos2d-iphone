//
//  AppController.h
//  cocos2d-ios
//
//  Created by Ricardo Quesada on 12/17/11.
//  Copyright (c) 2011 Sapus Media. All rights reserved.
//

#import <Availability.h>

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import <Foundation/Foundation.h>

@class CCDirector;

@interface BaseAppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;

	UINavigationController *rootViewController_;	// weak ref
	CCDirector	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *rootViewController;
@property (readonly) CCDirector *director;

@end

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
