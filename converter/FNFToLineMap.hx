import haxe.ds.ArraySort;
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

class FNFToLineMap
{
	/** Current BPM, change it using `updateBPM` **/
	public static var bpm:Float = 120;

	/** Single step in miliseconds **/
	public static var step_ms:Float = 125;

	/** offset **/
	public static var offset:Float = 0;

	static function main()
	{
		trace("hi");
		var isWindows:Bool = Sys.systemName() == "Windows";
		Sys.command(isWindows ? "cls" : "clear");
		Sys.println("[ \x1b[36mFNF To LineMap\x1b[0m ]");
        Sys.print("Path: ./fnfchart/");
		var path:String = "./fnfchart/" + Sys.stdin().readLine();
		if (FileSystem.exists(path))
		{
            var tileData:LineMap = {
                tiles: [],
                bpm: 0
            }
			var mainChart = Json.parse(File.getContent(path)).song;
            updateBPM(mainChart.bpm);
            tileData.bpm = mainChart.bpm;
            var anotherWeird:WeirdData = Json.parse(File.getContent(path)).song;
			var lastDirs:Array<Int> = [];
			var lastSteps:Array<Int> = [];
			var maxNote:Int = 0;

			for (e in anotherWeird.notes){
				var sec:Array<Dynamic> = e.sectionNotes;
                for (i in sec) maxNote++;	
			}
			var note:Int = 0;
			for (e in anotherWeird.notes) {
				var sec:Array<Dynamic> = e.sectionNotes;
				for (i in sec) {
					note++;
					var pNote:Float = note / maxNote;
					var percentage = Math.floor(pNote * 100);
	
					// Construct the progress bar
					var progressBar = "\x1b[36m┃";
					for (j in 1...50) {
						if (pNote * 50 >= j) progressBar += "█"; else progressBar += " ";
					}
					progressBar += "┃\x1b[0m";
	
					// Combine all output in one print statement
					var output = "\x1b[0G\x1b[K\r[  \x1b[38;5;10mWorking\x1b[0m ] Note: " + note + " >> " + percentage + "% " + progressBar;
					Sys.print(output);
	
					// Update less frequently
					if (note % 10 == 0 || note == maxNote) {
						Sys.print(output);
						Sys.sleep(0.01); // Small delay to visualize progress
					}
	
					var stp:Int = Math.round((i[0] - offset) / step_ms);
					if (lastSteps.contains(stp)) continue;
	
					lastSteps.push(stp);
					var rand:Int;
					do {
						rand = Math.round(Math.random() * 3);
					} while (lastDirs.contains(rand));
	
					lastDirs.push(rand);
					if (lastDirs.length > 2)
						lastDirs.shift();
	
					tileData.tiles.push(cast {
						step: stp,
						direction: rand
					});
				}
			}

			Sys.println("\n[   Info   ] BPM: " + mainChart.bpm + " // Tile Count: " + tileData.tiles.length);

			tileData.tiles.sort((a:TileData, b:TileData)->{
				var result:Int = 0;
		
				if (a.step < b.step)
					result = -1;
				else if (a.step > b.step)
					result = 1;
		
				return result;
			});

			File.saveContent("./linemap/"+mainChart.song+".json", Json.stringify(tileData, "\t"));
			Sys.println("[ Finished ] Saved on " + "./linemap/"+mainChart.song+".json");
		}
		else
		{
			Sys.println("File not found.");
		}
	}

	public static function updateBPM(newBPM:Float = 120)
	{
		bpm = newBPM;
		step_ms = ((60 / bpm) * 1000) / 4;
	}
}
