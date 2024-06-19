package;

import flixel.FlxGame;
import game.Conductor;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var _conductor:Conductor;
	public function new()
	{
		super();
		_conductor = new Conductor();
		addChild(new FlxGame(0, 0, states.PlayState, 120,120,true,false));
		addChild(new objects.SystemInfo(10,10,0xFFFFFF,false));
		FlxG.fixedTimestep = FlxG.autoPause = false;
	}
}
