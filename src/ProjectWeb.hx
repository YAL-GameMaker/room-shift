import yy.YyJsonParser;
import js.html.FileReader;
import js.lib.Promise;
import js.html.FileReaderSync;
import haxe.io.Path;
import js.html.File;

class ProjectWeb extends Project {
	public var fileList:Array<WebkitFile>;
	public var fileMap:Map<String, WebkitFile> = new Map();
	public var prefix = "";
	public function new(files:Array<WebkitFile>) {
		fileList = files;
		for (file in files) {
			var relPath = file.webkitRelativePath;
			fileMap[relPath] = file;
			if (Path.extension(relPath).toLowerCase() == "yyp") {
				prefix = Path.directory(relPath) + "/";
				filename = Path.withoutDirectory(relPath);
			}
		}
		super();
		if (filename != null) {
			readTextFileAsync(filename).then(text -> ready());
		} else throw "Directory does not contain a YYP file";
	}
	function fullPath(relPath:String) {
		return Path.normalize(prefix + relPath);
	}
	override function readTextFile(relPath:String):String {
		relPath = fullPath(relPath);
		var file = fileMap[relPath];
		if (file == null) throw '"$relPath" does not exist';
		if (file.yalContent == null) throw '"$relPath" is not ready';
		return file.yalContent;
	}
	override function writeTextFile(relPath:String, content:String) {
		relPath = fullPath(relPath);
		var file = fileMap[relPath];
		if (file == null) {
			throw "uh oh";
			//file = new File([""], relPath, null);
			fileMap[relPath] = file;
			fileList.push(file);
		}
		file.yalChanged = true;
		file.yalContent = content;
		file.yalContentYY = null;
	}
	public function readTextFileAsync(relPath:String) {
		relPath = fullPath(relPath);
		var file = fileMap[relPath];
		if (file == null) throw '"$relPath" does not exist';
		return new Promise((resolve, reject) -> {
			if (file.yalContent != null) {
				js.Browser.window.setTimeout(function() {
					resolve(file.yalContent);
				});
				return;
			}
			var reader = new FileReader();
			reader.onload = function() {
				file.yalContent = reader.result;
				file.yalContentYY = null;
				resolve(file.yalContent);
			};
			reader.onerror = function() {
				reject('Failed to read "$relPath": ' + reader.error);
			};
			reader.readAsText(file, relPath);
		});
	}
	public function readYyFileAsync(relPath:String):Promise<Any> {
		return readTextFileAsync(relPath).then(function(text) {
			return YyJsonParser.parse(text);
		});
	}
}
extern class WebkitFile extends File {
	public var webkitRelativePath:String;
	public var yalChanged:Bool;
	public var yalContent:String;
	public var yalContentYY:String;
}
