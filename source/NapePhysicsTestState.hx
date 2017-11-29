package;

import flixel.FlxG;
import lycan.world.NapeSpace;
import nape.geom.Vec2;
import nape.callbacks.InteractionListener;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionType;
import nape.callbacks.InteractionCallback;

class NapePhysicsTestState extends BaseSubState {
	private var space:NapeSpace;
	private var player:Player;
	private var platform1:StaticPlatform;
	private var platform2:StaticPlatform;
	
	public function new() {
		super();
	}
	
	override public function create():Void {
		super.create();
		
		space = new NapeSpace();
		NapeSpace.init();
		NapeSpace.drawDebug = true;
		NapeSpace.space.gravity = new Vec2(0, 250);
		
		NapeSpace.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, NapeCbTypes.playerType, NapeCbTypes.wallType, onPlayerStartedInteraction));
		NapeSpace.space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.COLLISION, NapeCbTypes.playerType, NapeCbTypes.wallType, onPlayerEndedInteraction));
		
		player = new Player();
		add(player);
		
		platform1 = new StaticPlatform(Std.int(FlxG.width * 0.475), Std.int(FlxG.height * 0.9), Std.int(FlxG.width * 0.9), 25);
		add(platform1);
		
		platform2 = new StaticPlatform(FlxG.width - 100, Std.int(FlxG.height / 2), 25, Std.int(FlxG.height));
		add(platform2);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		trace(player.nape.body.arbiters);
	}
	
	override public function draw():Void {
		super.draw();
	}
	
	private function onPlayerStartedInteraction(collision:InteractionCallback):Void {
		trace("PLAYER STARTED INTERACTING WITH WALL");
		trace(collision.int1.userData);
		player.groundable.add(cast collision.int2.userData.gameObject);
	}
	
	private function onPlayerEndedInteraction(collision:InteractionCallback):Void {
		trace("PLAYER FINISHED INTERACTING WITH WALL");
		player.groundable.remove(cast collision.int2.userData.gameObject);
	}
}