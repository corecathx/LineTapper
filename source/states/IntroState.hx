package states;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class IntroState extends FlxState {
	var playerBox:FlxSprite;
	var tileBox:FlxSprite;
	var ltText:FlxText;

    var currentlyLoading:Bool = false;

	override function create():Void
	{
        haxe.Timer.measure(()->{
            loadIntro();
            animateIntro();
        });

		super.create();
	}

    function loadIntro():Void {
        // Player Box sprite
        var _centerOffset:Float = 90;
        var _boxSize:Int = 100;
        playerBox = new FlxSprite().makeGraphic(_boxSize, _boxSize);
        playerBox.x = ((FlxG.width - playerBox.width) * 0.5) - _centerOffset;
        playerBox.screenCenter(Y);
        add(playerBox);

        // Tile Box sprite
        tileBox = new FlxSprite().loadGraphic(Assets.image("ArrowTile"));
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
        var _scaleDec:Float = 0.3;

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
        _rotateTime += elapsed;
        playerBox.angle = FlxEase.expoInOut(_rotateTime%1)*(-90);

        if (_rotateTime > 3) FlxG.switchState(new PlayState("Tutorial"));
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
            ltText.alpha = 1 - ltText.alpha;
            _curFlickTime = 0;
        }

        if (_curFlickPos > _flickerEndTime) {
            _textFlicker = false;
            _curFlickPos = 0;
        }

    }
}