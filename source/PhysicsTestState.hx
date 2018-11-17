package;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2BodyType;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUISlider;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.media.AudioSource;
import lime.media.openal.ALAuxiliaryEffectSlot;
import lime.media.openal.ALEffect;
import lime.media.openal.ALFilter;
import lycan.components.CameraAttachable;
import lycan.effects.Lightning;
import lycan.effects.LightningZone;
import lycan.entities.LSprite;
import lycan.phys.Phys;
import lycan.states.LycanState;
import lycan.system.FpsText;
import lycan.world.components.PhysicsEntity;
import openfl.Assets;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import lime.media.openal.AL;
import lime.media.openal.ALSource;
import lime.media.AudioSource;

class PhysSprite extends LSprite implements PhysicsEntity {
	public function new(x:Int, y:Int, width:Int, height:Int) {
		super(x, y);
		makeGraphic(width, height, FlxColor.fromRGB(255, 0, 64, 128));
		//pixelPerfectPosition = true;
		physics.init();
	}
}

class CameraLightningZone extends LightningZone implements CameraAttachable {}

@:access(flixel.system.FlxSound)
@:access(lycan.phys.Phys)
class PhysicsTestState extends LycanState {
	var fx:ALEffect;
	var handle:ALSource;
	var freq:Float = 0.5;
	var aux:ALAuxiliaryEffectSlot;
	var lightningZone:CameraLightningZone;
	var lightning:Lightning;
	override public function create():Void {
		super.create();
		//uiGroup.add(new FlxUISlider(this, "freq", 0, 0, 0, 1, 200, 15, 3, 0xffffffff));
		uiGroup.add(new FpsText(0, 0, 24));
		
		lightningZone = new CameraLightningZone(FlxG.width, FlxG.height);
		var cam:CameraAttachableComponent = cast lightningZone.cameraAttachable;
		cam.camera = FlxG.camera;
		
		
		FlxG.camera.pixelPerfectRender = false;
		
		
		lightning = new Lightning(0.4);
		lightning.displaceTime.set(0.7, 1.2);
		lightning.detail = 0.25;
		lightning.regenerateDistance = 30;
		lightning.thickness = 4;
		lightning.lightningType = LightningType.CONTINUOUS;
		lightning.startPoint.set(FlxG.width / 2, FlxG.height / 2);
		lightning.endPoint.set(FlxG.width / 2 + 100, FlxG.height / 2);
		lightning.flickers = false;
		lightning.generate();
		
		lightningZone.add(lightning);
		
		for (i in 0...2) {
			lightning = new Lightning(0.4);
			lightning.displaceTime.set(0.7, 1.2);
			lightning.regenerateDistance = 30;
			lightning.detail = 0.25;
			lightning.thickness = 1;
			lightning.lightningType = LightningType.CONTINUOUS;
			lightning.startPoint.set(FlxG.width / 2, FlxG.height / 2);
			lightning.endPoint.set(FlxG.width / 2 + 100, FlxG.height / 2);
			lightning.generate();
			lightningZone.add(lightning);
		}
		
		add(lightningZone);
		
		lightningZone.enableFilters = false;
		
		//aux = AL.createAux();
		//fx = AL.createEffect();
		//AL.effecti(fx, AL.EFFECT_TYPE, AL.EFFECT_EQUALIZER);
		//AL.effectf(fx, AL.EQUALIZER_LOW_CUTOFF, 0);
		//AL.effectf(fx, AL.EQUALIZER_LOW_GAIN, 0);
		//AL.effectf(fx, AL.EQUALIZER_MID1_CENTER, 0);
		//AL.effectf(fx, AL.EQUALIZER_MID1_GAIN, 0);
		//AL.effectf(fx, AL.EQUALIZER_MID1_WIDTH, 0);
		//AL.effectf(fx, AL.EQUALIZER_MID2_CENTER, 0);
		//AL.effectf(fx, AL.EQUALIZER_MID2_GAIN, 0);
		//AL.effectf(fx, AL.EQUALIZER_MID2_WIDTH, 0);
		//AL.effectf(fx, AL.EQUALIZER_HIGH_CUTOFF, 0);
		//AL.effectf(fx, AL.EQUALIZER_HIGH_GAIN, 0);
		//AL.auxi(aux, AL.EFFECTSLOT_EFFECT, fx);
		
		
		//var sound:FlxSound = FlxG.sound.load("assets/sounds/beeploop.ogg", 1, false);
		//var s:Sound = sound._sound;
		//var soundChannel:SoundChannel = s.play(0, 0);
		//var source:AudioSource = @:privateAccess soundChannel.__source;
		//var sendIndex:Int = 0;
		//var backend:lime._internal.backend.native.NativeAudioSource = @:privateAccess source.__backend;
		//handle = @:privateAccess backend.handle;
		//AL.sourcei(handle, AL.LOOPING, AL.TRUE);
		
		Phys.init();
		Phys.drawDebug = true;
		Phys.debugManipulator = new Box2DInteractiveDebug();
		//Phys.debugRenderer.setDrawScale(100);
		
		addRandomFlyingBoxes();
		
		//addStaticPlatform(Std.int(FlxG.width / 2 - 200), Std.int(FlxG.height - 200), Std.int(FlxG.width / 2), 25);
		//addGround(Std.int(FlxG.width / 2 - 980), Std.int(FlxG.height - 200), 10, 10, 50, 5, 5);
		//addGround(Std.int(FlxG.width / 2 + 200), Std.int(FlxG.height - 200), 100, 100, 50, 25, 25);
		addGround(Std.int(FlxG.width / 2 - 780), Std.int(FlxG.height - 350), 10, 10, 50, 0, 0);
		Phys.createWalls(FlxG.worldBounds.left, FlxG.worldBounds.top, FlxG.worldBounds.right, FlxG.worldBounds.bottom, 50);
		
		var player:Player = new Player(Std.int(FlxG.width / 2), Std.int(FlxG.height - 350), 30, 100);
		add(player);
		
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.9);
	}
	
	override public function destroy():Void {
		Phys.destroy();
		super.destroy();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		if (Phys.debugManipulator != null && Phys.debugManipulator.mouseJoint != null) {
			if (Phys.debugManipulator.mouseJoint.getBodyA() != null &&
				Phys.debugManipulator.mouseJoint.getBodyB() != null) {
				lightningZone.active = true;
				lightningZone.visible = true;
				var b = Phys.debugManipulator.mouseJoint.getBodyB().getUserData();
				for (l in lightningZone.group.members) {
					var e:LSprite = cast b.entity;
					l.startPoint.x = e.center.x - FlxG.camera.scroll.x;
					l.startPoint.y = e.center.y - FlxG.camera.scroll.y;
					l.endPoint.set(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);
				}
			}
		} else {
			lightningZone.active = false;
			lightningZone.visible = false;
		}
		
		if (FlxG.keys.justPressed.Y) {
			var body = Phys.debugManipulator.getBodyAtMouse();
			if (body != null) {
				trace(body.getPosition().y);
				FlxG.watch.add(body.getPosition(), "x", "body x");
				FlxG.watch.add(body.getPosition(), "y", "body y");
				FlxG.watch.add(body.getUserData().entity, "x", "sprite x");
				FlxG.watch.add(body.getUserData().entity, "y", "sprite y");
				FlxG.watch.add(body.m_linearVelocity, "x", "linearVelocityX");
				FlxG.watch.add(body.m_linearVelocity, "y", "linearVelocityY");
			}
		}
		
		//AL.sourcei(handle, AL.DIRECT_FILTER, fx);
		//AL.sourcei(handle, AL.DIRECT_FILTER, fx2);
		//AL.source3i(handle, AL.EFF, aux, 0, AL.FILTER_NULL);
	}
	
	override public function draw():Void {
		super.draw();
	}
	
	private function addRandomFlyingBoxes():Void {
		var numSprites = 25;
		for (i in 0...numSprites) {
			var testSprite:PhysSprite = new PhysSprite(Std.int(FlxG.width / numSprites * i), Std.int(Math.random() * 250), Std.int(12 + Math.random() * 24), Std.int(12 + Math.random() * 24));
			testSprite.physics.addRectangularShape(testSprite.width, testSprite.height, 10);
			testSprite.physics.linearVelocityX = 3;
			testSprite.physics.linearDamping = 0.1;
			testSprite.physics.angularVelocity = 12;
			testSprite.physics.angularDamping = 0.1;
			add(testSprite);
		}
	}
	
	private function addStaticPlatform(x:Int, y:Int, width:Int, height:Int):Void {
		var platform:PhysSprite = new PhysSprite(x, y, width, height);
		platform.physics.addRectangularShape(platform.width, platform.height);
		platform.physics.bodyType = B2BodyType.STATIC_BODY;
		add(platform);
	}
	
	private function addWall(x:Int, y:Int, width:Int, height:Int, bodyType:B2BodyType = B2BodyType.STATIC_BODY):PhysSprite {
		var wall:PhysSprite = new PhysSprite(x, y, width, height);
		wall.physics.addRectangularShape(wall.width, wall.height);
		wall.physics.bodyType = bodyType;
		add(wall);
		return wall;
	}
	
	private function addGround(x:Int, y:Int, width:Int, height:Int, parts:Int, nobblyYPositionVariation:Int = 0, nobblyHeightVariation:Int = 0):Void {
		for (i in 0...parts) {
			var wall:PhysSprite = new PhysSprite(x +  width * i, y + FlxG.random.int( -nobblyYPositionVariation, nobblyYPositionVariation),
			width, height + FlxG.random.int( -nobblyHeightVariation, nobblyHeightVariation));
			
			wall.physics.addRectangularShape(wall.width, wall.height);
			wall.physics.bodyType = B2BodyType.STATIC_BODY;
			add(wall);
		}
	}
}