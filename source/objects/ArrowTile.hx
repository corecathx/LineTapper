package objects;

import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import objects.BoxOutline;
import game.Utils.RGB;
import flixel.graphics.FlxGraphic;
import game.Conductor;
import lime.graphics.Image;
import objects.Player.PlayerDirection;
import openfl.display.BitmapData;

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
	
	public var outlineEffect:BoxOutline;

	/**
	 * Creates a new ArrowTile object.
	 * @param nX X Position
	 * @param nY Y Position
	 * @param dir Arrow direction of this tile points at.
	 * @param curStep This tile's Step time.
	 * @param tileColorData Color Data for this ArrowTile.
	 */
	public function new(nX:Float, nY:Float, dir:PlayerDirection, curStep:Int, ?tileColorData:TileColorData) {
		super(nX, nY);
		step = curStep;
		direction = dir;
		if (tileColorData != null)
			this.tileColorData = tileColorData;

		loadGraphic(Assets.image("arrow_tile"));
		setGraphicSize(Player.BOX_SIZE, Player.BOX_SIZE);
		updateHitbox();
		color = switch (step % 4) {
			case 0: FlxColor.fromRGB(tileColorData.zero.red, tileColorData.zero.green, tileColorData.zero.blue, 255);
			case 1: FlxColor.fromRGB(tileColorData.one.red, tileColorData.one.green, tileColorData.one.blue, 255);
			case 2: FlxColor.fromRGB(tileColorData.two.red, tileColorData.two.green, tileColorData.two.blue, 255);
			case 3: FlxColor.fromRGB(tileColorData.three.red, tileColorData.three.green, tileColorData.three.blue, 255);
			default: FlxColor.fromRGB(tileColorData.fallback.red, tileColorData.fallback.green, tileColorData.fallback.blue, 255);
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

		outlineEffect = cast new BoxOutline(nX,nY).makeGraphic(300,300,0xFFFFFFFF);
        outlineEffect.outline = 0.95;
		outlineEffect.alpha = 0;
		var _graphicSize:Float = Player.BOX_SIZE + (200);
		outlineEffect.setGraphicSize(_graphicSize,_graphicSize);
		outlineEffect.updateHitbox();
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
			outlineEffect.alpha += 5 * elapsed;
		
			var timeDiff:Float = Math.abs((Conductor.instance.time - (step * Conductor.instance.step_ms)) / (Conductor.instance.step_ms*6));
			
			var _animTime:Float = FlxEase.backOut(Math.abs(timeDiff));
			
			//trace(((Conductor.instance.time - (step * Conductor.instance.step_ms))-(Conductor.instance.step_ms*4)) + " // " + timeDiff);

			var _graphicSize:Float = Player.BOX_SIZE + (100 * _animTime);
			outlineEffect.scale.set(_graphicSize / outlineEffect.frameWidth, _graphicSize / outlineEffect.frameHeight);
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
			scale.set(scale.x*(0.9*elapsed), scale.y*(0.9*elapsed));
			angle += _angleAdd * elapsed;
		}

		if (already_hit) {
			scale.set(scale.x*(1.1*elapsed), scale.y*(1.1*elapsed));
			angle += _angleAdd * elapsed;
		}

		if (!missed && !already_hit) {
			_angleAdd = FlxG.random.float(-90, 90);
		}
		super.update(elapsed);
	}

	override function destroy() {
		outlineEffect.destroy();
		super.destroy();
	}
}
