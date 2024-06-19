package game;

import flixel.util.FlxSignal;

class Conductor {
    /** Currently active Conductor object **/
    public static var current:Conductor;

    /** Current song time / position **/
    public var time(default,set):Float = 0;

    /** Tracker for current beats **/
    public var current_beats:Int = 0;

    /** Tracker for current steps **/
    public var current_steps:Int = 0;

    /** Current BPM, change it using `updateBPM` **/
    public var bpm:Float = 120;

    /** Single beat in miliseconds **/
    public var beat_ms:Float = 500;

    /** Single step in miliseconds **/
	public var step_ms:Float = 125;

    /** Will be called on each beat tick changes. **/
    public var onBeatTick:FlxSignal;

    /** Will be called on each step tick changes. **/
    public var onStepTick:FlxSignal;

    // Internals used by this class. //
    private var _last_beats:Int = 0;
    private var _last_steps:Int = 0;

    /**
     * Initializes new Conductor object.
     */
    public function new(assign:Bool = true) {
        if (assign) current = this;
        updateBPM(120); // By default, it'll set this to 120.

        onBeatTick = new FlxSignal();
        onStepTick = new FlxSignal();
    }

    /**
     * Changes current bpm to `newBPM`.
     * @param newBPM New BPM to set.
     */
    public function updateBPM(newBPM:Float = 120) {
        bpm = newBPM;
        beat_ms = ((60 / bpm) * 1000);
        step_ms = beat_ms / 4;
    }

    /** get_ and set_ functions and other internal stuffs down here **/

    /**
     * Updates this conductor's time as well as updating current beats and steps.
     * @param nTime 
     * @return Float
     */
    private function set_time(nTime:Float):Float {
        current_steps = Std.int(time / step_ms);
        current_beats = Std.int(current_steps / 4);

        _checkTicks();
        return time = nTime;
    }

    private function _checkTicks() {
        if (_last_beats != current_beats) {
            onBeatTick.dispatch();
            _last_beats = current_beats;
        }

        if (_last_steps != current_steps) {
            onStepTick.dispatch();
            _last_steps = current_steps;
        }
    }
}