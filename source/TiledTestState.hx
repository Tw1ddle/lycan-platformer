package;

import flixel.util.typeLimit.OneOfTwo;
import nape.shape.Polygon;
import lycan.entities.LSprite;
import lycan.world.ObjectLoader;
import nape.phys.BodyType;
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
import lycan.world.layer.ObjectLayer;
import lycan.world.components.PhysicsEntity;

using lycan.world.ObjectLoader;

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
		Phys.enableDebugManipulator = true;
	}

	private function destroyPhysics():Void {
		Phys.destroy();
	}

	private function loadWorld():Void {
		world = new World(FlxPoint.get(spriteZoom, spriteZoom));

		var loader = new FlxTypedSignal<ObjectHandler>();

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
		loader.add((obj, layer)->{
			obj.width *= spriteZoom;
			obj.height *= spriteZoom;
			obj.x *= spriteZoom;
			obj.y *= spriteZoom;
		});

		loader.addByType("player", (obj, layer)->{
			player = new Player(obj.x, obj.y, 15, 40);
			// TODO I think this won't be positioning the body properly
			// Perhaps we need to readd a setPositon for bodies from flixel coords?
			player.physics.position.setxy(obj.x, obj.y + obj.height - player.height);
			add(player);

			// Camera follows the player
			// TODO this would need the updatePosition thing, and I think it probably wouldn't belong in a deault loader
			FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.9);
			FlxG.camera.snapToTarget();	
		});

		loader.addByType("crate", (obj, layer)->{
			//var crate:PhysSprite = new PhysSprite(obj.x, obj.y, obj.width, obj.height);
			//crateGroup.add(crate);
		});

		loader.addByType("movingPlatform", (obj, layer)->{
			// TODO
		});

		loader.addByType("switch", (obj, layer)->{
			// TODO
		});

		loader.addByType("button", (obj, layer)->{
			// TODO
		});

		loader.addByType("oneway", (obj, layer)->{
			//var oneway:PhysSprite = new PhysSprite(obj.x, obj.y, obj.width * spriteZoom, obj.height * spriteZoom);
			//onewayGroup.add(oneway);
		});
		
		world.load("assets/data/world.tmx", loader);
		
		// TODO ditch this?
		collisionLayer = cast world.getLayer("Collisions");


		var tm = collisionLayer.tilemap;
		
		// TODO use FlxNapeTilemap instead, refactor TileMap.hx
		var zoomedSize = 16 * spriteZoom;
		var obj:BasicPhysSprite = new BasicPhysSprite();
		obj.physics.init(null, false);
		for (h in 0...tm.heightInTiles) {
			for (w in 0...tm.widthInTiles) {
				var tile = collisionLayer.data[w + (tm.widthInTiles * h)];
				if (tile != 0) {
					@:privateAccess(flixel.tile.FlxTilemap) obj.physics.body.shapes.add(new Polygon(Polygon.rect(
						w * tm._tileWidth * spriteZoom, h * tm._tileHeight * spriteZoom, tm._tileWidth * spriteZoom, tm._tileHeight * spriteZoom)));
				}
			}
		}
		
		obj.physics.body.type = BodyType.STATIC;

		add(collisionGroup);
		add(world);
		add(onewayGroup);
		add(crateGroup);
	}
}

class BasicPhysSprite extends LSprite implements PhysicsEntity {}