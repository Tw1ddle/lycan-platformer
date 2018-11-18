package;

import lycan.entities.LSprite;
import flixel.util.FlxColor;
import lycan.world.components.PhysicsEntity;

class PhysSprite extends LSprite implements PhysicsEntity {
	public function new(x:Int, y:Int, width:Int, height:Int) {
		super(x, y);
		makeGraphic(width, height, FlxColor.fromRGB(255, 0, 64, 128));
		//pixelPerfectPosition = true;
		physics.init();
	}
}