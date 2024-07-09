import haxe.Json;
import sys.FileSystem;
import sys.io.File;

typedef TileData =
{
	var step:Int;
	var direction:Int;
}

typedef LineMap =
{
	var tiles:Array<TileData>;
	var bpm:Float;
}

typedef WeirdData = {
    var notes:Array<Dynamic>;
} 

/**
 * CDC is my FNF Engine's chart format ("CDEV Chart", used in FNF CDEV Engine)
 * This haxe code is used to convert CDC to this game's map format, currently called as "TileMap"
 */
class CDCToTileMap
{
	/** Current BPM, change it using `updateBPM` **/
	public static var bpm:Float = 120;

	/** Single beat in miliseconds **/
	public static var beat_ms:Float = 500;

	/** Single step in miliseconds **/
	public static var step_ms:Float = 125;

	/** offset **/
	public static var offset:Float = 60;

	static function main()
	{
		trace("hi");
		cls();
		Sys.println("hold on");
		var path:String = "D:/GAMES/FNFMOD/CoreDev Engine/cdev_engine-master/art/converter/chartTemp/right-now/right-now.cdc";

		if (FileSystem.exists(path))
		{
			Sys.println("Exists!");
            var tileData:LineMap = {
                tiles: [],
                bpm: 0
            }
			var mainChart = Json.parse(File.getContent(path));
            updateBPM(mainChart.info.bpm);
            tileData.bpm = mainChart.info.bpm;
            var anotherWeird:WeirdData = Json.parse(File.getContent(path));
			var lastDirs:Array<Int> = [];
			var lastStep:Int = 0;
			for (i in anotherWeird.notes)
			{
				var stp:Int = Math.round((i[0] - offset) / step_ms);
				if (lastStep == stp)
					continue;
				lastStep = stp;
				var rand:Int;
				do
				{
					rand = Math.round(Math.random() * 3);
				}
				while (lastDirs.contains(rand));
			
				lastDirs.push(rand);
				if (lastDirs.length > 2)
					lastDirs.shift();

				tileData.tiles.push(cast {
					step: stp,
					direction: rand
				});
			}

			trace("BPM: " + mainChart.info.bpm + " // ");

			File.saveContent("./assets/data/maps/Right Now/map.json", Json.stringify(tileData, "\t"));
		}
		else
		{
			Sys.println("Nope.");
		}
	}

	public static function updateBPM(newBPM:Float = 120)
	{
		bpm = newBPM;
		beat_ms = ((60 / bpm) * 1000);
		step_ms = beat_ms / 4;
	}

	static function cls()
	{
		Sys.command("cls");
	}
}
