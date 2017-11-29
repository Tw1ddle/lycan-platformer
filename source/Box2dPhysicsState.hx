package;

/*
* Originally based on one of the Box2D Haxe port samples (https://github.com/openfl/box2d)
* Which was provided with the following license:
* 
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

import box2D.collision.*;
import box2D.collision.shapes.*;
import box2D.common.*;
import box2D.common.math.*;
import box2D.dynamics.*;
import box2D.dynamics.contacts.*;
import box2D.dynamics.controllers.B2BuoyancyController;
import box2D.dynamics.joints.*;
import flash.display.Sprite;
import flixel.FlxG;
import lycan.states.LycanState;

class Box2dPhysicsState extends LycanState {
	// Physics engine step iterations
	private static inline var velocityIterations:Int = 10;
	private static inline var positionIterations:Int = 10;
	
	private static inline var physicsScale:Int = 30; // Scale factor mapping physics world to game world
	
	private var gravityVector = new B2Vec2(0, 20); // Gravity vector
	private var allowBodySleep:Bool = true; // Allow bodies to sleep
	private var world:B2World = null; // Box2D world
	private var enableWarmStarting:Bool = true; // Enable correction code that should reduce tunnelling etc
	
	private var worldBodies:Array<B2Body> = [];
	
	private var debugSprite:Sprite = null; // Debug sprite for displaying the Box2D world
	
	private var mouseJoint:B2MouseJoint = null; // Mouse joint for interactively manipulating the Box2D world
	
	private var mouseX(get, never):Float;
	private var mouseY(get, never):Float;
	private var physicsMouseX(get, never):Float;
	private var physicsMouseY(get, never):Float;

	public function new() {
		super();
		
		world = new B2World(gravityVector, allowBodySleep);
		world.setWarmStarting(enableWarmStarting);
		
		function setupDebugDrawing() {
			var dbgDraw:B2DebugDraw = new B2DebugDraw();
			debugSprite = new Sprite();
			dbgDraw.setSprite(debugSprite);
			dbgDraw.setDrawScale(30.0);
			dbgDraw.setFillAlpha(0.3);
			dbgDraw.setLineThickness(1.0);
			dbgDraw.setFlags(B2DebugDraw.e_shapeBit | B2DebugDraw.e_jointBit);
			world.setDebugDraw(dbgDraw);
		}();
		
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
		
		function addPlatform() {
			var platform:B2PolygonShape = new B2PolygonShape();
			var platformDef:B2BodyDef = new B2BodyDef();
			
			platformDef.position.set(300 / physicsScale, 200 / physicsScale);
			platform.setAsBox(200 / physicsScale, 25 / physicsScale);
			world.createBody(platformDef).createFixture2(platform);
		}();
		
		function addBodies() {
			var ground:B2Body = world.getGroundBody();
			var i:Int;
			var anchor:B2Vec2 = new B2Vec2();
			var body:B2Body;
			var fd:B2FixtureDef;
			
			var boxDef:B2PolygonShape = new B2PolygonShape();
			
			var bodyDef:B2BodyDef = new B2BodyDef();
			for(i in 0...5) {
				bodyDef.type = 2;
				fd = new B2FixtureDef();
				fd.shape = boxDef;
				fd.density = 1.0;
				
				// Override the default friction
				fd.friction = 0.3;
				fd.restitution = 0.1;
				boxDef.setAsBox((Math.random() * 5 + 10) / physicsScale, (Math.random() * 5 + 10) / physicsScale);
				bodyDef.position.set((Math.random() * 400 + 120) / physicsScale, (Math.random() * 150 + 50) / physicsScale);
				bodyDef.angle = Math.random() * Math.PI;
				body = world.createBody(bodyDef);
				body.createFixture(fd);
				worldBodies.push(body);
			}
			
			var circDef:B2CircleShape;
			for (i in 0...5) {
				var bodyDefC:B2BodyDef = new B2BodyDef();
				bodyDefC.type = 2;
				circDef = new B2CircleShape((Math.random() * 5 + 10) / physicsScale);
				fd = new B2FixtureDef();
				fd.shape = circDef;
				fd.density = 1.0;
				
				// Override the default friction
				fd.friction = 0.3;
				fd.restitution = 0.1;
				bodyDefC.position.set((Math.random() * 400 + 120) / physicsScale, (Math.random() * 150 + 50) / physicsScale);
				bodyDefC.angle = Math.random() * Math.PI;
				body = world.createBody(bodyDefC);
				body.createFixture(fd);
				worldBodies.push(body);
			}
			
			var bodyDefP:B2BodyDef;
			for (i in 0...5) {
				bodyDefP = new B2BodyDef();
				bodyDefP.type = 2;
				
				var polyDef:B2PolygonShape = new B2PolygonShape();
				if (Math.random() > 0.66) {
					polyDef.setAsArray([
						new B2Vec2((-10 -Math.random()*10) / physicsScale, ( 10 +Math.random()*10) / physicsScale),
						new B2Vec2(( -5 -Math.random()*10) / physicsScale, (-10 -Math.random()*10) / physicsScale),
						new B2Vec2((  5 +Math.random()*10) / physicsScale, (-10 -Math.random()*10) / physicsScale),
						new B2Vec2(( 10 +Math.random() * 10) / physicsScale, ( 10 +Math.random() * 10) / physicsScale)
						]);
				} else if (Math.random() > 0.5) {
					var array:Array<B2Vec2> = [];
					array[0] = new B2Vec2(0, (10 +Math.random()*10) / physicsScale);
					array[2] = new B2Vec2((-5 -Math.random()*10) / physicsScale, (-10 -Math.random()*10) / physicsScale);
					array[3] = new B2Vec2(( 5 +Math.random()*10) / physicsScale, (-10 -Math.random()*10) / physicsScale);
					array[1] = new B2Vec2((array[0].x + array[2].x), (array[0].y + array[2].y));
					array[1].multiply(Math.random()/2+0.8);
					array[4] = new B2Vec2((array[3].x + array[0].x), (array[3].y + array[0].y));
					array[4].multiply(Math.random() / 2 + 0.8);
					polyDef.setAsArray(array);
				} else {
					polyDef.setAsArray([
						new B2Vec2(0, (10 +Math.random()*10) / physicsScale),
						new B2Vec2((-5 -Math.random()*10) / physicsScale, (-10 -Math.random()*10) / physicsScale),
						new B2Vec2(( 5 +Math.random() * 10) / physicsScale, ( -10 -Math.random() * 10) / physicsScale)
					]);
				}
				fd = new B2FixtureDef();
				fd.shape = polyDef;
				fd.density = 1.0;
				fd.friction = 0.3;
				fd.restitution = 0.1;
				bodyDefP.position.set((Math.random() * 400 + 120) / physicsScale, (Math.random() * 150 + 50) / physicsScale);
				bodyDefP.angle = Math.random() * Math.PI;
				body = world.createBody(bodyDefP);
				body.createFixture(fd);
				worldBodies.push(body);
			};
		}();
		
		function setupBuoyancyController() {
			var buoyancyController = new B2BuoyancyController();
			buoyancyController.normal.set(0,-1);
			buoyancyController.offset = -200 / physicsScale;
			buoyancyController.density = 2.0;
			buoyancyController.linearDrag = 5;
			buoyancyController.angularDrag = 2;

			for(body in worldBodies) {
				buoyancyController.addBody(body);
			}
			
			world.addController(buoyancyController);
		}();
	}
	
	override public function create():Void {
		super.create();
		FlxG.addChildBelowMouse(debugSprite); // Add debug Box2D sprite
	}
	
	override public function destroy():Void {
		FlxG.game.removeChild(debugSprite); // Remove debug Box2D sprite
		super.destroy();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		handleInput(dt);
		updatePhysics(dt);
	}
	
	override public function draw():Void {
		super.draw();
		
		world.drawDebugData();
		
		// Draw water line
		debugSprite.graphics.lineStyle(1, 0x0000FF, 1);
		debugSprite.graphics.moveTo(5, 200);
		debugSprite.graphics.lineTo(635, 200);
	}
	
	private function handleInput(dt:Float):Void {
		handleMouse();
		handleKeys();
	}
	
	private function updatePhysics(dt:Float):Void {
		world.step(dt, velocityIterations, positionIterations);
		world.clearForces();
	}
	
	private function handleMouse():Void {
		if (FlxG.mouse.justPressed) {
			
			if (mouseJoint == null) {
				
				var bodyAtMouse = getBodyAtMouse();
				if (bodyAtMouse != null) {
					var jointDef = new B2MouseJointDef();
					jointDef.bodyA = world.getGroundBody();
					jointDef.bodyB = bodyAtMouse;
					jointDef.target.set(physicsMouseX, physicsMouseY);
					jointDef.collideConnected = true;
					jointDef.maxForce = 300 * bodyAtMouse.getMass();
					mouseJoint = cast world.createJoint(jointDef);
					
					bodyAtMouse.setAwake(true);
					
				}
			}
			
		} else if (FlxG.mouse.justReleased) {
			
			if (mouseJoint != null) {
				world.destroyJoint(mouseJoint);
				mouseJoint = null;
			}
			
		} else if (FlxG.mouse.justMoved) {
			
			if (mouseJoint != null) {
				mouseJoint.setTarget(new B2Vec2(physicsMouseX, physicsMouseY));
			}
			
		}
	}
	
	private function handleKeys():Void {
		if(FlxG.keys.pressed.D) {
			var body = getBodyAtMouse();
			if (body != null) {
				world.destroyBody(body);
			}
		}
	}
	
	private function getBodyAtMouse():B2Body {		
		// Make a small box around the mouse position
		var mousePVec = new B2Vec2(physicsMouseX, physicsMouseY);
		var aabb:B2AABB = new B2AABB();
		aabb.lowerBound.set(physicsMouseX - 0.001, physicsMouseY - 0.001);
		aabb.upperBound.set(physicsMouseX + 0.001, physicsMouseY + 0.001);
		var body:B2Body = null;
		
		// Query the world for overlapping shapes
		var getBodyCallback = function(fixture:B2Fixture):Bool {
			var shape:B2Shape = fixture.getShape();
			if (shape.testPoint(fixture.getBody().getTransform(), mousePVec)) {
				body = fixture.getBody();
				return false;
			}
			return true;
		}
		world.queryAABB(getBodyCallback, aabb);
		return body;
	}
	
	private function get_mouseX():Float {
		return FlxG.mouse.x;
	}
	private function get_mouseY():Float {
		return FlxG.mouse.y;
	}
	private function get_physicsMouseX():Float {
		return mouseX / physicsScale;
	}
	private function get_physicsMouseY():Float {
		return mouseY / physicsScale;
	}
}