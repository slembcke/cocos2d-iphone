// http://www.cocos2d-iphone.org
//
// Shows how to use Chipmunk + cocos2d
//

require("javascript-spidermonkey/helper.js");

var director = cc.Director.sharedDirector();
var _winSize = director.winSize();
var winSize = {width:_winSize[0], height:_winSize[1]};

var physics = {
	// "instance" variables
	space : null,

	// init physics
	init : function( layer ) {
		physics.space =  cp.spaceNew();
		cc.log( physics.space );
		var staticBody = cp.spaceGetStaticBody( physics.space );
		cc.log( staticBody );

		// Walls
		var walls = [cp.segmentShapeNew( staticBody, cp.v(0,0), cp.v(winSize.width,0), 0 ),				// bottom
				cp.segmentShapeNew( staticBody, cp.v(0,winSize.height), cp.v(winSize.width,winSize.height), 0),	// top
				cp.segmentShapeNew( staticBody, cp.v(0,0), cp.v(0,winSize.height), 0),				// left
				cp.segmentShapeNew( staticBody, cp.v(winSize.width,0), cp.v(winSize.width,winSize.height), 0)	// right
				];
		walls.forEach( function(item) {
			cp.shapeSetElasticity(item, 1);
			cp.shapeSetFriction(item, 1);
			cp.spaceAddStaticShape( physics.space, item );
		} );

		// Gravity
		cp.spaceSetGravity( physics.space, cp.v(0, -100) );
	},
};

var MyLayer = {

	// constructor
	create : function() {
		var layer1 = cc.Layer.create();
		layer1.onEnter = function () {
			cc.log("onEnter called");
			__jsc__.garbageCollect();

			physics.init( this );
			this.scheduleUpdate();
			for(var i=0; i<10; i++) {
				var sprite = MyLayer.addSprite( cp.v(winSize.width/2, winSize.height/2) );
				this.addChild( sprite );
			}
		};

		layer1.update = function( delta ) {
			cp.spaceStep( physics.space, delta );
		};

		var label = cc.LabelTTF.labelWithStringFontnameFontsize("Javascript: cocos2d + Chipmunk", "Arial", 28);
		label.setPosition( ccp( winSize.width/2, winSize.height-30) );
		layer1.addChild( label );

		label.setRotation( 2 );
		this.runAction( label );

		return layer1;
	},

	runAction : function( target ) {
		var rot = cc.RotateBy.create( 0.2, -4 );
		var rev = rot.reverse();
		var rep = cc.RepeatForever.create( cc.Sequence.create( rot, rev ) );

		target.runAction( rep );
	},

	addSprite : function( pos ) {
		var body = cp.bodyNew(1, cp.momentForBox(1, 20, 20) );
		cp.bodySetPos( body, pos );
		cp.spaceAddBody( physics.space, body );
		var shape = cp.boxShapeNew( body, 48, 108);
		cp.shapeSetElasticity( shape, 0.5 );
		cp.shapeSetFriction( shape, 0.5 );
		cp.spaceAddShape( physics.space, shape );

		var sprite = cc.ChipmunkSprite.create("grossini.png");
		sprite.setBody( body );
		return sprite;
	},
}


var scene = cc.Scene.create();
var layer = MyLayer.create();
scene.addChild( layer );

director.replaceScene( scene );
