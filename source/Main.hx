package;

import flash.geom.Point;
import flixel.FlxBasic;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();
		
		addChild(new FlxGame(1024, 768, RootState, 1, 60, 60, true, false));
	}
}