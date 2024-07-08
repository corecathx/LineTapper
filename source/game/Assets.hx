package game;

import flixel.graphics.FlxGraphic;
import game.MapData.LineMap;
import lime.graphics.Image;
import openfl.display.BitmapData;
import openfl.media.Sound;
import sys.FileSystem;
import sys.io.File;

typedef MapAsset =
{
	var audio:Sound;
	var map:LineMap;
}

/**
 * Helper class for this game's assets.
 */
class Assets
{
	/** Path to asset folders, modify only if necessary. **/
	inline public static var _ASSET_PATH:String = "./assets";

	inline public static var _DATA_PATH:String = '$_ASSET_PATH/data';
	inline public static var _FONT_PATH:String = '$_DATA_PATH/fonts';
	inline public static var _MAP_PATH:String = '$_DATA_PATH/maps';

	inline public static var _IMAGE_PATH:String = '$_ASSET_PATH/images';
	inline public static var _SOUND_PATH:String = '$_ASSET_PATH/sounds';

	/** Trackers for loaded assets. **/
	public static var loaded_images:Map<String, Bool> = new Map();

	public static var loaded_sounds:Map<String, Sound> = new Map();

	/**
	 * Unloads all loaded images.
	 */
	public static function unloadImages()
	{
		for (key in loaded_images.keys())
		{
			var graphic:FlxGraphic = FlxG.bitmap.get(key);
			if (graphic == null)
				continue;

			if (graphic.bitmap != null)
				graphic.bitmap.dispose();

			graphic.destroy();
			FlxG.bitmap.removeByKey(key);
		}

		loaded_images.clear();
		openfl.utils.Assets.cache.clear();
	}

	/**
	 * Loads a font file.
	 * @param name Your font's file name (without .ttf extension)
	 * @return Font
	 */
	public static function font(name:String)
	{
		var path:String = '$_FONT_PATH/$name.ttf';

		if (!FileSystem.exists(path))
			return null;

		return path;
	}

	/**
	 * Returns an image file from `./assets/images/`, Returns null if the `path` does not exist.
	 * @param file Image file name
	 * @return FlxGraphic (Warning: might return null)
	 */
	public static function image(file:String):FlxGraphic
	{
		var path:String = '$_IMAGE_PATH/$file.png';

		if (!FileSystem.exists(path))
			return null;

		if (loaded_images.exists(file))
			return FlxG.bitmap.get(file);

		var data:Image = Image.fromFile(path);
		var newBitmap:BitmapData = BitmapData.fromImage(data);
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, file);
		newGraphic.persist = true;

		var n:FlxGraphic = FlxG.bitmap.addGraphic(newGraphic);
		loaded_images.set(file, true);

		return n;
	}

	/**
	 * Returns MapAsset containing audio and map data.
	 * Returns null if the map folder does not exist.
	 * @param song Song's name.
	 * @return MapAsset (Warning: might return null)
	 */
	public static function map(song:String):MapAsset
	{
		var path:String = '$_MAP_PATH/$song';

		if (!FileSystem.exists(path))
			return null;

		var soundPath:String = '$path/audio.ogg';
		var mapPath:String = '$path/map.json';

		var mAsset:MapAsset = {
			audio: null,
			map: null
		};

		mAsset.audio = _sound_file(soundPath);

		if (FileSystem.exists(mapPath))
			mAsset.map = MapData.loadMap(File.getContent(mapPath));

		return mAsset;
	}

	/**
	 * Returns a sound file
	 * @param path Sound's file name (without extension)
	 * @return Sound
	 */
	inline public static function sound(name:String):Sound
		return _sound_file('$_SOUND_PATH/$name.ogg');

	/**
	 * [INTERNAL] Loads a sound file
	 * @param path Path to the sound file
	 * @return Sound
	 */
	public static function _sound_file(path:String):Sound
	{
		if (!FileSystem.exists(path))
			return null;

		if (!loaded_sounds.exists(path))
			loaded_sounds.set(path, Sound.fromFile(path));

		return loaded_sounds.get(path);
	}
}