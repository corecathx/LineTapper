package game;

import haxe.Json;

typedef TileData = {
    var step:Int;
    var direction:Int;
}
typedef LineMap = {
    var tiles:Array<TileData>;
    var bpm:Float;
}

class MapData {
	// Ignore please
    public static final TESTING_MAP:LineMap = {
        tiles: [ // starts down
            { step: 4, direction: 3 }, // right
            { step: 6, direction: 2 }, // up
            { step: 10, direction: 0 }, // left
            { step: 12, direction: 1 }, // down
            { step: 14, direction: 3 }, // right
            { step: 16, direction: 2 }, // up
        ],
        bpm: 159
    };
    public static function loadMap(rawJson:String):LineMap {
        return cast Json.parse(rawJson);
    }
}