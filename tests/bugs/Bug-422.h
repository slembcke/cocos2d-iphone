#import "cocos2d.h"

@class Menu;

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	
	UIViewController *viewController_;				// weak ref
	UINavigationController *navigationController_;	// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UIViewController *viewController;
@property (readonly) UINavigationController *navigationController;

@end

@interface Layer1 : CCLayer
{
}

-(void) reset;
-(void) check:(CCNode *)target;
-(void) menuCallback:(id) sender;
@end
