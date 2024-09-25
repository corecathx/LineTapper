package states;

import objects.Background;
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
import objects.tiles.ArrowTile;
import objects.Player;
import sys.io.File;

typedef Rating = {
    var count:Int;
    var arrowTiles:Array<ArrowTile>;
}

/**
 * ...
 */
class PlayState extends StateBase
{
	public static var instance:PlayState;

	public var songName:String = "Tutorial";
    public var songStarted:Bool = false;
    public var songEnded:Bool = false;
    public var misses:Int = 0;
    public var hits:Int = 0;
    public var ratings:Map<TileRating, Rating>;

	public var linemap:LineMap;
	public var speedRate:Float = 1;
    public var hasEndTransition:Bool = true;

	public var scoreBoard:FlxText;
	public var lyrics:Lyrics;
	public var lyricText:FlxText;

	public var timeBar:FlxBar;
	public var timeTextLeft:FlxText;
	public var timeTextRight:FlxText;

	public var combo:Int = 0;

	public var camFollow:FlxObject;

	public var player:Player;
	public var tile_group:FlxTypedGroup<ArrowTile>;

	public var scripts:ScriptGroup;

	public var bg_gradient:FlxSprite;
	public var backdrop:FlxBackdrop;
    public var gameBG:Background;

	public var gameCamera:FlxCamera;
	public var hudCamera:FlxCamera;
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

        initSong();
		scripts = new ScriptGroup('${Assets._MAP_PATH}/$songName/scripts/');
		scripts.executeFunc("create");

		initCameras();
		loadGameplay();
		loadHUD();

        ratings = new Map<String, Rating>();
        ratings = [
            PERFECT => {count: 0, arrowTiles: []},
            'Cool' => {count: 0, arrowTiles: []},
            'Meh' => {count: 0, arrowTiles: []}
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

    function endSong()
    {
        if (linemap.version == "1.0-alpha-v1"){
            if (!bg_gradient.visible && Background.typeFromString(linemap.theme.bgType) == VIDEO)
                gameBG.stopVideo();
        }
        if (linemap.version == "1.0-alpha-v2"){
            if (!bg_gradient.visible && Background.typeFromString(linemap.theme.bgData.bgType) == VIDEO)
                gameBG.stopVideo();
        }
        if (hasEndTransition){
            FlxTween.tween(bg_gradient, {alpha: 0}, 1);
            FlxTween.tween(scoreBoard, {alpha: 0}, 1);
            FlxTween.tween(backdrop, {alpha: 0}, 1);
            new FlxTimer().start(1, function(tmr:FlxTimer)
            {
                FlxFlicker.flicker(player, 0.5, 0.02, true);
            });
            new FlxTimer().start(1.5, function(tmr:FlxTimer)
            {
                trace('going to menu!');
                FlxG.switchState(new MenuState());
		        Conductor.instance.onBeatTick.remove(beatTick);
            });
        }else{
            trace('going to menu!');
            FlxG.switchState(new MenuState());
		    Conductor.instance.onBeatTick.remove(beatTick);
        }
    }

    function initSong() {
        var mapAsset:MapAsset = Assets.map(songName);
		lyrics = mapAsset.lyrics == null ? new Lyrics() : mapAsset.lyrics;
		FlxG.sound.playMusic(mapAsset.audio, 1, false);
		FlxG.sound.music.onComplete = ()->{
            songEnded = true;
			endSong();
		}
        Conductor.instance.time = 0;
		FlxG.sound.music.time = 0;
		FlxG.sound.music.pitch = speedRate;
		FlxG.sound.music.pause();

		linemap = mapAsset.map;

        if (linemap.version == null){
            legacyMode = true;
        }
    }

	function loadSong()
	{
		var current_direction:PlayerDirection = PlayerDirection.DOWN;
		var tileData:Array<Int> = [0, 0]; // Current Tile, rounded from 50px, 0,0 is the first tile.
		var curStep:Int = 0;

		for (tile in linemap.tiles)
		{
			// Calculate step difference
			var stepDifference:Int = tile.step - curStep;
			curStep = tile.step; // Update curStep to the instance tile step

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

			var _theme:Theme = linemap.theme == null ? {bgData: {}, tileColorData: Utils.DEFAULT_TILE_COLOR_DATA} : linemap.theme;
			var arrowTile = new ArrowTile(posX, posY, direction, curStep, _theme.tileColorData);
			tile_group.add(arrowTile);

			current_direction = direction;
		}

		Conductor.instance.updateBPM(linemap.bpm);
		Conductor.instance.onBeatTick.add(beatTick);

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

	function loadGameplay()
	{
		bg_gradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.BLACK, FlxColor.BLUE], 1, 90, true);
		bg_gradient.scale.set(1, 1);
		bg_gradient.scrollFactor.set();
		bg_gradient.alpha = 0.1;
		add(bg_gradient);

		backdrop = new FlxBackdrop(FlxGridOverlay.createGrid(50, 50, 100, 100, true, 0xFF000F30, 0xFF002763), XY);
		backdrop.alpha = 0;
		add(backdrop);

        if (!legacyMode){
            if (linemap.version == "1.0-alpha-v1"){
                if (linemap.theme.bg != ''){
                    bg_gradient.visible = false;
                    backdrop.visible = false;
                
                    var bgType = Background.typeFromString(linemap.theme.bgType);
                    gameBG = new Background(bgType, 'assets/data/maps/$songName/mapAssets/${linemap.theme.bg}${bgType == IMAGE ? '.png' : bgType == VIDEO ? '.mp4' : '.png'}', linemap.theme.scaleX, linemap.theme.scaleY, 0.45);
                    add(gameBG);
                }
            }
            if (linemap.version == "1.0-alpha-v2"){
                if (linemap.theme.bgData.bg != ''){
                    bg_gradient.visible = false;
                    backdrop.visible = false;
                
                    var bgType = Background.typeFromString(linemap.theme.bgData.bgType);
                    gameBG = new Background(bgType, 'assets/data/maps/$songName/mapAssets/${linemap.theme.bgData.bg}${bgType == IMAGE ? '.png' : bgType == VIDEO ? '.mp4' : '.png'}', linemap.theme.bgData.scaleX, linemap.theme.bgData.scaleY, linemap.theme.bgData.alpha);
                    add(gameBG);
                }
            }
        }else{
            trace('old ahh linemap');
        }

		tile_group = new FlxTypedGroup<ArrowTile>();
		add(tile_group);

		player = new Player(0, 0);
		add(player);
	}


	public var hitStatus:String = "";
	override public function update(elapsed:Float)
	{
		scripts.executeFunc("update", [elapsed]);
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			Conductor.instance.time = FlxG.sound.music.time;

		_update_HUD(elapsed);
		_update_gameplay(elapsed);

		super.update(elapsed);
		scripts.executeFunc("postUpdate", [elapsed]);
	}

	public function onTileHit(tile:ArrowTile, ?ratingName:String = 'Perfect')
        {
            if (tile.tile != null && tile.squareTileEffect != null){
                scripts.executeFunc("onTileHit", [tile]);
                FlxG.sound.play(Assets.sound("hit_sound"), 0.7);
                tile.onTileHit();
                tile.tile.already_hit = true;
                if (using_autoplay)
                    updatePlayerPosition(tile);
                combo++;
                scoreBoard.scale.x += 0.3;
                FlxG.camera.zoom += 0.05;
                var rating = ratings.get(ratingName);
                rating.count++;
                rating.arrowTiles.push(tile);
                scripts.executeFunc("postTileHit", [tile]);
            }
        }

    public function updatePlayerPosition(tile:ArrowTile){
        player.direction = tile.direction;
		player.setPosition(tile.x, tile.y);
    }
	
	public function beatTick(currentBeats:Int) {
		scripts.executeFunc("onBeatTick", [currentBeats]);
		if (player != null)
			player.scale.x = player.scale.y += 0.3;
		scripts.executeFunc("postBeatTick", [currentBeats]);
	}

	///////////////// INTERNAL FUNCTIONS /////////////////

	/**
	 * Updates the Heads Up Display.
	 */
	function _update_HUD(elapsed:Float) {
		if (FlxG.sound.music != null && FlxG.sound.music.playing){
			scoreBoard.text = (using_autoplay ? "Autoplay Mode\n" + "Combo: " + combo + "x" : "" + hitStatus + "\nCombo: " + combo + "x");
		} else {
			scoreBoard.text = "[ PRESS SPACE TO START ]\nControls: WASD / Arrow Keys";
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

		if (FlxG.keys.justPressed.SPACE)
		{
            songStarted = true;
            if (linemap.version == "1.0-alpha-v1"){
                if (!bg_gradient.visible && Background.typeFromString(linemap.theme.bgType) == VIDEO)
                    gameBG.playVideo();
            }
            if (linemap.version == "1.0-alpha-v2"){
                if (!bg_gradient.visible && Background.typeFromString(linemap.theme.bgData.bgType) == VIDEO)
                    gameBG.playVideo();
            }
			FlxG.sound.music.play();
			player.setPosition();
			player.started = true;
		}

		if (FlxG.keys.justPressed.ESCAPE) {
            tile_group.forEachAlive((tile:ArrowTile) ->
			{
                if (tile.tile != null)
                    tile.tile.visible = false;
                if (tile.squareTileEffect != null)
                    tile.squareTileEffect.visible = false;
			});
            FlxG.sound.music.fadeOut(0.5,0, function(t){
                FlxG.sound.music.stop();
            });
            songEnded = true;
			endSong();
		}

		if (FlxG.keys.justPressed.TAB) {
			using_autoplay = !using_autoplay;
		}

		if (FlxG.sound.music != null && !songEnded)
		{
			if (using_autoplay)
			{
				tile_group.forEachAlive((tile:ArrowTile) ->
				{
					if (Conductor.instance.current_steps > tile.tile.step - 1 && !tile.tile.already_hit)
						onTileHit(tile);
				});
			} else {
				player.checkTiles(tile_group);

				tile_group.forEachAlive((tile:ArrowTile) ->
				{
                    if (Conductor.instance.current_steps > tile.tile.step - 1 && !tile.tile.checked){
                        tile.tile.checked = true;
						player.onHitPropertyChange(tile.tile, 0, false);
                    }
				});

				FlxG.watch.addQuick("Player Current Step: ", player.currentStep);
				FlxG.watch.addQuick("Player Current Direction: ", player.direction);
				FlxG.watch.addQuick("Player Next Step: ", player.nextStep);
				FlxG.watch.addQuick("Player Next Direction: ", player.nextDirection);
			}


		}
		super.update(elapsed);
		scripts.executeFunc("postUpdate", [elapsed]);
	}

	
}
