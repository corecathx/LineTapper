package objects;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.utils.ByteArray;
import flixel.FlxSprite;
import flixel.math.FlxRect;

class BoxOutline extends FlxSprite {
    public var outline(default, set):Float = 0;
    var _ogPixels:BitmapData;

    override public function loadGraphic(Graphic:Dynamic, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, Key:String = ""):FlxSprite {
        super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
        _ogPixels = this.pixels.clone();
        return this;
    }
    override public function makeGraphic(Width:Int, Height:Int, Color:FlxColor = 0xFFFFFFFF, Unique:Bool = false, Key:String = ""):FlxSprite {
        super.makeGraphic(Width, Height, Color, Unique, Key);
        _ogPixels = this.pixels.clone();
        return this;
    }
    

    function set_outline(val:Float):Float {
        if (val < 0) val = 0;
        if (val > 1) val = 1;

        if (clipRect == null)
            clipRect = new FlxRect(0, 0, frameWidth, frameHeight);
    
        var actualVal:Float = 1-val;
        var _progress = {
            width: frameWidth * actualVal,
            height: frameHeight * actualVal,
        };
    
        clipRect.width = frameWidth - _progress.width;
        clipRect.height = frameHeight - _progress.height;
        clipRect.x = _progress.width * 0.5;
        clipRect.y = _progress.height * 0.5;
    
        this.pixels.copyPixels(_ogPixels, new Rectangle(0, 0, _ogPixels.width, _ogPixels.height), new openfl.geom.Point());

        var bitmapData:BitmapData = this.pixels;
        bitmapData.fillRect(new Rectangle(clipRect.x, clipRect.y, clipRect.width, clipRect.height), 0x00000000);
        
        var byteArray:ByteArray = bitmapData.getPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height));
        pixels.setPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height), byteArray);
    
        return outline = val;
    }
}
