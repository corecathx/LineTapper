package objects.menu;

import openfl.utils.ByteArray;
import openfl.events.ProgressEvent;
import openfl.display.BitmapData;
import openfl.events.Event;
import game.Utils;
import openfl.net.URLRequest;
import openfl.net.URLLoader;

@:structInit
class User {
    public var id:Int;
    public var username:String;
    public var display:String;
    public var profile_url:String;
}

class Profile extends FlxSprite {
    var _txt_displayName:FlxText;
    var _txt_indicator:FlxText;
    public function new(nX:Float = 0, nY:Float = 0) {
        super(nX,nY);

        // Loads the profile image
        trace("Preparing");
        var img:URLLoader = new URLLoader(new URLRequest(Utils.PLAYER.profile_url));
        img.dataFormat = BINARY;
        img.addEventListener(Event.COMPLETE, (e:Event) -> {
            loadGraphic(BitmapData.fromBytes(cast(img.data, ByteArray)));
            setGraphicSize(80,80);
            updateHitbox();

            _txt_displayName = new FlxText(0,0,-1,Utils.PLAYER.display,30);
            
        });
        img.load(new URLRequest(Utils.PLAYER.profile_url));
    }
}