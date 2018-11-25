package;

import flixel.FlxG;
import flixel.system.scaleModes.RatioScaleMode;
import lycan.core.LG;
import lycan.states.LycanRootState;
import lycan.states.LycanState;

class RootState extends LycanRootState {
	
	var testStates:Array<Class<LycanState>> = [TiledTestState];
	var currentTestState:Int = 0;
	
	public function new() {
		super();
		persistentUpdate = true;
		destroySubStates = true;
		
		// Only use system cursor in browser, otherwise you see both
		#if html5
		FlxG.mouse.useSystemCursor = true;
		#end
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