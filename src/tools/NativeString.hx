package tools;
import haxe.extern.EitherType;
#if js
import js.lib.RegExp;
#end
import haxe.Constraints.Function;

class NativeString {
	public static function repeat(s:String, n:Int) {
		var b = new StringBuf();
		for (_ in 0 ... n) {
			b.add(s);
		}
		return b.toString();
	}
	#if js
	public static inline function replaceExt(
		s:String, what:EitherType<String, RegExp>, by:EitherType<String, Function>
	):String {
		return untyped s.replace(what, by);
	}
	#end
}