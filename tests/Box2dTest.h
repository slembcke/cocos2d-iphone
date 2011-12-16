//
// cocos2d
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"


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

@interface MainLayer : CCLayer {
	
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
}
@end

@interface PhysicsSprite : CCSprite
{
	b2Body *body_;	// strong ref
}

-(void) setPhysicsBody:(b2Body*)body;

@end