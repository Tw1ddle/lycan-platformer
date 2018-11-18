package;

import lycan.states.LycanState;
import flixel.FlxG;
import flixel.system.scaleModes.RatioScaleMode;
import lycan.states.LycanRootState;
import flixel.math.FlxMath;

class RootState extends LycanRootState {
	
	var testStates:Array<Class<LycanState>> = [PhysicsTestState];
	var currentTestState:Int = 0;
	
	public function new() {
		super();
		persistentUpdate = true;
		destroySubStates = true;
	}
	
	override public function create():Void {
		super.create();
		FlxG.scaleMode = new RatioScaleMode();
		
		openSubState(Type.createInstance(testStates[currentTestState], []));
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		
		if (FlxG.keys.justPressed.F1) {
			currentTestState++;
			if (currentTestState >= testStates.length) currentTestState = 0;
			openSubState(Type.createInstance(testStates[currentTestState], []));
		}
	}
}