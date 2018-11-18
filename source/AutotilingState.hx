package;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import lycan.states.LycanRootState;
import lycan.states.LycanState;
import flixel.FlxG;
import flixel.FlxBasic;
import lycan.util.Spring;
import lycan.entities.LSprite;
import lycan.util.algorithm.Bresenham;
import openfl.display.Sprite;

class FluidCell {
	public var pressure:Float;
	public var velocity:FlxPoint;
	
	public function new(p:Float) {
		pressure = p;
		velocity = FlxPoint.get();
	}
}

class FluidZone extends LSprite {
	var grid:Array<FluidCell>;
	var newGrid:Array<FluidCell>;
	var lastPoint:FlxPoint;
	var viscosity:Float = 0.01;
	var natural:Float = 0.5;
	var gridWidth:Int;
	var gridHeight:Int;
	
	public function new(width:Int, height:Int) {
		super(0, 0);
		makeGraphic(width, height, 0, true);
		lastPoint = null;
		
		gridWidth = width;
		gridHeight = height;
		
		grid = [];
		newGrid = [];
		
		for (x in 0...gridWidth) for (y in 0...gridHeight) {
			grid[x + y * gridWidth] = new FluidCell(natural);
			newGrid[x + y * gridWidth] = new FluidCell(0);
		}
		scale.set(4, 4);
		updateHitbox();
		
		point0 = FlxPoint.get();
	}
	
	override public function draw():Void {
		for (x in 0...gridWidth) for (y in 0...gridHeight) {
			pixels.setPixel32(x, y, FlxColor.fromHSB(0, 0, 1, Math.min(getCell(grid, x, y).pressure, 1)));
		}
		dirty = true;
		
		super.draw();
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		
		if (FlxG.mouse.overlaps(this)) {
			if (lastPoint != null) {
				var start:FlxPoint = lastPoint.subtract(x, y);
				start.set(Math.floor(start.x / scale.x), Math.floor(start.y / scale.y));
				var end:FlxPoint = FlxPoint.get(FlxG.mouse.x, FlxG.mouse.y).subtract(x, y);
				end.set(Math.floor(end.x / scale.x), Math.floor(end.y / scale.y));
				var points:Array<{x:Int, y:Int}> = Bresenham.getLine(Std.int(start.x), Std.int(start.y), Std.int(end.x), Std.int(end.y));
				
				var dx = end.x - start.x;
				var dy = end.y - start.y;
				
				for (p in points) {
					var c:FluidCell = getCell(grid, p.x, p.y);
					if (c != null) c.velocity.add(dx / dt, dy / dt);
				}
				
				start.put();
				end.put();
			}
			lastPoint = FlxPoint.get(FlxG.mouse.x, FlxG.mouse.y);
		} else if (lastPoint != null) {
			lastPoint.put();
			lastPoint = null;
		}
		
		updateFlow(dt);
		
		updateDivergence(dt);
	}
	
	//f'[x,y] = f[x,y] + (dot(f[x-1,y-1] + f[x+1,y+1], {1,1}) +
                    //dot(f[x-1,y+1] + f[x+1,y-1], {1,-1}) * {1,-1} +
                    //(f[x-1,y] + f[x+1,y] - f[x,y-1] - f[x,y+1]) * {2,-2} +
                    //f[x,y] * -4) * 1/8
	var point0:FlxPoint;
					
	function updateDivergence(dt:Float) {
		for (i in 0...5) {
			for (x in 0...gridWidth) for (y in 0...gridHeight) {
				var n:FluidCell = getCell(newGrid, x, y);
				
				var tl:FluidCell = getCell(grid, x - 1, y - 1);
				var t:FluidCell = getCell(grid, x, y - 1);
				var tr:FluidCell = getCell(grid, x + 1, y - 1);
				var l:FluidCell = getCell(grid, x - 1, y);
				var c:FluidCell = getCell(grid, x, y);
				var r:FluidCell = getCell(grid, x + 1, y);
				var bl:FluidCell = getCell(grid, x - 1, y + 1);
				var b:FluidCell = getCell(grid, x, y + 1);
				var br:FluidCell = getCell(grid, x + 1, y + 1);
				
				var ftl = tl == null ? point0 : tl.velocity;
				var ft = t == null ? point0 : t.velocity;
				var ftr = tr == null ? point0 : tr.velocity;
				var fl = l == null ? point0 : l.velocity;
				var fc = c == null ? point0 : c.velocity;
				var fr = r == null ? point0 : r.velocity;
				var fbl = bl == null ? point0 : bl.velocity;
				var fb = b == null ? point0 : b.velocity;
				var fbr = br == null ? point0 : br.velocity;
				
				//n.velocity = c.velocity + 
				
			}
			
			flip();
		}
	}
	
	function flip() {
		var temp = grid;
		grid = newGrid;
		newGrid = temp;
	}
	
	function updateFlow(dt:Float) {
		for (x in 0...gridWidth) for (y in 0...gridHeight) {
			var c:FluidCell = getCell(grid, x, y);
			
			var txf:Float = c.velocity.x * dt + x;
			var tyf:Float = c.velocity.y * dt + y;
			
			var tx:Int = Math.floor(txf);
			var ty:Int = Math.floor(tyf);
			
			var xlerp:Float = txf - tx;
			var ylerp:Float = tyf - ty;
			
			for (xx in 0...2) for (yy in 0...2) {
				var tc:FluidCell = getCell(newGrid, tx + xx, ty + yy);
				if (tc != null) {
					var xd = xx > 0 ? xlerp : (1 - xlerp);
					var yd = yy > 0 ? ylerp : (1 - ylerp);
					tc.velocity.x += xd * c.velocity.x;
					tc.velocity.y += yd * c.velocity.y;
					tc.pressure += xd * yd * c.pressure;
				}
			}
			
			c.pressure = 0;
			c.velocity.set();
		}
		flip();
	}
	
	inline function getCell(grid:Array<FluidCell>, x:Int, y:Int):FluidCell {
		if (x < 0 || x >= gridWidth || y >= gridHeight || y < 0) return null;
		return grid[x + y * gridWidth];
	}
}

class AutotilingState extends LycanState {
	public var s:FlxSprite;
	var springX:Spring;
	var springY:Spring;
	
	override public function create():Void {
		super.create();
		
		bgColor = 0xff444444;
		//FlxG.camera.x -= 200;
		//FlxG.camera.y -= 200;
		//FlxG.camera.width += 400;
		//FlxG.camera.height += 400;
		
		springX = new Spring();
		springY = new Spring();
		s = new FlxSprite(200, 200);
		s.scale.set(0.8, 0.8);
		s.scrollFactor.set();
		
		add(s);
		
		springX.setTarget(FlxG.camera.scroll, "x");
		springY.setTarget(FlxG.camera.scroll, "y");
		
		add(springX);
		add(springY);
		
		for (i in 0...50) {
			var b:FlxSprite = cast add(new FlxSprite(FlxG.random.float(FlxG.width), FlxG.random.float(FlxG.height)));
			var sf:Float = FlxG.random.float(0.1, 1.5);
			b.scrollFactor.set(sf, sf);
			b.alpha = (sf - 0.1) / 1.4;
			b.scale.set(sf, sf);
		}
		
		add(new FluidZone(50, 50));
	}
	
	override public function update(dt:Float):Void {
		if (FlxG.mouse.justPressed) {
			var dx:Float = FlxG.mouse.x - ((s.x + (s.width / 2)));
			springX.velocity += dx * 10;
			var dy:Float = FlxG.mouse.y - ((s.y + (s.height / 2)));
			springY.velocity += dy * 10;
		}
		
		super.update(dt);
	}
}

@:tink
class Spring2D extends FlxBasic {
	public var springX:Spring;
	public var springY:Spring;
	
	@:prop(return springX.value, springX.value = param) var x:Float;
	@:prop(return springY.value, springY.value = param) var y:Float;
	@:prop(return springX.velocity, springX.velocity = param) var velocityX:Float;
	@:prop(return springY.velocity, springY.velocity = param) var velocityY:Float;
	
	public function new(springConstant:Float = 8, damping:Float = 7, minPeakForce:Float = 2, mass:Float = 1) {
		super();
		springX = new Spring(springConstant, damping, minPeakForce, mass);
		springY = new Spring(springConstant, damping, minPeakForce, mass);
	}
}