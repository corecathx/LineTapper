package game.backend.utils;

import game.native.NativeFunctions;
import cpp.Int32;

/**
 * Native helper class for Windows.
 * - CoreCat :]
 * 
 * This is meant to be used indirectly to call windows native functions.
 * It is indirect in order to further to help with Cross-Platform support.
 * - ZSolarDev :D
 */
class NativeUtil {
    /**
     * Returns current used memory in bytes for current platform.
     * If the platform is unsupported, it will return Garbage Collector memory.
     */
    public static function getUsedMemory():Float {
        #if windows
        return NativeFunctions.getCurrentUsedMemory();
        #else
        return openfl.system.System.totalMemory;
        #end
    }

    /**
     * Returns current free drive size in bytes.
     */
    public static function getCurrentDriveSize():Float {
        #if windows
        return NativeFunctions.getCurrentDriveSize();
        #else
        return 1.0;
        #end
    }

    /**
     * Returns current process CPU Usage.
     */
    public static function getCurrentCPUUsage():Float {
        #if windows
        return NativeFunctions.getCurrentCPUUsage();
        #else
        return 1.0;
        #end
    }



    /**
     * Creates a NativeFunctions Toast Notification.
     * @param title Toast title.
     * @param body Toast body / description.
     * @param res Icon res
     */
    public static function toast(title:String = "", body:String = "", res:Int = 0):Int
    {
        
        #if windows
        return NativeFunctions.toast(title, body, res);
        #else
        return 1;
        #end
    }

    /**
     * Allows the user to set the window title bar color. (WINDOWS 11 ONLY)
     * @param title Window title, do something like `lime.app.Application.current.window.title`.
     * @param targetColor This is a hex code that is in 0x00BBGGRR. Not RGB, but BGR.
     */
    public static function setWindowColor(title:String, targetColor:Int32) {
        #if windows
        NativeFunctions.setWindowColor(title, targetColor);
        #else
        trace("Unsupported platform! The window bars color remains unchanged.");
        #end
    }

    /**
     * Allows the user to switch between Dark Mode or Light Mode in the window.
     * @param title Window title, do something like `lime.app.Application.current.window.title`.
     * @param enable Whether to enable / disable Dark Mode.
     */
    public static function setWindowDarkMode(title:String, enable:Bool) {
        #if windows
        NativeFunctions.setWindowDarkMode(title, enable);
        #else
        trace("Unsupported platform! Dark mode property remains unchanged.");
        #end
    }

    /**
	 * Makes the process DPI Aware.
	 */
    public static function setDPIAware() {
        #if windows
        NativeFunctions.setDPIAware();
        #else
        trace("Unsupported platform! DPI Aware mode remains unchanged.");
        #end
    }
}