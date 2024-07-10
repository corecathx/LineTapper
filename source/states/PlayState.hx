package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxGradient;
import game.Conductor;
import game.MapData.LineMap;
import game.MapData;
import objects.ArrowTile;
import objects.Player;
import sys.io.File;

class PlayState extends FlxState
{
	public static var current:PlayState;

	public var songName:String = "Tutorial";

	public var linemap:LineMap;
	public var speedRate:Float = 1;

	public var scoreBoard:FlxText;
	public var combo:Int = 0;

	public var camFollow:FlxObject;

	public var player:Player;
	public var tile_group:FlxTypedGroup<ArrowTile>;

	var bg_gradient:FlxSprite;
	var bg:FlxBackdrop;

	var gameCamera:FlxCamera;
	var hudCamera:FlxCamera;
	var using_autoplay:Bool = true;

	/**
	 * Prepares `PlayState` to load and play `song` file.
	 * @param song 
	 */
	public function new(?song:String)
	{
		if (song != null)
			songName = song;
		super();
	}

	override public function create()
	{
		current = this;

		initCameras();
		loadGameplay();
		loadHUD();

		loadSong();
		camFollow = new FlxObject(player.x, player.y - 100, 1, 1);
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON);
		super.create();
	}

	function loadSong()
	{
		var mapAsset:MapAsset = Assets.map(songName);
		FlxG.sound.playMusic(mapAsset.audio, 1, true);
		FlxG.sound.music.time = 0;
		FlxG.sound.music.pitch = speedRate;
		FlxG.sound.music.pause();

		linemap = mapAsset.map;

		var current_direction:PlayerDirection = PlayerDirection.DOWN;
		var tileData:Array<Int> = [0, 0]; // Current Tile, rounded from 50px, 0,0 is the first tile.
		var curStep:Int = 0;

		for (tile in linemap.tiles)
		{
			// Calculate step difference
			var stepDifference:Int = tile.step - curStep;
			curStep = tile.step; // Update curStep to the current tile step

			var direction:PlayerDirection = cast tile.direction;

			switch (current_direction)
			{
				case PlayerDirection.LEFT:
					tileData[0] -= stepDifference;
				case PlayerDirection.RIGHT:
					tileData[0] += stepDifference;
				case PlayerDirection.UP:
					tileData[1] -= stepDifference;
				case PlayerDirection.DOWN:
					tileData[1] += stepDifference;
				default:
					trace("Invalid direction type in step " + tile.step);
			}

			// Debugging to ensure we are creating ArrowTiles
			var posX = tileData[0] * 50;
			var posY = tileData[1] * 50;

			var arrowTile = new ArrowTile(posX, posY, direction, curStep);
			tile_group.add(arrowTile);

			current_direction = direction;
		}

		Conductor.current.updateBPM(linemap.bpm);
		Conductor.current.onBeatTick.add(() ->
		{
			if (player != null)
				player.scale.x = player.scale.y += 0.3;
		});

		// trace("Tile group length: " + tile_group.length);
	}

	function initCameras()
	{
		gameCamera = new FlxCamera();
		FlxG.cameras.reset(gameCamera);

		hudCamera = new FlxCamera();
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCamera, false);
	}

	function loadHUD()
	{
		scoreBoard = new FlxText(20, 20, -1, "", 20);
		scoreBoard.setFormat(Assets.font("extenro-bold"), 14, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(scoreBoard);
		scoreBoard.cameras = [hudCamera];
	}

	function loadGameplay()
	{
		bg_gradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.BLACK, FlxColor.BLUE], 1, 90, true);
		bg_gradient.scale.set(1, 1);
		bg_gradient.scrollFactor.set();
		bg_gradient.alpha = 0.2;
		add(bg_gradient);

		bg = new FlxBackdrop(FlxGridOverlay.createGrid(50, 50, 100, 100, true, 0xFF000F30, 0xFF002763), XY);
		bg.scale.set(1, 1);
		bg.updateHitbox();
		bg.alpha = 0.3;
		add(bg);

		tile_group = new FlxTypedGroup<ArrowTile>();
		add(tile_group);

		player = new Player(0, 0);
		add(player);
	}


	public var hitStatus:String = "PERFECT!!";
	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.current.time = FlxG.sound.music.time;
		scoreBoard.text = (using_autoplay ? "Autoplay Mode\n" + "Combo: " + combo + "x" : "" + hitStatus + "\nCombo: " + combo + "x");

		scoreBoard.scale.y = scoreBoard.scale.x = FlxMath.lerp(1, scoreBoard.scale.x, 1 - (elapsed * 12));
		scoreBoard.setPosition(20 + (scoreBoard.width - scoreBoard.frameWidth), FlxG.height - (scoreBoard.height + 20));
		scoreBoard.screenCenter(X);
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 1 - (elapsed * 12));

		camFollow.x = FlxMath.lerp(player.getMidpoint().x, camFollow.x, 1 - (elapsed * 12));
		camFollow.y = FlxMath.lerp(player.getMidpoint().y, camFollow.y, 1 - (elapsed * 12));

		if (FlxG.keys.justPressed.SPACE)
		{
			FlxG.sound.music.play();
			player.setPosition();
			player.started = true;
		}

		if (FlxG.sound.music != null)
		{
			if (using_autoplay)
			{
				tile_group.forEachAlive((tile:ArrowTile) ->
				{
					if (Conductor.current.current_steps > tile.step - 1 && !tile.already_hit)
						onTileHit(tile);

					if (tile.already_hit && tile.step + 8 < Conductor.current.current_steps)
					{
						tile.kill();
						tile.destroy();
						tile_group.remove(tile, true);
					}
				});
			} else {
				player.checkTiles(tile_group);

				tile_group.forEachAlive((tile:ArrowTile) ->
				{
					if ((tile.missed||tile.already_hit) && tile.step + 8 < Conductor.current.current_steps)
					{
						tile.kill();
						tile.destroy();
						tile_group.remove(tile, true);
					}
				});

				FlxG.watch.addQuick("Player Current Step: ", player.currentStep);
				FlxG.watch.addQuick("Player Current Direction: ", player.direction);
				FlxG.watch.addQuick("Player Next Step: ", player.nextStep);
				FlxG.watch.addQuick("Player Next Direction: ", player.nextDirection);
			}
		}
		super.update(elapsed);
	}

	public function onTileHit(tile:ArrowTile)
	{
		tile.already_hit = true;
		player.direction = tile.direction;
		if (using_autoplay) player.setPosition(tile.x, tile.y);
		combo++;
		FlxG.sound.play(Assets.sound("hit_sound"), 0.7);
		scoreBoard.scale.x += 0.3;
		FlxG.camera.zoom += 0.05;
	}
}
