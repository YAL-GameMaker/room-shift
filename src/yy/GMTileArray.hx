package yy;

import haxe.ds.Vector;

typedef GMTileArray = Array<GMTileItem>;
typedef GMTileItem = Float;

abstract GMTileRLE(Array<Float>) {
	public inline function toArray():GMTileArray {
		var arr = this;
		var out = [];
		var pos = 0;
		while (pos < arr.length) {
			var op = Std.int(arr[pos++]);
			if (op < 0) {
				var fill = arr[pos++];
				for (_ in 0 ... -op) {
					out.push(fill);
				}
			} else {
				for (_ in 0 ... op) {
					out.push(arr[pos++]);
				}
			}
		}
		return out;
	}
	public static inline function fromArray(arr:GMTileArray):GMTileRLE {
		var i = 0;
		var n = arr.length;
		var out:Array<Float> = [];
		var numAt = -1;
		while (i < n) {
			var v = arr[i++];
			if (i + 1 < n && arr[i] == v && arr[i + 1] == v) {
				// sequence
				var start = i - 1;
				while (i < n) {
					if (arr[i] == v) {
						i += 1;
					} else break;
				}
				out.push(-(i - start));
				out.push(v);
				numAt = -1;
				continue;
			}
			if (numAt < 0) {
				numAt = out.length;
				out.push(0);
			}
			out[numAt] += 1;
			out.push(v);
		}
		return cast out;
	}
}

abstract GMTileGrid(Vector<GMTileGridRow>)
from Vector<GMTileGridRow>
to Vector<GMTileGridRow> {
	public var width(get, never):Int;
	inline function get_width() return this[0].length;
	
	public var height(get, never):Int;
	inline function get_height() return this.length;
	//
	public function new(cols:Int, rows:Int) {
		this = new Vector(rows, null);
		for (y in 0 ... rows) {
			this[y] = new Vector(cols, -2147483648.0);
		}
	}
	//
	public static function fromArray(arr:GMTileArray, cols:Int):GMTileGrid {
		var rows = Std.int(arr.length / cols);
		var out = new Vector<GMTileGridRow>(rows, null);
		var pos = 0;
		for (y in 0 ... rows) {
			var row = new GMTileGridRow(cols, 0.0);
			for (x in 0 ... cols) {
				row.set(x, arr[pos++]);
			}
			out[y] = row;
		}
		return out;
	}
	public function toArray():GMTileArray {
		var arr = [];
		for (y in 0 ... height) {
			var row = this[y];
			for (x in 0 ... width) {
				arr.push(row[x]);
			}
		}
		return arr;
	}
	//
	public static function fromRLE(rle:GMTileRLE, cols:Int) {
		return fromArray(rle.toArray(), cols);
	}
	public function toRLE():GMTileRLE {
		return GMTileRLE.fromArray(toArray());
	}
	//
	public inline function asVector():Vector<GMTileGridRow> return this;
	//
	public inline function get(x:Int, y:Int):GMTileItem {
		return this[y][x];
	}
	public inline function set(x:Int, y:Int, val:GMTileItem) {
		this[y][x] = val;
	}
	public function expand(dl:Int, dt:Int, dr:Int, db:Int) {
		inline function imin(a, b) {
			return a < b ? a : b;
		}
		inline function imax(a, b) {
			return a > b ? a : b;
		}
		var rows = height;
		var cols = width;
		//
		var newCols = cols + dl + dr;
		var newRows = rows + dt + db;
		var out = new GMTileGrid(newCols, newRows);
		//
		var x0 = imax(0, -dl);
		var x1 = cols - imax(0, -dr);
		//var ox = imax(0, dl);
		var y0 = imax(0, -dt);
		var y1 = rows - imax(0, -db);
		//var oy = imax(0, dt);
		//
		for (y in y0 ... y1) {
			for (x in x0 ... x1) {
				out.set(x + dl, y + dt, get(x, y));
			}
		}
		return out;
	}
	public function testFill() {
		for (y in 0 ... height) {
			for (x in 0 ... width) {
				set(x, y, (x + 1) + (y + 1) * 10);
			}
		}
	}
	@:keep public function toString() {
		return width + "x" + height + "\n" + this.map(row -> row.join("\t")).join("\n");
	}
}
typedef GMTileGridRow = Vector<GMTileItem>;
