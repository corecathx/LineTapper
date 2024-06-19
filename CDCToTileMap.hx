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

	static function main()
	{
		trace("hi");
		cls();
		Sys.println("hold on");
		var path:String = "D:/GAMES/FNFMOD/CoreDev Engine/cdev_engine-master/art/chartTemp/blazin/blazin.cdc";

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
            var lastDir:Int = 1;
			for (i in anotherWeird.notes)
			{
                var rand:Int = Math.round(Math.random()*3);
				do  {
                    rand = Math.round(Math.random()*3);
                } while (lastDir == rand);

                lastDir = rand;
                tileData.tiles.push(cast {
                    step: Math.round(i[0]/step_ms),
                    direction: rand
                });
			}
			trace("BPM: " + mainChart.info.bpm + " // ");

            File.saveContent("./newChart.json", Json.stringify(tileData,"\t"));
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
