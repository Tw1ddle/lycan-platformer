package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import lycan.world.components.GroundableComponent.Groundable;

class Player extends FlxSprite implements Groundable {
	public function new() {
		super(0, 0);
		makeGraphic(40, 120, FlxColor.fromHSB(360, 1, 1, 0.4));

		//nape.init(BodyType.KINEMATIC);
		//nape.setPosition(FlxG.width / 2, 200);
		//nape.body.cbTypes.add(NapeCbTypes.playerType);
		//nape.body.userData.gameObject = this;
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		var runSpeed = 25 * dt;
		
		if (FlxG.keys.anyPressed([FlxKey.A, FlxKey.LEFT])) {
			//nape.body.velocity.x = -runSpeed;
		} else if (FlxG.keys.anyPressed([FlxKey.D, FlxKey.RIGHT])) {
			//nape.body.velocity.x = runSpeed;
		} else {
			
		}
		
		if (FlxG.keys.anyJustPressed([FlxKey.W, FlxKey.UP])) {
			// TODO jump
		}
		
		if (groundable.isGrounded) {
			trace(groundable.isGrounded); // (actually before it updates, since it's appended)
		}
	}
}