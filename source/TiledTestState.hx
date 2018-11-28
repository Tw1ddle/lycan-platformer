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
import lycan.world.ObjectHandler;
import lycan.world.ObjectHandler.ObjectHandlers;
import lycan.world.World;
import lycan.world.layer.ObjectLayer;
import lycan.world.layer.TileLayer;
import nape.phys.Material;

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
		
		var objectHandlers = new ObjectHandlers();
		
		// Scale everything up
		objectHandlers.push((obj, layer)->{
			obj.width *= spriteZoom;
			obj.height *= spriteZoom;
			obj.x *= spriteZoom;
			obj.y *= spriteZoom;
			return null;
		});
		
		var objMap = new Map<TiledObject, FlxBasic>();

		var filterByType = function(type:String, handler:TiledObject->ObjectLayer->FlxBasic):TiledObject->ObjectLayer->FlxBasic {
			return function(o:TiledObject, l:ObjectLayer) {
				if (o.type == type) {
					var basic = handler(o, l);
					if(basic != null) {
						objMap.set(o, basic);
					}
					return basic;
				}
				return null;
			}
		};
		
		objectHandlers.push(filterByType("player", ((obj, layer, map)->{
			var player = new Player(obj.x, obj.y, 30, 60);
			// TODO I think this won't be positioning the body properly
			// Perhaps we need to readd a setPositon for bodies from flixel coords?
			player.physics.position.setxy(obj.x, obj.y + obj.height - player.height);
			
			// TODO let's not make this a manual thing?
			layer.add(player);
			
			return player;
		}).bind(_, _, objMap)));
		
		objectHandlers.push(filterByType("crate", ((obj, layer, map)->{
			//var crate:PhysSprite = new PhysSprite(obj.x, obj.y, obj.width, obj.height);
			return null;
		}).bind(_, _, objMap)));
		
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
			trace(world.namedObjects);
			
			// Set camera scroll bounds after loading
			FlxG.camera.setScrollBoundsRect(0, 0, world.width * world.scale.x, world.height * world.scale.y, true);
			player = cast world.namedObjects.get("player");
			
			// TODO this would need the updatePosition thing
			Sure.sure(player != null);
			FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.9);
			FlxG.camera.snapToTarget();
			
			add(world);
		});
		
		world.load("assets/data/world.tmx", objectHandlers, tileLayerHandler);
	}
}