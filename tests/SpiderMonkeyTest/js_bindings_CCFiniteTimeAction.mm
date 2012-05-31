/*
* AUTOGENERATED FILE. DO NOT EDIT IT
* Generated by ../../tools/js/generate_spidermonkey_bindings.py on 2012-05-31
*/

// needed for callbacks from objective-c to JS
#import <objc/runtime.h>
#import "JRSwizzle.h"

#import "jstypedarray.h"
#import "ScriptingCore.h"   

#import "js_bindings_CCFiniteTimeAction.h"
#import "js_bindings_cocos2d.h"


JSClass* JSPROXY_CCFiniteTimeAction_class = NULL;
JSObject* JSPROXY_CCFiniteTimeAction_object = NULL;
 // Constructor
JSBool JSPROXY_CCFiniteTimeAction_constructor(JSContext *cx, uint32_t argc, jsval *vp)
{
    JSObject *jsobj = JS_NewObject(cx, JSPROXY_CCFiniteTimeAction_class, JSPROXY_CCFiniteTimeAction_object, NULL);

    JSPROXY_CCFiniteTimeAction *proxy = [[JSPROXY_CCFiniteTimeAction alloc] initWithJSObject:jsobj];

    JS_SetPrivate(jsobj, proxy);
    JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));

    /* no callbacks */
    
    return JS_TRUE;
}

// Destructor
void JSPROXY_CCFiniteTimeAction_finalize(JSContext *cx, JSObject *obj)
{
	JSPROXY_CCFiniteTimeAction *pt = (JSPROXY_CCFiniteTimeAction*)JS_GetPrivate(obj);
	if (pt) {
		// id real = [pt realObj];
	
		/* no callbacks */

		[pt release];

		JS_free(cx, pt);
	}
}

// Arguments: 
// Ret value: ccTime
JSBool JSPROXY_CCFiniteTimeAction_duration(JSContext *cx, uint32_t argc, jsval *vp) {

	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = (JSPROXY_NSObject*) JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( [proxy realObj], @"Object not initialzied. error");
	NSCAssert( argc == 0, @"Invalid number of arguments" );
	ccTime ret_val;

	CCFiniteTimeAction *real = (CCFiniteTimeAction*) [proxy realObj];
	ret_val = [real duration ];
	JS_SET_RVAL(cx, vp, DOUBLE_TO_JSVAL(ret_val));
	return JS_TRUE;
}

// Arguments: 
// Ret value: CCFiniteTimeAction*
JSBool JSPROXY_CCFiniteTimeAction_reverse(JSContext *cx, uint32_t argc, jsval *vp) {

	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = (JSPROXY_NSObject*) JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( [proxy realObj], @"Object not initialzied. error");
	NSCAssert( argc == 0, @"Invalid number of arguments" );
	CCFiniteTimeAction* ret_val;

	CCFiniteTimeAction *real = (CCFiniteTimeAction*) [proxy realObj];
	ret_val = [real reverse ];

	JSObject *jsobj = JS_NewObject(cx, JSPROXY_CCFiniteTimeAction_class, JSPROXY_CCFiniteTimeAction_object, NULL);
	JSPROXY_CCFiniteTimeAction *ret_proxy = [[JSPROXY_CCFiniteTimeAction alloc] initWithJSObject:jsobj];
	[ret_proxy setRealObj: ret_val];
	JS_SetPrivate(jsobj, ret_proxy);
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));

	return JS_TRUE;
}

// Arguments: ccTime
// Ret value: None
JSBool JSPROXY_CCFiniteTimeAction_setDuration_(JSContext *cx, uint32_t argc, jsval *vp) {

	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = (JSPROXY_NSObject*) JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( [proxy realObj], @"Object not initialzied. error");
	NSCAssert( argc == 1, @"Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	double arg0; JS_ValueToNumber( cx, *argvp++, &arg0 );

	CCFiniteTimeAction *real = (CCFiniteTimeAction*) [proxy realObj];
	[real setDuration:(ccTime)arg0  ];
	JS_SET_RVAL(cx, vp, JSVAL_TRUE);
	return JS_TRUE;
}

@implementation JSPROXY_CCFiniteTimeAction

+(void) createClassWithContext:(JSContext*)cx object:(JSObject*)globalObj name:(NSString*)name
{
	JSPROXY_CCFiniteTimeAction_class = (JSClass *)calloc(1, sizeof(JSClass));
	JSPROXY_CCFiniteTimeAction_class->name = [name UTF8String];
	JSPROXY_CCFiniteTimeAction_class->addProperty = JS_PropertyStub;
	JSPROXY_CCFiniteTimeAction_class->delProperty = JS_PropertyStub;
	JSPROXY_CCFiniteTimeAction_class->getProperty = JS_PropertyStub;
	JSPROXY_CCFiniteTimeAction_class->setProperty = JS_StrictPropertyStub;
	JSPROXY_CCFiniteTimeAction_class->enumerate = JS_EnumerateStub;
	JSPROXY_CCFiniteTimeAction_class->resolve = JS_ResolveStub;
	JSPROXY_CCFiniteTimeAction_class->convert = JS_ConvertStub;
	JSPROXY_CCFiniteTimeAction_class->finalize = JSPROXY_CCFiniteTimeAction_finalize;
	JSPROXY_CCFiniteTimeAction_class->flags = JSCLASS_HAS_PRIVATE;

	static JSPropertySpec properties[] = {
		{0, 0, 0, 0, 0}
	};
	static JSFunctionSpec funcs[] = {
		JS_FN("duration", JSPROXY_CCFiniteTimeAction_duration, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FN("reverse", JSPROXY_CCFiniteTimeAction_reverse, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FN("setDuration", JSPROXY_CCFiniteTimeAction_setDuration_, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FS_END
	};
	static JSFunctionSpec st_funcs[] = {
		JS_FS_END
	};

	JSPROXY_CCFiniteTimeAction_object = JS_InitClass(cx, globalObj, JSPROXY_CCAction_object, JSPROXY_CCFiniteTimeAction_class, JSPROXY_CCFiniteTimeAction_constructor,0,properties,funcs,NULL,st_funcs);
}

@end
