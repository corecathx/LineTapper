package game.backend;

typedef LyricsData = {
    var time:Float;
    var text:String;
}

class Lyrics {
    public var lyrics:Array<LyricsData> = [];

    public function new(?content:String) {
        if (content == null) 
            return;
        for (line in content.split('\n')) {
            var parsed:Array<String> = line.split("--");
            if (parsed.length > 1) {
                var time:Float = parseMS(parsed[0].trim());
                var text:String = parsed[1].trim();
                lyrics.push({time:time, text:text});
            }
        }
    }

    function parseMS(time:String):Float {
        var parts = time.split(":");
        if (parts.length == 2) {
            var minutes = Std.parseInt(parts[0]);
            var seconds = Std.parseInt(parts[1].split(".")[0]);
            var milliseconds = Std.parseInt(parts[1].split(".")[1]);
            return (minutes * 60 * 1000) + (seconds * 1000) + milliseconds;
        }
        return 0;
    }

    public function getLyric(time:Float):String {
        var latest:String = "";
        for (lyric in lyrics) 
            if (time >= lyric.time) latest = lyric.text;
        return latest;
    }
}
