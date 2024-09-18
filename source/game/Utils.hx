package game;

import sys.io.File;
import sys.FileSystem;
import objects.menu.Profile.User;

using StringTools;

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
    public static function switchState(state:FlxState, ?transIn){} // Tf is this for???

    public static function initialize():Void {
        loadUser();
    }

    public static function tempAdd(file:String, content:String) {
        if (!FileSystem.exists("./temp/")){
            FileSystem.createDirectory("./temp/");
        }
        
        File.saveContent(file,content);
        trace("Saved sucessfully.");
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
            profile_url: "https://cdn.discordapp.com/avatars/694791036094119996/08795150028fbab041c2cc9359bc5e43.png?size=1024"
        }
    }
}