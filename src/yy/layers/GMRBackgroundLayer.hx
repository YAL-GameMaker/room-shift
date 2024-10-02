package yy.layers;

typedef GMRBackgroundLayer = {
	resourceType:String,
	resourceVersion:String,
	name:String,
	spriteId:{
		name:String,
		path:String
	},
	colour:Int,
	x:Int,
	y:Int,
	htiled:Bool,
	vtiled:Bool,
	hspeed:Float,
	vspeed:Float,
	stretch:Bool,
	animationFPS:Float,
	animationSpeedType:Int,
	userdefinedAnimFPS:Bool,
	visible:Bool,
	depth:Int,
	userdefinedDepth:Bool,
	inheritLayerDepth:Bool,
	inheritLayerSettings:Bool,
	inheritVisibility:Bool,
	inheritSubLayers:Bool,
	gridX:Int,
	gridY:Int,
	layers:Array<Any>,
	hierarchyFrozen:Bool,
	effectEnabled:Bool,
	effectType:Any,
	properties:Array<Any>
};