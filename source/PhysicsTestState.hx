package;

import SignalTile;
import nape.dynamics.InteractionGroup;
import flixel.FlxObject;
import openfl.ui.Keyboard;
import flash.events.KeyboardEvent;
import flash.events.Event;
import nape.geom.Vec2;
import nape.phys.BodyType;
import flixel.FlxCamera;
import flixel.FlxG;
import lycan.phys.Phys;
import lycan.states.LycanState;
import lycan.system.FpsText;
import lycan.supply.Node;
import lycan.phys.PlatformerPhysics;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

class PhysicsTestState extends LycanState {
    var player:Player;

	var movingPlatform:PhysSprite;
	
	var powerSource:SignalTile;
	
	override public function create():Void {
		super.create();
		
		Phys.init();
		Phys.drawDebug = true;

		#if !FLX_NO_DEBUG
		Phys.enableDebugManipulator = true;
		#end
		
		populateWorld();
		
		player = new Player(Std.int(FlxG.width / 2) - 200, Std.int(FlxG.height - 350), 30, 100);
		add(player);
		
		#if flash
		FlxG.camera.pixelPerfectRender = true;
		#else
		FlxG.camera.pixelPerfectRender = false;
		#end
		
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.9);
        player.physics.snapEntityToBody();
        FlxG.camera.snapToTarget();
		
		uiGroup.add(new FpsText(0, 0, 24));
		
		// Make a moving platform
		movingPlatform = new PhysSprite(100, 100, 100, 100);
		movingPlatform.physics.body.type = BodyType.KINEMATIC;
		movingPlatform.physics.body.allowRotation = false;
		movingPlatform.physics.setBodyMaterial(0, 5, 5);
		
		// Make crates
		for (i in 0...2) {
			var b:PhysSprite = cast add(new PhysSprite(Std.int(player.physics.body.position.x + 70 + 70 * i + 1), 400, 70, 70));
			b.physics.body.allowRotation = false;
			b.physics.body.isBullet = true;
			b.physics.body.mass = 50;
			b.physics.setBodyMaterial(0, 5, 2, 2);
		}
		
		var b:PhysSprite = cast add(new PhysSprite(400, Std.int(player.physics.body.position.y - 100), 200, 100));
		b.physics.body.type = BodyType.STATIC;
		b.physics.body.cbTypes.add(PlatformerPhysics.onewayType);
		b.allowCollisions = FlxObject.FLOOR;
		
		PlatformerPhysics.setupPlatformerPhysics();
		SignalTile.setupPhysics();
		
		powerSource = cast add(new SignalTile(70, 70, true, true, true, true));
		powerSource.physics.body.position.setxy(300, 500);
		var s:SignalTile = cast add(new SignalTile(70, 70, true, true, false, false));
		s.physics.body.position.setxy(460, 500);
		var s:SignalTile = cast add(new SignalTile(70, 70, false, false, true, true));
		s.physics.body.position.setxy(540, 500);
		var s:SignalTile = cast add(new SignalTile(70, 70, false, true, true, false));
		s.physics.body.position.setxy(610, 500);
	}
	
	override public function destroy():Void {
		super.destroy();
		Phys.destroy();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		handleInput(dt);
		
		powerSource.centerNode.applySignal(dt);
		
		var vel = movingPlatform.physics.body.velocity;
		vel.setxy(0, 0);
		var spd = 220;
		if (FlxG.keys.pressed.NUMPADEIGHT) vel.y -= spd;
		if (FlxG.keys.pressed.NUMPADFIVE) vel.y += spd;
		if (FlxG.keys.pressed.NUMPADFOUR) vel.x -= spd;
		if (FlxG.keys.pressed.NUMPADSIX) vel.x += spd;
	}
	
	override public function draw():Void {
		super.draw();
	}

	private function handleInput(dt:Float):Void {
		// Add the selected physics debug widget to the watch
		if (FlxG.keys.justPressed.Y) {
			var bodies = Phys.space.bodiesUnderPoint(Vec2.weak(FlxG.mouse.x, FlxG.mouse.y));
			var body = bodies.length > 0 ? bodies.at(0) : null;
			if (body != null) {
				FlxG.watch.add(body.position, "x", "body x");
				FlxG.watch.add(body.position, "y", "body y");
				FlxG.watch.add(body.userData.entity, "x", "sprite x");
				FlxG.watch.add(body.userData.entity, "y", "sprite y");
				FlxG.watch.add(body.velocity, "x", "vel x");
				FlxG.watch.add(body.velocity, "y", "vel y");
			}
		}
	}

	private function populateWorld():Void {
		trace(FlxG.worldBounds);
		Phys.createWalls(0, 0, FlxG.width, FlxG.height, 50);
		//addRandomFlyingBoxes();
		addNobblyGround(Std.int(FlxG.width / 2 - 780), Std.int(FlxG.height - 50), 10, 10, 50, 6, 0);
		
		var totalHeight:Float = 0;
		var totalWidth:Float = 0;
		for (i in 0...10) {
			var a = - i * Math.PI / 20;
			addStaticPlatform(Std.int(735 + totalWidth), Std.int(FlxG.height - totalHeight + 50), 100, 100, a);
			totalWidth += Math.cos(a) * 50;
			totalHeight += -Math.sin(a) * 50;
		}
	}
	
	// private function addRandomFlyingBoxes():Void {
	// 	var numSprites = 25;
	// 	for (i in 0...numSprites) {
	// 		var testSprite:PhysSprite = new PhysSprite(Std.int(FlxG.width / numSprites * i), Std.int(Math.random() * 250), Std.int(12 + Math.random() * 24), Std.int(12 + Math.random() * 24));
	// 		testSprite.physics.addRectangularShape(testSprite.width, testSprite.height, 10);
	// 		testSprite.physics.linearVelocityX = 3;
	// 		testSprite.physics.linearDamping = 0.1;
	// 		testSprite.physics.angularVelocity = 12;
	// 		testSprite.physics.angularDamping = 0.1;
	// 		add(testSprite);
	// 	}
	// }
	
	private function addStaticPlatform(x:Int, y:Int, width:Int, height:Int, angle:Float = 0):PhysSprite {
		var platform:PhysSprite = new PhysSprite(x, y, width, height);
		platform.physics.body.rotation = angle;
		platform.physics.body.type = BodyType.STATIC;
		add(platform);
		return platform;
	}
	
	private function addNobblyGround(x:Int, y:Int, width:Int, height:Int, parts:Int, nobblyYPositionVariation:Int = 0, nobblyHeightVariation:Int = 0):Void {
		for (i in 0...parts) {
			var wall:PhysSprite = new PhysSprite(x +  width * i, y + FlxG.random.int( -nobblyYPositionVariation, nobblyYPositionVariation),
			width, height + FlxG.random.int( -nobblyHeightVariation, nobblyHeightVariation));
			
			wall.physics.body.type = BodyType.STATIC;
			add(wall);
		}
	}

	/*
	private function addStaticOneWayPlatform():Void {
	}
	private function addMovingOneWayPlatform():Void {
	}
	private function addCrate():Void {
	}
	private function addThwomp():Void {
	}
	private function addSlope():Void {
	}
	private function addRope():Void {
	}
	private function addForceField():Void {
	}
	private function addWater():Void {
	}
	private function addWindMill():Void {
	}
	private function addSeeSaw():Void {
	}
	private function addRopeBridge():Void {
	}
	*/
}