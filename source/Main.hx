package;

import nape.dynamics.CollisionArbiter;
import flixel.FlxGame;
import openfl.display.Sprite;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.math.FlxRandom;
import flixel.system.debug.FlxDebugger.FlxDebuggerLayout;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.util.FlxStringUtil;
import nape.callbacks.BodyCallback;
import nape.callbacks.BodyListener;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.Material;
import nape.shape.Circle;
import nape.space.Space;

class Main extends Sprite {
	public function new() {
		super();
		
		addChild(new FlxGame(1024, 768, RootState, 1, 60, 60, true, false));
	}
}


// /**
//  * ...
//  * @author Jonathan Snyder
//  */
// class TestState extends FlxState {
//     var walls:Body;
//     public var ball:Body;
//     public var ballShape:Circle;
//     public var space(default, null):Space;
//     public var jumpStrength:Float = -2500;
//     public var collisionListener:InteractionCallback;
	
//     override public function create():Void {
//         super.create();
		
// 		FlxG.scaleMode = new StageSizeScaleMode();

//         FlxG.console.registerClass(FlxNapeSpace);
//         FlxG.console.autoPause = false;
//         FlxG.debugger.setLayout(FlxDebuggerLayout.RIGHT);
//         FlxG.debugger.track(FlxG);
//         FlxG.debugger.visible = true;


//         FlxNapeSpace.init();
//         FlxNapeSpace.space.gravity.setxy(0, 1000);
//         FlxNapeSpace.drawDebug = true;
//         space = FlxNapeSpace.space;


//         walls = FlxNapeSpace.createWalls(0, 0, 0, FlxG.height - 100, 10, new Material(0, 1, 1, 1));


//         ballShape = new Circle(50);


//         ball = new Body();
//         ball.position.setxy(FlxG.width / 2, 100);
//         ball.shapes.add(ballShape);
//         ball.space = FlxNapeSpace.space;


//         FlxG.watch.add(ball.velocity, "y", "vely");
//         FlxG.watch.add(FlxNapeSpace, "positionIterations", "pos it");
//         FlxG.watch.add(FlxNapeSpace, "velocityIterations", "vel it");
//         FlxG.watch.add(FlxG.game, 'ticks', 'game ms');
//         FlxG.watch.add(FlxNapeSpace.space, 'timeStamp', 'sp steps');
//         FlxG.watch.add(FlxNapeSpace.space, 'elapsedTime', 'sp elapsed');
//         FlxG.watch.add(ballShape, 'material', 'material');


//         var preListen:PreListener = new PreListener(InteractionType.COLLISION, CbType.ANY_BODY, CbType.ANY_BODY, onPre, 0, true);
//         var iListener:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, onInteraction, 0);
//         var iListener2:InteractionListener = new InteractionListener(CbEvent.END, InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, onInteraction, 5);
// 		var ongoingListener:InteractionListener = new InteractionListener(CbEvent.ONGOING, InteractionType.ANY, CbType.ANY_BODY, CbType.ANY_BODY, onOngoing, 5);
		
//         space.listeners.add(iListener);
//         space.listeners.add(iListener2);
//         space.listeners.add(preListen);
//         space.listeners.add(ongoingListener);

//         //possible solution, disable this to see the delay
//         space.listeners.add(new BodyListener(CbEvent.WAKE, CbType.ANY_BODY, onBodyListen, 1));
//         space.listeners.add(new BodyListener(CbEvent.SLEEP, CbType.ANY_BODY, onBodyListen, 1));

//     }

//     function onBodyListen(bc:BodyCallback) {
//         if (bc.event == CbEvent.SLEEP) {
//             FlxG.log.clear();
//         }


//         FlxG.log.warn(FlxStringUtil.formatTime(FlxG.game.ticks / 1000, true) + ": " + bc.event);
//     }

//     function onPre(cb:PreCallback):PreFlag {
//         FlxG.log.error(FlxStringUtil.formatTime(FlxG.game.ticks / 1000, true) + ": " + cb.event + " (PRE)");
//         return PreFlag.ACCEPT;
//     }

//     function onInteraction(cb:InteractionCallback) {

//         FlxG.log.notice(FlxStringUtil.formatTime(FlxG.game.ticks / 1000, true) + ": " + cb.event);
//     }
	
// 	function onOngoing(cb:InteractionCallback) {
// 		FlxG.log.notice(FlxStringUtil.formatTime(FlxG.game.ticks / 1000, true) + ": " + cb.event + " (ONGOING)");
//         for (a in cb.arbiters) {
//             if (a.isCollisionArbiter() && a.collisionArbiter.totalImpulse().length == 0) {
// 		        FlxG.log.notice(FlxStringUtil.formatTime(FlxG.game.ticks / 1000, true) + ": " + cb.event + " (REAL END!)");
//             }
//             // a.collisionArbiter.contacts.length
//         }
// 	}


//     override public function update(elapsed:Float):Void {
//         if (FlxG.keys.pressed.UP) {
//             ball.applyImpulse(Vec2.weak(0, jumpStrength));
//         }
// 		var mat = ballShape.material;
// 		if (FlxG.random.bool()) {
// 			mat.dynamicFriction = 0;
// 			mat.staticFriction = 4;
// 		} else {
// 			mat.dynamicFriction = 1;
// 			mat.staticFriction = 4;
// 		}
//         super.update(elapsed);
//     }

// }