package;

import lycan.states.LycanState;
import lycan.world.NapeSpace;

class NapePhysicsTestState extends BaseSubState {
	private var space:NapeSpace;
	private var player:Player;
	
	public function new() {
		super();
	}
	
	override public function create():Void {
		super.create();
		
		space = new NapeSpace();
		NapeSpace.init();
		NapeSpace.drawDebug = true;
		
		player = new Player();
		add(player);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
	}
	
	override public function draw():Void {
		super.draw();
		
		space.draw();
	}
}