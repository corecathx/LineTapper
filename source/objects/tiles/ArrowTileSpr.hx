package objects.tiles;

import game.Conductor;
import objects.tiles.ArrowTile.TileColorData;
import objects.Player.PlayerDirection;

/**
 * Arrow Tile object, a component of the ArrowTile group.
 */
 class ArrowTileSpr extends FlxSprite {
    public var verticalTextOffset:Int = 15;
    public var group:ArrowTile;
    public var squareTileEffect:SquareArrowTileEffect;
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

	/**
	 * Creates a new ArrowTile object.
	 * @param nX X Position
	 * @param nY Y Position
	 * @param dir Arrow direction of this tile points at.
	 * @param curStep This tile's Step time.
	 * @param tileColorData Color Data for this ArrowTile.
	 */
	public function new(nX:Float, nY:Float, dir:PlayerDirection, curStep:Int, group:ArrowTile, ?tileColorData:TileColorData) {
		super(nX, nY);
		step = curStep;
		direction = dir;
        this.group = group;
        antialiasing = true;
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

    public function onTileHit(?rating:String = 'PERFECT') {}

    public function onTileMiss() {}

	override function update(elapsed:Float) {
        super.update(elapsed);

		if (Conductor.instance.current_steps + 10 > step && Conductor.instance.current_steps < step && alpha < 1) {
			alpha += 2 * elapsed;
		}
        if (canUpdateColors)
            updateColors();
	}
}
