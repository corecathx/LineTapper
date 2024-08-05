package states;

import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;

using StringTools;
class MenuDebugState extends FlxState {
    var topText:FlxText;
    var inputText:FlxText;
    var inputCaret:FlxSprite;
    var song(default,set):String = "Tutorial";
    function set_song(val:String):String {
        if (inputText != null)
            inputText.text = val;

        return song = val;
    }
    override function create() {
        topText = new FlxText(20, 180, -1, "START TYPING YOUR SONG'S NAME", 20);
		topText.setFormat(Assets.font("extenro-extrabold"), 22, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		topText.screenCenter(X);
        add(topText);

        inputText = new FlxText(20, 20, -1, song, 20);
		inputText.setFormat(Assets.font("extenro-bold"), 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(inputText);

        inputCaret = new FlxSprite().makeGraphic(4,Std.int(inputText.height));
        add(inputCaret);
        super.create();
    }

    var hitBottom:Bool = false;
    var caretTime:Float = 0;
    override function update(elapsed:Float) {
        inputText.x = FlxMath.lerp((FlxG.width-inputText.width)*0.5, inputText.x, 1-(elapsed*12));
        inputText.y = (FlxG.height-inputText.height)*0.5;
        inputCaret.x = inputText.x + (song.length == 0 ? 0 : inputText.width + 5);
        inputCaret.y = inputText.y;

        caretTime += elapsed*2;

        inputCaret.alpha = 0.5 + (Math.sin(caretTime)*0.5);

        handleKeyInput(elapsed);
        super.update(elapsed);
    }
    var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    var keyTime:Float = 0;
    function handleKeyInput(elapsed:Float) {
        if (FlxG.keys.justPressed.ENTER) {
            FlxG.switchState(new PlayState(song));
            FlxG.sound.play(Assets.sound("menu/key_press"));
        } else if (FlxG.keys.firstPressed() != FlxKey.NONE && FlxG.keys.firstPressed() != FlxKey.SHIFT) {
            if (keyTime == 0 || keyTime > 0.3) {
                if (keyTime > 0.3) keyTime = 0.2;
                var keyPressed:FlxKey = FlxG.keys.firstPressed();
                switch (keyPressed) {
                    case FlxKey.BACKSPACE:
                        FlxG.sound.play(Assets.sound("menu/key_cancel"));
                        song = song.substring(0,song.length-1);
                    case FlxKey.SPACE:
                        FlxG.sound.play(Assets.sound("menu/key_press"));
                        song += " ";
                    default:
                        var keyName:String = Std.string(keyPressed);
                        if (allowedKeys.contains(keyName)) {
                            FlxG.sound.play(Assets.sound("menu/key_press"));
                            if (!FlxG.keys.pressed.SHIFT) 
                                keyName = keyName.toLowerCase();
                            song += keyName;
                            if(song.length >= 25) song = song.substring(1);
                        }
                }
            }
            keyTime+=elapsed;
        } else {
            keyTime = 0;
        }
    }
}