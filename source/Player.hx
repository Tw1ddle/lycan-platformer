package;

import flixel.FlxSprite;
import lycan.world.components.NapeComponent.NapeEntity;
import flixel.util.FlxColor;
import nape.phys.BodyType;

class Player extends FlxSprite implements NapeEntity {
	public function new() {
		super(0, 0);
		makeGraphic(40, 120, FlxColor.fromHSB(360, 1, 1, 0.4));
		
		nape.init(BodyType.KINEMATIC);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
	}
}