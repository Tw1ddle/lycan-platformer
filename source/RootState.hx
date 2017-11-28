package;

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
	public function new() {
		super();
	}
	
	override public function create():Void {
		super.create();
		openSubState(new PlayState());
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		if (FlxG.keys.justPressed.R) {
			// TODO reload world
		}
	}
	
	private function openPlaystate():Void {
		
	}
}