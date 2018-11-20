package;

import box2D.collision.B2WorldManifold;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import box2D.collision.shapes.B2MassData;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Fixture;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import lycan.entities.LSprite;
import lycan.util.GraphicUtil;
import lycan.world.components.Groundable;
import lycan.world.components.PhysicsEntity;
import box2D.dynamics.B2FilterData;
import box2D.dynamics.B2Fixture;

class MovingPlatform {}

class Player extends LSprite implements PhysicsEntity implements Groundable {
	var jumpSpeed:Float = -8;
	var runImpulse:Float = 10;
	var runSpeed:Float = 5;
	var movingPlatforms:Array<MovingPlatform>;
	var currentMovingPlatform:MovingPlatform;
	
	var feetFixture:B2Fixture;
	
	public function new(x:Int, y:Int, width:Int, height:Int) {
		super(x, y);
		makeGraphic(width, height, FlxColor.fromRGB(255, 255, 0, 180));
		
		GraphicUtil.makePlaceholderGraphic(this, "player", width, height, [
			{name: "idle", frameCount: 4},
			{name: "run", frameCount: 8},
			{name: "jumpUp", frameCount: 1},
			{name: "zeroG", frameCount: 1},
			{name: "fall", frameCount: 1}
		], FlxColor.WHITE, 10);
		
		physics.init();
		physics.fixedRotation = true;
		physics.sleepingAllowed = false;
		physics.addRectangularShapeAdv(width, height - width / 2, 0, -width / 4, 50, new B2FilterData(), 10, false, 0, this);
		feetFixture = physics.addCircleShapeAdv(width / 2, 0, (height - width) / 2, 0, new B2FilterData(), 0, false, 0, this);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		var running:Bool = false;
		if (physics.linearVelocityX > -runSpeed && FlxG.keys.anyPressed([FlxKey.A, FlxKey.LEFT])) {
			physics.applyImpulse(-runImpulse, 0);
			running = true;
		} else if (physics.linearVelocityX < runSpeed && FlxG.keys.anyPressed([FlxKey.D, FlxKey.RIGHT])) {
			physics.applyImpulse(runImpulse, 0);
			running = true;
		}
		
		
		if (FlxG.keys.anyPressed([FlxKey.ENTER])) {
			animation.play("run");
		}
		if (FlxG.keys.anyPressed([FlxKey.SPACE])) {
			animation.play("idle");
		}
		
		var c = physics.body.getContactList();
		groundable.forceGrounded = false;
		var i:Int = 0;
		while (c != null) {
			// Todo where were the extra contacts coming from without this!?
			if (c.contact.isTouching()) {
				var wm = new B2WorldManifold();
				c.contact.getWorldManifold(wm);
				var normal:B2Vec2 = wm.m_normal;
				var fn:FlxVector = FlxVector.get(normal.x, normal.y);
				var fa:Bool = c.contact.getFixtureA().m_body == physics.body;
				FlxG.watch.addQuick("normal", normal.x + " " + normal.y);
				FlxG.watch.addQuick("body a", fa);
				FlxG.watch.addQuick("body b", c.contact.getFixtureB().m_body == physics.body);
				var a:Float = fn.angleBetween(FlxPoint.weak(0, fa ? 0 : -1));
				fn.put();
				
				if (Math.abs(a) < 30) groundable.forceGrounded = true;
				
				i++;
			}
			c = c.next;
		}
		FlxG.watch.addQuick("contacts", i);
		
		if (groundable.isGrounded && !running) {
			feetFixture.setFriction(100);
		} else {
			feetFixture.setFriction(0);
		}
		
		if (FlxG.keys.anyPressed([FlxKey.W, FlxKey.UP])) {
			if (groundable.isGrounded) {// TODO condition
				physics.linearVelocityY = jumpSpeed;
			}
		}
		
		//physics.body.getContactList
		// TODO double jumps + not hanging on walls
	}
	
	public function run() {
		
	}
	
	public function jump() {
		
	}
}