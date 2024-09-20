package game.backend;

class StateBase extends FlxState {
    var _defaultCamera:FlxCamera;
    var _transIn:Bool = false;
    var _transText:String = "";
    public function new(?transInEnabled:Bool = true, ?trans_name:String = "") {
        super();
        _transIn = transInEnabled;
        _transText = trans_name;

        _defaultCamera = new FlxCamera();
        FlxG.cameras.reset(_defaultCamera);
        initTransIn();
    }

    function initTransIn():Void {
        if (!_transIn) return; 
        var _transCam:FlxCamera = new FlxCamera();
        _transCam.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(_transCam, false);
        

        var _tr_bg:FlxSprite = new FlxSprite().loadGraphic(Assets.image("ui/transition"));
        _tr_bg.cameras = [_transCam];
        add(_tr_bg);
        
        var _tr_text:FlxText = new FlxText(0,0,-1,_transText,30);
        _tr_text.setFormat(Assets.font("extenro-bold"));
        add(_tr_text);
    }
}