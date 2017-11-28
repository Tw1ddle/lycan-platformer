package;

import flixel.system.scaleModes.RatioScaleMode;
import lycan.states.LycanRootState;
import flixel.FlxG;

import lycan.components.entities.CameraEmitter;
import lycan.components.Attachable;
import lycan.components.CameraAttachable;
import lycan.components.CenterPositionable;
import lycan.components.Component;
import lycan.components.Entity;
import lycan.world.World;

class RootState extends LycanRootState {
	private var states = [];
	
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
		openSubState(new NapePhysicsTestState());
	}
}