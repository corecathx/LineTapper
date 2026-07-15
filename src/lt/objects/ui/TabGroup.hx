package lt.objects.ui;

import flixel.group.FlxSpriteGroup;

class TabGroup extends Panel {
    public var tabs:Array<TabsUI> = [];
    public var currentIndex:Int = 0;
    public var group:FlxSpriteGroup;
    public function new(nX:Float, nY:Float, nWidth:Float, nHeight:Float) {
        super(nX, nY, nWidth, nHeight);
        sliceRect = new FlxRect(5, 0, 20, 20);
        sourceRect = new FlxRect(0, 5, 30, 30);

        group = new FlxSpriteGroup();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        group.update(elapsed);
    }

    override function draw():Void {
        super.draw();
        
        group.cameras = cameras;
        for (i in group.members) {
            if (i == null) {
                group.members.remove(i);
                continue;
            }
            i.cameras = cameras;
        }
        var intendedWidth:Float = width / tabs.length;
        for (index => i in tabs){
            i.cameras = cameras;
            i.current = index == currentIndex;
            i.setSize(
                intendedWidth,
                FlxMath.lerp(i.height, i.current ? 25 : 20, FlxG.elapsed * 12)
            );
            i.setPosition(
                x + (intendedWidth * index),
                y - i.height,
            );

            if (FlxG.mouse.overlaps(i, i.cameras[0]) && FlxG.mouse.justReleased) {
                currentIndex = index;
                updateGroup();
            }

            i.draw();
        }

        group.setPosition(x+10,y+10);
        group.draw();
    }

    public function updateGroup() {
        for (i in group.members) {
            i.kill();
            group.remove(i);
            i.destroy();
        }
        group.clear();
        var current:TabsUI = tabs[currentIndex];
        if (current == null) return;

        //trace("Creating: " +current.name);
        current.callback(group);
    }

    public function add(name:String, callback:FlxSpriteGroup->Void) {
        var tab:TabsUI = new TabsUI(name,callback);
        tabs.push(tab);
        updateGroup();
    }
}

class TabsUI extends Panel {
    public var callback:FlxSpriteGroup->Void = (_)->{};
    public var label:Text;
    public var name(get,set):String;
    public var current:Bool = false;

    public function new(name:String,callback:FlxSpriteGroup->Void) {
        super(0,0, 20, 20);
        if (callback != null)
            this.callback = callback;
        sliceRect = new FlxRect(5, 5, 20, 20);
        sourceRect = new FlxRect(0, 0, 30, 25);

        label = new Text(0, 0, name, 13, CENTER);
        label.applyUIFont();
    }

    override function draw():Void {
        super.draw();
        
        label.setPosition(
            x + (width - label.width) * 0.5,
            y + (height - label.height) * 0.5
        );
        label.alpha = current ? 1 : 0.6;
        label.cameras = cameras;
        label.draw();
    }

    function get_name():String 
        return label?.text;
    
    function set_name(v:String):String 
        return label.text = v;
}