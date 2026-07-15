package lt.states;

import openfl.geom.Matrix;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import lt.graphics.shaders.ShadowShader;
import openfl.filters.ShaderFilter;
import lt.backend.Lyrics;
import lt.substates.PauseSubstate;
import lt.objects.play.Tile;
import lt.objects.play.TimingDisplay;
import flixel.ui.FlxBar;
import lt.backend.MapData.MapAsset;
import lt.objects.play.Player;
import lt.objects.play.GameplayStage;

class PlayState extends State {
    /**
     * Current active instance of PlayState.
     */
    public static var instance:PlayState;

    /**
	 * Current song's name.
	 */
	public var songName:String = "Tutorial";
    /**
     * Background camera, used by Backgrounds.
     * Lowest layer over everything.
     */
    public var bgCamera:FlxCamera;

    /**
	 * Gameplay camera, shortcut to `FlxG.camera`.
	 */
	public var gameCamera:FlxCamera;
	
	/**
	 * HUD Camera, has the highest layer.
	 */
	public var hudCamera:FlxCamera;

    public var shadowShader:ShadowShader;

    public var stage:GameplayStage;
    public var camFollow:FlxObject;
    public var player:Player;

    public var timeBar:FlxBar;
    public var timeTextLeft:Text;
    public var songText:Text;
    public var timeTextRight:Text;

    public var lyricsOverlay:Text;
    public var lyricsList:Lyrics;

    public var timing:TimingDisplay;
    public var playerText:Text;

    public var score:Int = 0;
    public var combo:Int = 0;

    public var playbackRate:Float = 1;
    public var paused:Bool = false;

    public var previewSprite:FlxSprite;

    public function new(?song:String) {
        super();
        songName = song ?? "Tutorial";
    }
    override function create() {
        instance = this;
        Conductor.instance.time = 0;

        bgCamera = new FlxCamera();
		
        gameCamera = new FlxCamera();
        gameCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.reset(gameCamera);

        FlxG.cameras.insert(bgCamera, FlxG.cameras.list.indexOf(gameCamera), false);
		hudCamera = new FlxCamera();
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCamera, false);

        FlxG.camera = gameCamera;

        inline function __i(cam:FlxCamera){
            return '${FlxG.cameras.list.indexOf(cam)} // ';
        }
        trace(__i(bgCamera) + __i(gameCamera) + __i(hudCamera));

        //shadowShader = new ShadowShader();
        //gameCamera.filters = [new ShaderFilter(shadowShader)];
        //hudCamera.filters = [new ShaderFilter(shadowShader)];
        

        stage = new GameplayStage(this);
        stage.generateTiles(loadSong(songName));
        stage.onTileHit.add(onTileHit);
        stage.onTileMiss.add(onTileMiss);
        player = stage.player;
        add(stage);
        
        initHUD();

        camFollow = new FlxObject(player.x, player.y - 100, 1, 1);
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON);
        super.create();

        //ok
        //cameraBitmap = new BitmapData(FlxG.camera.width, FlxG.camera.height);
        //previewSprite = new FlxSprite().loadGraphic(cameraBitmap);
        //previewSprite.scrollFactor.set();
        //previewSprite.cameras = [hudCamera];
        //add(previewSprite);
    }

    var cameraBitmap:BitmapData;

    inline function initHUD() {
        inline function makeText(nX:Float,nY:Float,label:String, size:Int, ?bold:Bool = false, ?align:FlxTextAlign):Text {
			var obj:Text = new Text(nX, nY, label, size, align, bold);
			obj.cameras = [hudCamera];
			obj.active = false;
			return obj;
		}

		// Time Bar lt.objects. //
		timeBar = new FlxBar(0,0,LEFT_TO_RIGHT, FlxG.width,5,null,"",0,1,false);
		timeBar.numDivisions = 2000; // uhhh
		timeBar.createFilledBar(0x00000000, 0xFFFFFFFF);
		timeBar.cameras = [hudCamera];
		add(timeBar);
		
		var startY:Float = timeBar.y + timeBar.height + 5;

		timeTextLeft = makeText(10, startY, "", 12, false, LEFT);
		add(timeTextLeft);

        songText = makeText(FlxG.width*0.5, startY, songName.toUpperCase(), 12, false, LEFT);
        songText.x -= songText.width*0.5;
        add(songText);

		timeTextRight = makeText(FlxG.width, startY, "", 12, false, LEFT);
		timeTextRight.x -= timeTextRight.width;
		add(timeTextRight);

        playerText = makeText(10, 0, "", 12, false, LEFT);
		add(playerText);

        lyricsList = Lyrics.fromSong(songName);
        lyricsOverlay = makeText(0,FlxG.height - 120,"", 20, false, CENTER);
        lyricsOverlay.applyUIFont();
        lyricsOverlay.fieldWidth = FlxG.width * 0.7;
        lyricsOverlay.screenCenter(X);
		add(lyricsOverlay);

        timing = new TimingDisplay();
        timing.y = FlxG.height - 25;
        timing.cameras = [hudCamera];
        add(timing);
    }

    function loadSong(_song:String) {
        var mapAsset:MapAsset = Assets.map(_song);
        FlxG.sound.playMusic(mapAsset.audio, 0.7, false);
		FlxG.sound.music.time = 0;
        FlxG.sound.music.pitch = playbackRate;
        FlxG.sound.music.onComplete = () -> {
            Utils.switchState(new MenuState(), PhraseManager.getPhrase("Leaving Gameplay"));
        }
		FlxG.sound.music.pause();
        Conductor.instance.updateBPM(mapAsset.map.bpm);
        return mapAsset.map;
    }

    public var started:Bool = false;

    override function update(elapsed:Float) {
        super.update(elapsed);
		if (FlxG.keys.justPressed.SPACE && !started) {
            stage.start();
            FlxG.sound.music.play();
			started = true;
        }

		if ((FlxG.keys.justReleased.ESCAPE || FlxG.keys.justReleased.BACKSPACE) && started)
            pauseGame();

        if (FlxG.keys.justPressed.B) 
            stage.autoplay = !stage.autoplay;

        //camFollow.x = player.getMidpoint().x;
        //camFollow.y = player.getMidpoint().y;
        camFollow.x = FlxMath.lerp(player.getMidpoint().x, camFollow.x, 1 - (elapsed * 12));
        camFollow.y = FlxMath.lerp(player.getMidpoint().y, camFollow.y, 1 - (elapsed * 12));

        timeBar.percent = (Conductor.instance.time / FlxG.sound.music.length) * 100;
        timeTextLeft.text = Utils.formatMS(Conductor.instance.time);
        timeTextRight.text = Utils.formatMS(FlxG.sound.music.length);
        timeTextRight.x = FlxG.width - (timeTextRight.width + 10);

        playerText.updateHitbox();
        playerText.setPosition(10, FlxG.height - (playerText.height + 10));

        FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, elapsed*12);

        lyricsOverlay.text = lyricsList.getLyric(Conductor.instance.time);

        //no work :(

        //previewSprite.graphic.bitmap.draw(gameCamera.canvas);
        //if (previewSprite != null) {
        //    previewSprite.scale.set(0.4,0.4);
        //    previewSprite.updateHitbox();
        //    previewSprite.setPosition(FlxG.width - previewSprite.width, (FlxG.height - previewSprite.height) * 0.5);    
        //}
    }

    override function closeSubState() {
        super.closeSubState();
        unpauseGame();
    }

    public function pauseGame() {
        if (paused) return;
        paused = stage.paused = true;
        FlxG.sound.music.pause();
        openSubState(new PauseSubstate(this));
    }

    public function unpauseGame() {
        if (!paused) return;
        paused = stage.paused = false;
        FlxG.sound.music.play();
    }

    public function onTileHit(tile:Tile) {
        timing.addBar(tile.time - Conductor.instance.time);
        combo++;
        FlxG.camera.zoom += 0.02;
        updatePlayerText();
    }
    public function onTileMiss(tile:Tile) {
        combo = 0;
        updatePlayerText("MISSED");
    }

    var _tween:FlxTween;
    public function updatePlayerText(rating:String = "PERFECT!") {
        playerText.text = '$rating\n${combo}x';

        playerText.scale.set(1.2,1.2);
        playerText.updateHitbox();
        playerText.setPosition(10, FlxG.height - (playerText.height + 10));
        if (_tween!=null) _tween.cancel();

        _tween = FlxTween.tween(playerText.scale, {x:1,y:1}, 0.2, {onUpdate: (_)->{
            playerText.updateHitbox();
        },onComplete: (_)->{
            _tween = null;
        }});
    }
}