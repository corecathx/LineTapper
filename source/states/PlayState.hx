package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
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

	public var MAP:LineMap;
	public var speedRate:Float = 1;

	public var scoreBoard:FlxText;
	public var combo:Int = 0;

	public var player:Player;
	public var tile_group:FlxTypedGroup<ArrowTile>;

	var bg_gradient:FlxSprite;
	var bg:FlxBackdrop;

	var gameCamera:FlxCamera;
	var hudCamera:FlxCamera;

	var auto_map:Array<Dynamic> = [];
	var using_autoplay:Bool = true;


	override public function create()
	{
		current = this;

		initCameras();
		loadGameplay();
		loadHUD();

		loadSong();
		FlxG.camera.follow(player, LOCKON);
		super.create();
	}
	function loadSong() {
		FlxG.sound.playMusic(AssetPaths.Inst__ogg,1,true);
		FlxG.sound.music.time = 0;
		FlxG.sound.music.pitch = speedRate;
		FlxG.sound.music.pause();

		MAP = MapData.loadMap(File.getContent("./assets/data/newChart.json"));
	
		var current_direction:PlayerDirection = PlayerDirection.DOWN;
		var tileData:Array<Int> = [0, 0]; // Current Tile, rounded from 50px, 0,0 is the first tile.
		var curStep:Int = 0;
	
		for (tile in MAP.tiles) {
			// Calculate step difference
			var stepDifference:Int = tile.step - curStep;
			curStep = tile.step; // Update curStep to the current tile step

			var direction:PlayerDirection = cast tile.direction;

			switch (current_direction) {
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

			auto_map.push([curStep,direction]);
			var arrowTile = new ArrowTile(posX, posY, direction, curStep);
			tile_group.add(arrowTile);
	
			current_direction = direction;
	
		}
	
		Conductor.current.updateBPM(MAP.bpm);
		Conductor.current.onBeatTick.add(() -> {
			player.scale.x = player.scale.y += 0.3;
		});
	
		trace("Tile group length: " + tile_group.length);
	}
	

	function initCameras() {
		gameCamera = new FlxCamera();
		FlxG.cameras.reset(gameCamera);

		hudCamera = new FlxCamera();
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCamera, false);
	}

	function loadHUD() {
		scoreBoard = new FlxText(20,20,-1,"",20);
		scoreBoard.setFormat(AssetPaths.fred_sembold__ttf, 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(scoreBoard);
		scoreBoard.cameras = [hudCamera];
	}

	function loadGameplay() {
		bg_gradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.BLACK, FlxColor.BLUE], 1, 90, true);
		bg_gradient.scale.set(1, 1);
		bg_gradient.scrollFactor.set();
		bg_gradient.alpha = 0.2;
		add(bg_gradient);

		bg = new FlxBackdrop(FlxGridOverlay.createGrid(50,50,100,100,true,0xFF000F30,0xFF002763), XY);
		bg.scale.set(1, 1);
		bg.updateHitbox();
		bg.alpha = 0.3;
		add(bg);

		tile_group = new FlxTypedGroup<ArrowTile>();
		add(tile_group);

		player = new Player(0,0);
		add(player);
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music != null) 
			Conductor.current.time = FlxG.sound.music.time;
		scoreBoard.text = (using_autoplay ? "Autoplay Mode\n" + "Combo: " + combo + "x" : ""
		+ "PERFECT!!"
		+ "\nCombo: "+combo+"x");

		scoreBoard.scale.y = scoreBoard.scale.x = FlxMath.lerp(1,scoreBoard.scale.x,1-(elapsed*12));
		scoreBoard.setPosition(20 + (scoreBoard.width - scoreBoard.frameWidth), FlxG.height-(scoreBoard.height+20));
		scoreBoard.screenCenter(X);
		FlxG.camera.zoom = FlxMath.lerp(1,FlxG.camera.zoom, 1-(elapsed*12));

		if (FlxG.keys.justPressed.SPACE) {
			FlxG.sound.music.play();
			player.setPosition();
			player.started = true;
		}
		if (FlxG.sound.music != null && using_autoplay) {
			tile_group.forEachAlive((tile:ArrowTile) ->
			{
				if (Conductor.current.current_steps > tile.step - 1 && !tile.already_hit)
					onTileHit(tile);

				if (tile.already_hit && tile.step + 8 < Conductor.current.current_steps)
				{
					trace("Killed");
					tile.kill();
					tile.destroy();
					tile_group.remove(tile, true);
				}
			});
		}
		super.update(elapsed);
	}

	public function onTileHit(tile:ArrowTile)
	{
		tile.already_hit = true;
		player.direction = tile.direction;
		player.setPosition(tile.x, tile.y);
		combo++;
		scoreBoard.scale.x += 0.3;
		FlxG.camera.zoom += 0.05;
	}
}
