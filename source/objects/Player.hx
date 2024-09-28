package objects;

import objects.ArrowTile;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import game.Conductor;
import states.PlayState;

enum abstract Direction(Int) {
	var LEFT = 0;
	var DOWN = 1;
	var UP = 2;
	var RIGHT = 3;
}

/**
 * Player object.
 */
class Player extends FlxSprite {
	/** Size of this player's box sprite, and also used by Tiles. **/
	public static var BOX_SIZE:Int = 50;

	/** Defines current direction of the player. **/
	public var direction:Direction = DOWN;

	/** Current step of the player, which is `Conductor.instance.current_steps`. **/
	public var currentStep:Int = 0;

	/** A progress from previous tile to the next tile from 0 to 1. **/
	public var tileProgress:Float = 0;

	/** Current visible / spawned trails of the player object. **/
	public var trails:Array<FlxSprite> = [];

	/** Trail spawn interval, higher = less trails, lower = more trails. **/
	public var trail_delay:Float = 0.05;

	/** Whether to start the player's movement. **/
	public var started:Bool = false;
	 
	/** The text that appears on top of the player (rating text). **/
	public var ratingText:FlxText;

	/** Defines last hitted tile rating. **/
	public var lastRating:TileRating = MISS;

	/** Defines next hittable tile. **/
	public var nextTileData:{x:Float,y:Float,step:Float} = {x:0,y:0,step:0};

	/** Defines last tile data. **/
	public var lastTileData:{x:Float,y:Float,step:Float} = {x:0,y:0,step:0};

	public function new(nX:Float, nY:Float) {
		super(nX, nY);
		makeGraphic(BOX_SIZE, BOX_SIZE, 0xFFFFFFFF);

		ratingText = new FlxText(0,0,-1,"MISS",20);
		ratingText.setFormat(Assets.font("extenro"), 12, FlxColor.RED, CENTER, OUTLINE, FlxColor.BLACK);
		ratingText.alpha = 0;
	}

	override function update(elapsed:Float) {
		updateProperties();
        if (!PlayState.instance.songEnded)
		    updateMovement(elapsed);

		handleTrails(elapsed);
		updateScale(elapsed);
		updateRatingText(elapsed);
		super.update(elapsed);
	}
		
	override function draw() {
		for (i in trails) {
			if (i.visible && i.alpha > 0)
				i.draw();
		}
		super.draw();

        if (ratingText.scale.x > 0 || ratingText.visible) {
			ratingText.x = x - (ratingText.width-width)/2;
			ratingText.y = y - (ratingText.height+10);
			ratingText.draw();
        }
	}

	///// PUBLIC API /////

	/**
	 * Shows the rating text based of a tile's rating.
	 * @param tile 
	 * @param rating 
	 */
	public function showRating(tile:ArrowTile) {
		if (tile == null) {
			trace("Tile is null, ignoring showRating command.");
			return;
		}
        
		ratingText.text = (cast tile.rating).toUpperCase();
		ratingText.color = switch (tile.rating) {
			case PERFECT: 0xFF0084FF;
			case COOL: 0xFF34A350;
			case MEH: 0xFFE7D744;
			case MISS: 0xFFFF0000;
			default: 0xFFFFFFFF;
		}
        _ratingTime = 0;
        ratingText.alpha = 1;
        ratingText.scale.set(1.4,1.4); // zoom inn lol
	}

	/**
	 * Checks every tile object.
	 * @param tile_group 
	 */
	public function checkTiles(tile_group:FlxTypedGroup<ArrowTile>) {
		if (!started)
			return;
		if (tile_group == null)
			return;
		_handleMovements(tile_group);
		_handleInputs(tile_group);
	}

	public function onHitPropertyChange(nextTile:ArrowTile, offset:Float, applyOffset:Bool) {
		var xPos:Float = nextTile.x;
		var yPos:Float = nextTile.y;

		if (applyOffset) {
			switch (nextTile.direction) {
				case Direction.LEFT:
					xPos += offset;
				case Direction.DOWN:
					yPos -= offset;
				case Direction.UP:
					yPos += offset;
				case Direction.RIGHT:
					xPos -= offset;
			}
		}

		setPosition(xPos, yPos);
		direction = nextTile.direction;
	}

	private function updateMovement(elapsed:Float) {
		if (!started)
			return;
		
		var validCheck:Bool = nextTileData != null && lastTileData != null;
		FlxG.watch.addQuick("Using new method?", validCheck);
		FlxG.watch.addQuick("Tiles", (nextTileData) + " // " + (lastTileData));
		if (validCheck) {
			var targetTime:Float = nextTileData.step * Conductor.instance.step_ms;
			var lastTime:Float = lastTileData.step * Conductor.instance.step_ms;
			var curTime:Float = Conductor.instance.time;
		
			FlxG.watch.addQuick("Times", targetTime + " // " + lastTime);
		
			if (targetTime != lastTime) {
				tileProgress = (curTime - lastTime) / (targetTime - lastTime);
		
				x = lastTileData.x + (nextTileData.x - lastTileData.x) * tileProgress;
				y = lastTileData.y + (nextTileData.y - lastTileData.y) * tileProgress;
		
				FlxG.watch.addQuick("Player Progress", tileProgress);
			}
		} else { // Use legacy method of movement
			var addX:Float = 0;
			var addY:Float = 0;
	
			elapsed *= 1000;
	
			var moveVel:Float = ((BOX_SIZE / Conductor.instance.step_ms) * states.PlayState.instance.speedRate) * elapsed;
	
			switch (direction) {
				case Direction.LEFT:
					addX -= moveVel;
				case Direction.DOWN:
					addY += moveVel;
				case Direction.UP:
					addY -= moveVel;
				case Direction.RIGHT:
					addX += moveVel;
			}
	
			x += addX;
			y += addY;
	
			if (direction == Direction.LEFT || direction == Direction.RIGHT) {
				y = Math.round(y / BOX_SIZE) * BOX_SIZE;
			} else if (direction == Direction.UP || direction == Direction.DOWN) {
				x = Math.round(x / BOX_SIZE) * BOX_SIZE;
			}
		}
	}

	///// PRIVATE FUNCTIONS /////

	var _ratingTime:Float = 0;
	private function updateRatingText(elapsed:Float) {
		if (ratingText.scale.x <= 0) return;

        _ratingTime += elapsed;
        var _targetSize:Float = _ratingTime > (Conductor.instance.beat_ms/1000)*0.9 ? 0 : 1;
        var _currentSize:Float = FlxMath.lerp(_targetSize,ratingText.scale.x,1-(elapsed*12));
        ratingText.scale.set(_currentSize,_currentSize);
	}

	private function updateProperties() {
		if (Conductor.instance != null)
			currentStep = Conductor.instance.current_steps;
	}

	private function updateScale(e:Float) {
		var _scale:Float = FlxMath.lerp(1, scale.x, 1 - (e * 12));
		scale.set(_scale, _scale);
	}

	private var _trailTime:Float = 0;
	public function handleTrails(elapsed:Float) {
		if (!started)
			return;
		_trailTime += elapsed;

		if (_trailTime > trail_delay) {
			var n:FlxSprite = new FlxSprite(x, y).makeGraphic(BOX_SIZE, BOX_SIZE, 0xFFFFFFFF);
			n.alpha = 0.8;
			n.active = false;
			n.blend = ADD;
			trails.push(n);
			_trailTime = 0;
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

	private function _handleInputs(tile_group:FlxTypedGroup<ArrowTile>) {
		// so uhh, i've removed the directional key controls.
		var keyPressed:Bool = FlxG.keys.justPressed.ANY;
		var usingAuto:Bool = PlayState.instance.using_autoplay;

		// check for the next tile.
		var _nextTile:ArrowTile = null;

		tile_group.forEachAlive((tile:ArrowTile) -> {
			if (tile == null || tile.already_hit || tile.missed)
				return;
			if (tile.step > currentStep) {
				if (_nextTile == null || tile.step < _nextTile.step)
					_nextTile = tile;
			}
		});

		if (_nextTile != null) {
			inline function __tileHit(__tile:ArrowTile) {
				PlayState.instance.onTileHit(__tile);
				lastRating = __tile.rating;
				direction = __tile.direction;
			}
			var _nextStep:Float = _nextTile.step;
			var _nextDirection:Direction = _nextTile.direction;

			var _tileTime:Float = _nextStep * Conductor.instance.step_ms;
			var _timeDiff:Float = Conductor.instance.time - _tileTime;

			if (!usingAuto) {
				var _hitable:Bool = _tileTime > Conductor.instance.time - (Conductor.instance.safe_zone_offset * 1.2)
					&& _tileTime < Conductor.instance.time + (Conductor.instance.safe_zone_offset * 0.4);
				
				if (_hitable && keyPressed) {
					__tileHit(_nextTile);
				} else if (!_nextTile.missed && _tileTime < Conductor.instance.time - (Conductor.instance.safe_zone_offset * 0.4)) {
					PlayState.instance.onTileMiss(_nextTile);
					direction = _nextDirection;
				}
			} else {
				if (Conductor.instance.time > _tileTime)
					__tileHit(_nextTile);
			}
		}
	}

	private function _handleMovements(tile_group:FlxTypedGroup<ArrowTile>) {
		var nextTile:ArrowTile = null;
		var lastTile:ArrowTile = null;
	
		for (tile in tile_group.members) {
			if (tile == null || tile.already_hit || tile.missed)
				continue;
	
			if (tile.step > currentStep) {
				nextTile = tile;
				break;
			}
		}
	
		for (tile in tile_group.members) {
			if (tile == null)
				continue;
	
			if (tile.step <= currentStep) 
				lastTile = tile;
		}
	
		if (nextTile != null)
			nextTileData = {x:nextTile.x, y:nextTile.y, step:nextTile.step};
		if (lastTile != null)
			lastTileData = {x:lastTile.x, y:lastTile.y, step:lastTile.step};
	}
	
}
