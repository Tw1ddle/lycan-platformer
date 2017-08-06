package;

import flixel.FlxGame;
import openfl.display.Sprite;

import lycan.states.LycanRootState;

class Main extends Sprite {
	public function new() {
		super();
		addChild(new FlxGame(0, 0, LycanRootState, 1, 60, 60, true, false));
	}
}