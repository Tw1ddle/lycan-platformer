package;

import nape.geom.ConvexResult;
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
import lycan.components.Entity;
import lycan.components.Component;
import flixel.FlxObject;
import lycan.world.components.CharacterController;

class Player extends LSprite implements CharacterController implements Groundable implements PhysicsEntity {
	public function new(x:Int, y:Int, width:Int, height:Int) {
		super(x, y);

		GraphicUtil.makePlaceholderGraphic(this, "player", width, height, [
			{name: "idle", frameCount: 4},
			{name: "run", frameCount: 8},
			{name: "jump", frameCount: 1},
			{name: "zeroG", frameCount: 1},
			{name: "fall", frameCount: 1}
		], FlxColor.WHITE, 10);
		
		characterController.init();
	}
	
	override public function update(dt:Float) {
		super.update(dt);
	}
	
	override function updateAnimation(dt:Float) {
		var body = physics.body;
		var velocity = body.velocity;
		
		if (groundable.isGrounded) {
			//if (characterController.)
			animation.play("idle");
		} else {
			if (velocity.y > 200) {
				animation.play("fall");
			} else if (velocity.y < -200) {
				animation.play("jump");
			} else {
				animation.play("zeroG");
			}
		}
		
		setFacingFlip(RIGHT, false, false);
		setFacingFlip(LEFT, true, false);
		
		
		super.updateAnimation(dt);
	}
	
	

}