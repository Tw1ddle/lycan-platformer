package ;

import nape.shape.Polygon;
import nape.dynamics.InteractionFilter;
import nape.phys.BodyType;
import nape.phys.Body;
import nape.shape.ShapeType;
import nape.shape.Shape;
import lycan.supply.Node.Edge;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionType;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionListener;
import nape.callbacks.CbType;
import flixel.util.FlxColor;
import lycan.supply.Node.EdgeTwoWay;
import lycan.supply.Node.SignalHolder;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxMath;
import flixel.FlxG;
import lycan.components.Entity;
import lycan.components.Component;
import lycan.components.Attachable;
import haxe.ds.Map;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxBasic;
import lycan.world.components.PhysicsEntity;
import flixel.group.FlxSpriteGroup;
import lycan.supply.SignalCarrier;
import lycan.phys.Phys;
import lycan.supply.Node;

class SignalTile extends FlxSpriteGroup implements SignalCarrier implements PhysicsEntity {
	var sprite:FlxSprite;
	
	public var centerNode:Node;
	public var connectableNodes:Array<Node>;
	public var topNode:Node;
	public var leftNode:Node;
	public var rightNode:Node;
	public var bottomNode:Node;
	public var externalEdges:Array<Edge>;
	
	public static var signalConnectorType:CbType = new CbType();
	
	public static function setupPhysics() {
		Phys.space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, signalConnectorType, signalConnectorType, (cb:InteractionCallback)->{
			var n1:Node = cast cb.int1.userData.node;
			var n2:Node = cast cb.int2.userData.node;
			var c1:SignalCarrierComponent = cast cb.int1.userData.carrier;
			var c2:SignalCarrierComponent = cast cb.int2.userData.carrier;
			
			if (n1 != n2) {
				c1.edges.push(new Edge(n1, n2));
				c2.edges.push(new Edge(n2, n1));
			}
		}));
		
		Phys.space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.SENSOR, signalConnectorType, signalConnectorType, (cb:InteractionCallback)->{
			var n1:Node = cast cb.int1.userData.node;
			var n2:Node = cast cb.int2.userData.node;
			var c1:SignalCarrierComponent = cast cb.int1.userData.carrier;
			var c2:SignalCarrierComponent = cast cb.int2.userData.carrier;
			
			for (c in [c1, c2]) {
				for (e in c.edges) {
					if ((e.input == n1 && e.output == n2) || (e.output == n1 && e.input == n2)) {
						e.destroy();
						c.edges.remove(e);
					}
				}
			}
		}));
	}
	
	public function new(width:Float, height:Float, top:Bool, right:Bool, bottom:Bool, left:Bool, connectionWidth:Float = 10, leniency:Float = 0.5) {
		super();
		
		sprite = new FlxSprite();
		sprite.makeGraphic(Std.int(width), Std.int(height), 0, true);
		
		add(sprite);
		
		this.width = width;
		this.height = height;
		
		physics.init(BodyType.DYNAMIC, false);
		physics.body.shapes.add(new Polygon(Polygon.box(width, height)));
		
		centerNode = new Node(width / 2, height / 2);
		signalCarrier.nodes.push(centerNode);
		connectableNodes = [];
		
		function makeEdgeNode(x:Float, y:Float) {
			var out:Node = new Node(x, y);
			var e1:Edge = new Edge(out, centerNode);
			var e2:Edge = new Edge(centerNode, out);
			signalCarrier.nodes.push(out);
			signalCarrier.edges.push(e1);
			signalCarrier.edges.push(e2);
			connectableNodes.push(out);
			return out;
		}
		
		function makeSensor(node:Node, x:Float, y:Float, width:Float, height:Float) {
			var s:Polygon = new Polygon(Polygon.rect(x, y, width, height));
			s.sensorEnabled = true;
			// TODO is the filter even necessary?
			// s.filter.collisionGroup = 0;
			// s.filter.collisionMask = 0;
			// s.filter.sensorGroup = 1;
			// s.filter.sensorMask = 1;
			s.cbTypes.add(signalConnectorType);
			s.userData.node = node;
			s.userData.carrier = signalCarrier;
			physics.body.shapes.add(s);
		}
		
		if (top) {
			topNode = makeEdgeNode(width / 2, 0);
			makeSensor(topNode, -connectionWidth / 2, -(height / 2) - leniency, connectionWidth, 10 + leniency);
		}
		if (bottom) {
			bottomNode = makeEdgeNode(width / 2, height);
			makeSensor(bottomNode,  -connectionWidth / 2, (height / 2) - 10, connectionWidth, 10 + leniency);
		}
		if (left) {
			leftNode = makeEdgeNode(0, height / 2);
			makeSensor(leftNode, (-width / 2) - leniency,  -connectionWidth / 2, 10 + leniency, connectionWidth);
		}
		if (right) {
			rightNode = makeEdgeNode(width, height / 2);
			makeSensor(rightNode, width / 2 - 10,  -connectionWidth / 2, 10 + leniency, connectionWidth);
		}
		
		signalCarrier.drawToSprite(sprite, true);
		
		centerNode.onSignalChanged.add((b)->{
			sprite.alpha = b ? 1 : 0.3;
		});
		
		sprite.alpha = 0.5;
		
		physics.body.allowRotation = false;
		
		origin.set(width / 2, height / 2);
	}
}