package;

import box2D.collision.shapes.B2MassData;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Fixture;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import lycan.entities.LSprite;
import lycan.util.GraphicUtil;
import lycan.world.components.Groundable;
import lycan.world.components.PhysicsEntity;
import box2D.dynamics.B2FilterData;

class MovingPlatform {}

class Player extends LSprite implements PhysicsEntity implements Groundable {
	var jumpSpeed:Float = -8;
	var runImpulse:Float = 10;
	var runSpeed:Float = 5;
	var movingPlatforms:Array<MovingPlatform>;
	var currentMovingPlatform:MovingPlatform;
	
	public function new(x:Int, y:Int, width:Int, height:Int) {
		super(x, y);
		makeGraphic(width, height, FlxColor.fromRGB(255, 255, 0, 180));
		
		GraphicUtil.makePlaceholderGraphic(this, "player", width, height, [
			{name: "idle", frameCount: 4},
			{name: "run", frameCount: 8},
			{name: "jumpUp", frameCount: 1},
			{name: "zeroG", frameCount: 1},
			{name: "fall", frameCount: 1}
		], FlxColor.WHITE, 10);
		
		physics.init();
		physics.fixedRotation = true;
		physics.sleepingAllowed = false;
		physics.addRectangularShapeAdv(width, height, 0, 0, 50, new B2FilterData(), 10, false, 0, this);
		
		//box2D.collision.
		//physics.body.getContactList()
		
		// Sensor for checking if grounded
		var groundedSensor = physics.addCircleShapeAdv(10, 0, height / 2, 50, new B2FilterData(), 10, true, 0, this);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		if (FlxG.keys.anyPressed([FlxKey.A, FlxKey.LEFT])) {
			physics.applyImpulse(-runImpulse, 0);
		} else if (FlxG.keys.anyPressed([FlxKey.D, FlxKey.RIGHT])) {
			physics.applyImpulse(runImpulse, 0);
		}
		
		
		if (FlxG.keys.anyPressed([FlxKey.ENTER])) {
			animation.play("run");
		}
		if (FlxG.keys.anyPressed([FlxKey.SPACE])) {
			animation.play("idle");
		}
		
		if (FlxG.keys.anyJustPressed([FlxKey.W, FlxKey.UP])) {
			if (true || groundable.isGrounded) {// TODO condition
				physics.linearVelocityY = jumpSpeed;
			}
		}
		
		// TODO double jumps + not hanging on walls
		
		if (groundable.isGrounded) {
			trace(groundable.isGrounded); // (actually before it updates, since it's appended)
		}
	}
	
	public function run() {
		
	}
	
	public function jump() {
		
	}
}