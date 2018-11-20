package;

import box2D.dynamics.B2BodyType;
import lycan.world.ObjectLoaderRules;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.addons.editors.tiled.TiledObject;
import lycan.world.layer.ObjectLayer;
import lycan.world.layer.TileLayer;
import lycan.world.World;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import lycan.phys.Phys;
import lycan.states.LycanState;
import lycan.system.FpsText;

class TiledTestState extends LycanState {
    var spriteZoom:Int = 3;
    var player:Player = null;
	var collisionLayer:TileLayer = null;
	var world:World = null;

	// Groups
	var onewayGroup:FlxTypedGroup<PhysSprite> = new FlxTypedGroup<PhysSprite>();
	var crateGroup:FlxTypedGroup<PhysSprite> = new FlxTypedGroup<PhysSprite>();

	override public function create():Void {
		super.create();
		
		setupUI();
        initPhysics();
		
		overlay.color = FlxColor.RED;

		// World
		loadWorld();

		add(world);

		add(onewayGroup);
		add(crateGroup);
		
		collisionLayer = cast world.getLayer("Collisions");
	}
	
	override public function destroy():Void {
		FlxG.camera.follow(null);

		destroyPhysics();
		super.destroy();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);

		handleInput(dt);
	}
	
	override public function draw():Void {
		super.draw();
	}

	private function handleInput(dt:Float):Void {
		// Add the selected physics debug widget to the watch
		if (FlxG.keys.justPressed.Y) {
			var body = Phys.debugManipulator.getBodyAtMouse();
			if (body != null) {
				FlxG.watch.add(body.getPosition(), "x", "body x");
				FlxG.watch.add(body.getPosition(), "y", "body y");
				FlxG.watch.add(body.getUserData().entity, "x", "sprite x");
				FlxG.watch.add(body.getUserData().entity, "y", "sprite y");
				FlxG.watch.add(body.m_linearVelocity, "x", "linearVelocityX");
				FlxG.watch.add(body.m_linearVelocity, "y", "linearVelocityY");
			}
		}
	}

	private function setupUI():Void {
		uiGroup.add(new FpsText(0, 0, 24)); // FPS counter
	}

	private function initPhysics():Void {
		Phys.init();
		Phys.drawDebug = true;
		Phys.debugManipulator = new Box2DInteractiveDebug();
	}

	private function destroyPhysics():Void {
		Phys.destroy();
	}

	private function loadWorld():Void {
		world = new World(FlxPoint.get(spriteZoom, spriteZoom));
		var loader = new ObjectLoaderRules();
		
		
		//TODO note that TiledObject already makes a reference to the TiledObjectLayer it is on, so we don't need to pass it
		var matchType = function(type:String, obj:TiledObject) {
			return obj.type == type;
		};
		
		// TODO little experiment to scale everything up
		loader.addHandler((_)->return true, function(obj:TiledObject, layer:ObjectLayer) {
			obj.width *= spriteZoom;
			obj.height *= spriteZoom;
			obj.x *= spriteZoom;
			obj.y *= spriteZoom;
			return null;
		});
		
		//TODO I think we might not even need to return the objects with these loaders anymore
		// This was for things like getting a refernce to player
		loader.addHandler(matchType.bind("player"), function(obj:TiledObject, layer:ObjectLayer) {
			player = new Player(0, 0, 40, 100);
			player.physics.setPixelPosition(obj.x, obj.y + obj.height - player.height);

			// Camera follows the player
			FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.9);
			FlxG.camera.snapToTarget();	

			return player;
		});
		loader.addHandler(matchType.bind("crate"), function(obj:TiledObject, layer:ObjectLayer) {
			var crate:PhysSprite = new PhysSprite(obj.x, obj.y, obj.width, obj.height);
			crate.physics.body.setType(B2BodyType.STATIC_BODY);
			crateGroup.add(crate);
			return crate;
		});
		loader.addHandler(matchType.bind("movingPlatform"), function(obj:TiledObject, layer:ObjectLayer) {
			return null;
		});
		loader.addHandler(matchType.bind("switch"), function(obj:TiledObject, layer:ObjectLayer) {
			return null; //TODO
		});
		loader.addHandler(matchType.bind("button"), function(obj:TiledObject, layer:ObjectLayer) {
			return null; //TODO
		});
		loader.addHandler(matchType.bind("oneway"), function(obj:TiledObject, layer:ObjectLayer) {
			var oneway:PhysSprite = new PhysSprite(obj.x, obj.y, obj.width * spriteZoom, obj.height * spriteZoom);
			onewayGroup.add(oneway);
			return null;//TODO oneway;
		});
		
		world.load("assets/data/world.tmx", loader);
	}
}