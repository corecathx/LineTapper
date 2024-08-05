package objects;

import flixel.graphics.FlxGraphic;
import game.Conductor;
import lime.graphics.Image;
import objects.Player.PlayerDirection;
import openfl.display.BitmapData;

/**
 * Arrow Tile object, used during gameplay.
 */
class ArrowTile extends FlxSprite {
	/**
	 * Arrow direction of this tile points at. (`PlayerDirection`)
	 */
	public var direction:PlayerDirection = DOWN;
	/**
	 * This tile's Step time.
	 */
	public var step:Int = 0;
	/**
	 * Indicates whether this tile have been hit.
	 */
	public var already_hit:Bool = false;
	/**
	 * Indicates whether the player missed this tile.
	 */
	public var missed:Bool = false;

	public var hitsound_played:Bool = false;


	/**
	 * Creates a new ArrowTile object.
	 * @param nX X Position
	 * @param nY Y Position
	 * @param dir Arrow direction of this tile points at.
	 * @param curStep This tile's Step time.
	 */
    public function new(nX:Float, nY:Float, dir:PlayerDirection, curStep:Int) {
        super(nX,nY);
        step = curStep;
		direction = dir;
		loadGraphic(Assets.image("ArrowTile"));
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
	

		if (missed) {
			color = FlxColor.RED;
			scale.set(scale.x - (2 * elapsed), scale.y - (2 * elapsed));
			angle += _angleAdd * elapsed;
		}

		if (already_hit) {
			scale.set(scale.x + (3 * elapsed), scale.y + (3 * elapsed));
			angle += _angleAdd * elapsed;
		}

		if (!missed && !already_hit) {
			_angleAdd = FlxG.random.float(-90, 90);
		}

        super.update(elapsed);
    }
}