package tools;

import haxe.iterators.DynamicAccessIterator;
import haxe.iterators.DynamicAccessKeyValueIterator;
#if (js)
import tools.NativeObject;
#end

/**
	This is _almost_ like haxe.DynamicAccess, but with some JS-specific tricks.
	@author YellowAfterlife
**/
#if js
@:forward(keys)
#else
@:forward(keys)
#end
abstract Dictionary<T>(DictionaryImpl<T>) from DictionaryImpl<T> {
	public inline function new() {
		#if js
		this = js.lib.Object.create(null);
		#else
		this = {};
		#end
	}
	public static function fromKeys<T>(keys:Array<String>, val:T):Dictionary<T> {
		var out = new Dictionary();
		for (key in keys) out.set(key, val);
		return out;
	}
	public static function fromObject<T>(obj:Dynamic):Dictionary<T> {
		var out = new Dictionary<T>();
		#if js
		NativeObject.forField(obj, function(s) {
			out.set(s, untyped obj[s]);
		});
		#else
		for (key in Reflect.fields(obj)) {
			out.set(key, Reflect.field(obj, key));
		}
		#end
		return out;
	}
	//
	public function copy():Dictionary<T> {
		#if js
		var dict = new Dictionary();
		NativeObject.forField(this, function(s) {
			dict[s] = get(s);
		});
		return dict;
		#else
		return this.copy();
		#end
	}
	//
	public inline function isEmpty():Bool {
		#if js
		return !NativeObject.hasFields(this);
		#else
		for (k => v in this) {
			return false;
		}
		return true;
		#end
	}
	public inline function exists(key:String):Bool {
		#if js
		return Reflect.hasField(this, key);
		#else
		return this.exists(key);
		#end
	}
	//
	#if js
	@:arrayAccess public inline function get(key:String):T {
		return untyped this[key];
	}
	public inline function nc(key:String):T {
		return JsTools.nca(this, untyped this[key]);
	}
	public inline function set(k:String, v:T):Void {
		untyped this[k] = v;
	}
	@:arrayAccess public inline function setret(k:String, v:T):T {
		return untyped this[k] = v;
	}
	public inline function remove(k:String):Void {
		js.Syntax.code("delete {0}[{1}]", this, k);
	}
	public inline function size():Int {
		return NativeObject.countFields(this);
	}
	#else
	@:arrayAccess public inline function get(key:String):T {
		return this.get(key);
	}
	public inline function nc(key:String):T {
		return (this != null ? this.get(key) : null);
	}
	public inline function set(k:String, v:T):Void {
		this.set(k, v);
	}
	@:arrayAccess public inline function setret(k:String, v:T):T {
		return this[k] = v;
	}
	public inline function remove(key:String):Void {
		this.remove(key);
	}
	public function size():Int {
		var n = 0;
		for (_ => _ in this) n += 1;
		return n;
	}
	#end
	public function defget(key:String, def:T):T {
		return this.exists(key) ? get(key) : def;
	}
	//
	public function move(k1:String, k2:String):Bool {
		if (exists(k2)) return false;
		if (exists(k1)) {
			var val = get(k1);
			remove(k1);
			set(k2, val);
			return true;
		} else return false;
	}
	//
	public inline function keys():Array<String> {
		return Reflect.fields(this);
	}
	//
	public inline function keyValueIterator():DynamicAccessKeyValueIterator<T> {
		return new DynamicAccessKeyValueIterator(this);
	}
	public inline function forEach(fn:String->T->Void):Void {
		#if js
		NativeObject.forField(this, function(s) fn(s, get(s)));
		#else
		for (key => val in this) fn(key, val);
		#end
	}
}

#if js
typedef DictionaryImpl<T> = Dynamic;
#else
typedef DictionaryImpl<T> = haxe.DynamicAccess<T>;
#end