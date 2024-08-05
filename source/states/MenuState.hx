package states;

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
class MenuState extends FlxState {
    var bg:FlxSprite;
    var boxBelow:FlxSprite;
    var logo:FlxSprite;

    var ind_top:FlxSprite;
    var ind_bot:FlxSprite;

    var particles:FlxSpriteGroup;
    var menuGroup:FlxTypedGroup<FlxText>;
    var tri_top:FlxSprite; // Triangle Top
    var tri_bot:FlxSprite; // Triangle Bottom

    var curSelected:Int = 0;
    var options:Map<String, Void->Void> = [
        "options" => ()->trace("wawer"),
        "play" => ()->FlxG.switchState(new MenuDebugState()),
        "edit" => ()->trace("no pls")
    ];

    var canInteract:Bool = false;
    override function create() {
        var _scaleDiff:Float = 1 - IntroState._scaleDec;

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
        
        logo = new FlxSprite().loadGraphic(Assets.image("menu/logo"));
        logo.screenCenter(X);
        logo.y = 30;
        logo.scale.set(0.6,0.6);
        logo.visible = false;
        add(logo);

        var scaleXTarget:Float = (FlxG.width * 0.75) / boxBelow.width;
        var scaleYTarget:Float = (boxBelow.height - 30) / boxBelow.height;

        trace("x: " + scaleXTarget + " // y: " + scaleYTarget);

        FlxTween.tween(boxBelow, {alpha: 0.3}, 1, {ease: FlxEase.expoInOut});
        FlxTween.tween(boxBelow.scale, {x: scaleXTarget, y: scaleYTarget}, 1, {ease: FlxEase.expoInOut, onComplete: (_)->{
            trace("everything should work by now");
            startMenu();
        }});
        
        super.create();
    }

    function generateOptions() {
        var n:Int = 0;
        for (name => _ in options) {
            var txt:FlxText = new FlxText(0,0,-1,name.toUpperCase(),8);
            txt.setFormat(Assets.font("extenro-bold"),18,FlxColor.WHITE,CENTER);
            txt.x = ((FlxG.width - txt.width) * 0.5) + ((130) * (curSelected-n));
            txt.alpha = 0;
            txt.active = false;
            txt.ID = n;
            menuGroup.add(txt);
            n++;
        }

        tri_top = new FlxSprite().loadGraphic(Assets.image("ui/triangle"));
        tri_top.screenCenter(X);
        tri_top.y = boxBelow.y - (tri_top.height+5);
        tri_top.flipY = true;
        add(tri_top);

        tri_bot = new FlxSprite().loadGraphic(Assets.image("ui/triangle"));
        tri_bot.screenCenter(X);
        tri_bot.y = boxBelow.y + boxBelow.height + 5;
        add(tri_bot);

        tri_bot.alpha = tri_top.alpha = 0;

        curSelected = 0;
    }

    function startMenu() {

        var logo_yDec:Float = 50;

        logo.y -= logo_yDec;
        FlxFlicker.flicker(logo, 1,0.02,true);
        FlxTween.tween(logo, {y:logo.y+logo_yDec}, 1, {ease:FlxEase.expoInOut, onComplete: (_)->{
            canInteract = true;
            for (obj in [tri_bot, tri_top]) {
                FlxTween.tween(obj, {alpha: 1}, 1, {ease: FlxEase.expoOut});
            }
        }});


    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (FlxG.keys.justPressed.SPACE) {
            FlxG.resetState();
        }

        if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT){
            tri_top.y -= 10; // stupid
            tri_bot.y += 10;
            curSelected = FlxMath.wrap(curSelected+(FlxG.keys.justPressed.LEFT ? 1 : -1), 0, Lambda.count(options)-1);
        } 
        menuUpdate(elapsed);
    }

    var _timePassed:Float = 0;
    var _timeTracked:Float = 0;
    function menuUpdate(elapsed:Float) {
        if (!canInteract) return;

        _timePassed += elapsed;
        bg.alpha = (Math.sin(_timePassed)*0.1);

        // Particle Generator (funny)
        if (_timePassed - _timeTracked > FlxG.random.float(0.4,1.3)) {
            _timeTracked = _timePassed;
            var s:FlxSprite = new FlxSprite(FlxG.random.float(0,FlxG.width),FlxG.height+FlxG.random.float(30,50)).makeGraphic(10,10);
            var scaling:Float = FlxG.random.float(0.1,1.2);
            s.active = false;
            s.scale.set(scaling,scaling);
            particles.add(s);
        }

        particles.forEachAlive((spr:FlxSprite) -> {
            spr.y -= (100*spr.scale.x)*elapsed;
            spr.angle += (150*spr.scale.x)*elapsed;
            if (spr.y < -20) {
                spr.destroy();
                remove(spr);
            }
        });

        // Menu Texts 
        var lerpFactor:Float = 1-(elapsed*12);
        for (obj in menuGroup.members) {
            var diff:Int = curSelected - obj.ID;
            obj.screenCenter(Y);

            obj.x = FlxMath.lerp(((FlxG.width - obj.width) * 0.5) + ((130) * diff),obj.x,lerpFactor);
            obj.alpha = FlxMath.lerp(curSelected == obj.ID ? 1 : 0.4, obj.alpha, lerpFactor);
            obj.scale.x = obj.scale.y = FlxMath.lerp(curSelected == obj.ID ? 1 : 0.7,obj.scale.x,lerpFactor);
        }

        // Menu Triangles
        tri_top.y = FlxMath.lerp(boxBelow.y - (tri_top.height + 5), tri_top.y, lerpFactor);
        tri_bot.y = FlxMath.lerp(boxBelow.y + boxBelow.height + 5, tri_bot.y, lerpFactor);
    }
}