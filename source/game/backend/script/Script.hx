package game.backend.script;

import haxe.io.Path;
import hscript.Expr;
import hscript.Parser;
import sys.FileSystem;
import hscript.Interp;

/**
 * HScript Handler for LineTapper.
 */
class Script {
    public var filename:String = "";
    public var interp:Interp;
    public var error:Bool = false;

    /**
     * Loads a new script.
     * @param path Script's path.
     */
    public function new(path:String) {
        if (!FileSystem.exists(path)) {
            trace("Failed loading song scripts, path: " + path);
            return;
        }
        
        // Actually init the interp.
        interp = new Interp();
        initialize();
        loadFile(path);
    }

    /**
     * Executes a function from the Script.
     * @param name Function Name
     * @param args Arguments (optional)
     */
    public function executeFunc(funcName:String, ?args:Array<Any>):Dynamic
    {
        if (interp == null)
            return null;

        if (interp.variables.exists(funcName)) {
            var f = interp.variables.get(funcName);
            if (args == null) {
                var result = null;
                try {
                    result = f();
                } catch (e) {
                    Sys.println("[ERROR] " + filename + " : " + e.toString());
                    error = true;
                }
                return result;
            } else {
                var result = null;
                try {
                    result = Reflect.callMethod(null, f, args);
                } catch (e) {
                    Sys.println("[ERROR] " + filename + " : " + e.toString());
                    error = true;
                }
                return result;
            }
        }
        return null;
    }

    public function loadFile(path:String) {
        if (path.trim() == "")
			return;

        filename = Path.withoutExtension(Path.withoutDirectory(path));
        trace(filename);
		try
		{
			interp.execute(parse(path));
		}
		catch (e) {}
    }

    public function parse(path:String) {
        var parser:Parser = new Parser();
        parser.allowTypes = parser.allowMetadata = parser.allowJSON = true;
        var ast:Expr = null;
        try {
            ast = parser.parseString(sys.io.File.getContent(path));
        } catch (ex) {
            var ext = Std.string(ex);
            var line = parser.line;
            var message:String = 'An error occured while parsing the file located at "$path".\r\n$ext at $line';
            if (!openfl.Lib.application.window.fullscreen)
                openfl.Lib.application.window.alert(message);
            error = true;
        }
        return ast;
    }

	public function setVariable(name:String, val:Dynamic)
    {
        interp.variables.set(name, val);
    }

    /**
     * Initializes the script with bunch of variables.
     */
    public function initialize() {
        setVariable("game", FlxG.state);
        setVariable("trace", this.trace);
        setVariable("addLib", function(className:String) // Similar to haxe's "import"
        {
            var splitClassName = [for (e in className.split(".")) e.trim()];
            var realClassName = splitClassName.join(".");
            var cl = Type.resolveClass(realClassName);
            var en = Type.resolveEnum(realClassName);
            if (cl == null && en == null) {
                var msg = 'Class / Enum at $realClassName does not exist.';
                this.trace(msg);
            } else {
                var classname:String = splitClassName[splitClassName.length - 1];

                if (en != null) {
                    var enumThingy = {};
                    for (c in en.getConstructors())
                        Reflect.setField(enumThingy, c, en.createByName(c));
                    setVariable(classname, enumThingy);
                } else {
                    setVariable(classname, cl);
                }
                this.trace("Imported " + splitClassName[splitClassName.length - 1]);
            }
        });

        // Stuffs //
        setVariable("FlxSprite", FlxSprite);
    }

    /** Some stuff that might be useful for scripting. **/
    public function trace(data:Dynamic) {
        var posInfo = interp.posInfos();
		posInfo.className = "HScript - "+filename+".hx";

		var lineNumber = Std.string(posInfo.lineNumber);
		var methodName = posInfo.methodName;
		var className = posInfo.className;
		trace('$filename:$lineNumber: $data', posInfo);
    } 
}