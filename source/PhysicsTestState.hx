package;

import box2D.dynamics.B2BodyType;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lycan.entities.LSprite;
import lycan.phys.Phys;
import lycan.states.LycanState;
import lycan.world.components.PhysicsEntity;

class PhysSprite extends LSprite implements PhysicsEntity {
	public function new(x:Int, y:Int, width:Int, height:Int) {
		super(x, y);
		makeGraphic(width, height, FlxColor.fromRGB(255, 0, 64, 128));
		
		physics.init();
	}
}

class PhysicsTestState extends LycanState {
	override public function create():Void {
		super.create();
		
		Phys.init();
		Phys.drawDebug = true;
		Phys.debugManipulator = new Box2DInteractiveDebug();
		
		addRandomFlyingBoxes();
		
		addStaticPlatform(Std.int(FlxG.width / 2 - 200), Std.int(FlxG.height - 200), Std.int(FlxG.width / 2), 25);
		
		addMovingPlatform(Std.int(FlxG.width / 2 + 500), Std.int(FlxG.height + 200), Std.int(FlxG.width / 3), 25);
		
		addGround(Std.int(FlxG.width / 2 - 980), Std.int(FlxG.height - 200), 10, 10, 50, 5, 5);
		
		addGround(Std.int(FlxG.width / 2 + 200), Std.int(FlxG.height - 200), 100, 100, 50, 25, 25);
		
		addGround(Std.int(FlxG.width / 2 - 780), Std.int(FlxG.height - 350), 10, 10, 50, 0, 0);
		
		addWall(Std.int(FlxG.width / 2 - 300), Std.int(FlxG.height - 500), 25, 100);
		
		var player:Player = new Player(Std.int(FlxG.width / 2), Std.int(FlxG.height - 350), 40, 120);
		add(player);
		
		FlxG.camera.follow(player, null, 0.9);
	}
	
	override public function destroy():Void {
		Phys.destroy();
		super.destroy();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		if (FlxG.keys.justPressed.Y) {
			var body = Phys.debugManipulator.getBodyAtMouse();
			if (body != null) {
				FlxG.watch.add(body.m_linearVelocity, "x", "linearVelocityX");
				FlxG.watch.add(body.m_linearVelocity, "y", "linearVelocityY");
			}
		}
	}
	
	override public function draw():Void {
		super.draw();
	}
	
	private function addRandomFlyingBoxes():Void {
		var numSprites = 25;
		for (i in 0...numSprites) {
			var testSprite:PhysSprite = new PhysSprite(Std.int(FlxG.width / numSprites * i), Std.int(Math.random() * 250), Std.int(4 + Math.random() * 24), Std.int(4 + Math.random() * 24));
			testSprite.physics.addRectangularShape(testSprite.width, testSprite.height, 10);
			testSprite.physics.linearVelocityX = 3;
			testSprite.physics.linearDamping = 0.1;
			testSprite.physics.angularVelocity = 12;
			testSprite.physics.angularDamping = 0.1;
			add(testSprite);
		}
	}
	
	private function addStaticPlatform(x:Int, y:Int, width:Int, height:Int):Void {
		var platform:PhysSprite = new PhysSprite(x, y, width, height);
		platform.physics.addRectangularShape(platform.width, platform.height);
		platform.physics.bodyType = B2BodyType.STATIC_BODY;
		add(platform);
	}
	
	private function addMovingPlatform(x:Int, y:Int, width:Int, height:Int):Void {
		var wall = addWall(x, y, width, height, B2BodyType.KINEMATIC_BODY);
		wall.physics.linearVelocityX = 5;
		
		// Move back and forth
		new FlxTimer().start(3, function(t:FlxTimer):Void {
			wall.physics.linearVelocityX = -wall.physics.linearVelocityX;
		}, 0);
	}
	
	private function addWall(x:Int, y:Int, width:Int, height:Int, bodyType:B2BodyType = B2BodyType.STATIC_BODY):PhysSprite {
		var wall:PhysSprite = new PhysSprite(x, y, width, height);
		wall.physics.addRectangularShape(wall.width, wall.height);
		wall.physics.bodyType = bodyType;
		add(wall);
		return wall;
	}
	
	private function addGround(x:Int, y:Int, width:Int, height:Int, parts:Int, nobblyYPositionVariation:Int = 0, nobblyHeightVariation:Int = 0):Void {
		for (i in 0...parts) {
			var wall:PhysSprite = new PhysSprite(x +  width * i, y + FlxG.random.int( -nobblyYPositionVariation, nobblyYPositionVariation),
			width, height + FlxG.random.int( -nobblyHeightVariation, nobblyHeightVariation));
			
			wall.physics.addRectangularShape(wall.width, wall.height);
			wall.physics.bodyType = B2BodyType.STATIC_BODY;
			add(wall);
		}
	}
}