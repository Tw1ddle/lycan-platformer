package;

import box2D.dynamics.B2World;
import lycan.states.LycanState;
import lycan.world.Box2D;

class PhysicsTestState extends BaseSubState {
	private var world:B2World;
	
	public function new() {
		super();
	}
	
	override public function create():Void {
		super.create();
		
		var b2 = Box2D.get;
		world = b2.world;
		b2.drawDebug = true;
		
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
	}
	
	override public function draw():Void {
		super.draw();
		
		//space.draw();
	}
}