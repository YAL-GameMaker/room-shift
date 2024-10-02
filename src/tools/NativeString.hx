package tools;

class NativeString {
	public static function repeat(s:String, n:Int) {
		var b = new StringBuf();
		for (_ in 0 ... n) {
			b.add(s);
		}
		return b.toString();
	}
}