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


cc.LayerGradient.extend = function (prop) {
    var _super = this.prototype;

    // Instantiate a base class (but only create the instance,
    // don't run the init constructor)
    initializing = true;
    var prototype = new this();
    initializing = false;
    fnTest = /xyz/.test(function(){xyz;}) ? /\b_super\b/ : /.*/;

    // Copy the properties over onto the new prototype
    for (var name in prop) {
        // Check if we're overwriting an existing function
        prototype[name] = typeof prop[name] == "function" &&
            typeof _super[name] == "function" && fnTest.test(prop[name]) ?
            (function (name, fn) {
                return function () {
                    var tmp = this._super;

                    // Add a new ._super() method that is the same method
                    // but on the super-class
                    this._super = _super[name];

                    // The method only need to be bound temporarily, so we
                    // remove it when we're done executing
                    var ret = fn.apply(this, arguments);
                    this._super = tmp;

                    return ret;
                };
            })(name, prop[name]) :
            prop[name];
    }

    // The dummy class constructor
    function Class() {
        // All construction is actually done in the init method
        if (!initializing && this.ctor)
            this.ctor.apply(this, arguments);
    }

    // Populate our constructed prototype object
    Class.prototype = prototype;

    // Enforce the constructor to be what we expect
    Class.prototype.constructor = Class;

    // And make this class extendable
    Class.extend = arguments.callee;

    return Class;
};

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

        // Menu
        var item1 = cc.MenuItemImage.create("b1.png", "b2.png", this, this.backCallback);
        var item2 = cc.MenuItemImage.create("r1.png", "r2.png", this, this.restartCallback);
        var item3 = cc.MenuItemImage.create("f1.png", "f2.png", this, this.nextCallback);
        var item4 = cc.MenuItemFont.create("back", this, function() { require("javascript-spidermonkey/main.js"); } );
        item4.setFontSize( 22 );

        var menu = cc.Menu.create(item1, item2, item3, item4 );

        menu.setPosition( cc.p(0,0) );
        item1.setPosition( cc.p(winSize.width / 2 - 100, 30));
        item2.setPosition( cc.p(winSize.width / 2, 30));
        item3.setPosition( cc.p(winSize.width / 2 + 100, 30));
        item4.setPosition( cc.p(winSize.width - 60, winSize.height - 30 ) );

        this.addChild(menu, 1);


        // back menu
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
// MenuItemSpriteTest
//
//------------------------------------------------------------------
var MenuItemSpriteTest = BaseLayer.extend({

    _vertically : true,
    _menu : null,

    onEnter:function () {
        this._super();
   
        // Sprites can't be reused since they are children of MenuItem
        // If you want to reuse them, use "MenuItemImage" instead
        var sprite1_1 = cc.Sprite.create("menuitemsprite.png", cc.rect(0, 23*2, 115, 23) );
        var sprite2_1 = cc.Sprite.create("menuitemsprite.png", cc.rect(0, 23*1, 115, 23) );
        var sprite1_2 = cc.Sprite.create("menuitemsprite.png", cc.rect(0, 23*2, 115, 23) );
        var sprite2_2 = cc.Sprite.create("menuitemsprite.png", cc.rect(0, 23*1, 115, 23) );
        var sprite3_2 = cc.Sprite.create("menuitemsprite.png", cc.rect(0, 23*0, 115, 23) );
        var sprite1_3 = cc.Sprite.create("menuitemsprite.png", cc.rect(0, 23*2, 115, 23) );
        var sprite2_3 = cc.Sprite.create("menuitemsprite.png", cc.rect(0, 23*1, 115, 23) );
        var sprite3_3 = cc.Sprite.create("menuitemsprite.png", cc.rect(0, 23*0, 115, 23) );

        var item1 = cc.MenuItemSprite.create(sprite1_1, sprite2_1);
        var item2 = cc.MenuItemSprite.create(sprite1_2, sprite2_2, sprite3_2, this, this.item_cb);
        var item3 = cc.MenuItemSprite.create(sprite1_3, sprite2_3, sprite3_3, this, this.item_cb);

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
        return "item = cc.MenuItemSprite.create(spr_normal, spr_selected, spr_disabled, this, this.cb )";
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


//
// Order of tests
//

scenes.push( MenuItemFontTest );
scenes.push( MenuItemImageTest );
scenes.push( MenuItemSpriteTest );

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
        director.replaceScene( cc.TransitionFade.create(0.5, scene ) );
}

run();

