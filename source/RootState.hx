package;

import flixel.FlxG;
import flixel.system.scaleModes.RatioScaleMode;
import lycan.states.LycanRootState;

class RootState extends LycanRootState {
	public function new() {
		super();
		persistentUpdate = true;
		destroySubStates = true;
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
		closeSubState();
		
		//openSubState(new Box2dPhysicsState());
		openSubState(new PhysicsTestState());
	}
}