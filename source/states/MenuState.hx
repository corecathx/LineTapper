package states;

import flixel.util.FlxTimer;
import lime.app.Application;
import game.native.Windows;
import objects.menu.Profile;
import objects.Player;
import flixel.math.FlxMath;
import haxe.Constraints.Function;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.effects.FlxFlicker;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxGradient;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * Main Menu of LineTapper.
 */
class MenuState extends StateBase {
	var bg:FlxSprite;
	var boxBelow:FlxSprite;
	var logo:FlxSprite;

	var ind_top:FlxSprite;
	var ind_bot:FlxSprite;

	var user_profile:Profile;

	var particles:FlxSpriteGroup;
	var menuGroup:FlxTypedGroup<FlxText>;
	var tri_top:FlxSprite; // Triangle Top
	var tri_bot:FlxSprite; // Triangle Bottom
    var fromIntro:Bool = false;

	var curSelected:Int = 0;
	var options:Array<Dynamic> = [
		["options", () -> trace("wawer")],
		["play", () -> FlxG.switchState(new MenuDebugState())],
		["edit", () -> trace("wawer")]
	];

    override public function new(?fromIntro:Bool = false){
        trace('menu!');
        super();
        this.fromIntro = fromIntro;
    }

	var canInteract:Bool = false;
	var _scaleDiff:Float = 0;
	override function create() {
		_scaleDiff = 1 - IntroState._scaleDec;
        
		// Objects
		bg = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.BLACK, FlxColor.WHITE], 1, 90, true);
		bg.alpha = 0;
		add(bg);

		particles = new FlxSpriteGroup();
		add(particles);

		boxBelow = new FlxSprite().makeGraphic(Std.int(IntroState._boxSize * _scaleDiff), Std.int(IntroState._boxSize * _scaleDiff));
		boxBelow.screenCenter();
		add(boxBelow);

		menuGroup = new FlxTypedGroup<FlxText>();
		add(menuGroup);

		generateOptions();

		logo = new FlxSprite().loadGraphic(Assets.image("menu/logo-pl"));
		logo.screenCenter(X);
		logo.y = 30;
		logo.scale.set(0.6, 0.6);
		logo.visible = false;
		add(logo);
		
		user_profile = new Profile(0,FlxG.height-(Profile.size.height+20));
		user_profile.x -= user_profile.nWidth + 10;
		add(user_profile);

		var scaleXTarget:Float = (FlxG.width * 0.75) / boxBelow.width;
		var scaleYTarget:Float = (boxBelow.height - 30) / boxBelow.height;

        if(fromIntro){
        new FlxTimer().start(1.5, function(t){
            FlxG.camera.flash(0x42FFFFFF, 1);
            FlxG.camera.angle = 15;
            FlxG.camera.zoom += 0.05;
            FlxTween.tween(FlxG.camera, {angle: 0, zoom: 1}, 1, {ease: FlxEase.quadOut});
            FlxFlicker.flicker(logo, 0.5, 0.02, true);
        });
        }else{
            FlxG.sound.playMusic(Assets.music('menu_music'), 1, false);
            FlxG.sound.pause();
            FlxG.sound.music.time = 6850;
            FlxG.sound.resume();
        }
		FlxTween.tween(boxBelow, {alpha: 0.3}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(boxBelow.scale, {x: scaleXTarget, y: scaleYTarget}, 1, {
			ease: FlxEase.expoInOut,
			onComplete: (_) -> {
				trace("everything should work by now");
				startMenu();
			}
		});
		super.create();
	}

	function generateOptions() {
		curSelected = 1;
		for (index => data in options) {
			var txt:FlxText = new FlxText(0, 0, -1, data[0].toUpperCase(), 8);
			txt.setFormat(Assets.font("extenro-bold"), 18, FlxColor.WHITE, CENTER);
			txt.x = ((FlxG.width - txt.width) * 0.5) + ((130) * (curSelected - index));
			txt.alpha = 0;
			txt.active = false;
			txt.ID = index;
			menuGroup.add(txt);
		}

		tri_top = new FlxSprite().loadGraphic(Assets.image("ui/triangle"));
		tri_top.screenCenter(X);
		tri_top.y = boxBelow.y - (tri_top.height + 5);
		tri_top.flipY = true;
		add(tri_top);

		tri_bot = new FlxSprite().loadGraphic(Assets.image("ui/triangle"));
		tri_bot.screenCenter(X);
		tri_bot.y = boxBelow.y + boxBelow.height + 5;
		add(tri_bot);

		tri_bot.alpha = tri_top.alpha = 0;
	}

	function startMenu() {
		var logo_yDec:Float = 50;

		logo.y -= logo_yDec;
        if (!fromIntro)
            FlxFlicker.flicker(logo, 0.5, 0.02, true);
		FlxTween.tween(logo, {y: logo.y + logo_yDec}, 0.5, {
			ease: FlxEase.expoInOut,
			onComplete: (_) -> {
				canInteract = true;
				for (obj in [tri_bot, tri_top]) {
					FlxTween.tween(obj, {alpha: 1}, 1, {ease: FlxEase.expoOut});
				}
				FlxTween.tween(user_profile,{x: 20},1, {ease: FlxEase.expoOut});
			}
		});
	}

	var confirmed:Bool = false;

	override function update(elapsed:Float) {
        if (!FlxG.sound.music.playing) {
            FlxG.sound.playMusic(Assets.music('menu_music'), 1, false);
            FlxG.sound.pause();
            FlxG.sound.music.time = 6850;
            FlxG.sound.resume();
        }
		if (FlxG.keys.justPressed.SPACE) {
			FlxG.resetState();
		}

		if (!confirmed) {
			if (FlxG.keys.justPressed.ENTER) {
				confirmed = true;
                for (obj in menuGroup.members) {
                    if (curSelected == obj.ID) {
						FlxTween.tween(boxBelow.scale,{x: (obj.width+20*2) / (Std.int(IntroState._boxSize * _scaleDiff))},1,{ease:FlxEase.expoOut});
                        FlxFlicker.flicker(obj,1, 0.04,false,true,(_)->{
                            options[curSelected][1]();   
                        });
                    } else {
                        FlxTween.tween(obj, {alpha:0}, 1);
                    }
                }
			}

			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT) {
				FlxG.sound.play(Assets.sound("menu/key_press"));
				tri_top.y -= 10; // stupid
				tri_bot.y += 10;
				curSelected = FlxMath.wrap(curSelected + (FlxG.keys.justPressed.LEFT ? 1 : -1), 0, options.length - 1);
			}
		}

		menuUpdate(elapsed);
		super.update(elapsed);
	}

	var _timePassed:Float = 0;
	var _timeTracked:Float = 0;

	function menuUpdate(elapsed:Float) {
		if (!canInteract)
			return;

		_timePassed += elapsed;
		bg.alpha = (Math.sin(_timePassed) * 0.1);

        // There is FlxEmitter for a reason, Core. I'm remaking this the intended way later.
		// Particle Generator (funny)
		if (_timePassed - _timeTracked > FlxG.random.float(0.4, 1.3)) {
			_timeTracked = _timePassed;
			var s:FlxSprite = new FlxSprite(FlxG.random.float(0, FlxG.width), FlxG.height + FlxG.random.float(30, 50)).makeGraphic(10, 10);
			var scaling:Float = FlxG.random.float(0.1, 1.2);
			s.active = false;
			s.scale.set(scaling, scaling);
			particles.add(s);
		}

		particles.forEachAlive((spr:FlxSprite) -> {
			spr.y -= (100 * spr.scale.x) * elapsed;
			spr.angle += (150 * spr.scale.x) * elapsed;
			if (spr.y < -20) {
				spr.destroy();
				remove(spr);
			}
		});

		// Menu Texts
		var lerpFactor:Float = 1 - (elapsed * 12);
		for (obj in menuGroup.members) {
			var diff:Int = curSelected - obj.ID;
			obj.screenCenter(Y);

			obj.x = FlxMath.lerp(((FlxG.width - obj.width) * 0.5) + ((130) * diff), obj.x, lerpFactor);
			if (!confirmed) obj.alpha = FlxMath.lerp(curSelected == obj.ID ? 1 : 0.4, obj.alpha, lerpFactor);
			obj.scale.x = obj.scale.y = FlxMath.lerp(curSelected == obj.ID ? 1 : 0.7, obj.scale.x, lerpFactor);
		}

		// Menu Triangles
		tri_top.y = FlxMath.lerp(boxBelow.y - (tri_top.height + 5), tri_top.y, lerpFactor);
		tri_bot.y = FlxMath.lerp(boxBelow.y + boxBelow.height + 5, tri_bot.y, lerpFactor);
	}
}
