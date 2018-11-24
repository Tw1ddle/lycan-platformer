package;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;
import haxe.io.Path;
import lycan.entities.LSprite;
import lycan.phys.Phys;
import lycan.states.LycanState;
import lycan.system.FpsText;
import lycan.world.TileSetLoader.TileSetHandler;
import lycan.world.World;
import lycan.world.components.PhysicsEntity;
import lycan.world.layer.TileLayer;
import nape.phys.Material;
import openfl.display.BitmapData;

using lycan.world.ObjectLoader;
using lycan.world.TileLayerLoader;

class TiledTestState extends LycanState {
    var spriteZoom:Int = 3;
	var world:World = null;

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
	}
	
	override public function draw():Void {
		super.draw();
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
		// TODO factor most of these functions out into helper functions in lycan
		
		world = new World(FlxPoint.get(spriteZoom, spriteZoom));
		
		var tileSetHandler:TileSetHandler = function(tiledMap:TiledMap) {
			// Load tileset graphics
			var tilesetBitmaps = new Array<BitmapData>();
			for (tileset in tiledMap.tilesetArray) {
				// TODO might require attention later
				if (tileset.properties.contains("noload")) continue;
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
			world.combinedTileset = FlxTileFrames.combineTileSets(tilesetBitmaps, tileSize, spacing, spacing);
			tileSize.put();
			spacing.put();
			
			// Save a reference to the tileset map
			world.namedTilesets = tiledMap.tilesets;
		};
		
		var objectLoader = new FlxTypedSignal<ObjectHandler>();
		
		// Scale everything up
		objectLoader.add((obj, layer)->{
			obj.width *= spriteZoom;
			obj.height *= spriteZoom;
			obj.x *= spriteZoom;
			obj.y *= spriteZoom;
		});

		objectLoader.addByType("player", (obj, layer)->{
			var player = new Player(obj.x, obj.y, 30, 60);
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
					return new FlxNapeTilemap();
				}
				return new FlxTilemap();
			}();
			
			// TODO decide whether to do autotiling based on the map/layer properties
			// NOTE using using embedded assets here was broken on html5
			tilemap.loadMapFromArray(tiledLayer.tileArray, tiledLayer.map.width, tiledLayer.map.height, "assets/images/autotiles_full.png",
				Std.int(tiledLayer.map.tileWidth), Std.int(tiledLayer.map.tileHeight), FlxTilemapAutoTiling.FULL, 0, 0, 0);
			
			// TODO decide scale based on layer info/properties, not world?
			tilemap.scale.copyFrom(world.scale);
			
			if (key("hidden")) {
				tilemap.visible = false;
			}
			
			if (key("collision")) {
				var napeMap:FlxNapeTilemap = cast tilemap;
				
				napeMap.setupCollideIndex(1, new Material(0, 0, 2, 1, 0.001));
				napeMap.body.scaleShapes(world.scale.x, world.scale.y);
				napeMap.body.space = Phys.space;
				
				/*
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
				*/
				
				tilemap.solid = true;
				world.collidableTilemaps.push(tilemap);
			}
			
			return tilemap;
		};
		
		// Set camera scroll bounds after loading
		world.onLoadingComplete.add(()-> {
			FlxG.camera.setScrollBoundsRect(0, 0, world.width * world.scale.x, world.height * world.scale.y, true);
		});
		
		world.load("assets/data/world.tmx", tileSetHandler, objectLoader, tileLayerHandler);
		
		add(world);
		add(onewayGroup);
		add(crateGroup);
	}
}

class BasicPhysSprite extends LSprite implements PhysicsEntity {}