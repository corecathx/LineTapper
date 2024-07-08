package objects;

import flixel.graphics.FlxGraphic;
import game.Conductor;
import lime.graphics.Image;
import objects.Player.PlayerDirection;
import openfl.display.BitmapData;

class ArrowTile extends FlxSprite {
	public var direction:PlayerDirection = DOWN;
	public var step:Int = 0;
	public var already_hit:Bool = false;
    public function new(nX:Float, nY:Float, dir:PlayerDirection, curStep:Int) {
        super(nX,nY);
        step = curStep;
		direction = dir;
        loadGraphic(FlxGraphic.fromBitmapData(BitmapData.fromFile("./assets/images/ArrowTile.png")));
		color = switch (step % 4)
		{
			case 0: 0xFFFF8800;
			case 1: 0xFFFBFF00;
			case 2: 0xFF00EEFF;
			case 3: 0xFFFF00FF;
			default: 0xFFFFFFFF;
		}

        switch (dir) {
            case LEFT:
                angle = 90;
            case RIGHT:
                angle = -90;
            case UP:
                angle = 180;
            default:
                angle = 0;
        }
        alpha = 0;
    }

	var _angleAdd:Float = 0;
    override function update(elapsed:Float) {
		if (Conductor.current.current_steps + 10 > step && Conductor.current.current_steps < step && alpha < 1)
		{
            alpha += 2 * elapsed;
        } else {
            alpha -= 3 * elapsed;
        }
		if (already_hit)
		{
			scale.set(scale.x + (3 * elapsed), scale.y + (3 * elapsed));
			angle += _angleAdd * elapsed;
		}
		else
		{
			_angleAdd = FlxG.random.float(-90, 90);
		}
        super.update(elapsed);
    }
}