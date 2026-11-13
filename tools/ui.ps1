# Helper de automatizacion de la consola VMware (host Windows)
Add-Type -AssemblyName System.Drawing, System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class UI {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h,int c);
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint f,uint dx,uint dy,uint d,IntPtr e);
  [DllImport("user32.dll")] public static extern void keybd_event(byte vk,byte sc,uint f,IntPtr e);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr dc, uint flags);
  public struct RECT { public int L,T,R,B; }
}
"@
$script:VMW = Get-Process vmware | Select-Object -First 1

function Get-VMWindow {
  $script:VMW.Refresh()
  return $script:VMW.MainWindowHandle
}
function Focus-VMware {
  $h = Get-VMWindow
  [UI]::ShowWindow($h, 9) | Out-Null
  Start-Sleep -Milliseconds 400
  [UI]::SetForegroundWindow($h) | Out-Null
  Start-Sleep -Milliseconds 600
  return $h
}
function Click-At([int]$x,[int]$y) {
  [UI]::SetCursorPos($x,$y) | Out-Null
  Start-Sleep -Milliseconds 150
  [UI]::mouse_event(0x0002,0,0,0,[IntPtr]::Zero)
  Start-Sleep -Milliseconds 60
  [UI]::mouse_event(0x0004,0,0,0,[IntPtr]::Zero)
  Start-Sleep -Milliseconds 250
}
function Send-WinKey([byte]$vk) {
  [UI]::keybd_event(0x5B,0,0,[IntPtr]::Zero)
  Start-Sleep -Milliseconds 80
  [UI]::keybd_event($vk,0,0,[IntPtr]::Zero)
  Start-Sleep -Milliseconds 60
  [UI]::keybd_event($vk,0,2,[IntPtr]::Zero)
  [UI]::keybd_event(0x5B,0,2,[IntPtr]::Zero)
  Start-Sleep -Milliseconds 400
}
function Send-Text([string]$t) {
  [System.Windows.Forms.SendKeys]::SendWait($t)
  Start-Sleep -Milliseconds 250
}
function Save-VMScreen([string]$path) {
  $h = Get-VMWindow
  $r = New-Object UI+RECT
  [UI]::GetWindowRect($h,[ref]$r) | Out-Null
  $w = $r.R - $r.L; $hh = $r.B - $r.T
  $bmp = New-Object Drawing.Bitmap $w,$hh
  $g = [Drawing.Graphics]::FromImage($bmp)
  $dc = $g.GetHdc()
  [UI]::PrintWindow($h,$dc,2) | Out-Null
  $g.ReleaseHdc($dc); $g.Dispose()
  $bmp.Save($path,[Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  return $path
}
