import yy.GMProject;
import yy.YyJsonPrinter;
import yy.YyJsonParser;

class Project {
	/**
		That's right, we're doing this again.
		Can't override static methods, you know?
	**/
	public static var current:Project;
	//
	public var filename:String;
	public function new() {
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
}