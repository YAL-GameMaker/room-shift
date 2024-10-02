package yy.layers;

typedef GMRPathLayer = {
	resourceType:String,
	resourceVersion:String,
	name:String,
	pathId:{
		name:String,
		path:String
	},
	colour:Int,
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