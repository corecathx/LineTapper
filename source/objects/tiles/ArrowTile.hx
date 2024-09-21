package objects.tiles;

import flixel.group.FlxGroup;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import game.Utils.RGB;
import objects.Player.PlayerDirection;

/**
 * Arrow Tile colors from the map.
 */
 typedef TileColorData = {
	var zero:RGB;
	var one:RGB;
	var two:RGB;
	var three:RGB;
	var fallback:RGB;
}

/**
 * Arrow Tile group, used during gameplay to display multiple objects linked to the main ArrowTileSpr.
 */
class ArrowTile extends FlxGroup {
    public var tile:ArrowTileSpr;
    public var squareTileEffect:SquareArrowTileEffect;
    public function new(nX:Float, nY:Float, dir:PlayerDirection, curStep:Int, ?tileColorData:TileColorData){
        super();
        tile = new ArrowTileSpr(nX, nY, dir, curStep, this, tileColorData);
        add(tile);
        squareTileEffect = new SquareArrowTileEffect(nX, nY, tile, 5);
        add(squareTileEffect);
    }
    public function onTileHit(?rating:String = 'PERFECT') {
        tile.onTileHit();

        // Tween based on properties instead of a set value. Just a way to make sure custom things like modcharts won't break.
        FlxTween.tween(tile, {"scale.x": tile.scale.x + tile.scale.x/2.5, "scale.y": tile.scale.y + tile.scale.y/2.5, angle: tile.angle + 70, alpha: 0}, 0.5, {ease: FlxEase.quadOut});
        FlxTween.tween(squareTileEffect, {"scale.x": tile.scale.x + 1.7, "scale.y": tile.scale.y + 1.7, alpha: 0}, 0.5, {ease: FlxEase.quadOut});
        new FlxTimer().start(0.25, function(t){
            FlxFlicker.flicker(squareTileEffect, 0.25, 0.02);
        });
        new FlxTimer().start(0.5, function(t){
            remove(squareTileEffect);
            squareTileEffect.kill();
            squareTileEffect = null;
        });
        var rTxt = new FlxText(tile.x, tile.y + tile.verticalTextOffset, 0, rating);
        rTxt.setFormat(Assets.font("extenro-bold"), 10, FlxColor.CYAN, CENTER, OUTLINE, FlxColor.WHITE);
        rTxt.borderSize = 0.5;
        rTxt.updateHitbox();
        add(rTxt);
        new FlxTimer().start(0.25, function(t){
            FlxFlicker.flicker(rTxt, 0.25, 0.02, false, true, function(e){
                remove(rTxt);
                rTxt.kill();
                rTxt = null;
            });
        });
    }
    public function onTileMiss() {
        tile.onTileMiss();
        FlxTween.tween(tile, {"scale.x": tile.scale.x - tile.scale.x/2.5, "scale.y": tile.scale.y - tile.scale.y/2.5, angle: tile.angle - 10, alpha: 0}, 0.5, {ease: FlxEase.quadIn});
        FlxTween.tween(squareTileEffect, {"scale.x": tile.scale.x - tile.scale.x/2.5, "scale.y": tile.scale.y - tile.scale.y/2.5, angle: -10, alpha: 0}, 0.5, {ease: FlxEase.quadIn});
        new FlxTimer().start(0.5, function(t){
            remove(squareTileEffect);
            squareTileEffect.kill();
            squareTileEffect = null;
        });
        var mTxt = new FlxText(tile.x, tile.y + tile.verticalTextOffset, 0, 'MISS');
        mTxt.setFormat(Assets.font("extenro-bold"), 10, 0xFFAA0000, CENTER, OUTLINE, FlxColor.WHITE);
        mTxt.borderSize = 0.5;
        mTxt.updateHitbox();
        add(mTxt);
        new FlxTimer().start(0.25, function(t){
            FlxFlicker.flicker(mTxt, 0.25, 0.02, false, true, function(e){
                remove(mTxt);
                mTxt.kill();
                mTxt = null;
            });
        });
    }
}