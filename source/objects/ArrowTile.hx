package objects;

import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import states.PlayState;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import objects.TileEffect;
import game.Utils.RGB;
import flixel.graphics.FlxGraphic;
import game.Conductor;
import lime.graphics.Image;
import objects.Player.Direction;
import openfl.display.BitmapData;

enum abstract TileRating(String) from String to String {
	var PERFECT = "perfect";
	var COOL = "good";
	var MEH = "meh";
	var MISS = "miss";
}

/**
 * Arrow Tile colors from the map.
 */
typedef TileColorData = {
	var zero:RGB;
	var one:RGB;
	var two:RGB;
	var three:RGB;
	var fallback:RGB;
}

/**
 * Arrow Tile object, used during gameplay.
 */
class ArrowTile extends FlxSprite {
	/**
	 * Value for the tile color data.
	 */
	public var tileColorData:TileColorData = Utils.DEFAULT_TILE_COLOR_DATA;

	/**
	 * If this tile updates its color each frame.
	 */
	public var canUpdateColors:Bool = true;

	/**
	 * Arrow direction of this tile points at. (`Direction`)
	 */
	public var direction:Direction = DOWN;

	/**
	 * Variable to assist with miss handling.
	 */
	public var checked:Bool = false;

	/**
	 * This tile's Step time.
	 */
	public var step:Float = 0;

	/**
	 * Indicates whether this tile have been hit.
	 */
	public var already_hit:Bool = false;

	/**
	 * Indicates whether the player missed this tile.
	 */
	public var missed:Bool = false;

	/**
	 * Rating of this tile after gets hit.
	 */
	public var rating:TileRating = MISS;

	public var hitsound_played:Bool = false;
	
	public var outlineEffect:TileEffect;

	/**
	 * Creates a new ArrowTile object.
	 * @param nX X Position
	 * @param nY Y Position
	 * @param dir Arrow direction of this tile points at.
	 * @param curStep This tile's Step time.
	 * @param tileColorData Color Data for this ArrowTile.
	 */
	public function new(nX:Float, nY:Float, dir:Direction, curStep:Int, ?tileColorData:TileColorData) {
		super(nX, nY);
		step = curStep;
		direction = dir;
		if (tileColorData != null)
			this.tileColorData = tileColorData;

		loadGraphic(Assets.image("arrow_tile"));
		setGraphicSize(Player.BOX_SIZE, Player.BOX_SIZE);
		updateHitbox();
		
        initProperties();

		outlineEffect = new TileEffect(nX,nY).makeGraphic(300,300,0xFFFFFFFF);
        outlineEffect.outline = 0.95;
		outlineEffect.alpha = 0;
		var _graphicSize:Float = Player.BOX_SIZE + (200);
		outlineEffect.setGraphicSize(_graphicSize,_graphicSize);
		outlineEffect.updateHitbox();
	}

    function initProperties() {
        // Colors //
        var colorIndex = Std.int(step % 4);
        var colorData = [
            tileColorData.zero, tileColorData.one, tileColorData.two, tileColorData.three
        ];
        
        var selectedColor = (colorIndex < colorData.length) ? colorData[colorIndex] : tileColorData.fallback;
        color = FlxColor.fromRGB(selectedColor.red, selectedColor.green, selectedColor.blue, 255);

        // Direction / angles //
        switch (direction) {
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

	override function draw() {
		super.draw();
		outlineEffect.x = x - (outlineEffect.width-width)/2;
		outlineEffect.y = y - (outlineEffect.height-height)/2;
		outlineEffect.draw();
	}

	var _angleAdd:Float = 0;
	override function update(elapsed:Float) {
		if (Conductor.instance.current_steps + 6 > step && Conductor.instance.current_steps < step) {
			var timeDiff:Float = Math.abs((Conductor.instance.time - (step * Conductor.instance.step_ms)) / (Conductor.instance.step_ms*6));	
			var _animTime:Float = FlxEase.backOut(Math.abs(timeDiff));
			var _graphicSize:Float = Player.BOX_SIZE + (100 * _animTime);
			
			outlineEffect.scale.set(_graphicSize / outlineEffect.frameWidth, _graphicSize / outlineEffect.frameHeight);
			outlineEffect.alpha += 5 * elapsed;
		} else {
			outlineEffect.alpha -= 10 * elapsed;
		}
		
		if (Conductor.instance.current_steps + 10 > step && Conductor.instance.current_steps < step && alpha < 1) {
			alpha += 2 * elapsed;
		} else {
			alpha -= 3 * elapsed;
		}

		if (missed) {
			canUpdateColors = false;
			color = FlxColor.RED;
			scale.x = scale.y *= 0.9 * (elapsed*5);
			angle += _angleAdd * elapsed;
		}

		if (already_hit) {
			scale.x = scale.y *= 1.1 * (elapsed*5);
			angle += _angleAdd * elapsed;
		}

		if (!missed && !already_hit) {
			_angleAdd = FlxG.random.float(-90, 90);
		}
		super.update(elapsed);
	}

    /**
        Callback function that will be fired when this tile is hit.
    **/
	public function onTileHit(?rating:TileRating = MISS):Void {
		this.rating = rating;
        PlayState.instance.player.showRating(this);
	}

    /**
        Callback function that will be fired when this tile is missed.
    **/
	public function onTileMiss():Void {
        PlayState.instance.player.showRating(this);
	}

	override function destroy() {
		if (outlineEffect != null) outlineEffect.destroy();
		super.destroy();
	}
}
