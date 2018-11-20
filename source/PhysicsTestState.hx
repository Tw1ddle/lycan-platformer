package;

import box2D.dynamics.B2BodyType;
import flixel.FlxCamera;
import flixel.FlxG;
import lycan.phys.Phys;
import lycan.states.LycanState;
import lycan.system.FpsText;

class PhysicsTestState extends LycanState {
    var player:Player;

	override public function create():Void {
		super.create();
		
		setupUI();
		setupPhysics();
		populateWorld();
		createAndAddPlayer();
		setupCamera();
	}
	
	override public function destroy():Void {
		super.destroy();
		destroyPhysics();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		handleInput(dt);
	}
	
	override public function draw():Void {
		super.draw();
	}

	private function handleInput(dt:Float):Void {
		// Add the selected physics debug widget to the watch
		if (FlxG.keys.justPressed.Y) {
			var body = Phys.debugManipulator.getBodyAtMouse();
			if (body != null) {
				FlxG.watch.add(body.getPosition(), "x", "body x");
				FlxG.watch.add(body.getPosition(), "y", "body y");
				FlxG.watch.add(body.getUserData().entity, "x", "sprite x");
				FlxG.watch.add(body.getUserData().entity, "y", "sprite y");
				FlxG.watch.add(body.m_linearVelocity, "x", "linearVelocityX");
				FlxG.watch.add(body.m_linearVelocity, "y", "linearVelocityY");
			}
		}
	}

	private function setupUI():Void {
		// FPS counter
		uiGroup.add(new FpsText(0, 0, 24));
	}

	private function setupPhysics():Void {
		Phys.init();
		Phys.drawDebug = true;
		Phys.debugManipulator = new Box2DInteractiveDebug();
	}

	private function destroyPhysics():Void {
		Phys.destroy();
	}

	private function populateWorld():Void {
		addWorldWalls();
		
		//addRandomFlyingBoxes();
		
		addNobblyGround(Std.int(FlxG.width / 2 - 780), Std.int(FlxG.height - 50), 10, 10, 50, 6, 0);
		
		var totalHeight:Float = 0;
		var totalWidth:Float = 0;
		for (i in 0...11) {
			var p = addStaticPlatform(Std.int(500 + totalWidth), Std.int(FlxG.height + 50 - totalHeight), 100, 100);
			var a = - i * Math.PI / 20;
			p.physics.body.setAngle(a);
			totalWidth += Math.cos(a) * 50;
			totalHeight += -Math.sin(a) * 50;
		}
	}

	private function createAndAddPlayer():Void {
		// Create player and set up player controller
		player = new Player(Std.int(FlxG.width / 2), Std.int(FlxG.height - 350), 30, 100);
		add(player);
	}

	private function setupCamera():Void {
		FlxG.camera.pixelPerfectRender = false;

		// Follow the player
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.9);
	}

	private function addWorldWalls():Void {
		Phys.createWalls(FlxG.worldBounds.left, FlxG.worldBounds.top, FlxG.worldBounds.right, FlxG.worldBounds.bottom, 50);
	}
	
	private function addRandomFlyingBoxes():Void {
		var numSprites = 25;
		for (i in 0...numSprites) {
			var testSprite:PhysSprite = new PhysSprite(Std.int(FlxG.width / numSprites * i), Std.int(Math.random() * 250), Std.int(12 + Math.random() * 24), Std.int(12 + Math.random() * 24));
			testSprite.physics.addRectangularShape(testSprite.width, testSprite.height, 10);
			testSprite.physics.linearVelocityX = 3;
			testSprite.physics.linearDamping = 0.1;
			testSprite.physics.angularVelocity = 12;
			testSprite.physics.angularDamping = 0.1;
			add(testSprite);
		}
	}
	
	private function addStaticPlatform(x:Int, y:Int, width:Int, height:Int):PhysSprite {
		var platform:PhysSprite = new PhysSprite(x, y, width, height);
		platform.physics.addRectangularShape(platform.width, platform.height);
		platform.physics.bodyType = B2BodyType.STATIC_BODY;
		platform.physics.body.getFixtureList().setFriction(1);
		add(platform);
		return platform;
	}
	
	private function addWall(x:Int, y:Int, width:Int, height:Int, bodyType:B2BodyType = B2BodyType.STATIC_BODY):PhysSprite {
		var wall:PhysSprite = new PhysSprite(x, y, width, height);
		wall.physics.addRectangularShape(wall.width, wall.height);
		wall.physics.bodyType = bodyType;
		add(wall);
		return wall;
	}
	
	private function addNobblyGround(x:Int, y:Int, width:Int, height:Int, parts:Int, nobblyYPositionVariation:Int = 0, nobblyHeightVariation:Int = 0):Void {
		for (i in 0...parts) {
			var wall:PhysSprite = new PhysSprite(x +  width * i, y + FlxG.random.int( -nobblyYPositionVariation, nobblyYPositionVariation),
			width, height + FlxG.random.int( -nobblyHeightVariation, nobblyHeightVariation));
			
			wall.physics.addRectangularShape(wall.width, wall.height);
			wall.physics.bodyType = B2BodyType.STATIC_BODY;
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