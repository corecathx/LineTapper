package game;

import objects.ArrowTile.TileColorData;
import haxe.Json;
import openfl.media.Sound;
import game.backend.Lyrics;
typedef MapAsset =
{
	var audio:Sound;
	var map:LineMap;
    var lyrics:Lyrics;
}
typedef TileData = {
    var step:Int;
    var direction:Int;
}
typedef Theme = {
    var tileColorData:TileColorData;
    var bg:String;
}
typedef LineMap = {
    var tiles:Array<TileData>;
    var theme:Theme;
    var bpm:Float;
}

class MapData {
    public static function loadMap(rawJson:String):LineMap {
        return cast Json.parse(rawJson);
    }
}