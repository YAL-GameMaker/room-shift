package yy;

typedef GMPath = {
	resourceType:String,
	resourceVersion:String,
	name:String,
	kind:Int,
	precision:Int,
	closed:Bool,
	points:Array<{
		speed:Float,
		x:Float,
		y:Float
	}>,
	parent:{
		name:String,
		path:String
	}
};