package;

import lime.app.Application;
import game.system.Game;
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

		Game.setDPIAware();

		addChild(new FlxGame(0, 0, states.IntroState, 120,120,true,false));
		addChild(new objects.SystemInfo(10,10,0xFFFFFF,false));
		FlxG.fixedTimestep = FlxG.autoPause = false;

		Game.setWindowDarkMode(Application.current.window.title, true);
	}
}
