package;

import flixel.FlxG;
import flixel.system.scaleModes.RatioScaleMode;
import lycan.states.LycanRootState;
import flixel.math.FlxMath;

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
		
		if (FlxG.keys.justPressed.O) {
			targetZoom += 0.5;
		} else if (FlxG.keys.justPressed.P) {
			targetZoom -= 0.5;
		}
		easeCameraZoom();
	}
	
	private function openPlaystate():Void {
		closeSubState();

		//openSubState(new Box2dPhysicsState());
		//openSubState(new AutotilingState());
		//openSubState(new PhysicsTestState());
		openSubState(new TiledTestState());
	}
	
	// Some code for easing the zoom level
	private var actualZoom(get, set):Float;
	private function get_actualZoom():Float {
		return FlxG.camera.zoom;
	}
	private function set_actualZoom(zoom:Float):Float {
		FlxG.camera.zoom = zoom;
		return FlxG.camera.zoom;
	}
	private var targetZoom(default, set):Float = 1;
	private function set_targetZoom(zoom:Float):Float {
		return this.targetZoom = FlxMath.bound(zoom, 0.05, 3);
	}
	private function easeCameraZoom():Void {
		actualZoom = FlxMath.lerp(actualZoom, targetZoom, 0.02);
	}
}