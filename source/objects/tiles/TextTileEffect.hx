package objects.tiles;

class TextTileEffect extends FlxText
{
    public var target:FlxSprite;
    public var xOffset:Float = 0;
    public var yOffset:Float = 0;
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        x = target.x + xOffset;
        y = target.y + yOffset;
    }
}