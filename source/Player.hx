package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import lycan.world.components.Groundable;
import lycan.world.components.PhysicsEntity;

class Player extends FlxSprite implements PhysicsEntity implements Groundable {
	public function new(x:Int, y:Int, width:Int, height:Int) {
		super(x, y);
		makeGraphic(width, height, FlxColor.fromRGB(255, 255, 0, 180));

		physics.init();
		physics.addRectangularShape(width, height, 50);
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
			physics.linearVelocityY = -2;
		}
		
		if (groundable.isGrounded) {
			trace(groundable.isGrounded); // (actually before it updates, since it's appended)
		}
	}
}