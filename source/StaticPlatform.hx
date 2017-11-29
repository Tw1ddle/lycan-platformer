package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import lycan.world.components.NapeComponent.NapeEntity;
import nape.phys.BodyType;

class StaticPlatform extends FlxSprite implements NapeEntity {
	public function new(x:Int, y:Int, width:Int, height:Int) {
		super(x, y);
		makeGraphic(width, height, FlxColor.fromHSB(360, 1, 1, 0.3));
		
		nape.init(BodyType.STATIC);
		nape.setPosition(x, y);
		nape.body.allowMovement = false;
		nape.body.allowRotation = false;
		nape.body.cbTypes.add(NapeCbTypes.wallType);
		nape.body.userData.gameObject = this;
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
	}
}