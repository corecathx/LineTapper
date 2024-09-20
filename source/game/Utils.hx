package game;

import sys.thread.Thread;
import sys.io.File;
import sys.FileSystem;
import objects.menu.Profile.User;

using StringTools;

typedef RBG = {
	var red:Int;
	var green:Int;
	var blue:Int;
}

class Utils {
    /**
     * Every supported Haxe file extensions (Used for Scripting).
     */
    public static var HAXE_EXT:Array<String> = ["hx","hxs","hscript"];
    public static function checkHXS(filename:String) {
        for (i in HAXE_EXT)
            if (filename.endsWith(i)) return true;
        return false;
    }

    /**
     * Player's data.
     */
    public static var PLAYER:User = null;

    public static final TRANSITION_TIME:Float = 1;
    public static function switchState(state:FlxState, ?transIn){}

    public static function initialize():Void {
        loadUser();
    }

    public static function loadUser():Void {
        if (PLAYER != null) {
            trace("User are already logged in!");
            return;
        }

        // For testing purposes
        PLAYER = {
            id: 1,
            username: "corecathx",
            display: "CoreCat",
            profile_url: null
        }
    }
}