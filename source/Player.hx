package;

import nape.phys.Body;
import flixel.math.FlxMath;
import lycan.phys.PlatformerPhysics;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.geom.Vec2;
import nape.shape.Circle;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import lycan.entities.LSprite;
import lycan.util.GraphicUtil;
import lycan.world.components.Groundable;
import lycan.world.components.PhysicsEntity;
import nape.shape.Shape;
import nape.phys.BodyType;
import lycan.phys.Phys;

class MovingPlatform {}

class Player extends LSprite implements PhysicsEntity implements Groundable {
	var jumpSpeed:Float = -1200;
	var runImpulse:Float = 1000;
	var runSpeed:Float = 500;
	var maxJumps:Int = 2;
	var maxJumpVelY:Float = 200;
	var airDrag:Float = 2500;
	
	/** Indicates how in control the character is. Applies high drag while in air. */
	var hasControl:Bool;
	var currentJumps:Int;
	var canJump:Bool;
	
	var movingPlatforms:Array<MovingPlatform>;
	var currentMovingPlatform:MovingPlatform;
	
	var bodyShape:Shape;
	var feetShape:Shape;
	
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
		
		physics.init(BodyType.DYNAMIC, false);
		physics.body.position.setxy(x, y);
		physics.body.allowRotation = false;
		feetShape = new Circle(width / 2, Vec2.weak(0, (height - width) / 2));
		bodyShape = new Polygon(Polygon.rect(-width / 2, -height / 2, width, height - width / 2));
		physics.body.shapes.add(feetShape);
		physics.body.shapes.add(bodyShape);
		physics.setBodyMaterial();
		// //feetShape.
		
		hasControl = true;
		currentJumps = 0;
		
		physics.body.cbTypes.add(PlatformerPhysics.groundableType);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		var running:Bool = false;
		if (physics.body.velocity.x > -runSpeed && FlxG.keys.anyPressed([FlxKey.A, FlxKey.LEFT])) {
			physics.body.applyImpulse(Vec2.weak(-runImpulse, 0));
			running = true;
		} else if (physics.body.velocity.x < runSpeed && FlxG.keys.anyPressed([FlxKey.D, FlxKey.RIGHT])) {
			physics.body.applyImpulse(Vec2.weak(runImpulse, 0));
			running = true;//TODO rename to moving
		}
		if (FlxG.keys.anyPressed([A, LEFT, RIGHT, D])) running = true;
		
		
		if (FlxG.keys.anyPressed([FlxKey.ENTER])) {
			animation.play("run");
		}
		if (FlxG.keys.anyPressed([FlxKey.SPACE])) {
			animation.play("idle");
		}
		
		FlxG.watch.addQuick("grounded", groundable.isGrounded);
		if (groundable.isGrounded && !running) {
			feetShape.material.dynamicFriction = 100;
			feetShape.material.staticFriction = 100;
		} else {
			feetShape.material.dynamicFriction = 0;
			feetShape.material.staticFriction = 0;
		}
		
		FlxG.watch.addQuick("feet friction", feetShape.material.dynamicFriction);
		
		var body:Body = physics.body;
		
		if (groundable.isGrounded) {
			currentJumps = 0;
			canJump = true;
		} else {
			if (hasControl && !running) {
				var vx:Float = body.velocity.x;
				body.velocity.x -= FlxMath.signOf(vx) * Math.min(dt * airDrag, Math.abs(vx));
			}
		}
		
		if (currentJumps >= maxJumps || (body.velocity.y > maxJumpVelY && !groundable.isGrounded)) {
			canJump = false;
		}
		
		
		if (FlxG.keys.anyJustPressed([FlxKey.W, FlxKey.UP])) {
			if (canJump) {
				currentJumps++;
				physics.body.velocity.y = jumpSpeed;
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