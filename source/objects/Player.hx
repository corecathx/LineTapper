package objects;

import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import game.Conductor;

enum abstract PlayerDirection(Int) {
    var LEFT = 0;
    var DOWN = 1;
    var UP = 2;
    var RIGHT = 3;
}

typedef PlayerControls = {
    var keys:Array<FlxKey>;
    var dir:PlayerDirection;
}

class Player extends FlxSprite {
    public var direction:PlayerDirection = PlayerDirection.DOWN;
    public var speed:Float = 1;
    public var pixelMovement:Float = 5;

    public var trails:Array<FlxSprite> = [];
    public var trail_length:Int = 5;
    public var trail_time:Float = 0;
    public var trail_delay:Float = 0.05;
    public var started:Bool = false;

    public function new(nX:Float, nY:Float) {
        super(nX, nY);
        makeGraphic(50, 50, 0xFFFFFFFF);
    }

    override function update(elapsed:Float) {
        updateControls();
        updateMovement(elapsed);
        handleTrails(elapsed);
        updateScale(elapsed);
        super.update(elapsed);
    }

    public function updateScale(e:Float) {
        var _scale:Float = FlxMath.lerp(1, scale.x, 1 - (e * 12));
        scale.set(_scale, _scale);
    }

    override function draw() {
        for (i in trails) {
            if (i.visible && i.alpha > 0) i.draw();
        }
        super.draw();
    }

    private var _curTime:Float = 0;
    public function handleTrails(elapsed:Float) {
        if (!started) return;
        _curTime += elapsed;

        if (_curTime > trail_delay) {
            var n:FlxSprite = new FlxSprite(x, y).makeGraphic(50, 50, 0xFFFFFFFF);
            n.alpha = 0.8;
            trails.push(n);
            _curTime = 0;
        }

        for (i in trails) {
            if (i.alpha > 0) {
                i.alpha -= 0.8 * elapsed;
                i.color = FlxColor.interpolate(FlxColor.BLUE, FlxColor.CYAN, i.alpha - 0.2);
                i.scale.set(i.alpha, i.alpha);
            } else {
                i.kill();
                i.destroy();
                trails.remove(i);
            }
        }
    }

    private function updateControls() {
        if (!started) return;
        var keys:Array<PlayerControls> = [
            {keys: [FlxKey.A, FlxKey.LEFT], dir: PlayerDirection.LEFT},
            {keys: [FlxKey.S, FlxKey.DOWN], dir: PlayerDirection.DOWN},
            {keys: [FlxKey.W, FlxKey.UP], dir: PlayerDirection.UP},
            {keys: [FlxKey.D, FlxKey.RIGHT], dir: PlayerDirection.RIGHT}
        ];

        for (c in keys) {
            var pressed:Bool = false;
            for (i in c.keys) if (!pressed) pressed = FlxG.keys.checkStatus(i, JUST_PRESSED);
            if (pressed) {
                direction = c.dir;
                states.PlayState.current.combo++;
                states.PlayState.current.scoreBoard.scale.x+=0.3;

                FlxG.camera.zoom += 0.05;
            }
        }
    }

    private function updateMovement(elapsed:Float) {
        if (!started) return;
        var addX:Float = 0;
        var addY:Float = 0;

        // If `elapsed` is in seconds, convert it to milliseconds
        elapsed *= 1000;

        // Calculate the movement velocity to move 50 pixels per step_ms
        var moveVel:Float = ((50 / Conductor.current.step_ms) * states.PlayState.current.speedRate) * elapsed;

        switch (direction) {
            case PlayerDirection.LEFT: 
                addX -= moveVel;
            case PlayerDirection.DOWN: 
                addY += moveVel;
            case PlayerDirection.UP: 
                addY -= moveVel;
            case PlayerDirection.RIGHT: 
                addX += moveVel;
        }

        x += addX;
        y += addY;

        // Snap to 50 pixel grid
        if (direction == PlayerDirection.LEFT || direction == PlayerDirection.RIGHT) {
            y = Math.round(y / 50) * 50;
        } else if (direction == PlayerDirection.UP || direction == PlayerDirection.DOWN) {
            x = Math.round(x / 50) * 50;
        }
    }
}
