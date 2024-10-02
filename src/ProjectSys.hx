import sys.io.File;
import haxe.io.Path;

class ProjectSys extends Project {
	public var dir:String;
	public function new(path:String) {
		dir = Path.directory(path);
		filename = Path.withoutDirectory(path);
		super();
	}
	override function readTextFile(relPath:String):String {
		return File.getContent(Path.join([dir, relPath]));
	}
	override function writeTextFile(relPath:String, content:String) {
		File.saveContent(Path.join([dir, relPath]), content);
	}
}