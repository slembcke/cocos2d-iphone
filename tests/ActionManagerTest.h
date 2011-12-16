#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	
	UIViewController *viewController_;		// weak ref
	UINavigationController *navigationController_;	// weak ref
}
@property (nonatomic, retain) UIWindow *window;
@property (readonly) UIViewController *viewController;
@property (readonly) UINavigationController *navigationController;
@end

@interface ActionManagerTest: CCLayer
{
    CCTextureAtlas *atlas;
}
-(NSString*) title;
-(NSString*) subtitle;

@end

@interface CrashTest : ActionManagerTest
{
}
@end

@interface LogicTest : ActionManagerTest
{
}
@end


@interface PauseTest : ActionManagerTest
{
}
@end

@interface RemoveTest : ActionManagerTest
{
}
@end

@interface Issue835 : ActionManagerTest
{
}
@end

