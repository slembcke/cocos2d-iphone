#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class Menu;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
}
@end


@interface Layer1 : Layer
{
	Menu * menu;
}
-(void) onOptions: (id) sender;
-(void) onVoid: (id) sender;
-(void) onQuit: (id) sender;
@end

@interface Layer2 : Layer
{
	Menu * menu;
}
-(void) onGoBack: (id) sender;
-(void) onFullscreen: (id) sender;
@end

@interface Layer3: ColorLayer
{
}
@end

