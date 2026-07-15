package;

import sys.FileSystem;
import sys.io.File;
import haxe.Json;

class Lib {
    static final RESET:String = "\x1b[0m";
    static final GREEN:String = "\x1b[32m";
    static final RED:String = "\x1b[31m";
    static final YELLOW:String = "\x1b[33m";
    static final CYAN:String = "\x1b[36m";
    static final BOLD:String = "\x1b[1m";

    public static function main():Void {
        Sys.println('${BOLD}${CYAN}==== LineTapper Setup ====${RESET}');

        if (!FileSystem.exists("./lib.json")) {
            Sys.println('${BOLD}${RED}Error: lib.json not found.${RESET}');
            return;
        }

        run("haxelib", ['update'], function() {
            var list:Array<LTLib> = Json.parse(File.getContent("./lib.json"));
            for (lib in list) {
                var args:Array<String> = ["install", lib.name];
                if (Reflect.hasField(lib, "version")) args.push(lib.version);
                //if (Reflect.hasField(lib, "quiet") && lib.quiet) 
                args.push("--quiet");
                args.push("--always");

                Sys.println('${BOLD}${YELLOW}Installing: ${lib.name} ${lib?.version ?? ""}${RESET}');
                run("haxelib", args, ()->{
                    Sys.println('${GREEN}[✓] Installed: ${lib.name}${RESET}');
                }, onFailed);
            }
            Sys.println('${BOLD}${CYAN}Haxelib List Final${RESET}');
            run("haxelib", ["list"],()->{}, onFailed);
        }, onFailed);
    }

    static function run(cmd:String, args:Array<String>, onSuccess:Void->Void, onFail:String->Void):Void {
        Sys.println('${CYAN}> ${cmd} ${args.join(" ")}${RESET}');
        
        var result = Sys.command(cmd,args);
        
        if (result == 0) 
            onSuccess();
        else
            onFail(cmd);
    }

    static function onFailed(cmd:String):Void {
        Sys.println('${RED}[✗] Error occurred while running: ${cmd}${RESET}');
    }
}

typedef LTLib = {
    name:String,
    ?version:String,
    ?quiet:Bool
}