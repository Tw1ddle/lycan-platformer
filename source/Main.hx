package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();
		
		// Disable right click context menu (desirable in browsers)
		stage.showDefaultContextMenu = false;
		
		addChild(new FlxGame(1024, 768, RootState, 1, 60, 60, true, false));
	}
}