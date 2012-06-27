//
// http://www.cocos2d-iphone.org
//
// Javascript + cocos2d label tests
//

require("javascript-spidermonkey/helper.js");

var director = cc.Director.getInstance();
var _winSize = director.winSize();
var winSize = {width:_winSize[0], height:_winSize[1]};
var centerPos = cc.p( winSize.width/2, winSize.height/2 );

var scenes = []
var currentScene = 0;

var nextSpriteTestAction = function () {
	currentScene = currentScene + 1;
	if( currentScene >= scenes.length )
		currentScene = 0;

	loadScene(currentScene);
};
var backSpriteTestAction = function () {
	currentScene = currentScene -1;
	if( currentScene < 0 )
		currentScene = scenes.length -1;

	loadScene(currentScene);
};
var restartSpriteTestAction = function () {
	loadScene( currentScene );
};

var loadScene = function (sceneIdx)
{
	_winSize = director.winSize();
	winSize = {width:_winSize[0], height:_winSize[1]};

	var scene = new cc.Scene();
	scene.init();
	var layer = new scenes[ sceneIdx ]();

	scene.addChild( layer );

//	scene.walkSceneGraph(0);

	director.replaceScene( scene );
//    __jsc__.garbageCollect();
}

//------------------------------------------------------------------
//
// BaseLayer
//
//------------------------------------------------------------------
var BaseLayer = function() {

	//
	// VERY IMPORTANT
	//
	// Only subclasses of a native classes MUST call __associateObjectWithNative
	// Failure to do so, it will crash.
	//
	var parent = goog.base(this);
	__associateObjWithNative( this, parent );
	this.init();

	this.title = function () {
	    return "No title";
	}

	this.subtitle = function () {
	    return "No Subtitle";
	}

}
goog.inherits(BaseLayer, cc.Layer );

//
// Instance 'base' methods
// XXX: Should be defined after "goog.inherits"
//
BaseLayer.prototype.onEnter = function() {
	var label = cc.LabelTTF.labelWithStringFontnameFontsize(this.title(), "Arial", 28);
	this.addChild(label, 1);
	label.setPosition( cc.p(winSize.width / 2, winSize.height - 50));

	var strSubtitle = this.subtitle();
	if (strSubtitle != "") {
	    var l = cc.LabelTTF.labelWithStringFontnameFontsize(strSubtitle, "Thonburi", 16);
	    this.addChild(l, 1);
	    l.setPosition( cc.p(winSize.width / 2, winSize.height - 80));
	}

	// WARNING: MenuItem API will change!
	var item1 = cc.MenuItemImage.itemWithNormalImageSelectedimageBlock("b1.png", "b2.png", this.backCallback);
	var item2 = cc.MenuItemImage.itemWithNormalImageSelectedimageBlock("r1.png", "r2.png", this.restartCallback);
	var item3 = cc.MenuItemImage.itemWithNormalImageSelectedimageBlock("f1.png", "f2.png", this.nextCallback);

	var menu = cc.Menu.create( item1, item2, item3 );

	menu.setPosition( cc.p(0,0) );
	item1.setPosition( cc.p(winSize.width / 2 - 100, 30));
	item2.setPosition( cc.p(winSize.width / 2, 30));
	item3.setPosition( cc.p(winSize.width / 2 + 100, 30));

	this.addChild(menu, 1);
}

BaseLayer.prototype.restartCallback = function (sender) {
    cc.log("restart called");
    restartSpriteTestAction();
}

BaseLayer.prototype.nextCallback = function (sender) {
    cc.log("next called");
    nextSpriteTestAction();
}

BaseLayer.prototype.backCallback = function (sender) {
    cc.log("back called");
    backSpriteTestAction();
}

//------------------------------------------------------------------
//
// Label Atlas Test
//
//------------------------------------------------------------------
var LabelAtlasTest = function(file) {

	goog.base(this);

	this.initialize = function() {

		this.label1 = cc.LabelAtlas.create("123 Test", "tuffy_bold_italic-charmap.plist");
		this.addChild( this.label1 );
		this.label1.setPosition( cc.p(10,100) );
		this.label1.setOpacity( 200 );

		this.label2 = cc.LabelAtlas.create( "0123456789", "tuffy_bold_italic-charmap.plist" );
		this.addChild( this.label2 );
		this.label2.setPosition( cc.p(10,200) );
		this.label2.setOpacity( 32 );

		this.scheduleUpdate();


		this.time = 0;
	}

	this.title = function () {
		return "LabelAtlas";
	}

	this.subtitle = function () {
		return "Updating label should be fast";
	}

	this.update = function( delta ) {
		this.time += delta;
		var num = this.time.toFixed(2);
		var string = '' + num + ' test'
		this.label1.setString( string );

		string = '' + Math.floor( this.time);
		this.label2.setString( string );
	}

	this.initialize();
}
goog.inherits(LabelAtlasTest, BaseLayer );

//------------------------------------------------------------------
//
// BMFontColorTest
//
//------------------------------------------------------------------
var BMFontColorTest = function(file) {

	goog.base(this);

	this.initialize = function() {

		var label = cc.LabelBMFont.create("Blue", "bitmapFontTest5.fnt");
		this.addChild( label );
		label.setColor( cc.c3(0,0,255) );
		label.setPosition( cc.p( winSize.width/2, 1*winSize.height/4) );
		label.setAnchorPoint( cc.p(0.5, 0.5) );

		label = cc.LabelBMFont.create("Red", "bitmapFontTest5.fnt");
		this.addChild( label );
		label.setColor( cc.c3(255,0,0) );
		label.setPosition( cc.p( winSize.width/2, 2*winSize.height/4) );
		label.setAnchorPoint( cc.p(0.5, 0.5) );

		label = cc.LabelBMFont.create("Red", "bitmapFontTest5.fnt");
		this.addChild( label );
		label.setColor( cc.c3(0,255,0) );
		label.setPosition( cc.p( winSize.width/2, 3*winSize.height/4) );
		label.setAnchorPoint( cc.p(0.5, 0.5) );
	}

	this.title = function () {
		return "LabelBMFont";
	}

	this.subtitle = function () {
		return "Testing color";
	}

	this.initialize();
}
goog.inherits(BMFontColorTest, BaseLayer );


//
// Order of tests
//
scenes.push( LabelAtlasTest );
scenes.push( BMFontColorTest );

//------------------------------------------------------------------
//
// Main entry point
//
//------------------------------------------------------------------
function run()
{
    var scene = new cc.Scene();
    scene.init();
    var layer = new scenes[currentScene]();
    scene.addChild( layer );

    director.runWithScene( scene );
}

run();
