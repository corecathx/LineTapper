package objects;

import cpp.Int64;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import flixel.group.FlxGroup;
import hxvlc.flixel.FlxVideoSprite as Video;

enum BackgroundType {
    VIDEO;
    IMAGE;
    NONE;
}

class Background extends FlxGroup
{
    public var type:BackgroundType;
    public var asset:String;
    public var scaleX:Float;
    public var scaleY:Float;
    public var image:FlxSprite;
    public var overlay:FlxSprite;
    public var video:Video;
    public var alpha:Float = 0.45;
    public var setVideoTime:Bool = false;
    public var time:Float = 0;

    override public function new(type:BackgroundType, asset:String, ?scaleX:Float = 1, ?scaleY:Float = 1, ?alpha:Float = 0.45)
    {
        super();
        this.type = type;
        this.asset = asset;
        this.alpha = alpha;
        this.scaleX = scaleX;
        this.scaleY = scaleY;

        loadAssets();
    }

    public static function typeFromString(v:String):BackgroundType
    {
        return v == 'VIDEO' ? VIDEO : v == 'IMAGE' ? IMAGE : v == 'NONE' ? NONE : NONE;
    }

    public static function typeToString(v:BackgroundType):String
    {
        return v == VIDEO ? 'VIDEO' : v == IMAGE ? 'IMAGE' : v == NONE ? 'NONE' : 'NONE';
    }

    public function updateVideo()
    {
        if (type == VIDEO && setVideoTime && video.bitmap.isPlaying){
            video.bitmap.time = Std.int(time);
        }
    }

    public function stopVideo()
    {
        remove(video);
        video.stop();
        video.visible = false;
    }
    
    public function playVideo()
    {
        video.play();
    }

    public function loadAssets()
    {
        if (type == VIDEO)
        {
            video = new Video();
            video.alpha = alpha;
            video.antialiasing = true;
            video.scrollFactor.set();
            video.bitmap.onPlaying.add(function():Void
            {
                updateVideo();
            });
            video.bitmap.onFormatSetup.add(function():Void
            {
                if (video.bitmap != null && video.bitmap.bitmapData != null)
                {
                    video.setGraphicSize(1280, 720);
                    video.updateHitbox();
                    video.screenCenter();
                }
            });
            video.load(asset, [':no-audio']);
            add(video);
        }
        if (type == IMAGE)
        {
            image = new FlxSprite(0, 0, asset);
            image.alpha = alpha;
            image.scrollFactor.set();
            image.scale.set(scaleX, scaleY);
            image.screenCenter();
            add(image);
        }
    }
}