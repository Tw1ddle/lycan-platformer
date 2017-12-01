package;

import box2D.collision.shapes.B2MassData;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2World;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import lycan.states.LycanState;
import lycan.world.Box2D;
import lycan.world.components.PhysicsEntity;
import box2D.dynamics.B2BodyType;

class PhysSprite extends FlxSprite implements PhysicsEntity {
	public function new(x:Int, y:Int, width:Int = 8, height:Int = 8) {
		super(x, y);
		makeGraphic(width, height, FlxColor.fromRGB(128, 0, 64, 64));
		
		physics.init();
		physics.setPixelPosition(x, y);
	}
	
	override public function destroy():Void	super.destroy();
	override public function kill():Void	super.kill();
	override public function revive():Void	super.revive();
}

class PhysicsTestState extends LycanState {
	private var world:B2World;
	
	override public function create():Void {
		super.create();
		
		Box2D.init();
		world = Box2D.world;
		Box2D.drawDebug = true;
		
		var numSprites = 500;
		for (i in 0...numSprites) {
			var testSprite:PhysSprite = new PhysSprite(Std.int(FlxG.width / numSprites * i), Std.int(Math.random() * 250));
			testSprite.physics.body.setAngularVelocity(0);
			testSprite.physics.body.setLinearDamping(0.1);
			testSprite.physics.body.setAngularDamping(0.1);
		
			// Forcibly set density/mass of the fixtures/body
			var fixtures:B2Fixture = testSprite.physics.body.getFixtureList();

				fixtures.setDensity(10);

			testSprite.physics.body.resetMassData();
			
			add(testSprite);
		}
		
		var platform:PhysSprite = new PhysSprite(Std.int(FlxG.width / 2 - 200), Std.int(FlxG.height - 200), Std.int(FlxG.width / 2), 25);
		platform.physics.body.setType(B2BodyType.STATIC_BODY);
		add(platform);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
	}
	
	override public function draw():Void {
		super.draw();
	}
}