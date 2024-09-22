package game.backend.utils;

class ShapeUtil{
    public static function makeHollowRect(?x:Float = 0, ?y:Float = 0, ?width:Int = 50, ?height:Int = 50, ?graphicSizeX:Float = 50, ?graphicSizeY:Float = 50, ?color:FlxColor = 0xFFFFFFFF, ?hollowPercent:Float = 0.95):Shape{
        var shape = new Shape(x, y);
        shape.makeGraphic(width, height, color);
        shape.setGraphicSize(graphicSizeX, graphicSizeY);
		shape.updateHitbox();
        shape.hollowPercent = hollowPercent;
        return shape;
    }
    
    public static function addHollowRectToShape(?shape:Shape = null, ?x:Float = 0, ?y:Float = 0, ?width:Int = 50, ?height:Int = 50, ?graphicSizeX:Float = 50, ?graphicSizeY:Float = 50, ?color:FlxColor = 0xFFFFFFFF, ?hollowPercent:Float = 0.95):Shape{
        if (shape != null){
            shape.makeGraphic(width, height, color);
            shape.setGraphicSize(graphicSizeX, graphicSizeY);
		    shape.updateHitbox();
            shape.hollowPercent = hollowPercent;
            return shape;
        }
        return null;
    }
}