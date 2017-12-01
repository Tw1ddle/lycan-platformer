package;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Fixture;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import lycan.world.components.Groundable;
import lycan.world.components.PhysicsEntity;
import box2D.dynamics.B2FilterData;

class Player extends FlxSprite implements PhysicsEntity implements Groundable {
	public function new(x:Int, y:Int, width:Int, height:Int) {
		super(x, y);
		makeGraphic(width, height, FlxColor.fromRGB(255, 255, 0, 180));

		physics.init();
		physics.fixedRotation = true;
		physics.sleepingAllowed = false;
		physics.addRectangularShapeAdv(width, height, 0, 0, 50, new B2FilterData(), 10, false, 0, this);
		
		// Sensor for checking if grounded
		var groundedSensor = physics.addCircleShapeAdv(10, 0, height / 2, 50, new B2FilterData(), 10, true, 0, this);
	}
	
	override public function destroy():Void	super.destroy();
	override public function kill():Void	super.kill();
	override public function revive():Void	super.revive();
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		var runSpeed = 250 * dt;
		
		if (FlxG.keys.anyPressed([FlxKey.A, FlxKey.LEFT])) {
		    physics.linearVelocityX = -runSpeed;
		} else if (FlxG.keys.anyPressed([FlxKey.D, FlxKey.RIGHT])) {
			physics.linearVelocityX = runSpeed;
		}
		
		if (FlxG.keys.anyJustPressed([FlxKey.W, FlxKey.UP])) {
			
			if (groundable.isGrounded) {
				physics.linearVelocityY = -2;
			}
			
		}
		
		// TODO double jumps + not hanging on walls
		
		if (groundable.isGrounded) {
			trace(groundable.isGrounded); // (actually before it updates, since it's appended)
		}
	}
}