import yy.GMProject;
import yy.YyJsonPrinter;
import yy.YyJsonParser;
using StringTools;

class Project {
	/**
		That's right, we're doing this again.
		Can't override static methods, you know?
	**/
	public static var current:Project;
	//
	public var filename:String;
	public var roomList:Array<String> = [];
	//
	public function new() {
		
	}
	public function ready() {
		var root:GMProject = readYyFile(filename);
		//
		var yyResourceVersion = try {
			Std.parseFloat(root.resourceVersion);
		} catch (x:Dynamic) 1.0;
		//
		var metaData = root.MetaData;
		if (metaData != null && metaData.IDEVersion != null) {
			var rxYear = new EReg("^(20\\d{2})\\.", "");
			var year = 0;
			if (rxYear.match(metaData.IDEVersion)) {
				year = Std.parseInt(rxYear.matched(1));
			}
			
			@:privateAccess {
				YyJsonPrinter.isGM2023 = year >= 2023;
				YyJsonPrinter.isGM2024 = year >= 2024;
				YyJsonPrinter.wantPrefixFields = year < 2023 && yyResourceVersion >= 1.6;
			}
		}
		//
		for (res in root.resources) {
			var rel = res.id.path;
			if (!rel.startsWith("rooms/")) continue;
			roomList.push(res.id.name);
		}
	}
	//
	public function readTextFile(relPath:String):String {
		throw "todo";
	}
	public function readYyFile(relPath:String):Any {
		var text = readTextFile(relPath);
		return YyJsonParser.parse(text);
	}
	public function readYyResource(kind:String, name:String):Any {
		return readYyFile(kind + 's/$name/$name.yy');
	}
	//
	public function writeTextFile(relPath:String, content:String) {
		throw "todo";
	}
	public function writeYyFile(relPath:String, obj:Any) {
		writeTextFile(relPath, YyJsonPrinter.stringify(obj, true));
	}
	public function procRoomArg(rooms:Array<String>, arg:String) {
		function roomProc(room:String, remove:Bool) {
			if (remove) {
				rooms.remove(room);
			} else {
				if (!rooms.contains(room)) {
					rooms.push(room);
				}
			}
		}
		var remove = false;
		if (arg.startsWith("-")) {
			remove = true;
			arg = arg.substring(1);
		}
		if (arg.contains("*") || arg.contains("#")) {
			var rs = "^" + arg.replace("*", ".+?").replace("#", "\\d+?") + "$";
			var rx = new EReg(rs, "");
			for (room in roomList) {
				if (rx.match(room)) roomProc(room, remove);
			}
		} else {
			if (roomList.contains(arg)) {
				roomProc(arg, remove);
			} else {
				RoomShift.warn('Room "$arg" does not exist.');
			}
		}
	}
}