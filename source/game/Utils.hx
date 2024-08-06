package game;

import sys.io.File;
import sys.FileSystem;
import objects.menu.Profile.User;

class Utils {
    public static var PLAYER:User = null;

    public static final TRANSITION_TIME:Float = 1;
    public static function switchState(state:FlxState, ?transIn){

    }

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
            profile_url: "https://avatars.githubusercontent.com/u/73734126?v=4"
        }
    }
}