package;

import flixel.FlxG;
import flixel.system.scaleModes.RatioScaleMode;
import lycan.states.LycanRootState;

class RootState extends LycanRootState {
	public function new() {
		super();
	}
	
	override public function create():Void {
		super.create();
		FlxG.scaleMode = new RatioScaleMode();
		openPlaystate();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		if (FlxG.keys.justPressed.R) {
			openPlaystate();
		}
	}
	
	private function openPlaystate():Void {
		openSubState(new Box2dPhysicsState());
	}
}