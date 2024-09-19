package objects;

import flixel.graphics.FlxGraphic;
import game.Conductor;
import lime.graphics.Image;
import objects.Player.PlayerDirection;
import openfl.display.BitmapData;

/**
 * Arrow Tile colors from the map.
 */
typedef TileColorData = {
    var zero:String;
    var one:String;
    var two:String;
    var three:String;
    var fallback:String;
}

/**
 * Arrow Tile object, used during gameplay.
 */
class ArrowTile extends FlxSprite {
    /**
    * Value for the tile color data.
    */
    public var tileColorData:TileColorData = {
        zero: '0xFFFF8800',
        one: '0xFFFBFF00',
        two: '0xFF00EEFF',
        three: '0xFFFF00FF',
        fallback: '0xFFFFFFFF'
    };
    /**
	 * If this tile updates its color each frame.
	 */
    public var canUpdateColors:Bool = true;
	/**
	 * Arrow direction of this tile points at. (`PlayerDirection`)
	 */
	public var direction:PlayerDirection = DOWN;
    /**
     * Variable to assist with miss handling.
     */
    public var checked:Bool = false;
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
     * @param tileColorData Color Data for this ArrowTile.
	 */
    public function new(nX:Float, nY:Float, dir:PlayerDirection, curStep:Int, ?tileColorData:TileColorData) {
        super(nX,nY);
        step = curStep;
		direction = dir;
        trace(tileColorData);
        if (tileColorData != null)
            this.tileColorData = tileColorData;

		loadGraphic(Assets.image("ArrowTile"));
		updateColors();

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

    public function updateColors()
    {
        color = switch (step % 4)
		{
			case 0: FlxColor.fromString(tileColorData.zero);
			case 1: FlxColor.fromString(tileColorData.one);
			case 2: FlxColor.fromString(tileColorData.two);
			case 3: FlxColor.fromString(tileColorData.three);
			default: FlxColor.fromString(tileColorData.fallback);
		}
    }

	var _angleAdd:Float = 0;
    override function update(elapsed:Float) {
		if (Conductor.instance.current_steps + 10 > step && Conductor.instance.current_steps < step && alpha < 1)
		{
			alpha += 2 * elapsed;
		} else {
			alpha -= 3 * elapsed;
		}
	

		if (missed) {
            canUpdateColors = false;
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
        if (canUpdateColors)
            updateColors();
        super.update(elapsed);
    }
}