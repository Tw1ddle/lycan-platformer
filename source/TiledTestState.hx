package;

import flixel.FlxBasic;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import haxe.ds.Map;
import lycan.phys.Phys;
import lycan.states.LycanState;
import lycan.system.FpsText;
import lycan.world.WorldHandlers;
import lycan.world.World;
import lycan.world.layer.ObjectLayer;
import lycan.world.layer.TileLayer;
import nape.phys.Material;
import lycan.phys.PlatformerPhysics;
import flixel.addons.editors.tiled.TiledMap;

class TiledTestState extends LycanState {
    var spriteZoom:Int = 3;
	var world:World = null;
	var player:Player = null;
	
	override public function create():Void {
		super.create();
		
		setupUI();
		initPhysics();
		
		loadWorld();
	}
	
	override public function destroy():Void {
		FlxG.camera.follow(null);
		
		destroyPhysics();
		super.destroy();
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
		
		PlatformerPhysics.setupPlatformerPhysics();
	}

	private function destroyPhysics():Void {
		Phys.destroy();
	}

	private function loadWorld():Void {
		world = new World(new FlxPoint(spriteZoom, spriteZoom));
		
		var objectHandlers:ObjectHandlers = new ObjectHandlers();
		var objectLayerHandlers:ObjectLayerHandlers = new ObjectLayerHandlers();
		var tileLayerHandler:TileLayerHandler;
		var worldHandlers:WorldHandlers = new WorldHandlers();
		
		function loadObject(type:String, func:TiledObject->ObjectLayer->Map<TiledObject, FlxBasic>->Void) {
			objectHandlers.add((obj:TiledObject, layer:ObjectLayer, map:Map<TiledObject, FlxBasic>)->{
				if (obj.type != type) return;
				var objExists:Bool = map.exists(obj);
				func(obj, layer, map);
				var o = map.get(obj);
				var name = obj.name;
				// If we have a flixel object
				if (o != null) {
					// Add to ObjectLayer if it's new
					if (!objExists) {
						layer.add(o);
					}
					// Add to named object map
					if (name != null && name != "") {
						var wo = layer.world.namedObjects;
						// Warn if we already had a named instance
						if (wo.exists(name)) {
							FlxG.log.warn("Loaded multiple objects with name: " + name);
						}
						layer.world.namedObjects.set(name, o);
					}
				}
			});
		}
		
		// ---- OBJECT LOADING DEFINITIONS ----
		
		// Scale everything up
		objectHandlers.add((obj, layer, map)->{
			obj.width *= spriteZoom;
			obj.height *= spriteZoom;
			obj.x *= spriteZoom;
			obj.y *= spriteZoom;
		});
		
		loadObject("player", (obj, layer, map)->{
			var player = new Player(obj.x, obj.y + obj.height - 60, 30, 60);
			player.physics.snapBodyToEntity();
			map.set(obj, player);
		});
		
		loadObject("crate", (obj, layer, map)->{
			//var crate:PhysSprite = new PhysSprite(obj.x, obj.y, obj.width, obj.height);
		});
		
		
		// ---- TILE LAYER LOADING DEFINITIONS ----
		tileLayerHandler = (tiledLayer, layer)->{
			var layerProperties = tiledLayer.properties;
			var hasKey = layerProperties.contains;
			var val = layerProperties.get;
			
			// TODO have engine specific properties for physics
			var tilemap:FlxTilemap = function():FlxTilemap {
				if (hasKey("collision")) {
					if (val("collision") == "nape") {
						// TODO?
					}
					return new FlxNapeTilemap();
				}
				return new FlxTilemap();
			}();
			
			// TODO decide whether to do autotiling based on the map/layer properties
			tilemap.loadMapFromArray(tiledLayer.tileArray, tiledLayer.map.width, tiledLayer.map.height, "assets/images/autotiles_full.png",
				Std.int(tiledLayer.map.tileWidth), Std.int(tiledLayer.map.tileHeight), FlxTilemapAutoTiling.FULL, 0, 0, 0);
			
			// TODO decide scale based on layer info/properties, not world?
			tilemap.scale.copyFrom(world.scale);
			
			tilemap.visible = hasKey("hidden") ? false : true;
			
			if (hasKey("collision")) {
				var napeMap:FlxNapeTilemap = cast tilemap;
				
				napeMap.setupCollideIndex(1, new Material(0, 1, 2, 0, 0.001));
				napeMap.body.scaleShapes(world.scale.x, world.scale.y);
				napeMap.body.space = Phys.space;
				
				tilemap.solid = true;
			}
			
			return tilemap;
		};
		
		// worldHandlers.add(()->{
			
		// });
		
		
		// Load the world
		world.load(new TiledMap("assets/data/world.tmx"), objectHandlers, objectLayerHandlers, tileLayerHandler, worldHandlers);
		
		// Set camera scroll bounds after loading
		FlxG.camera.setScrollBoundsRect(0, 0, world.width * world.scale.x, world.height * world.scale.y, true);
		player = cast world.namedObjects.get("player");
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.9);
		FlxG.camera.snapToTarget();
		
		add(world);
	}
}