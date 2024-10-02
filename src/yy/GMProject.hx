package yy;

/**
 * ...
 * @author YellowAfterlife
 */
typedef GMProject = {
	>YyBase,
	resources:Array<YyProjectResource>,
	//
	/** Exists 2.3 and forward */
	?Folders:Array<YyProjectFolder>,
	/** Exists 2.3 and forward */
	?TextureGroups:Array<YyTextureGroup>,
	//
	?MetaData: { IDEVersion: String },
};
typedef YyProjectFolder = {
	>YyBase,
	folderPath:String,
	?order:Int,
	name:String,
}
typedef YyTextureGroup = {
	>YyBase,
	name: String,
	isScaled:Bool,
	autocrop:Bool,
	border:Int,
	mipsToGenerate:Int,
	groupParent:String,
	targets:Int,
}

typedef YyResourceOrderItem = {
	name:String,
	path:String,
	order:Int,
}
typedef YyResourceOrderSettings = {
	FolderOrderSettings: Array<YyResourceOrderItem>,
	ResourceOrderSettings: Array<YyResourceOrderItem>,
}