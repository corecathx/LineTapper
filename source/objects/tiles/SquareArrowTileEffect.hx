package objects.tiles;

import game.Conductor;
import game.backend.utils.ShapeUtil;
import game.backend.utils.Shape;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * The square indicating when to hit an ArrowTile, a component of the ArrowTile group.
 */
class SquareArrowTileEffect extends Shape {
    public var tile:ArrowTileSpr;
    public var targetStepDist:Float = 5;
    public var stepDistSecs:Float = 0;
    var step_sec:Float = 0;
    var called:Bool = false;
    var stepDist:Float = 0;
    public function new(x:Float, y:Float, tile:ArrowTileSpr, ?targetStepDist:Float = 5) {
		super(x, y);
        this.tile = tile;
        this.targetStepDist = targetStepDist;

        //Make the square
        antialiasing = false;
        ShapeUtil.addHollowRectToShape(this, x, y, 50, 50, Player.BOX_SIZE, Player.BOX_SIZE);
        scale.x = 1.7;
        scale.y = 1.7;
        alpha = 0;

        //Initialize variables
        step_sec = Conductor.instance.step_ms / 1000;
        stepDistSecs = step_sec * (this.targetStepDist + 1);
    }

    public function runHitAnimation()
    {
        FlxTween.tween(this, {"scale.x": 1, "scale.y": 1}, stepDistSecs, {ease: FlxEase.quadIn});
    }

    override public function update(elapsed:Float){
        super.update(elapsed);
        color = tile.color;
        stepDist = Math.abs(Conductor.instance.current_steps - tile.step);
        alpha = tile.alpha;
        if (stepDist <= targetStepDist && !called){
            called = true;
            runHitAnimation();
        }
    }
}