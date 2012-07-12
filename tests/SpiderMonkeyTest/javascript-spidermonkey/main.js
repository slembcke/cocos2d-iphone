//
// http://www.cocos2d-iphone.org
// http://www.cocos2d-html5.org
// http://www.cocos2d-x.org
//
// Javascript + cocos2d actions tests
//

require("javascript-spidermonkey/helper.js");

var director = cc.Director.getInstance();
var _winSize = director.winSize();
var winSize = {width:_winSize[0], height:_winSize[1]};
var centerPos = cc.p( winSize.width/2, winSize.height/2 );

var scenes = []
var currentScene = 0;

var nextScene = function () {
	currentScene = currentScene + 1;
	if( currentScene >= scenes.length )
		currentScene = 0;

	withTransition = true;
	loadScene(currentScene);
};

var previousScene = function () {
	currentScene = currentScene -1;
	if( currentScene < 0 )
		currentScene = scenes.length -1;

	withTransition = true;
	loadScene(currentScene);
};

var restartScene = function () {
	loadScene( currentScene );
};

var loadScene = function (sceneIdx)
{
	_winSize = director.winSize();
	winSize = {width:_winSize[0], height:_winSize[1]};
	centerPos = cc.p( winSize.width/2, winSize.height/2 );

	var scene = new cc.Scene();
	scene.init();
	var layer = new scenes[ sceneIdx ]();

	scene.addChild( layer );

//	scene.walkSceneGraph(0);

	director.replaceScene( scene );
//    __jsc__.garbageCollect();
}



//
// Base Layer
//

var BaseLayer = cc.LayerGradient.extend({

    ctor:function () {
                                
        var parent = new cc.LayerGradient();
        __associateObjWithNative(this, parent);
        this.init(cc.c4(0, 0, 0, 255), cc.c4(0, 128, 255, 255));
    },

    title:function () {
        return "No Title";
    },

    subtitle:function () {
        return "";
    },

    code:function () {
        return "";
    },

    restartCallback:function (sender) {
        restartScene();
    },

    nextCallback:function (sender) {
        nextScene();
    },

    backCallback:function (sender) {
       previousScene();
    },

    onEnter:function () {
        // DO NOT CALL this._super()
//        this._super();

        // add title and subtitle
        var label = cc.LabelTTF.create(this.title(), "Arial", 28);
        this.addChild(label, 1);
        label.setPosition( cc.p(winSize.width / 2, winSize.height - 40));

        var strSubtitle = this.subtitle();
        if (strSubtitle != "") {
            var l = cc.LabelTTF.create(strSubtitle, "Thonburi", 16);
            this.addChild(l, 1);
            l.setPosition( cc.p(winSize.width / 2, winSize.height - 70));
        }

        var strCode = this.code();
        if( strCode !="" ) {
            var label = cc.LabelTTF.create(strCode, 'CourierNewPSMT', 16);
            label.setPosition( cc.p( winSize.width/2, winSize.height-120) );
            this.addChild( label,10 );

            var labelbg = cc.LabelTTF.create(strCode, 'CourierNewPSMT', 16);
            labelbg.setColor( cc.c3(10,10,255) );
            labelbg.setPosition( cc.p( winSize.width/2 +1, winSize.height-120 -1) );
            this.addChild( labelbg,9);
        }
    }
});

//------------------------------------------------------------------
//
// MenuItemFontTest
//
//------------------------------------------------------------------
var MenuItemFontTest = BaseLayer.extend({
    onEnter:function () {
        this._super();

        var item1 = cc.MenuItemFont.create("Item 1. Should be RED");
        var item2 = cc.MenuItemFont.create("This item is bigger", this, this.item_cb);
        var item3 = cc.MenuItemFont.create("This item should be disabled", this, this.item_cb);

        // callback function can be modified in runtime
        item1.setCallback( this, this.item_cb );

        // font color can be changed in runtime
        item1.setColor( cc.c3(255,0,0) );

        // font size can be changed in runtime (it is faster to do it before creating the item)
        item2.setFontSize( 48 );

        // font name can be changed in runtime (it is faster to do it before creating the item)
        item3.setFontName( "Courier New");

        // item could be enabled / disabled in runtime
        item3.setIsEnabled( false );

        var menu = cc.Menu.create( item1, item2, item3 );
        menu.alignItemsVertically();

        menu.setPosition( cc.p( winSize.width/2, winSize.height/2) );

        this.addChild( menu );
    },

    title:function () {
        return "Menu Item Font";
    },
    subtitle:function () {
        return "3 items. 3rd should be disabled. Smaller font";
    },
    code:function () {
        return "item = cc.MenuItemFont.create('Press me', this, this.callback)";
    },

    // callback
    item_cb:function(sender) {
        cc.log("Item " + sender + " pressed");
    },


});

//------------------------------------------------------------------
//
// MenuItemImage
//
//------------------------------------------------------------------
var MenuItemImageTest = BaseLayer.extend({

    _vertically : true,

    _menu : null,

    onEnter:function () {
        this._super();
  
        var item1 = cc.MenuItemImage.create("btn-play-normal.png", "btn-play-selected.png" );
        var item2 = cc.MenuItemImage.create("btn-highscores-normal.png", "btn-highscores-selected.png", this, this.item_cb  );
        var item3 = cc.MenuItemImage.create("btn-about-normal.png", "btn-about-selected.png", this, this.item_cb  );
        
        // callback function can be modified in runtime
        item1.setCallback( this, this.item_cb );

        // item could be enabled / disabled in runtime
        item3.setIsEnabled( false );

        this._menu = cc.Menu.create( item1, item2, item3 );
        this._menu.alignItemsVertically();

        this._menu.setPosition( cc.p( winSize.width/2, winSize.height/2) );

        this.addChild( this._menu );
    },


    title:function () {
        return "Menu Item Sprite";
    },
    subtitle:function () {
        return "3 items. 3rd should be disabled.";
    },
    code:function () {
        return "item = cc.MenuItemImage.create('normal.png', 'selected.png' , 'disabled.png', this, this.cb )";
    },

    // callback
    item_cb:function(sender) {
        cc.log("Item " + sender + " pressed");
        if( this._vertically )
            this._menu.alignItemsHorizontally();
        else
            this._menu.alignItemsVertically();

        this._vertically = ! this._vertically;

    },

});

//------------------------------------------------------------------
//
// MainTest
//
//------------------------------------------------------------------
var MainTest = BaseLayer.extend({

    _vertically : true,
    _menu : null,

    onEnter:function () {
        this._super();
  
        cc.MenuItemFont.setFontSize(20);
        var item1 = cc.MenuItemFont.create("Actions: Basic Tests", this, function() { require("javascript-spidermonkey/test-actions.js"); } );
        var item2 = cc.MenuItemFont.create("Actions: Ease Tests", this, function() { require("javascript-spidermonkey/test-easeactions.js"); } );
        var item3 = cc.MenuItemFont.create("Actions: Progress Tests", this, function() { require("javascript-spidermonkey/test-actionsprogress.js"); } );
        var item4 = cc.MenuItemFont.create("Chipmunk Tests", this, function() { require("javascript-spidermonkey/test-chipmunk.js"); } );
        var item5 = cc.MenuItemFont.create("Label Tests", this, function() { require("javascript-spidermonkey/test-label.js"); } );
        var item6 = cc.MenuItemFont.create("Menu Tests", this, function() { require("javascript-spidermonkey/test-menu.js"); } );
        var item7 = cc.MenuItemFont.create("Parallax Tests", this, function() { require("javascript-spidermonkey/test-parallax.js"); } );
        var item8 = cc.MenuItemFont.create("Particle Tests", this, function() { require("javascript-spidermonkey/test-particles.js"); } );
        var item9 = cc.MenuItemFont.create("Sprite Tests", this, function() { require("javascript-spidermonkey/test-sprite.js"); } );
        var item10 = cc.MenuItemFont.create("Tilemap Tests", this, function() { require("javascript-spidermonkey/test-tilemap.js"); } );
        var item11 = cc.MenuItemFont.create("CocosDenshion Tests", this, function() { require("javascript-spidermonkey/test-cocosdenshion.js"); } );
        var item12 = cc.MenuItemFont.create("cocos2d presentation", this, function() { require("javascript-spidermonkey/test-cocos2djs.js"); } );


        this._menu = cc.Menu.create( item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11, item12 );
        this._menu.alignItemsVertically();

        this._menu.setPosition( cc.p( winSize.width/2, winSize.height/2) );

        this.addChild( this._menu );
    },

    title:function () {
        return "Javascript tests";
    },

});


//
// Order of tests
//

scenes.push( MainTest);

//------------------------------------------------------------------
//
// Main entry point
//
//------------------------------------------------------------------
function run()
{
    var scene = cc.Scene.create();
    var layer = new scenes[currentScene]();
    scene.addChild( layer );

    var runningScene = director.getRunningScene();
    if( runningScene == null )
        director.runWithScene( scene );
    else
        director.replaceScene( cc.TransitionSplitCols.create(1, scene ) );

    director.setDisplayStats(true);
}

run();

