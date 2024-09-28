package game;

import objects.tiles.ArrowTile;
import haxe.Json;
import openfl.media.Sound;
import game.backend.Lyrics;
typedef MapAsset =
{
	var audio:Sound;
	var map:LineMap;
    var lyrics:Lyrics;
}
enum MapVersion { // (1 = 1.0, 15 = 1.5, 27 = 2.7, etc...)
    ALPHA1; // 1.0-alpha
    LEGACY; // The first linemap version
}
typedef TileData = {
    var step:Int;
    var direction:Int;
}
@:allow(MapData)
private typedef TempMapTheme = {
    var tileColorData:MapTileColorData;
    var ?bgType:String;
    var ?scaleX:Float;
    var ?scaleY:Float;
    var ?bg:String;
    var ?bgData:MapBackgroundData;
}
typedef MapTheme = {
    var tileColorData:MapTileColorData;
    var bgData:MapBackgroundData;
}
typedef MapBackgroundData = {
    var ?bgType:String;
    var ?scaleX:Float;
    var ?scaleY:Float;
    var ?alpha:Float;
    var ?bg:String;
}
@:allow(MapData)
private typedef TempLineMap = {
    var version:String;
    var ?mapVer:MapVersion;
    var tiles:Array<TileData>;
    var theme:TempMapTheme;
    var ?mapTheme:MapTheme;
    var bpm:Float;
}
typedef LineMap = {
    var versionStr:String;
    var version:MapVersion;
    var tiles:Array<TileData>;
    var theme:MapTheme;
    var bpm:Float;
}

class MapData {
    public static function loadMap(rawJson:String):LineMap {
        var map:TempLineMap = cast Json.parse(rawJson);
        //Set up the map version
        if (map.version != null){
            if (map.mapVer == null && map.version.startsWith('1.0-alpha'))
                map.mapVer = ALPHA1;

            if (map.mapVer == null){ // If none of the checks worked
                trace("This linemap version doesn't exist, defaulting to legacy mode. Did you make a typo?");
                map.mapVer = LEGACY;
            }
        }else{
            map.mapVer = LEGACY;
            trace("old ahh linemap");
        }

        //Set up the theme
        if (map.mapVer == LEGACY){
            var tempBgData:MapBackgroundData = {
                bgType: 'NONE',
                scaleX: 1,
                scaleY: 1,
                alpha: 0.45,
                bg: ''
            };
            map.theme = {
                tileColorData: Common.DEFAULT_TILE_COLOR_DATA,
                bgData: tempBgData
            }
        }else{
            if (map.theme.bgData == null){
                map.theme.bgData = {
                    bgType: map.theme.bgType,
                    scaleX: map.theme.scaleX,
                    scaleY: map.theme.scaleY,
                    alpha: 0.45,
                    bg: map.theme.bg
                };
            }
        }
        map.mapTheme = {
            tileColorData: map.theme.tileColorData,
            bgData: map.theme.bgData
        };
        var finalMap:LineMap = {
            versionStr: map.version,
            version: map.mapVer,
            tiles: map.tiles,
            theme: map.mapTheme,
            bpm: map.bpm
        }

        return finalMap;
    }
}