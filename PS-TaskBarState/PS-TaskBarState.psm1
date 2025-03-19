# This function toggles the Windows Taskbar Auto-Hide state.
# Inspired by the following post: https://www.elevenforum.com/t/enable-or-disable-automatically-hide-taskbar-in-windows-11.414/post-449345
function Invoke-TaskBarState {
    [cmdletBinding()]
    $Source=@"
using System;
using System.Runtime.InteropServices;
public class TaskBar {
    [DllImport("shell32.dll")]
    public static extern IntPtr SHAppBarMessage(uint dwMessage, ref APPBARDATA pData);
    public const uint ABM_GETSTATE = 0x00000004;
    public const uint ABM_SETSTATE = 0x0000000A;
    public const uint ABS_AUTOHIDE = 0x00000001;
    public const uint ABS_ALWAYSONTOP = 0x00000002;
    
    [StructLayout(LayoutKind.Sequential)]
    public struct APPBARDATA { 
        public uint cbSize;
        public IntPtr hWnd;
        public uint uCallbackMessage;
        public uint uEdge;
        public RECT rc;
        public IntPtr lParam;
    };
    
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int left;
        public int top;
        public int right;
        public int bottom;
    }
    
    public static void SetTaskBarState() {
        APPBARDATA abd = new APPBARDATA();
        abd.cbSize = (uint)Marshal.SizeOf(abd);
        IntPtr uState = SHAppBarMessage(ABM_GETSTATE, ref abd);
        IntPtr param = (IntPtr)((ulong)uState & ABS_ALWAYSONTOP);
        if (((ulong)uState & ABS_AUTOHIDE) != 0)
        {
            abd.lParam = param;
        }
        else
        {
        abd.lParam = (IntPtr)((ulong)ABS_AUTOHIDE | (ulong)param);
        }
        SHAppBarMessage(ABM_SETSTATE, ref abd);
    }
}
"@
    Add-Type -TypeDefinition $Source
    [TaskBar]::SetTaskBarState()
}