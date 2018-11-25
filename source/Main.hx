package;

import nape.dynamics.CollisionArbiter;
import flixel.FlxGame;
import openfl.display.Sprite;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.math.FlxRandom;
import flixel.system.debug.FlxDebugger.FlxDebuggerLayout;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.util.FlxStringUtil;
import nape.callbacks.BodyCallback;
import nape.callbacks.BodyListener;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.Material;
import nape.shape.Circle;
import nape.space.Space;

class Main extends Sprite {
	public function new() {
		super();
		
		// Disable right click context menu (desirable in browsers)
		stage.showDefaultContextMenu = false;
		
		addChild(new FlxGame(1024, 768, RootState, 1, 60, 60, true, false));
	}
}