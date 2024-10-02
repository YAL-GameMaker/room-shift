import yy.GMProject;
import yy.GMTileSet;
import yy.GMRoom;
import yy.GMPath;
import yy.layers.*;
import yy.GMTileArray;

class RoomShift {
	public static function apply(roomName:String, config:RoomShiftConfig) {
		var project = Project.current;
		var roomPath = 'rooms/$roomName/$roomName.yy';
		var room:GMRoom = project.readYyFile(roomPath);
		//
		var sdx = config.sizeDX ?? 0;
		var sdy = config.sizeDY ?? 0;
		var ox = config.offsetX ?? 0;
		var oy = config.offsetY ?? 0;
		//
		var hasSize = sdx != 0 || sdy != 0;
		var hasOffset = ox != 0 || oy != 0;
		if (!hasOffset && !hasSize) return;
		//
		if (hasSize) {
			room.roomSettings.Width += sdx;
			room.roomSettings.Height += sdy;
		}
		//
		for (layer in room.layers) switch (layer.resourceType) {
			case "GMRInstanceLayer": if (hasOffset) {
				var instLayer:GMRInstanceLayer = cast layer;
				for (inst in instLayer.instances) {
					inst.x += ox;
					inst.x += ox;
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
				if (tileLayer.tilesetId == null) continue;
				//
				var tileSet:GMTileSet = project.readYyFile(tileLayer.tilesetId.path);
				var arr = tileLayer.tiles.TileCompressedData.toArray();
				var grid = GMTileGrid.fromArray(arr, tileLayer.tiles.SerialiseWidth);
				var tileWidth = tileSet.tileWidth;
				var tileHeight = tileSet.tileHeight;
				tileLayer.x += ox;
				tileLayer.y += oy;
			};
			case "GMRPathLayer": if (hasOffset) {
				var pathLayer:GMRPathLayer = cast layer;
				if (pathLayer.pathId == null) continue;
				//
				var relPath = pathLayer.pathId.path;
				var path:GMPath = project.readYyFile(relPath);
				for (pt in path.points) {
					pt.x += ox;
					pt.y += oy;
				}
				project.writeYyFile(relPath, path);
			}
		}
		//
		project.writeYyFile(roomPath, room);
	}
}
typedef RoomShiftConfig = {
	?sizeDX:Int,
	?sizeDY:Int,
	?offsetX:Int,
	?offsetY:Int,
}
typedef RoomShiftPathMod = (name:String, func:GMPath->Void)->Void;