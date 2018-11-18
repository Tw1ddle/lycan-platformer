package;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.addons.editors.tiled.TiledObject;
import lycan.world.layer.ObjectLayer;
import lycan.world.layer.ObjectLayer.ObjectLoader;
import haxe.ds.StringMap;
import lycan.world.layer.TileLayer;
import lycan.world.World;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import lycan.entities.LSprite;
import lycan.phys.Phys;
import lycan.states.LycanState;
import lycan.system.FpsText;
import lycan.world.components.PhysicsEntity;

class PhysSprite extends LSprite implements PhysicsEntity {
	public function new(x:Int, y:Int, width:Int, height:Int) {
		super(x, y);
		makeGraphic(width, height, FlxColor.fromRGB(0, 255, 64, 128));
		physics.init();
	}
}

class TiledTestState extends LycanState {
    var spriteZoom:Int = 2;
    var player:Player = null;
	var collisionLayer:TileLayer = null;
	var world:World = null;

	// Groups
	var onewayGroup:FlxTypedGroup<PhysSprite> = new FlxTypedGroup<PhysSprite>();
	var crateGroup:FlxTypedGroup<PhysSprite> = new FlxTypedGroup<PhysSprite>();
	var worldCollisionGroup:FlxGroup = new FlxGroup();

	override public function create():Void {
		super.create();
		
		setupUI();
        initPhysics();
		
		// Player
		player = new Player(0, 0, 40, 100);
		overlay.color = FlxColor.RED;
	
		// Camera follows the player
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.9);
		FlxG.camera.snapToTarget();	

		// World
		loadWorld();
		worldCollisionGroup.add(player);
		worldCollisionGroup.add(crateGroup);
		add(world);
		
		collisionLayer = cast world.getLayer("Collisions");
	}
	
	override public function destroy():Void {
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
		var loader:StringMap<ObjectLoader> = new StringMap<ObjectLoader>();
		
		loader.set("player", function(obj:TiledObject, layer:ObjectLayer) {
			player.setPosition(obj.x, obj.y + obj.height - player.height / 2);
			return player;
		});
		loader.set("crate", function(obj:TiledObject, layer:ObjectLayer) {
			var crate:PhysSprite = new PhysSprite(obj.x, obj.y, 50, 50);
			crateGroup.add(crate);
			return crate;
		});
		loader.set("movingPlatform", function(obj:TiledObject, layer:ObjectLayer) {
			return null;
		});
		loader.set("switch", function(obj:TiledObject, layer:ObjectLayer) {
			return null; //TODO
		});
		loader.set("button", function(obj:TiledObject, layer:ObjectLayer) {
			return null; //TODO
		});
		loader.set("oneway", function(obj:TiledObject, layer:ObjectLayer) {
			var oneway:PhysSprite = new PhysSprite(obj.x, obj.y, obj.width * spriteZoom, obj.height * spriteZoom);
			onewayGroup.add(oneway);
			return oneway;
		});
		
		world.load("assets/data/world.tmx", loader);
	}
}