package;

import nape.phys.BodyType;
import flixel.addons.nape.FlxNapeTilemap;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.addons.editors.tiled.TiledObject;
import lycan.world.layer.TileLayer;
import lycan.world.World;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import lycan.phys.Phys;
import lycan.states.LycanState;
import lycan.system.FpsText;
import flixel.util.FlxSignal;
import nape.geom.AABB;
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
import nape.geom.IsoFunction;
import nape.geom.Mat23;
import nape.geom.MarchingSquares;
import nape.geom.Vec2;



class TiledTestState extends LycanState {
    var spriteZoom:Int = 3;
    var player:Player = null;
	var collisionLayer:TileLayer = null;
	var world:World = null;

	// Groups
	var onewayGroup:FlxTypedGroup<PhysSprite> = new FlxTypedGroup<PhysSprite>();
	var crateGroup:FlxTypedGroup<PhysSprite> = new FlxTypedGroup<PhysSprite>();

	// TODO remove
	var collisionGroup:FlxTypedGroup<PhysSprite> = new FlxTypedGroup<PhysSprite>();

	override public function create():Void {
		super.create();
		
		setupUI();
        initPhysics();
		
		overlay.color = FlxColor.RED;

		loadWorld();
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
	}

	private function setupUI():Void {
		uiGroup.add(new FpsText(0, 0, 24)); // FPS counter
	}

	private function initPhysics():Void {
		Phys.init();
		Phys.drawDebug = true;
	}

	private function destroyPhysics():Void {
		Phys.destroy();
	}

	private function loadWorld():Void {
		world = new World(FlxPoint.get(spriteZoom, spriteZoom));

		var loader = new FlxTypedSignal<TiledObject->Void>();

		// TODO Insert the object into the named objects map
		//if (o.name != null && o.name != "") {
		//	if (world.namedObjects.exists(o.name)) {
		//		throw("Error loading world. Object names must be unique: " + o.name);
		//	}
		//	world.namedObjects.set(o.name, object);
		//}

		var matchType = function(type:String, obj:TiledObject) {
			return obj.type == type;
		};

		// Scale everything up
		loader.add(function(obj:TiledObject) {
			obj.width *= spriteZoom;
			obj.height *= spriteZoom;
			obj.x *= spriteZoom;
			obj.y *= spriteZoom;
		});

		loader.add(function(obj:TiledObject) {
			if(!matchType("player", obj)) {
				return;
			}

			player = new Player(obj.x, obj.y, 40, 100);
			player.physics.position.setxy(obj.x, obj.y + obj.height - player.height);

			// Camera follows the player
			FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.9);
			FlxG.camera.snapToTarget();	
		});

		loader.add(function(obj:TiledObject) {
			if(!matchType("crate", obj)) {
				return;
			}

			//var crate:PhysSprite = new PhysSprite(obj.x, obj.y, obj.width, obj.height);
			//crateGroup.add(crate);
		});

		loader.add(function(obj:TiledObject) {
			if(!matchType("movingPlatform", obj)) {
				return;
			}
			// TODO
		});

		loader.add(function(obj:TiledObject) {
			if(!matchType("switch", obj)) {
				return;
			}
			// TODO
		});

		loader.add(function(obj:TiledObject) {
			if(!matchType("button", obj)) {
				return;
			}
			// TODO
		});

		loader.add(function(obj:TiledObject) {
			if(!matchType("oneway", obj)) {
				return;
			}
			//var oneway:PhysSprite = new PhysSprite(obj.x, obj.y, obj.width * spriteZoom, obj.height * spriteZoom);
			//onewayGroup.add(oneway);
		});
		
		world.load("assets/data/world.tmx", loader);

		collisionLayer = cast world.getLayer("Collisions");

		// TODO use FlxNapeTilemap instead, refactor TileMap.hx
		var zoomedSize = 16 * spriteZoom;
		var halfZoomedSize = Std.int(zoomedSize / 2);
		for(h in 0...collisionLayer.heightInTiles) {
			for(w in 0...collisionLayer.widthInTiles) {
				var tile = collisionLayer.data[w + (collisionLayer.widthInTiles * h)];
				if(tile != 0) {
					var obj:PhysSprite = new PhysSprite(w * zoomedSize + halfZoomedSize, h * zoomedSize + halfZoomedSize, zoomedSize, zoomedSize);
					obj.physics.body.type = BodyType.STATIC;
					collisionGroup.add(obj);
				}
			}
		}

		add(collisionGroup);
		add(world);
		add(onewayGroup);
		add(crateGroup);
	}
}