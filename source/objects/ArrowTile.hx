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

    override function update(elapsed:Float) {
        if (Conductor.current.current_steps+8 > step && Conductor.current.current_steps < step && alpha < 1) {
            alpha += 2 * elapsed;
        } else {
            alpha -= 3 * elapsed;
        }
		if (already_hit)
		{
			scale.set(scale.x + (3 * elapsed), scale.y + (3 * elapsed));
		}
        super.update(elapsed);
    }
}