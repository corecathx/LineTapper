package game.backend;

class TempFile {
    public var pathFromTemp(default, null):String = '';
    public var content:String = '';

    public function new(pathFromTemp:String, content:String){
        this.pathFromTemp = pathFromTemp;
        this.content = content;
        if (!FileSystem.exists('temp/')){
            FileSystem.createDirectory('temp/');
        }
        
        File.saveContent(pathFromTemp,content);
    }

    public function remove():Int{ //Returns an exit code.
        try{
            FileSystem.deleteFile('temp/$pathFromTemp');
        }catch(e)
        {
            return 1;
        }
        if (!FileSystem.exists('temp/'))
            FileSystem.deleteDirectory('temp/'); // Only empty directories are removed.

        return 0;
    }

    public function setContent(newContent:String)
    {
        content = newContent;
    }
}