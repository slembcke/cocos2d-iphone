/*
* AUTOGENERATED FILE. DO NOT EDIT IT
* Generated by ../../tools/js/generate_spidermonkey_bindings.py on 2012-05-30
*/

// needed for callbacks from objective-c to JS
#import <objc/runtime.h>
#import "JRSwizzle.h"

#import "jstypedarray.h"
#import "ScriptingCore.h"   

#import "js_bindings_CCActionInterval.h"


JSClass* JSPROXY_CCActionInterval_class = NULL;
JSObject* JSPROXY_CCActionInterval_object = NULL;
 // Constructor
JSBool JSPROXY_CCActionInterval_constructor(JSContext *cx, uint32_t argc, jsval *vp)
{
    JSObject *jsobj = JS_NewObject(cx, JSPROXY_CCActionInterval_class, JSPROXY_CCActionInterval_object, NULL);

    JSPROXY_CCActionInterval *proxy = [[JSPROXY_CCActionInterval alloc] initWithJSObject:jsobj];

    JS_SetPrivate(jsobj, proxy);
    JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));

    /* no callbacks */
    
    return JS_TRUE;
}

// Destructor
void JSPROXY_CCActionInterval_finalize(JSContext *cx, JSObject *obj)
{
	JSPROXY_CCActionInterval *pt = (JSPROXY_CCActionInterval*)JS_GetPrivate(obj);
	if (pt) {
		// id real = [pt realObj];
	
		/* no callbacks */

		[pt release];

		JS_free(cx, pt);
	}
}

// Arguments: ccTime
// Ret value: CCActionInterval
JSBool JSPROXY_CCActionInterval_actionWithDuration_(JSContext *cx, uint32_t argc, jsval *vp) {
	NSCAssert( argc == 1, @"Invalid number of arguments" );
	double arg0; JS_ValueToNumber( cx, vp[2], &arg0 );

	CCActionInterval *real = [CCActionInterval actionWithDuration:(ccTime)arg0  ];

	JSObject *jsobj = JS_NewObject(cx, JSPROXY_CCActionInterval_class, JSPROXY_CCActionInterval_object, NULL);
	JSPROXY_CCActionInterval *ret_proxy = [[JSPROXY_CCActionInterval alloc] initWithJSObject:jsobj];
	[ret_proxy setRealObj: real];
	JS_SetPrivate(jsobj, ret_proxy);
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));

	return JS_TRUE;
}

// Arguments: 
// Ret value: ccTime
JSBool JSPROXY_CCActionInterval_elapsed(JSContext *cx, uint32_t argc, jsval *vp) {

	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = (JSPROXY_NSObject*) JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( [proxy realObj], @"Object not initialzied. error");
	NSCAssert( argc == 0, @"Invalid number of arguments" );
	ccTime ret_val;

	CCActionInterval *real = (CCActionInterval*) [proxy realObj];
	ret_val = [real elapsed ];
	JS_SET_RVAL(cx, vp, DOUBLE_TO_JSVAL(ret_val));
	return JS_TRUE;
}

// Arguments: ccTime
// Ret value: None
JSBool JSPROXY_CCActionInterval_initWithDuration_(JSContext *cx, uint32_t argc, jsval *vp) {

	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = (JSPROXY_NSObject*) JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( ![proxy realObj], @"Object not initialzied. error");
	NSCAssert( argc == 1, @"Invalid number of arguments" );
	double arg0; JS_ValueToNumber( cx, vp[2], &arg0 );

	CCActionInterval *real = [[CCActionInterval alloc] initWithDuration:(ccTime)arg0  ];
	[proxy setRealObj: real];
	[real release];

	JS_SET_RVAL(cx, vp, JSVAL_TRUE);
	return JS_TRUE;
}

// Arguments: 
// Ret value: BOOL
JSBool JSPROXY_CCActionInterval_isDone(JSContext *cx, uint32_t argc, jsval *vp) {

	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = (JSPROXY_NSObject*) JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( [proxy realObj], @"Object not initialzied. error");
	NSCAssert( argc == 0, @"Invalid number of arguments" );
	BOOL ret_val;

	CCActionInterval *real = (CCActionInterval*) [proxy realObj];
	ret_val = [real isDone ];
	JS_SET_RVAL(cx, vp, BOOLEAN_TO_JSVAL(ret_val));
	return JS_TRUE;
}

// Arguments: 
// Ret value: CCActionInterval*
JSBool JSPROXY_CCActionInterval_reverse(JSContext *cx, uint32_t argc, jsval *vp) {

	JSObject* obj = (JSObject *)JS_THIS_OBJECT(cx, vp);
	JSPROXY_NSObject *proxy = (JSPROXY_NSObject*) JS_GetPrivate( obj );
	NSCAssert( proxy, @"Invalid Proxy object");
	NSCAssert( [proxy realObj], @"Object not initialzied. error");
	NSCAssert( argc == 0, @"Invalid number of arguments" );
	CCActionInterval* ret_val;

	CCActionInterval *real = (CCActionInterval*) [proxy realObj];
	ret_val = [real reverse ];

	JSObject *jsobj = JS_NewObject(cx, JSPROXY_CCActionInterval_class, JSPROXY_CCActionInterval_object, NULL);
	JSPROXY_CCActionInterval *ret_proxy = [[JSPROXY_CCActionInterval alloc] initWithJSObject:jsobj];
	[ret_proxy setRealObj: ret_val];
	JS_SetPrivate(jsobj, ret_proxy);
	JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL(jsobj));

	return JS_TRUE;
}

@implementation JSPROXY_CCActionInterval

+(void) createClassWithContext:(JSContext*)cx object:(JSObject*)globalObj name:(NSString*)name
{
	JSPROXY_CCActionInterval_class = (JSClass *)calloc(1, sizeof(JSClass));
	JSPROXY_CCActionInterval_class->name = [name UTF8String];
	JSPROXY_CCActionInterval_class->addProperty = JS_PropertyStub;
	JSPROXY_CCActionInterval_class->delProperty = JS_PropertyStub;
	JSPROXY_CCActionInterval_class->getProperty = JS_PropertyStub;
	JSPROXY_CCActionInterval_class->setProperty = JS_StrictPropertyStub;
	JSPROXY_CCActionInterval_class->enumerate = JS_EnumerateStub;
	JSPROXY_CCActionInterval_class->resolve = JS_ResolveStub;
	JSPROXY_CCActionInterval_class->convert = JS_ConvertStub;
	JSPROXY_CCActionInterval_class->finalize = JSPROXY_CCActionInterval_finalize;
	JSPROXY_CCActionInterval_class->flags = JSCLASS_HAS_PRIVATE;

	static JSPropertySpec properties[] = {
		{0, 0, 0, 0, 0}
	};
	static JSFunctionSpec funcs[] = {
		JS_FN("elapsed", JSPROXY_CCActionInterval_elapsed, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FN("initWithDuration", JSPROXY_CCActionInterval_initWithDuration_, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FN("isDone", JSPROXY_CCActionInterval_isDone, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FN("reverse", JSPROXY_CCActionInterval_reverse, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FS_END
	};
	static JSFunctionSpec st_funcs[] = {
		JS_FN("actionWithDuration", JSPROXY_CCActionInterval_actionWithDuration_, 1, JSPROP_PERMANENT | JSPROP_SHARED),
		JS_FS_END
	};

	JSPROXY_CCActionInterval_object = JS_InitClass(cx, globalObj, JSPROXY_CCFiniteTimeAction_object, JSPROXY_CCActionInterval_class, JSPROXY_CCActionInterval_constructor,0,properties,funcs,NULL,st_funcs);
}

@end
