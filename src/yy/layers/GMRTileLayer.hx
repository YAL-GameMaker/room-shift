package yy.layers;

import yy.GMTileArray;

typedef GMRTileLayer = {
	resourceType:String,
	resourceVersion:String,
	name:String,
	depth:Int,
	tilesetId:{
		name:String,
		path:String
	},
	x:Int,
	y:Int,
	tiles:{
		TileDataFormat:Int,
		SerialiseWidth:Int,
		SerialiseHeight:Int,
		TileCompressedData:GMTileRLE
	},
	visible:Bool,
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