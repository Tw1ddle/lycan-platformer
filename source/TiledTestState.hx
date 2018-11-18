package;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import lycan.entities.LSprite;
import lycan.phys.Phys;
import lycan.states.LycanState;
import lycan.system.FpsText;
import lycan.world.components.PhysicsEntity;

class PhysSprite extends LSprite implements PhysicsEntity {
	public function new(x:Int, y:Int, width:Int, height:Int) {
		super(x, y);
		makeGraphic(width, height, FlxColor.fromRGB(255, 0, 64, 128));
		//pixelPerfectPosition = true;
		physics.init();
	}
}

class TiledTestState extends LycanState {
	override public function create():Void {
		super.create();
		
		setupUI();
		
        setupPhysics();
		//populateWorld();
		//createAndAddPlayer();
		//setupCamera();
	}
	
	override public function destroy():Void {
		destroyPhysics();
		super.destroy();
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
		//addWorldWalls();
	}

	/*
	private function createAndAddPlayer():Void {
		// Create player and set up player controller
		player = new Player(Std.int(FlxG.width / 2), Std.int(FlxG.height - 350), 30, 100);
		add(player);
	}

	private function setupCamera():Void {
		FlxG.camera.pixelPerfectRender = false;
		// Follow the player
		//FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.9);
	}	

	private function addStaticPlatform(x:Int, y:Int, width:Int, height:Int):Void {
		var platform:PhysSprite = new PhysSprite(x, y, width, height);
		platform.physics.addRectangularShape(platform.width, platform.height);
		platform.physics.bodyType = B2BodyType.STATIC_BODY;
		add(platform);
	}
	
	private function addWall(x:Int, y:Int, width:Int, height:Int, bodyType:B2BodyType = B2BodyType.STATIC_BODY):PhysSprite {
		var wall:PhysSprite = new PhysSprite(x, y, width, height);
		wall.physics.addRectangularShape(wall.width, wall.height);
		wall.physics.bodyType = bodyType;
		add(wall);
		return wall;
	}
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