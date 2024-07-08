package objects;

import flixel.FlxG;
import flixel.math.FlxMath;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
import sys.io.File;

/**
 * FPS and Memory Usage counter that's shown on top corner left of the game.
 */
class SystemInfo extends TextField
{
	/**
	 * Just like the variable's name, it returns current FPS.
	 */
	public var curFps:Int = 0;

	/**
	 * Current used Memory by the game in Bytes.
	 * (Depends on what memory setting the player used, it can be showing the garbage collector memory / the total program used memory.)
	 */
	public var curMemory:Float = 0;
	
	/**
	 * Memory Peak / Highest Memory.
	 */
	public var highestMemory:Float = 0;

	/**
	 * Static instance of this class.
	 */
	public static var current:SystemInfo = null;

	public var times:Array<Float>;

	public static var curFont = Assets.font("fredoka-bold");

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0x000000, bold:Bool = false)
	{
		super();
		x = inX;
		y = inY;
		current = this;

		selectable = false;
		defaultTextFormat = new TextFormat(curFont, 12, inCol, false);
		text = "FPS: ";
		times = [];
		autoSize = LEFT;
	}

	var updateTime:Float = 0;
	private override function __enterFrame(elapsed:Float) {
		if (updateTime > 1000){
			updateTime = 0;
			return;
		}
		var now = Timer.stamp();
		times.push(now);
	
		while (times[0] < now - 1)
			times.shift();
	
		curMemory = System.totalMemory;
		curFps = times.length > 120 ? 120 : times.length;
		
		updateText();

		updateTime += elapsed;
	}

	public dynamic function updateText():Void {
		var ramStr:String = convert_size(Std.int(curMemory));
		var lowFPS:Bool = (curFps < 120 / 2);
		if (visible)
		{
			var c = {
				fps: curFps + " FPS ("+ Std.int((1/curFps)*1000)+ "ms)" + (lowFPS?" [!]":""),
				mem: ramStr + " RAM"
			}
			var wholeText = '${c.fps}\n${c.mem}';

			text = wholeText + "\n\n > LineTapper v0.0.1 - (Proof of Concept)";
			applySizes();
		}
	
		textColor = lowFPS ? 0xFF0000 : 0xFFFFFF;
	}

	function applySizes(){
		this.setTextFormat(new TextFormat(curFont, 18, 0xFFFFFF),0,Std.string(times.length).length);
	}

    public function convert_size(bytes:Float):String
    {
        if (bytes == 0)
            return "0 B";

        var size_name:Array<String> = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
        var digit:Int = Std.int(Math.log(bytes) / Math.log(1024));
        return FlxMath.roundDecimal(bytes / Math.pow(1024, digit), 2) + " " + size_name[digit];
    }
}