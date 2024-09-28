package game.native;

import cpp.Int32;

/**
 * Native Windows Functions.
 * You aren't supposed to use this directly.
 * To use the functions, use NativeUtil.
 * - ZSolarDev :|
 */
@:buildXml('
<target id="haxe">
  <lib name="dwmapi.lib" if="windows" />
  <lib name="shell32.lib" if="windows" />
  <lib name="gdi32.lib" if="windows" />
  <lib name="ole32.lib" if="windows" />
  <lib name="uxtheme.lib" if="windows" />
</target>
')

@:cppFileCode('
#include <iostream>
#include <Windows.h>
#include <psapi.h>
#include <dwmapi.h>
#include <Shlobj.h>
#include <shellapi.h>
#include <cstdio>
#include <strsafe.h>

static float CalculateCPULoad(unsigned long long idleTicks, unsigned long long totalTicks)
{
   static unsigned long long _previousTotalTicks = 0;
   static unsigned long long _previousIdleTicks = 0;

   unsigned long long totalTicksSinceLastTime = totalTicks-_previousTotalTicks;
   unsigned long long idleTicksSinceLastTime  = idleTicks-_previousIdleTicks;

   float ret = 1.0f-((totalTicksSinceLastTime > 0) ? ((float)idleTicksSinceLastTime)/totalTicksSinceLastTime : 0);

   _previousTotalTicks = totalTicks;
   _previousIdleTicks  = idleTicks;
   return ret;
}

static unsigned long long FileTimeToInt64(const FILETIME & ft) {return (((unsigned long long)(ft.dwHighDateTime))<<32)|((unsigned long long)ft.dwLowDateTime);}

float GetCPULoad()
{
   FILETIME idleTime, kernelTime, userTime;
   return GetSystemTimes(&idleTime, &kernelTime, &userTime) ? CalculateCPULoad(FileTimeToInt64(idleTime), FileTimeToInt64(kernelTime)+FileTimeToInt64(userTime))*100.0f : -1.0f;
}
')


@:allow(game.backend.utils.NativeUtil)
class NativeFunctions
{
    ///////////////// SETTER FUNCTIONS /////////////////

    @:functionCode('
        int darkMode = enable ? 1 : 0;
        
        HWND window = FindWindowA(NULL, title.c_str());
        // Look for child windows if top level aint found
        if (window == NULL) window = FindWindowExA(GetActiveWindow(), NULL, NULL, title.c_str());
        
        if (window != NULL && S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
    ')
    private static function setWindowDarkMode(title:String, enable:Bool) {}

    @:functionCode('
        COLORREF COLOR = targetColor;
        
        HWND window = FindWindowA(NULL, title.c_str());
        // Look for child windows if top level aint found
        if (window == NULL) window = FindWindowExA(GetActiveWindow(), NULL, NULL, title.c_str());
        
        BOOL SET_CAPTION_COLOR = SUCCEEDED(DwmSetWindowAttribute(window, DWMWINDOWATTRIBUTE::DWMWA_CAPTION_COLOR, &COLOR, sizeof(COLOR)));
    ')
    private static function setWindowColor(title:String, targetColor:Int32) {}

	@:functionCode('
        SetProcessDPIAware();
    ')
	private static function setDPIAware(){}


    ///////////////// GETTER FUNCTIONS /////////////////

    @:functionCode('
        ULARGE_INTEGER freeBytesAvailableToCaller;
        ULARGE_INTEGER totalNumberOfBytes;
        ULARGE_INTEGER totalNumberOfFreeBytes;
    
        if (GetDiskFreeSpaceExA(NULL, &freeBytesAvailableToCaller, &totalNumberOfBytes, &totalNumberOfFreeBytes)) {
            double freeSpaceGB = static_cast<double>(freeBytesAvailableToCaller.QuadPart) / 1073741824;
            double totalSpaceGB = static_cast<double>(totalNumberOfBytes.QuadPart) / 1073741824;
        
            return freeSpaceGB;
        } else {
            DWORD errorCode = GetLastError();
            printf("oh no it failed, %d\\n", errorCode);
        }
    ')
    private static function getCurrentDriveSize():Float {
        return 0;
    }

    @:functionCode('
        PROCESS_MEMORY_COUNTERS info;
        GetProcessMemoryInfo(GetCurrentProcess(), &info, sizeof(info));
        return (size_t)info.WorkingSetSize;
    ')
    private static function getCurrentUsedMemory():Float{
        return 0.0;
    }

    @:functionCode('
        return GetCPULoad();
    ')
    private static function getCurrentCPUUsage():Float {
        return 0.0;
    }


    ///////////////// MISC FUNCTIONS /////////////////

    @:functionCode('
        NOTIFYICONDATA m_NID;

        memset(&m_NID, 0, sizeof(m_NID));
        m_NID.cbSize = sizeof(m_NID);
        m_NID.hWnd = GetForegroundWindow();
        m_NID.uFlags = NIF_MESSAGE | NIIF_WARNING | NIS_HIDDEN;

        m_NID.uVersion = NOTIFYICON_VERSION_4;

        if (!Shell_NotifyIcon(NIM_ADD, &m_NID))
            return FALSE;
    
        Shell_NotifyIcon(NIM_SETVERSION, &m_NID);

        m_NID.uFlags |= NIF_INFO;
        m_NID.uTimeout = 1000;
        m_NID.dwInfoFlags = NULL;

        LPCTSTR lTitle = title.c_str();
        LPCTSTR lDesc = body.c_str();

        if (StringCchCopy(m_NID.szInfoTitle, sizeof(m_NID.szInfoTitle), lTitle) != S_OK)
            return FALSE;

        if (StringCchCopy(m_NID.szInfo, sizeof(m_NID.szInfo), lDesc) != S_OK)
            return FALSE;

        return Shell_NotifyIcon(NIM_MODIFY, &m_NID);
    ')
    private static function toast(title:String = "", body:String = "", res:Int = 0)    // TODO: Linux (found out how to do it so ill do it soon)
    {
        return res;
    }
}