package game.backend.script;

import states.PlayState;
import flixel.FlxBasic;
import hscript.Interp;

class ScriptUtil {
    public static function trace(interp:Interp, fileName:String, data:Dynamic) {
        var posInfo = interp.posInfos();
		posInfo.className = "HScript - "+fileName+".hx";

		var lineNumber = Std.string(posInfo.lineNumber);
		var methodName = posInfo.methodName;
		var className = posInfo.className;
		trace('$fileName:$lineNumber: $data');
    }

    public static function add(obj:FlxBasic)
    {
        PlayState.instance.add(obj);
    }
}