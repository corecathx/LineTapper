package objects.menu;

import flixel.util.FlxSpriteUtil;
import haxe.Timer;
import flixel.math.FlxMath;
import flixel.addons.effects.FlxSkewedSprite;
import openfl.utils.ByteArray;
import openfl.events.ProgressEvent;
import openfl.display.BitmapData;
import openfl.events.Event;

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
    public static var size = {
        width: 50,
        height: 50
    }
    public var nWidth(get,default):Float = 0;
    function get_nWidth():Float {
        var w:Float = width + 10 + 80;
        if (_txt_displayName == null || _txt_indicator == null)
            return w;

        w += Math.max(_txt_displayName.width,_txt_indicator.width);
        return w;
    }
    var _txt_displayName:FlxText;
    var _txt_indicator:FlxText;
    var _parent_effect:FlxSkewedSprite;
    var _effect_grp:Array<Dynamic> = [];

    var ready:Bool = false;

    public function new(nX:Float = 0, nY:Float = 0) {
        super(nX,nY);
        return; // Will be removed later.
        // Loads the profile image
        trace("Preparing");
        var img:URLLoader = new URLLoader(new URLRequest(Common.PLAYER.profile_url));
        img.dataFormat = BINARY;
        img.addEventListener(Event.COMPLETE, (e:Event) -> {
            var temp:FlxSprite = new FlxSprite().loadGraphic(BitmapData.fromBytes(cast(img.data, ByteArray)));
            var circ:FlxSprite = new FlxSprite().makeGraphic(Std.int(temp.width),Std.int(temp.height),FlxColor.TRANSPARENT);
            FlxSpriteUtil.drawCircle(circ,-1,-1,-1,FlxColor.BLACK);
            FlxSpriteUtil.alphaMask(this,temp.pixels,circ.pixels);
            setGraphicSize(size.width,size.height);
            updateHitbox();

            _txt_displayName = new FlxText(0,0,-1,Common.PLAYER.display,30);
            _txt_displayName.setFormat(Assets.font("extenro-bold"), 14, FlxColor.WHITE);
            _txt_indicator = new FlxText(0,0,-1,"OFFLINE",30);
            _txt_indicator.setFormat(Assets.font("extenro-bold"), 8, FlxColor.GRAY);
            ready = true;
        });
        img.load(new URLRequest(Common.PLAYER.profile_url));

        _parent_effect = new FlxSkewedSprite();
        _parent_effect = cast _parent_effect.makeGraphic(15,size.height);
        _parent_effect.antialiasing = true;
        _parent_effect.skew.x = -30;
    }

    var drawWait:Float = 0;

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (!ready) return;
        drawWait += elapsed;
        if (drawWait < 0.3) return;
        drawWait = 0;

        var _slash:FlxSkewedSprite = new FlxSkewedSprite();
        _slash = cast _slash.loadGraphic(_parent_effect.graphic);
        _slash.antialiasing = true;
        _slash.skew.x = _parent_effect.skew.x;
        _effect_grp.push([Timer.stamp(), _slash]);
    }

    override function draw() {
        super.draw();
        if (!ready) return;
        _txt_displayName.setPosition(x+width+10,y+5);
        _txt_displayName.draw();

        _txt_indicator.setPosition(x+width+10,_txt_displayName.y+_txt_displayName.height+5);
        _txt_indicator.draw();

        _parent_effect.x = (x + (nWidth-50) + 10);
        _parent_effect.y = y;
        _parent_effect.draw();

        for (i in _effect_grp) {
            if (i[1] == null) continue;
            var cur:Float = Timer.stamp();
            i[1].x = _parent_effect.x + (30*(cur-i[0])*3);
            i[1].y = _parent_effect.y;
            i[1].scale.x = 1 - (cur-i[0]);
            i[1].alpha = (1 - (cur-i[0]))*0.4;
            if (cur - i[0] > 1) {
                _effect_grp.remove(i);
                i[1].destroy();
            } else {
                i[1].draw();
            }
        }
    }
}