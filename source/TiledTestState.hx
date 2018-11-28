package;

import flixel.FlxBasic;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import haxe.ds.Map;
import haxe.io.Path;
import lycan.phys.Phys;
import lycan.states.LycanState;
import lycan.system.FpsText;
import lycan.world.ObjectHandler;
import lycan.world.ObjectHandler.ObjectHandlers;
import lycan.world.World;
import lycan.world.layer.ObjectLayer;
import lycan.world.layer.TileLayer;
import nape.phys.Material;
import openfl.display.BitmapData;
import lycan.phys.PlatformerPhysics;

using lycan.world.TileLayerHandler;

class TiledTestState extends LycanState {
    var spriteZoom:Int = 3;
	var world:World = null;
	var player:Player = null;

	override public function create():Void {
		super.create();
		
		setupUI();
		initPhysics();
		
		loadWorld();
		PlatformerPhysics.setupPlatformerPhysics();
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
	}

	private function destroyPhysics():Void {
		Phys.destroy();
	}

	private function loadWorld():Void {
		world = new World(new FlxPoint(spriteZoom, spriteZoom));
		
		var namedTileSets = new Map<String, TiledTileSet>();
		var combinedTileSet:FlxTileFrames = null;
		var namedObjectLayers = new Map<String, ObjectLayer>();
		var namedTileLayers = new Map<String, TileLayer>();
		var namedObjects = new Map<String, FlxBasic>();
		
		world.onLoadedTileSets.add((tiledMap)-> {
			// Load tileset graphics
			var tilesetBitmaps = new Array<BitmapData>();
			for (tileset in tiledMap.tilesetArray) {
				if (tileset.properties.contains("noload")) {
					continue;
				}
				var imagePath = new Path(tileset.imageSource);
				var processedPath = "assets/images/" + imagePath.file + "." + imagePath.ext;
				tilesetBitmaps.push(FlxAssets.getBitmapData(processedPath));
			}
			
			if (tilesetBitmaps.length == 0) {
				throw "Cannot load an empty tilemap, as it will result in invalid bitmap data errors";
			}
			
			// Combine tilesets into single tileset
			var tileSize:FlxPoint = FlxPoint.get(tiledMap.tileWidth, tiledMap.tileHeight);
			var spacing:FlxPoint = FlxPoint.get(2, 2);
			combinedTileSet = FlxTileFrames.combineTileSets(tilesetBitmaps, tileSize, spacing, spacing);
			tileSize.put();
			spacing.put();
			
			namedTileSets = tiledMap.tilesets;
		});
		
		world.onLoadedObjectLayer.add((tiledLayer, layer)-> {
			if (tiledLayer.name == null || tiledLayer.name == "") {
				return;
			}
			namedObjectLayers.set(tiledLayer.name, layer);
		});
		
		world.onLoadedTileLayer.add((tiledLayer, layer)-> {
			if (tiledLayer.name == null || tiledLayer.name == "") {
				return;
			}
			namedTileLayers.set(tiledLayer.name, layer);
		});
		
		var objectHandlers = new ObjectHandlers();
		
		// TODO is there any way around the single parameter limit for @:op?
		// e.g. like by implementing @:from or @:to on the actual ObjectHandler so it's auto-converted there?
		var pack = function(type:String, map:Map<String, FlxBasic>, handler:ObjectHandler) {
			return { type: type, map: map, handler: handler };
		};
		
		// Scale everything up
		objectHandlers += (obj, layer)->{
			obj.width *= spriteZoom;
			obj.height *= spriteZoom;
			obj.x *= spriteZoom;
			obj.y *= spriteZoom;
		};
		objectHandlers += pack("player", namedObjects, (obj, layer)->{
			var player = new Player(obj.x, obj.y, 30, 60);
			// TODO I think this won't be positioning the body properly
			// Perhaps we need to readd a setPositon for bodies from flixel coords?
			player.physics.position.setxy(obj.x, obj.y + obj.height - player.height);
			return player;
		});
		objectHandlers += pack("crate", namedObjects, (obj, layer)->{
			//var crate:PhysSprite = new PhysSprite(obj.x, obj.y, obj.width, obj.height);
			return null;
		});
		objectHandlers += pack("movingPlatform", namedObjects, (obj, layer)->{
			// TODO
			return null;
		});
		objectHandlers += pack("switch", namedObjects, (obj, layer)->{
			// TODO
			return null;
		});
		objectHandlers += pack("button", namedObjects, (obj, layer)->{
			// TODO
			return null;
		});
		objectHandlers += pack("oneway", namedObjects, (obj, layer)->{
			//var oneway:PhysSprite = new PhysSprite(obj.x, obj.y, obj.width * spriteZoom, obj.height * spriteZoom);
			return null;
		});
		
		var tileLayerHandler:TileLayerHandler = function(tiledLayer:TiledTileLayer, layer:TileLayer):FlxTilemap {
			
			var layerProperties = tiledLayer.properties;
			
			var key = (p:String)->{
				return layerProperties.contains(p);
			}
			var val = (p:String)->{
				return layerProperties.get(p);
			}
			
			// TODO have engine specific properties for physics
			var tilemap:FlxTilemap = function():FlxTilemap {
				if (key("collision")) {
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
			
			tilemap.visible = key("hidden") ? false : true;
			
			if (key("collision")) {
				var napeMap:FlxNapeTilemap = cast tilemap;
				
				napeMap.setupCollideIndex(1, new Material(0, 0, 2, 1, 0.001));
				napeMap.body.scaleShapes(world.scale.x, world.scale.y);
				napeMap.body.space = Phys.space;
				
				tilemap.solid = true;
			}
			
			return tilemap;
		};
		
		world.onLoadingComplete.add(()-> {
			trace(namedObjects);
			
			// Set camera scroll bounds after loading
			FlxG.camera.setScrollBoundsRect(0, 0, world.width * world.scale.x, world.height * world.scale.y, true);
			player = cast namedObjects.get("player");
			
			// TODO this would need the updatePosition thing
			Sure.sure(player != null);
			FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.9);
			FlxG.camera.snapToTarget();
			
			add(world);
		});
		
		world.load("assets/data/world.tmx", objectHandlers, tileLayerHandler);
	}
}