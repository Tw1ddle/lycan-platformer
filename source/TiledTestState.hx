package;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;
import lycan.entities.LSprite;
import lycan.phys.Phys;
import lycan.states.LycanState;
import lycan.system.FpsText;
import lycan.world.World;
import lycan.world.components.PhysicsEntity;
import lycan.world.layer.TileLayer;
import nape.phys.BodyType;
import nape.shape.Polygon;

using lycan.world.ObjectLoader;
using lycan.world.TileLayerLoader;

class TiledTestState extends LycanState {
    var spriteZoom:Int = 3;
    var player:Player = null;
	var world:World = null;

	// Groups
	var onewayGroup:FlxTypedGroup<PhysSprite> = new FlxTypedGroup<PhysSprite>();
	var crateGroup:FlxTypedGroup<PhysSprite> = new FlxTypedGroup<PhysSprite>();

	override public function create():Void {
		super.create();
		
		setupUI();
        initPhysics();
		
		FlxG.fixedTimestep = false;
		
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
		
		#if !FLX_NO_DEBUG
		Phys.enableDebugManipulator = true;
		#end
	}

	private function destroyPhysics():Void {
		Phys.destroy();
	}

	private function loadWorld():Void {
		world = new World(FlxPoint.get(spriteZoom, spriteZoom));

		var objectLoader = new FlxTypedSignal<ObjectHandler>();

		// TODO Insert the object into the named objects map
		//if (o.name != null && o.name != "") {
		//	if (world.namedObjects.exists(o.name)) {
		//		throw("Error loading world. Object names must be unique: " + o.name);
		//	}
		//	world.namedObjects.set(o.name, object);
		//}

		// Scale everything up
		objectLoader.add((obj, layer)->{
			obj.width *= spriteZoom;
			obj.height *= spriteZoom;
			obj.x *= spriteZoom;
			obj.y *= spriteZoom;
		});

		objectLoader.addByType("player", (obj, layer)->{
			player = new Player(obj.x, obj.y, 30, 60);
			// TODO I think this won't be positioning the body properly
			// Perhaps we need to readd a setPositon for bodies from flixel coords?
			player.physics.position.setxy(obj.x, obj.y + obj.height - player.height);
			add(player);

			// Camera follows the player
			// TODO this would need the updatePosition thing, and I think it probably wouldn't belong in a deault loader
			FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.9);
			FlxG.camera.snapToTarget();
		});

		objectLoader.addByType("crate", (obj, layer)->{
			//var crate:PhysSprite = new PhysSprite(obj.x, obj.y, obj.width, obj.height);
			//crateGroup.add(crate);
		});

		objectLoader.addByType("movingPlatform", (obj, layer)->{
			// TODO
		});

		objectLoader.addByType("switch", (obj, layer)->{
			// TODO
		});

		objectLoader.addByType("button", (obj, layer)->{
			// TODO
		});

		objectLoader.addByType("oneway", (obj, layer)->{
			//var oneway:PhysSprite = new PhysSprite(obj.x, obj.y, obj.width * spriteZoom, obj.height * spriteZoom);
			//onewayGroup.add(oneway);
		});
		
		var tileLayerHandler:TileLayerHandler = function(tiledLayer:TiledTileLayer, layer:TileLayer):FlxTilemap {
			
			// TODO choose either nape, regular or other tilemap based on global properties, then map/world properties, then layer properties
			var tilemap = new FlxTilemap();
			
			// TODO decide whether to do autotiling based on the map
			// NOTE using using embedded assets is broken on html5
			tilemap.loadMapFromArray(tiledLayer.tileArray, tiledLayer.map.width, tiledLayer.map.height, "assets/images/autotiles_full.png",
				Std.int(tiledLayer.map.tileWidth), Std.int(tiledLayer.map.tileHeight), FlxTilemapAutoTiling.FULL, 1, 1, 1);
			
			// TODO decide scale based on layer info/properties?
			tilemap.scale.copyFrom(world.scale);
			
			// TODO use FlxNapeTilemap instead
			var obj:BasicPhysSprite = new BasicPhysSprite();
			obj.physics.init(null, false);
			
			var tileData = tilemap.getData(false);
			for (h in 0...tilemap.heightInTiles) {
				for (w in 0...tilemap.widthInTiles) {
					var tile = tileData[w + (tilemap.widthInTiles * h)];
					if (tile != 0) {
						@:privateAccess(flixel.tile.FlxTilemap) obj.physics.body.shapes.add(new Polygon(Polygon.rect(
							w * tilemap._tileWidth * spriteZoom, h * tilemap._tileHeight * spriteZoom, tilemap._tileWidth * spriteZoom, tilemap._tileHeight * spriteZoom)));
					}
				}
			}
			
			obj.physics.body.type = BodyType.STATIC;
			obj.physics.setBodyMaterial(0, 0);
			
			// TODO handle properties properly
			if (tiledLayer.properties.contains("collides")) {
				tilemap.solid = true;
				world.collidableTilemaps.push(tilemap);
				if (tiledLayer.properties.get("collides") == "oneway") {
					tilemap.allowCollisions = FlxObject.UP;
				}
			}
			if (tiledLayer.properties.contains("hidden")) {
				tilemap.visible = false;
			}
			
			return tilemap;
		};
		
		world.load("assets/data/world.tmx", objectLoader, tileLayerHandler);
		
		add(world);
		add(onewayGroup);
		add(crateGroup);
	}
}

class BasicPhysSprite extends LSprite implements PhysicsEntity {}