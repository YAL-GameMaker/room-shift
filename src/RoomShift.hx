import yy.GMProject;
import yy.GMTileSet;
import yy.GMRoom;
import yy.GMPath;
import yy.layers.*;
import yy.GMTileArray;

class RoomShift {
	public static inline function log(msg:String) {
		#if sys
		Sys.println(msg);
		#else
		trace(msg);
		#end
	}
	static function timeDiffToString(td:Float) {
		if (td < 1) {
			return Math.round(td * 1000) + "ms";
		} else {
			return (Math.round(td * 100) / 100) + "s";
		}
	}
	public static inline function logStart(msg:String):RoomShiftTimeCtx {
		#if sys
		Sys.print(msg + "...");
		#end
		return { name: msg, time: haxe.Timer.stamp() };
	}
	public static inline function logEnd(ctx:RoomShiftTimeCtx) {
		#if sys
		Sys.println(" " + timeDiffToString(Sys.time() - ctx.time));
		#else
		trace(ctx.name + ": " + timeDiffToString(haxe.Timer.stamp() - ctx.time));
		#end
	}
	public static function apply(roomName:String, config:RoomShiftConfig) {
		var project = Project.current;
		var roomPath = 'rooms/$roomName/$roomName.yy';
		log('Applying to "$roomName"...');
		//
		var tc = logStart("Loading YY");
		var room:GMRoom = project.readYyFile(roomPath);
		logEnd(tc);
		tc = logStart("Applying");
		var roomSettings = room.roomSettings;
		//
		var sx = config.sizeDX ?? 0;
		var sy = config.sizeDY ?? 0;
		var ox = config.offsetX ?? 0;
		var oy = config.offsetY ?? 0;
		//
		var halign = config.halign ?? 0;
		var valign = config.valign ?? 0;
		if (config.width != null) {
			sx = config.width - roomSettings.Width;
			ox = Math.round(sx * halign / 2);
		}
		if (config.height != null) {
			sy = config.height - roomSettings.Height;
			oy = Math.round(sy * valign / 2);
		}
		//
		var hasSize = sx != 0 || sy != 0;
		var hasOffset = ox != 0 || oy != 0;
		if (!hasOffset && !hasSize) return;
		//
		if (hasSize) {
			roomSettings.Width += sx;
			roomSettings.Height += sy;
		}
		//
		function proc(layer:GMRLayer) switch (layer.resourceType) {
			case "GMRLayer": {
				for (sublayer in layer.layers) proc(sublayer);
			};
			case "GMRInstanceLayer": if (hasOffset) {
				var instLayer:GMRInstanceLayer = cast layer;
				for (inst in instLayer.instances) {
					inst.x += ox;
					inst.y += oy;
				}
			};
			case "GMRAssetLayer": if (hasOffset) {
				var assetLayer:GMRAssetLayer = cast layer;
				for (sprite in assetLayer.assets) {
					sprite.x += ox;
					sprite.y += oy;
				}
			};
			case "GMRTileLayer": {
				var tileLayer:GMRTileLayer = cast layer;
				if (tileLayer.tilesetId == null) return;
				//
				var tileSet:GMTileSet = project.readYyFile(tileLayer.tilesetId.path);
				var tileWidth = tileSet.tileWidth;
				var tileHeight = tileSet.tileHeight;
				//
				var addX = 0, addY = 0;
				var addLeft = 0, addTop = 0;
				if (ox != 0) {
					addLeft = Math.ceil(ox / tileWidth);
					addX = ox - addLeft * tileWidth;
				}
				if (oy != 0) {
					addTop = Math.ceil(oy / tileHeight);
					addY = oy - addTop * tileHeight;
				}
				//
				var tiles = tileLayer.tiles;
				var grid = GMTileGrid.fromRLE(tiles.TileCompressedData, tiles.SerialiseWidth);
				if (addLeft != 0 || addTop != 0) {
					grid = grid.expand(addLeft, addTop, 0, 0);
					tiles.TileCompressedData = grid.toRLE();
					tiles.SerialiseWidth += addLeft;
					tiles.SerialiseHeight += addTop;
				}
				//
				tileLayer.x += addX;
				tileLayer.y += addY;
			};
			case "GMRPathLayer": if (hasOffset) {
				var pathLayer:GMRPathLayer = cast layer;
				if (pathLayer.pathId == null) return;
				//
				var relPath = pathLayer.pathId.path;
				var path:GMPath = project.readYyFile(relPath);
				for (pt in path.points) {
					pt.x += ox;
					pt.y += oy;
				}
				project.writeYyFile(relPath, path);
			};
			case "GMRBackgroundLayer": if (hasOffset) {
				var backLayer:GMRBackgroundLayer = cast layer;
				if (backLayer.spriteId == null) return;
				//
				backLayer.x += ox;
				backLayer.y += oy;
			};
		}
		for (layer in room.layers) proc(layer);
		//
		logEnd(tc);
		tc = logStart("Writing YY");
		project.writeYyFile(roomPath, room);
		logEnd(tc);
	}
}
typedef RoomShiftConfig = {
	?sizeDX:Int,
	?sizeDY:Int,
	?offsetX:Int,
	?offsetY:Int,
	?width:Int,
	?height:Int,
	?halign:Float,
	?valign:Float,
}
typedef RoomShiftPathMod = (name:String, func:GMPath->Void)->Void;
typedef RoomShiftTimeCtx = { name:String, time:Float };