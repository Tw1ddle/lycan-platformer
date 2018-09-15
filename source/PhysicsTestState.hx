package;

import box2D.dynamics.B2BodyType;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import lycan.entities.LSprite;
import lycan.states.LycanState;
import lycan.phys.Phys;
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
		
		var numSprites = 100;
		for (i in 0...numSprites) {
			var testSprite:PhysSprite = new PhysSprite(Std.int(FlxG.width / numSprites * i), Std.int(Math.random() * 250), Std.int(4 + Math.random() * 24), Std.int(4 + Math.random() * 24));
			testSprite.physics.addRectangularShape(testSprite.width, testSprite.height, 10);
			testSprite.physics.linearVelocityX = 3;
			testSprite.physics.linearDamping = 0.1;
			testSprite.physics.angularVelocity = 12;
			testSprite.physics.angularDamping = 0.1;
			add(testSprite);
		}
		
		var platform:PhysSprite = new PhysSprite(Std.int(FlxG.width / 2 - 200), Std.int(FlxG.height - 200), Std.int(FlxG.width / 2), 25);
		platform.physics.addRectangularShape(platform.width, platform.height);
		platform.physics.bodyType = B2BodyType.STATIC_BODY;
		add(platform);
		
		var wall:PhysSprite = new PhysSprite(Std.int(FlxG.width / 2 + 200), Std.int(FlxG.height - 300), 25, 500);
		wall.physics.addRectangularShape(wall.width, wall.height);
		wall.physics.bodyType = B2BodyType.STATIC_BODY;
		add(wall);
		
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
	}
	
	override public function draw():Void {
		super.draw();
	}
}