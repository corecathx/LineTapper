package objects;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import game.Conductor;
import states.PlayState;

enum abstract PlayerDirection(Int) {
	var LEFT = 0;
	var DOWN = 1;
	var UP = 2;
	var RIGHT = 3;
}

class Player extends FlxSprite {
	public static var BOX_SIZE:Int = 50;
	public var direction:PlayerDirection = DOWN;
	public var nextDirection:PlayerDirection = DOWN;

	public var nextTileProgress:Float = 0;

	public var speed:Float = 1;
	public var pixelMovement:Float = 5;

	public var currentStep:Int = 0;
	public var nextStep:Int = 0;

	public var trails:Array<FlxSprite> = [];
	public var trail_length:Int = 5;
	public var trail_time:Float = 0;
	public var trail_delay:Float = 0.05;
	public var started:Bool = false;

	public function new(nX:Float, nY:Float) {
		super(nX, nY);
		makeGraphic(BOX_SIZE, BOX_SIZE, 0xFFFFFFFF);
	}

	override function update(elapsed:Float) {
		updateProperties();
        if (!PlayState.instance.songEnded)
		    updateMovement(elapsed);

		handleTrails(elapsed);
		updateScale(elapsed);
		super.update(elapsed);
	}

	function updateProperties() {
		if (Conductor.instance != null)
			currentStep = Conductor.instance.current_steps;
	}

	public function updateScale(e:Float) {
		var _scale:Float = FlxMath.lerp(1, scale.x, 1 - (e * 12));
		scale.set(_scale, _scale);
	}

	override function draw() {
		for (i in trails) {
			if (i.visible && i.alpha > 0)
				i.draw();
		}
		super.draw();
	}

	private var _curTime:Float = 0;

	public function handleTrails(elapsed:Float) {
		if (!started)
			return;
		_curTime += elapsed;

		if (_curTime > trail_delay) {
			var n:FlxSprite = new FlxSprite(x, y).makeGraphic(BOX_SIZE, BOX_SIZE, 0xFFFFFFFF);
			n.alpha = 0.8;
			n.active = false;
			n.blend = ADD;
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

	// remind me to rewrite this soon please
	public function checkTiles(tile_group:FlxTypedGroup<ArrowTile>) {
		if (!started)
			return;
		if (tile_group == null)
			return;

		var keys:Array<Array<Dynamic>> = [
			[FlxKey.A, FlxKey.LEFT],
			[FlxKey.S, FlxKey.DOWN],
			[FlxKey.W, FlxKey.UP],
			[FlxKey.D, FlxKey.RIGHT]
		];
		var pressArray:Array<Bool> = [false, false, false, false];

		for (index => keyList in keys) {
			var pressed:Bool = false;
			for (key in keyList) {
				if (FlxG.keys.checkStatus(key, JUST_PRESSED)) {
					pressed = true;
					break; // Exit inner loop once a key is pressed
				}
			}
			pressArray[index] = pressed;
		}

		var nextTile:ArrowTile = null;
		tile_group.forEachAlive((tile:ArrowTile) -> {
			if (tile == null || tile.already_hit || tile.missed)
				return;

			if (nextTile == null)
				nextTile = tile;
			else if (tile.step > currentStep && tile.step < nextTile.step)
				nextTile = tile;
		});

		if (nextTile != null) {
			nextStep = nextTile.step;
			nextDirection = nextTile.direction;

			var tileTime:Float = nextTile.step * Conductor.instance.step_ms;
			var hitable:Bool = tileTime > Conductor.instance.time - (Conductor.instance.safe_zone_offset * 1.5)
				&& tileTime < Conductor.instance.time + (Conductor.instance.safe_zone_offset * 0.25);

			var timeDiff:Float = tileTime - Conductor.instance.time; // + is early, - is late.
			// i want to die :sob:
			var tOffset:Float = timeDiff * (BOX_SIZE / Conductor.instance.step_ms) * states.PlayState.instance.speedRate;

			if (hitable) {
				if (pressArray[cast nextTile.direction] && !nextTile.already_hit) {
					nextTile.already_hit = true;
					PlayState.instance.hitStatus = "PERFECT!!";
					PlayState.instance.onTileHit(nextTile);
					//onHitPropertyChange(nextTile, tOffset, true);
				}
			} else if (!nextTile.missed && tileTime < Conductor.instance.time - (Conductor.instance.safe_zone_offset * 0.2)) {
				trace("MISSED!!!");
                PlayState.instance.misses++;
				PlayState.instance.hitStatus = "MISSED!";
				PlayState.instance.combo = 0;
				nextTile.missed = true;
                
				//onHitPropertyChange(nextTile, tOffset, false);
			}
		}
	}

	public function onHitPropertyChange(nextTile:ArrowTile, offset:Float, applyOffset:Bool) {
		var xPos:Float = nextTile.x;
		var yPos:Float = nextTile.y;

		trace("Offset: " + offset);

		if (applyOffset) {
			switch (nextTile.direction) {
				case PlayerDirection.LEFT:
					xPos += offset;
				case PlayerDirection.DOWN:
					yPos -= offset;
				case PlayerDirection.UP:
					yPos += offset;
				case PlayerDirection.RIGHT:
					xPos -= offset;
			}
		}

		setPosition(xPos, yPos);
		direction = nextTile.direction;
	}

	private function updateMovement(elapsed:Float) {
		if (!started)
			return;
		var addX:Float = 0;
		var addY:Float = 0;

		elapsed *= 1000;

		var moveVel:Float = ((BOX_SIZE / Conductor.instance.step_ms) * states.PlayState.instance.speedRate) * elapsed;

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

		if (direction == PlayerDirection.LEFT || direction == PlayerDirection.RIGHT) {
			y = Math.round(y / BOX_SIZE) * BOX_SIZE;
		} else if (direction == PlayerDirection.UP || direction == PlayerDirection.DOWN) {
			x = Math.round(x / BOX_SIZE) * BOX_SIZE;
		}
	}
}
