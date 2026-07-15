package lt.backend;

import haxe.Timer;
import sys.io.File;
import sys.FileSystem;
import haxe.Constraints.Function;
import haxe.PosInfos;
import lime.app.Application;
using StringTools;

class Log {
	private static var hxTrace:Function;
	private static var log:Array<String> = [];
	private static var startTime:Float;

	public static function init():Void {
		hxTrace = haxe.Log.trace;
		haxe.Log.trace = haxeTrace;

		startTime = Timer.stamp(); // start timestamp (ms)
		prettyPrint(Game.VERSION_LABEL);

		Application.current.onExit.add((_) -> {
			if (!FileSystem.exists('log'))
				FileSystem.createDirectory('log');
			File.saveContent('log/log.txt', @:privateAccess log.join('\n'));
			Log.info('Log saved to log/log.txt');
		});
	}

	// ANSI Styling
	private static inline function ansi(code:String):String return '\033[${code}m';
	private static inline function fg256(color:Int):String return '\033[38;5;${color}m';
	private static inline function reset():String return '\033[0m';

	// Log levels
	@:keep public static inline function error(value:Dynamic, ?pos:PosInfos):Void print(value, "✖", "ERR", 196, pos);
	@:keep public static inline function warn(value:Dynamic, ?pos:PosInfos):Void print(value, "⚠", "WRN", 214, pos);
	@:keep public static inline function info(value:Dynamic, ?pos:PosInfos):Void print(value, "✔", "INF", 40, pos);
	@:keep public static inline function script(value:Dynamic, ?pos:PosInfos):Void print(value, "➤", "SCR", 141, pos);
	private static inline function haxeTrace(value:Dynamic, ?pos:PosInfos):Void print(value, "•", "TRC", 250, pos);

	private static inline function print(value:Dynamic, icon:String, label:String, color:Int, ?pos:PosInfos):Void {
		var runtime = formatDuration((Timer.stamp() - startTime)*1000);
		var posStr = pos.fileName.replace("src/", "") + ":" + pos.lineNumber;
		var timestamp = ansi("2") + "[" + runtime + " - " + posStr + "]" + reset();
		var padded = rpad(timestamp, " ", 60);
		var line = padded + fg256(color) + ansi("1") + icon + " " + label + reset() + ": " + value;
		Sys.println(line);
		log.push('[' + runtime + " " + posStr + "] " + label + ": " + value);
	}

	public static function prettyPrint(text:String):Void {
		var lines = text.trim().split("\n");
		var width = 0;
		for (line in lines)
			if (line.length > width)
				width = line.length;

		var edge = repeat("═", width + 8);
		var top = "╔" + edge + "╗";
		var bottom = "╚" + edge + "╝";

		Sys.println("");
		Sys.println(top);
		for (line in lines) {
			var padded = centerText(line, width);
			Sys.println("║  " + fg256(45) + ansi("1") + padded + reset() + "  ║");
		}
		Sys.println(bottom);
	}

	// Format runtime since start
	private static function formatDuration(ms:Float):String {
		var totalSec = Std.int(ms / 1000);
		var h = Std.int(totalSec / 3600);
		var m = Std.int((totalSec % 3600) / 60);
		var s = totalSec % 60;

		var result = "";
		if (h > 0) result += '${h}h ';
		if (m > 0 || h > 0) result += '${m}m ';
		result += '${s}s';
		return result.trim();
	}

	// Utilities
	private static inline function rpad(text:String, ch:String, len:Int):String {
		while (text.length < len)
			text += ch;
		return text;
	}

	private static inline function repeat(ch:String, count:Int):String {
		var out = "";
		for (i in 0...count)
			out += ch;
		return out;
	}

	private static inline function centerText(text:String, width:Int):String {
		var space = width - text.length;
		var left = Std.int(space / 2);
		var right = space - left;
		return repeat(" ", left) + text + repeat(" ", right);
	}
}
