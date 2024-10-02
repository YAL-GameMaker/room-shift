import yy.GMTileArray;

class Main {
	public static function main() {
		/*var g = new GMTileGrid(4, 4);
		g.testFill();
		trace(g);
		trace(g.expand(1, 0, -1, -1));*/
		Project.current = new ProjectSys("room-shift-test/room-shift-test.yyp");
		RoomShift.apply("Room1", {
			offsetX: 10,
			offsetY: -10,
		});
	}
}