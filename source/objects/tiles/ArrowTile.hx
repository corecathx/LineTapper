package objects.tiles;

import states.PlayState;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import game.Conductor;
import objects.tiles.ArrowTile.MapTileColorData;
import objects.Player.Direction;

/**
 * Arrow Tile colors from the map.
 */
 typedef MapTileColorData = {
	var zero:RGB;
	var one:RGB;
	var two:RGB;
	var three:RGB;
	var fallback:RGB;
}

enum abstract TileRating(String) from String to String {
	var PERFECT = "perfect";
	var COOL = "good";
	var MEH = "meh";
	var MISS = "miss";
}

/**
 * Arrow Tile object, a component of the ArrowTile playstate.
 */
 class ArrowTile extends FlxSprite {
    public var verticalTextOffset:Int = 15;
    public var squareTileEffect:SquareArrowTileEffect;
    public var playstate:PlayState;
	/**
	 * Value for the tile color data.
	 */
	public var tileColorData:MapTileColorData = Common.DEFAULT_TILE_COLOR_DATA;

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
	public var step:Int = 0;

	/**
	 * Indicates whether this tile have been hit.
	 */
	public var hit:Bool = false;

	/**
	 * Indicates whether the player missed this tile.
	 */
	public var missed:Bool = false;

    /**
	 * Rating of this tile after gets hit.
	 */
	public var rating:TileRating = MISS;

	/**
	 * Creates a new ArrowTile object.
	 * @param nX X Position
	 * @param nY Y Position
	 * @param dir Arrow direction of this tile points at.
	 * @param curStep This tile's Step time.
	 * @param tileColorData Color Data for this ArrowTile.
	 */
	public function new(nX:Float, nY:Float, dir:Direction, curStep:Int, ?tileColorData:MapTileColorData, playstate:PlayState) {
		super(nX, nY);
		step = curStep;
		direction = dir;
        antialiasing = true;
        this.playstate = playstate;
		if (tileColorData != null)
			this.tileColorData = tileColorData;

		loadGraphic(Assets.image("arrow_tile"));
		setGraphicSize(Player.BOX_SIZE, Player.BOX_SIZE);
		updateHitbox();
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

        squareTileEffect = new SquareArrowTileEffect(nX, nY, this, 5);
        this.playstate.add(squareTileEffect);
	}

    public static function tileRatingToString(rating:TileRating):String
    {
        return rating == 'perfect' ? 'Perfect!' : rating == 'cool' ? 'Cool!' : rating == 'meh' ? 'Meh.' : rating == 'miss' ? 'Missed!' : 'Perfect!';
    }

    function updateColors()
    {
        color = switch (step % 4) {
			case 0: FlxColor.fromRGB(tileColorData.zero.red, tileColorData.zero.green, tileColorData.zero.blue, 255);
			case 1: FlxColor.fromRGB(tileColorData.one.red, tileColorData.one.green, tileColorData.one.blue, 255);
			case 2: FlxColor.fromRGB(tileColorData.two.red, tileColorData.two.green, tileColorData.two.blue, 255);
			case 3: FlxColor.fromRGB(tileColorData.three.red, tileColorData.three.green, tileColorData.three.blue, 255);
			default: FlxColor.fromRGB(tileColorData.fallback.red, tileColorData.fallback.green, tileColorData.fallback.blue, 255);
		}
    }

    public function onTileHit(?rating:TileRating = PERFECT)
    {
        hit = true;
        // Tween based on properties instead of a set value. Just a way to make sure custom things like modcharts won't break.
        FlxTween.tween(this, {"scale.x": scale.x + scale.x/2.5, "scale.y": scale.y + scale.y/2.5, angle: angle + 70, alpha: 0}, 0.5, {ease: FlxEase.quadOut});
        FlxTween.tween(squareTileEffect, {"scale.x": scale.x + 1.7, "scale.y": scale.y + 1.7, alpha: 0}, 0.5, {ease: FlxEase.quadOut});
        new FlxTimer().start(0.5, function(t){
            playstate.remove(squareTileEffect);
            if (squareTileEffect != null)
                squareTileEffect.kill();
            squareTileEffect = null;
        });
        playstate.flickerTextOnPlayer(tileRatingToString(rating), FlxColor.CYAN, 0.35);
    }

    public function onTileMiss()
    {
        missed = true;
        FlxTween.tween(this, {"scale.x": scale.x - scale.x/2.5, "scale.y": scale.y - scale.y/2.5, angle: angle - 10, alpha: 0}, 0.5, {ease: FlxEase.quadIn});
        FlxTween.tween(squareTileEffect, {"scale.x": scale.x - scale.x/2.5, "scale.y": scale.y - scale.y/2.5, angle: -10, alpha: 0}, 0.5, {ease: FlxEase.quadIn});
        new FlxTimer().start(0.5, function(t){
            playstate.remove(squareTileEffect);
            if (squareTileEffect != null)
                squareTileEffect.kill();
            squareTileEffect = null;
        });
        playstate.flickerTextOnPlayer(tileRatingToString(MISS), 0xFFAA0000, 0.35);
    }

	override function update(elapsed:Float) {
        super.update(elapsed);

		if (Conductor.instance.current_steps + 10 > step && Conductor.instance.current_steps < step && alpha < 1) {
			alpha += 2 * elapsed;
		}
        if (canUpdateColors)
            updateColors();
	}
}
