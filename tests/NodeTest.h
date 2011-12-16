
@class CCSprite;

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
@interface TestDemo : CCLayer
{}
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface Test2 : TestDemo
{}
@end

@interface Test4 : TestDemo
{}
@end

@interface Test5 : TestDemo
{}
@end

@interface Test6 : TestDemo
{}
@end

@interface StressTest1 : TestDemo
{}
@end

@interface StressTest2 : TestDemo
{}
@end

@interface SchedulerTest1 : TestDemo
{}
@end

@interface NodeToWorld : TestDemo
{}
@end

@interface CameraOrbitTest : TestDemo
{}
@end

@interface CameraZoomTest : TestDemo
{
	float z_;
}
@end

@interface CameraCenterTest : TestDemo
{}
@end

@interface ConvertToNode : TestDemo
{}
@end

@interface CCArrayTest : TestDemo
{}
@end

@interface NodeOpaqueTest : TestDemo
{}
@end

@interface NodeNonOpaqueTest : TestDemo
{}
@end
