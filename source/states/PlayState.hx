package states;

import flixel.ui.FlxBar;
import game.backend.Lyrics;

import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import game.backend.script.ScriptGroup;
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

typedef Rating = {
    var count:Int;
    var arrowTiles:Array<ArrowTile>;
}

/**
 * Main gameplay state of LineTapper.
 */
class PlayState extends StateBase
{
	/**
	 * Current instance of PlayState.
	 */
	public static var instance:PlayState;

	/**
	 * Current song's name.
	 */
	public var songName:String = "Tutorial";

    /**
     * Defines whether the song has ended.
     */
    public var songEnded:Bool = false;

    /**
     * Contains information about current gameplay ratings.
     */
    public var ratings:Map<TileRating, Rating>;

	/**
	 * Current song's LineMap / Map data.
	 */
	public var linemap:LineMap;

	/**
	 * Playback speed of current song.
	 */
	public var speedRate:Float = 1;

    /**
     * Whether to enable the end transition when the song ends.
     */
    public var hasEndTransition:Bool = true;

	/**
	 * TBA
	 */
	public var scoreBoard:FlxText;

	/**
	 * Lyrics data of this song.
	 */
	public var lyrics:Lyrics;
	
	/**
	 * Lyrics text object of this song.
	 */
	public var lyricText:FlxText;

	/**
	 * Time bar object.
	 */
	public var timeBar:FlxBar;

	/**
	 * Current elapsed song time.
	 */
	public var timeTextLeft:FlxText;

	/**
	 * Current song's length.
	 */
	public var timeTextRight:FlxText;

	/**
	 * Current combo counter.
	 */
	public var combo:Int = 0;

	/**
	 * An object that used by the camera to follow the player.
	 */
	public var camFollow:FlxObject;

	/**
	 * The player object.
	 */
	public var player:Player;

	/**
	 * A group containing current spawned tiles.
	 */
	public var tile_group:FlxTypedGroup<ArrowTile>;

	/**
	 * Current running scripts of this song.
	 */
	public var scripts:ScriptGroup;

	/**
	 * Gradient gameplay background.
	 */
	public var bg_gradient:FlxSprite;

	/**
	 * The world camera, shortcut to `FlxG.camera`.
	 */
	public var gameCamera:FlxCamera;
	
	/**
	 * The HUD Camera.
	 */
	public var hudCamera:FlxCamera;

	/**
	 * Defines whether to use autoplay for this song.
	 */
	public var using_autoplay:Bool = false;

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
		instance = this;

		scripts = new ScriptGroup('${Assets._MAP_PATH}/$songName/scripts/');
		scripts.executeFunc("create");

		initCameras();
		loadGameplay();
		loadHUD();

        ratings = new Map<String, Rating>();
        ratings = [
            PERFECT => {count: 0, arrowTiles: []},
            COOL => {count: 0, arrowTiles: []},
            MEH => {count: 0, arrowTiles: []},
			MISS => {count: 0, arrowTiles: []}
        ];

		loadSong();
		camFollow = new FlxObject(player.x, player.y - 100, 1, 1);
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON);
		scripts.executeFunc("postCreate");
		super.create();
	}

    override public function destroy()
    {
        super.destroy();
        scripts.executeFunc("destroy");
    }

	/**
	 * Loads the song data then spawns the tiles.
	 */
	function loadSong()
	{
		Conductor.instance.time = 0; 
		var mapAsset:MapAsset = Assets.map(songName);
		lyrics = mapAsset.lyrics == null ? new Lyrics() : mapAsset.lyrics;
		FlxG.sound.playMusic(mapAsset.audio, 1, false);
		FlxG.sound.music.onComplete = ()->{
            songEnded = true;
			endSong();
		}
		FlxG.sound.music.time = 0;
		FlxG.sound.music.pitch = speedRate;
		FlxG.sound.music.pause();

		linemap = mapAsset.map;

		var current_direction:Direction = Direction.DOWN;
		var tileData:Array<Int> = [0, 0]; // Current Tile, rounded from 50px, 0,0 is the first tile.
		var curStep:Int = 0;

		for (tile in linemap.tiles)
		{
			var stepDifference:Int = tile.step - curStep;
			curStep = tile.step; // Update curStep to the instance tile step

			var direction:Direction = cast tile.direction;

			switch (current_direction)
			{
				case Direction.LEFT:
					tileData[0] -= stepDifference;
				case Direction.RIGHT:
					tileData[0] += stepDifference;
				case Direction.UP:
					tileData[1] -= stepDifference;
				case Direction.DOWN:
					tileData[1] += stepDifference;
				default:
					trace("Invalid direction type in step " + tile.step);
			}

			var posX = tileData[0] * 50;
			var posY = tileData[1] * 50;

			var _theme:Theme = linemap.theme == null ? {bg:"" ,tileColorData: Utils.DEFAULT_TILE_COLOR_DATA} : linemap.theme;
			var arrowTile = new ArrowTile(posX, posY, direction, curStep, _theme.tileColorData);
			tile_group.add(arrowTile);

			current_direction = direction;
		}

		Conductor.instance.updateBPM(linemap.bpm);
		Conductor.instance.onBeatTick.add(beatTick);

		// trace("Tile group length: " + tile_group.length);
	}

	/**
	 * Initializes the camera objects
	 */
	function initCameras()
	{
		gameCamera = new FlxCamera();
		FlxG.cameras.reset(gameCamera);

		hudCamera = new FlxCamera();
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCamera, false);
	}

	/**
	 * Loads HUD Objects.
	 */
	function loadHUD()
	{
		inline function makeText(nX:Float,nY:Float,label:String, size:Int, ?bold:Bool = false, ?align:FlxTextAlign):FlxText {
			var obj:FlxText = new FlxText(nX, nY, -1, label);
			obj.setFormat(Assets.font("extenro"+(bold?"-bold":"")), size, FlxColor.WHITE, align, OUTLINE, FlxColor.BLACK);
			obj.cameras = [hudCamera];
			obj.active = false;
			return obj;
		}
		// HUD Text Objects. //
		scoreBoard = makeText(20, 20, "", 14, true, CENTER);
		add(scoreBoard);

		lyricText = makeText(20, 20, "", 14, false, CENTER);
		add(lyricText);

		// Time Bar Objects. //
		timeBar = new FlxBar(0,0,LEFT_TO_RIGHT, FlxG.width,5,null,"",0,1,false);
		timeBar.numDivisions = 2000; // uhhh
		timeBar.createFilledBar(0x00000000, 0xFFFFFFFF);
		timeBar.cameras = [hudCamera];
		add(timeBar);
		
		var startY:Float = timeBar.y + timeBar.height + 5;

		timeTextLeft = makeText(10, startY, "", 12, false, LEFT);
		add(timeTextLeft);

		timeTextRight = makeText(FlxG.width, startY, "", 12, false, LEFT);
		timeTextRight.x -= timeTextRight.width;
		add(timeTextRight);
	}

	/**
	 * Loads necessary objects for gameplay.
	 */
	function loadGameplay()
	{
		bg_gradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.BLACK, FlxColor.BLUE], 1, 90, true);
		bg_gradient.scale.set(1, 1);
		bg_gradient.scrollFactor.set();
		bg_gradient.alpha = 0.1;
		add(bg_gradient);

		tile_group = new FlxTypedGroup<ArrowTile>();
		add(tile_group);

		player = new Player(0, 0);
		add(player);
	}

	var _desyncedCount:Int = 0;
	override public function update(elapsed:Float)
	{
		scripts.executeFunc("update", [elapsed]);
		if (FlxG.sound.music != null && FlxG.sound.music.playing) {
			Conductor.instance.time += elapsed*1000;
			if (Math.abs(Conductor.instance.time - FlxG.sound.music.time) > 50) {
				Conductor.instance.time = FlxG.sound.music.time;
				_desyncedCount++;
				FlxG.watch.addQuick("Desynced for", _desyncedCount + " times.");
			}
		}

		_update_HUD(elapsed);
		_update_gameplay(elapsed);

		super.update(elapsed);
		scripts.executeFunc("postUpdate", [elapsed]);
	}

	/**
	 * A function that'll be called when the song ends.
	 */
	public function endSong()
	{
		if (hasEndTransition){
			FlxTween.tween(bg_gradient, {alpha: 0}, 1);
			FlxTween.tween(scoreBoard, {alpha: 0}, 1);
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				FlxFlicker.flicker(player, 0.5, 0.02, true);
			});
			new FlxTimer().start(1.5, function(tmr:FlxTimer)
			{
				FlxG.switchState(new MenuState());
				Conductor.instance.onBeatTick.remove(beatTick);
			});
		}else{
			FlxG.switchState(new MenuState());
			Conductor.instance.onBeatTick.remove(beatTick);
		}
	}

	/**
	 * A function that'll be caled when the tile gets hit.
	 * @param tile The tile object that gets hit.
	 * @param ratingName Rating of this tile.
	 */
	public function onTileHit(tile:ArrowTile, ?ratingName:TileRating = PERFECT)
	{
		if (tile == null) return;
		tile.onTileHit(ratingName);
		
		scripts.executeFunc("onTileHit", [tile]);
		tile.already_hit = true;
		//if (using_autoplay)
		//	updatePlayerPosition(tile);
		combo++;
		scoreBoard.scale.x += 0.3;
		FlxG.camera.zoom += 0.05;
		increaseRating(tile);

		scripts.executeFunc("postTileHit", [tile]);
	}

	public function onTileMiss(tile:ArrowTile) {
		scripts.executeFunc("onTileMiss", [tile]);
		tile.missed = true;
		player.lastRating = MISS;
		combo = 0;

		tile.onTileMiss();
		increaseRating(tile);
		scripts.executeFunc("postTileMiss", [tile]);
	}

    public function updatePlayerPosition(tile:ArrowTile){
        player.direction = tile.direction;
		player.setPosition(tile.x, tile.y);
    }
	
	public function increaseRating(tile:ArrowTile) {
		if (ratings.exists(tile.rating)) {
			var rating = ratings.get(tile.rating);
			rating.count++;
			rating.arrowTiles.push(tile);
		}
	}

	public function beatTick(currentBeats:Int) {
		scripts.executeFunc("onBeatTick", [currentBeats]);
		if (player != null)
			player.scale.x = player.scale.y += 0.3;
		scripts.executeFunc("postBeatTick", [currentBeats]);
	}

	///////////////// PRIVATE / INTERNAL FUNCTIONS /////////////////

	/**
	 * Updates the Heads Up Display.
	 */
	function _update_HUD(elapsed:Float) {
		if (FlxG.sound.music != null && FlxG.sound.music.playing){
			var _comboStr:String = "Combo: " + combo + "x";
			var _ratingStr:String = (cast (player.lastRating,String)).toUpperCase();
			scoreBoard.text = (using_autoplay ? 'Autoplay Mode\n$_comboStr' : '$_ratingStr\n$_comboStr');
		} else {
			scoreBoard.text = "[ PRESS SPACE TO START ]\nControls: Any keys.";
		}
		scoreBoard.scale.y = scoreBoard.scale.x = FlxMath.lerp(1, scoreBoard.scale.x, 1 - (elapsed * 24));
		scoreBoard.setPosition(20 + (scoreBoard.width - scoreBoard.frameWidth), FlxG.height - (scoreBoard.height + 20));
		scoreBoard.screenCenter(X);

		lyricText.text = lyrics.getLyric(Conductor.instance.time);
		lyricText.setPosition(0,FlxG.height - (scoreBoard.height + 80));
		lyricText.screenCenter(X);

		timeBar.percent = (Conductor.instance.time / FlxG.sound.music.length)*100;
		timeTextLeft.text = Utils.formatMS(Conductor.instance.time);
		timeTextRight.text =  Utils.formatMS(FlxG.sound.music.length);
		timeTextRight.x = FlxG.width - (timeTextRight.width+10);
	}

	/**
	 * Updates the gameplay, such as camera, controls, and tile update.
	 */
	function _update_gameplay(elapsed:Float) {
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 1 - (elapsed * 12));

		camFollow.x = FlxMath.lerp(player.getMidpoint().x, camFollow.x, 1 - (elapsed * 12));
		camFollow.y = FlxMath.lerp(player.getMidpoint().y, camFollow.y, 1 - (elapsed * 12));

		FlxG.watch.addQuick("Player Midpoint", player.getMidpoint().x + " // " + player.getMidpoint().y);
		FlxG.watch.addQuick("camFollow", camFollow.x + " // " + camFollow.y);
		if (FlxG.keys.justPressed.SPACE)
		{
			FlxG.sound.music.play();
			player.setPosition();
			player.started = true;
		}

		if (FlxG.keys.justPressed.ESCAPE) {
			endSong();
		}

		if (FlxG.keys.justPressed.TAB) {
			using_autoplay = !using_autoplay;
		}

		if (FlxG.sound.music != null)
		{
			player.checkTiles(tile_group);
			FlxG.watch.addQuick("Player Step: ", player.currentStep);
			FlxG.watch.addQuick("Player Direction: ", player.direction);
			FlxG.watch.addQuick("Player XY: ", player.x + " / " + player.y);
			/*if (using_autoplay)
			{
				tile_group.forEachAlive((tile:ArrowTile) ->
				{
					if (Conductor.instance.current_steps > tile.step - 1 && !tile.already_hit)
						onTileHit(tile);
				});
			} else {
				player.checkTiles(tile_group);

				tile_group.forEachAlive((tile:ArrowTile) ->
				{
                    if (Conductor.instance.current_steps > tile.step - 1 && !tile.checked){
                        tile.checked = true;
						player.onHitPropertyChange(tile, 0, false);
                    }
				});

				FlxG.watch.addQuick("Player Step: ", player.currentStep);
				FlxG.watch.addQuick("Player Direction: ", player.direction);
				FlxG.watch.addQuick("Player XY: ", player.x + " / " + player.y);
			}*/

			tile_group.forEachAlive((tile:ArrowTile)->{
				if ((tile.already_hit || tile.missed) 
					&& Conductor.instance.current_steps > tile.step + 8) {
					tile.kill();
					tile_group.remove(tile);
					tile.destroy();
				}
				if (Conductor.instance.current_steps < tile.step) return;
				if (!tile.hitsound_played) {
					FlxG.sound.play(Assets.sound("hit_sound"), 0.7);
					tile.hitsound_played = true;
				}
			});
		}
	}

}
