package game.backend.script;

import haxe.io.Path;
import sys.FileSystem;

/**
 * A way to handle multiple scripts at once.
 * This class will run every script on the provided path.
 */
class ScriptGroup {
    /**
     * Every script instances.
     */
    public var instances:Array<Script> = [];

    /**
     * Checking `path` for HScript file then loads all of them.
     * @param path Folder path that you wanted the scripts to be executed.
     */
    public function new(path:String) {
        if (!FileSystem.exists(path)) {
            trace("This folder is non-existent: " + path);
            return;
        }

        for (file in FileSystem.readDirectory(path)) {
            var current_path:String = path + "/" + file;
            if (FileSystem.isDirectory(current_path)) 
                continue;
            if (Utils.checkHXS(current_path)) {
                var script:Script = new Script(current_path);
                instances.push(script);
            }
        }
    }

    public function executeFunc(name:String, ?args:Array<Any>) {
        for (script in instances) {
            if (script == null) continue;
            script.executeFunc(name,args);
        }
    }
}