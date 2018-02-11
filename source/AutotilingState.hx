package;

import flixel.FlxSprite;
import lycan.states.LycanRootState;
import lycan.states.LycanState;
import flixel.FlxG;
import flixel.FlxBasic;

class AutotilingState extends LycanState {
	public var s:FlxSprite;
	var springX:Spring;
	var springY:Spring;
	
	override public function create():Void {
		super.create();
		
		bgColor = 0xff444444;
		//FlxG.camera.x -= 200;
		//FlxG.camera.y -= 200;
		//FlxG.camera.width += 400;
		//FlxG.camera.height += 400;
		
		springX = new Spring();
		springY = new Spring();
		s = new FlxSprite(200, 200);
		s.scale.set(0.8, 0.8);
		s.scrollFactor.set();
		
		add(s);
		
		springX.setTarget(FlxG.camera.scroll, "x");
		springY.setTarget(FlxG.camera.scroll, "y");
		
		add(springX);
		add(springY);
		
		for (i in 0...50) {
			var b:FlxSprite = cast add(new FlxSprite(FlxG.random.float(FlxG.width), FlxG.random.float(FlxG.height)));
			var sf:Float = FlxG.random.float(0.1, 1.5);
			b.scrollFactor.set(sf, sf);
			b.alpha = (sf - 0.1) / 1.4;
			b.scale.set(sf, sf);
		}
	}
	
	override public function update(dt:Float):Void {
		if (FlxG.mouse.justPressed) {
			var dx:Float = FlxG.mouse.x - ((s.x + (s.width / 2)));
			springX.velocity += dx * 10;
			var dy:Float = FlxG.mouse.y - ((s.y + (s.height / 2)));
			springY.velocity += dy * 10;
		}
		
		super.update(dt);
	}
}

@:tink
class Spring2D extends FlxBasic {
	public var springX:Spring;
	public var springY:Spring;
	
	@:prop(return springX.value, springX.value = param) var x:Float;
	@:prop(return springY.value, springY.value = param) var y:Float;
	@:prop(return springX.velocity, springX.velocity = param) var velocityX:Float;
	@:prop(return springY.velocity, springY.velocity = param) var velocityY:Float;
	
	public function new(springConstant:Float = 8, damping:Float = 7, minPeakForce:Float = 2, mass:Float = 1) {
		super();
		springX = new Spring(springConstant, damping, minPeakForce, mass);
		springY = new Spring(springConstant, damping, minPeakForce, mass);
	}
}