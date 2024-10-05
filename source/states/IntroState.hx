package states;


import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * That one animation that starts when the game boots up.
 */
class IntroState extends FlxState {
    public static var _boxSize:Int = 72;
    public static var _scaleDec:Float = 0.3;

	var playerBox:FlxSprite;
	var tileBox:FlxSprite;
	var ltText:FlxText;
    
    var playing:Bool = false;
    var currentlyLoading:Bool = false;

	override function create():Void
	{
        Common.initialize();
        haxe.Timer.measure(()->{
            loadIntro();
            animateIntro();
        });

		super.create();
	}

    function loadIntro():Void {
        // Player Box sprite
        var _centerOffset:Float = 90;
 
        playerBox = new FlxSprite().makeGraphic(_boxSize, _boxSize);
        playerBox.x = ((FlxG.width - playerBox.width) * 0.5) - _centerOffset;
        playerBox.screenCenter(Y);
        add(playerBox);

        // Tile Box sprite
        tileBox = new FlxSprite().loadGraphic(Assets.image("arrow_tile"));
        tileBox.setGraphicSize(playerBox.frameWidth, playerBox.frameHeight);
        tileBox.updateHitbox();
        tileBox.x = ((FlxG.width - tileBox.width) * 0.5) + _centerOffset;
        tileBox.screenCenter(Y);
        add(tileBox);

        // Text underneath it
        ltText = new FlxText(0,0,-1,"LINETAPPER",20);
		ltText.setFormat(Assets.font("extenro-bold"), 18, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		ltText.screenCenter(X);
        ltText.y = playerBox.y + playerBox.height + 20;
        
        add(ltText);
    }

    var _textFlicker:Bool = false;
    function animateIntro() {
        var _tweenXOffset:Float = 30;

        playerBox.x -= _tweenXOffset;
        tileBox.x += _tweenXOffset;
        ltText.y += _tweenXOffset;

        ltText.alpha = playerBox.alpha = tileBox.alpha = 0;

        // Actually animating it (yeah this is horrible.)
        new FlxTimer().start(1,(_)->{ // Make a little wait here
            // LineTapper Sequence
            FlxTween.tween(playerBox, {x: playerBox.x+_tweenXOffset, alpha: 1}, 0.5, {ease:FlxEase.expoOut});
            FlxTween.tween(tileBox, {x: tileBox.x-_tweenXOffset, alpha: 1}, 0.5, {ease:FlxEase.expoOut, onComplete: (_)->{
                _textFlicker = true;
                FlxTween.tween(ltText, {y: ltText.y-_tweenXOffset}, 0.5, {ease:FlxEase.expoOut, onComplete:(_)->{
                    new FlxTimer().start(0.5,(_)->{
                        // Loading Sequence
                        var xTarget:Float = (FlxG.width - playerBox.width) * 0.5;
                        _textFlicker = true;
                        FlxTween.tween(ltText, {y: ltText.y+_tweenXOffset}, 0.5, {ease:FlxEase.expoOut, onComplete:(_)->{
                            ltText.text = "LOADING...";
                            ltText.screenCenter(X);
                            ltText.x += 10;
                            ltText.alpha = 0;
                            FlxTween.tween(ltText, {y: ltText.y-_tweenXOffset, alpha:1}, 0.5, {ease:FlxEase.expoOut});
                            FlxTween.tween(playerBox.scale, {x: playerBox.scale.x - _scaleDec, y: playerBox.scale.y - _scaleDec}, 0.5, {ease:FlxEase.expoOut});
                        }});

                        FlxTween.tween(playerBox, {x: xTarget}, 0.5, {ease:FlxEase.expoOut});
                        FlxTween.tween(tileBox, {x: xTarget}, 0.5, {ease:FlxEase.expoOut, onComplete:(_)->{
                            tileBox.kill();
                            tileBox.destroy();
                            remove(tileBox);
                            currentlyLoading = true;
                        }});
                    });
                }});
            }});
        });

    }

    override function update(elapsed:Float) {
        flickerEffectUpdate(elapsed);
        loadingSeqUpdate(elapsed);

        if (FlxG.keys.justPressed.SPACE) 
            FlxG.resetState();
        super.update(elapsed);
    }

    var _rotateTime:Float = 0;
    function loadingSeqUpdate(elapsed:Float) {
        if (!currentlyLoading) return;

        if (_rotateTime > 3) {
            playerBox.angle = 0;
            if (!playing){
                playing = true;
                FlxG.sound.playMusic(Assets.music('menu_music'));
                FlxTween.tween(ltText, {alpha:0}, 2, {ease:FlxEase.circIn, onComplete:(_)->{
                    ltText.destroy();
                    remove(ltText);
                }});
                new FlxTimer().start(5.5, function(_){
                    FlxG.switchState(new MenuState(true));
                });
            }
        } else {
            _rotateTime += elapsed;
            playerBox.angle = FlxEase.expoInOut(_rotateTime%1)*(-90);
        }
   
    }

    /**
     * Flicker effect thing
     */
     
    var _flickerDelay:Float = 0.03;
    var _curFlickTime:Float = 0;
    var _curFlickPos:Float = 0;
    var _flickerEndTime:Float = 0.3;
    function flickerEffectUpdate(elapsed:Float) {
        if (!_textFlicker) return;

        _curFlickTime += elapsed;
        _curFlickPos += elapsed;
        if (_curFlickTime > _flickerDelay){
            if (_rotateTime < 3)
                ltText.alpha = 1 - ltText.alpha;
            _curFlickTime = 0;
        }

        if (_curFlickPos > _flickerEndTime) {
            _textFlicker = false;
            _curFlickPos = 0;
        }

    }
}