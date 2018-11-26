package;

import flixel.FlxObject;
import openfl.ui.Keyboard;
import flash.events.KeyboardEvent;
import flash.automation.KeyboardAutomationAction;
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

class PhysicsTestState extends LycanState {
    var player:Player;

	var signalSystem:SignalSystem;
	var n1:Node;
	var n2:Node;
	var n3:Node;
	var e1:Edge;
	var e2:Edge;
	var tl1:TimelineSprite;
	var tl2:TimelineSprite;

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
		
		
		tl1 = cast uiGroup.add(new TimelineSprite(100, 100));
		tl2 = cast uiGroup.add(new TimelineSprite(100, 400));
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, (e:KeyboardEvent)->{
			if (e.keyCode == Keyboard.D) {
				tl1.timeline = tl1.timeline.difference(tl2.timeline);
			}
			if (e.keyCode == Keyboard.R) {
				tl2.timeline.clear();
			}
			if (e.keyCode == Keyboard.A) {
				tl1.timeline.add(tl2.timeline);
			}
		});
		
		signalSystem = new SignalSystem();
		n1 = new Node();
		n2 = new Node();
		n3 = new Node();
		e1 = new Edge(n1, n2);
		e2 = new Edge(n2, n3);
		signalSystem.nodes.add(n1);
		signalSystem.nodes.add(n2);
		signalSystem.nodes.add(n3);
		signalSystem.edges.add(e1);
		signalSystem.edges.add(e2);
		add(signalSystem);
		
		// Make crates
		for (i in 0...6) {
			var b:PhysSprite = cast add(new PhysSprite(Std.int(player.physics.body.position.x + 70 + 70 * i + 1), 400, 70, 70));
			b.physics.body.allowRotation = false;
			b.physics.setBodyMaterial(0, 5, 5, 2);
		}
		
		var b:PhysSprite = cast add(new PhysSprite(400, Std.int(player.physics.body.position.y - 100), 200, 100));
		b.physics.body.type = BodyType.STATIC;
		b.physics.body.cbTypes.add(PlatformerPhysics.onewayType);
		b.allowCollisions = FlxObject.FLOOR;
		
		PlatformerPhysics.setupPlatformerPhysics();
	}
	
	override public function destroy():Void {
		super.destroy();
		Phys.destroy();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		handleInput(dt);
		
		// Playing with the supply network
		if (FlxG.keys.pressed.SPACE) {
			n1.addSignal();
			
			FlxG.watch.addQuick("s", "t");
		} else  FlxG.watch.addQuick("s","f");
		
		FlxG.watch.addQuick("n1", n1.signalOn + " " + n1.propagation);
		FlxG.watch.addQuick("e1 prop", e1.propagation);
		FlxG.watch.addQuick("n2", n1.signalOn);
		FlxG.watch.addQuick("e2 prop", e2.propagation);
		FlxG.watch.addQuick("n3", n1.signalOn);
		
		//@:privateAccess tl1.timeline = n1.inputTimeline;
		//@:privateAccess tl2.timeline = n1.propagationTimeline;
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