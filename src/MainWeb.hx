import js.html.Blob;
import haxe.io.Bytes;
import haxe.zip.Entry;
import haxe.ds.List;
import haxe.io.BytesOutput;
import haxe.zip.Writer;
import js.html.FormElement;
import ProjectWeb.WebkitFile;
import RoomShift;
import js.html.InputEvent;
import js.html.InputElement;
import js.html.Element;
import js.Browser.*;
using StringTools;

class MainWeb {
	static inline function find<T:Element>(query:String, ?c:Class<T>):T {
		return cast document.querySelector(query);
	}
	static inline function findInput(name:String):InputElement {
		return find("#opt-" + name);
	}
	static var opt_left = findInput("left");
	static var opt_right = findInput("right");
	static var opt_top = findInput("top");
	static var opt_bottom = findInput("bottom");
	static var opt_width = findInput("width");
	static var opt_height = findInput("height");
	static var opt_halign = findInput("halign");
	static var opt_valign = findInput("valign");
	static var opt_rooms = findInput("rooms");
	static var opt_project = findInput("project");
	static var opt_run = findInput("run");
	static var opt_download = findInput("download");
	static var project:ProjectWeb = null;
	static var form_project:FormElement = find("#form-project");
	
	public static function main() {
		for (node in document.querySelectorAll(".set-input")) {
			var btn:InputElement = cast node;
			var target:InputElement = find(btn.dataset.target);
			var value = btn.dataset.value;
			btn.onclick = function(_) {
				target.value = value;
			}
		}
		//
		/*opt_left.value = "16";
		opt_top.value = "32";
		opt_rooms.value = "Room1";*/
		//
		opt_project.onchange = function() {
			var files:Array<WebkitFile> = [];
			for (file in opt_project.files) {
				files.push(cast file);
			}
			RoomShift.logElement.innerHTML = "";
			try {
				project = new ProjectWeb(files);
				Project.current = project;
				opt_run.disabled = false;
				RoomShift.log("Project loaded! You can modify rooms now.");
			} catch (x) {
				opt_run.disabled = true;
				RoomShift.warn("Failed to load: " + x);
			}
			form_project.reset();
		}
		opt_run.onclick = function() {
			if (opt_run.disabled || project == null) return;
			var opt:RoomShiftConfig = {};
			function flt(input:InputElement):Null<Float> {
				var s = input.value;
				if (s.trim() == "") return null;
				var v = Std.parseFloat(s);
				if (Math.isNaN(v)) {
					RoomShift.log(input.id + "'s value is not a number");
					return null;
				}
				return v;
			}
			function int(input:InputElement):Null<Int> {
				var s = input.value;
				if (s.trim() == "") return null;
				var v = Std.parseInt(s);
				if (v == null) {
					RoomShift.log(input.id + "'s value is not a number");
					return null;
				}
				return v;
			}
			opt.sizeDX = int(opt_left);
			opt.offsetX = opt.sizeDX;
			opt.sizeDY = int(opt_top);
			opt.offsetY = opt.sizeDY;
			opt.offsetX += int(opt_right);
			opt.offsetY += int(opt_bottom);
			opt.width = int(opt_width);
			opt.height = int(opt_height);
			opt.halign = flt(opt_halign);
			opt.valign = flt(opt_valign);
			var rooms = [];
			var roomStr = opt_rooms.value.trim().replace("\r", "");
			for (line in roomStr.split("\n")) {
				line = line.trim();
				if (line == "") continue;
				project.procRoomArg(rooms, line);
			}
			//
			function next(_:Any) {
				var room = rooms.shift();
				if (room != null) {
					return RoomShift.applyAsync(room, opt).then(next);
				} else {
					RoomShift.log("OK!");
					opt_download.disabled = false;
					return null;
				}
			}
			opt_download.disabled = true;
			RoomShift.logElement.innerHTML = "";
			if (rooms.length == 0) {
				RoomShift.warn("Nothing to do!");
			} else next(null);
		}
		opt_download.onclick = function() {
			if (opt_download.disabled) return;
			var files = [];
			for (file in project.fileList) {
				if (file.yalChanged) files.push(file);
			}
			//
			var zipFiles = new List();
			for (file in project.fileList) if (file.yalChanged) {
				var zipBytes = Bytes.ofString(file.yalContent);
				var zipEntry:Entry = {
					fileName: file.webkitRelativePath,
					fileSize: zipBytes.length,
					fileTime: Date.now(),
					compressed: false,
					dataSize: zipBytes.length,
					data: zipBytes,
					crc32: null,
				};
				zipFiles.push(zipEntry);
			}
			var zipOutput = new BytesOutput();
			var zipWriter = new Writer(zipOutput);
			zipWriter.write(zipFiles);
			var zipBytes = zipOutput.getBytes();
			zipBytes = zipBytes.sub(0, zipOutput.length);
			//
			var zipBlob:Blob = new Blob([zipBytes.getData()]);
			var zipName = "rooms-shifted.zip";
			(cast window).saveAs(zipBlob, zipName, "application/zip");
			//
			console.log(files);
		}
		//
	}
}