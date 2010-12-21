#import "cocos2d.h"

//CLASS INTERFACE
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
@interface cocos2dmacAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window;
}

- (IBAction)toggleFullScreen:(id)sender;

@end
#endif // Mac

@interface TestDemo : CCLayer
{
}
-(NSString*) title;
@end

@interface Test1 : TestDemo
{}
@end
