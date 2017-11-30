package;

import box2D.dynamics.B2World;
import flixel.FlxSprite;
import lycan.components.entities.LSprite;
import lycan.states.LycanState;
import lycan.world.Box2D;
import lycan.world.components.PhysicsEntity;

import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.B2BodyDef;

class PhysSprite extends FlxSprite implements PhysicsEntity {
	public function new() {
		super(100, 100);
	}
	
	override public function destroy():Void	super.destroy();
	override public function kill():Void	super.kill();
	override public function revive():Void	super.revive();
}

class PhysicsTestState extends LycanState {
	private var world:B2World;
	
	override public function create():Void {
		super.create();
		
		Box2D.init();
		world = Box2D.world;
		Box2D.drawDebug = true;
		
		var physicsScale = 30; // TODO
		
		var s:PhysSprite = new PhysSprite();
		//s.physics.
		add(s);
		
		function addWalls() {
			var wall:B2PolygonShape= new B2PolygonShape();
			var wallBd:B2BodyDef = new B2BodyDef();			
			// Left
			wallBd.position.set(-95 / physicsScale, 360 / physicsScale / 2);
			wall.setAsBox(100 / physicsScale, 400 / physicsScale / 2);
			world.createBody(wallBd).createFixture2(wall);
			// Right
			wallBd.position.set((640 + 95) / physicsScale, 360 / physicsScale / 2);
			world.createBody(wallBd).createFixture2(wall);
			// Top
			wallBd.position.set(640 / physicsScale / 2, -95 / physicsScale);
			wall.setAsBox(680 / physicsScale/2, 100 / physicsScale);
			world.createBody(wallBd).createFixture2(wall);
			// Bottom
			wallBd.position.set(640 / physicsScale / 2, (360 + 95) / physicsScale);
			world.createBody(wallBd).createFixture2(wall);
		}();
		
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
	}
	
	override public function draw():Void {
		super.draw();
		
		//space.draw();
	}
}