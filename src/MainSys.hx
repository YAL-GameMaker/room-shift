import yy.YyJsonMeta;
import yy.YyJsonPrinter;
import yy.GMTileArray;
using StringTools;
import RoomShift;

class MainSys {
	public static function main() {
		YyJsonPrinter.init();
		Sys.println("Running...");
		//
		var args = Sys.args();
		var opt:RoomShiftConfig = {
			offsetX: 0,
			offsetY: 0,
			sizeDX: 0,
			sizeDY: 0,
		};
		function parseAlign(s:String, ctx:String):Float {
			switch (s) {
				case "left", "top": return 0;
				case "center", "middle": return 1;
				case "right", "bottom": return 2;
				default: {
					var f = Std.parseFloat(s);
					if (Math.isNaN(f)) throw 'Expected an align name or number for "$ctx", got "$s"';
					return f;
				}
			}
		}
		var projectPath = null;
		var i = 0;
		while (i < args.length) {
			var del = 2;
			var arg = args[i];
			inline function argStr(k = 1) {
				return args[i + k];
			}
			inline function argInt(k = 1) {
				return Std.parseInt(args[i + k]);
			}
			switch (arg) {
				case "--project": projectPath = argStr();
				case "--left": {
					var amt = argInt();
					opt.offsetX += amt;
					opt.sizeDX += amt;
				};
				case "--top": {
					var amt = argInt();
					opt.offsetY += amt;
					opt.sizeDY += amt;
				};
				case "--right": opt.sizeDX += argInt();
				case "--bottom": opt.sizeDY += argInt();
				case "--width": opt.width = argInt();
				case "--height": opt.height = argInt();
				case "--halign": opt.halign = parseAlign(argStr(), arg);
				case "--valign": opt.valign = parseAlign(argStr(), arg);
				default: del = 0;
			}
			if (del > 0) {
				args.splice(i, del);
			} else {
				i += 1;
			}
		}
		//
		if (projectPath == null) {
			Sys.println('Expected a --project path');
			Sys.exit(1);
		}
		var project = new ProjectSys(projectPath);
		Project.current = project;
		//
		var rooms = [];
		function roomProc(room:String, remove:Bool) {
			if (remove) {
				rooms.remove(room);
			} else {
				if (!rooms.contains(room)) {
					rooms.push(room);
				}
			}
		}
		for (arg in args) {
			var remove = false;
			if (arg.startsWith("-")) {
				remove = true;
				arg = arg.substring(1);
			}
			if (arg.contains("*") || arg.contains("#")) {
				var rs = "^" + arg.replace("*", ".+?").replace("#", "\\d+?") + "$";
				var rx = new EReg(rs, "");
				for (room in project.roomList) {
					if (rx.match(room)) roomProc(room, remove);
				}
			} else {
				if (project.roomList.contains(arg)) {
					roomProc(arg, remove);
				} else {
					Sys.println('Room "$arg" does not exist.');
				}
			}
		}
		//
		if (rooms.length == 0) {
			Sys.println('No rooms to apply to!');
			Sys.exit(1);
		}
		Sys.println("Configuration: " + opt);
		Sys.println("Rooms: " + rooms.join(", "));
		return;
		for (room in rooms) {
			RoomShift.apply(room, opt);
		}
		Sys.println("OK!");
	}
}