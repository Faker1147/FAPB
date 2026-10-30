# Dump a loaded 32-bit DLL image to a flat file.
#
# This must run under 32-bit Windows PowerShell:
#   %WINDIR%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe
#
# Examples:
#   powershell -File tools/dump32.ps1 -Dll tools/artifacts/yapb_dumpme.dll -Out tools/artifacts/yapb_b1.bin -Block 0
#   powershell -File tools/dump32.ps1 -Dll tools/artifacts/yapb_dumpme.dll -Out tools/artifacts/yapb_b2.bin -Block 1
#
# -Block 1 reserves the DLL's preferred base (0x10000000) first, forcing
# Windows to relocate it.  Comparing the two dumps recovers every base
# relocation that the UPX stub applied, so the rebuilt PE can be loaded
# at any address.

param(
    [Parameter(Mandatory = $true)][string]$Dll,
    [Parameter(Mandatory = $true)][string]$Out,
    [int]$Block = 0
)

$ErrorActionPreference = "Stop"

if ([IntPtr]::Size -ne 4) {
    throw "Run this script with 32-bit PowerShell: $env:WINDIR\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
}

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class DumpNative
{
    [DllImport("kernel32", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern IntPtr LoadLibraryW(string path);

    [DllImport("kernel32", SetLastError = true)]
    public static extern IntPtr VirtualAlloc(IntPtr addr, UIntPtr size, uint type, uint protect);

    public static IntPtr ReservePreferredBase()
    {
        return VirtualAlloc((IntPtr)0x10000000, (UIntPtr)0x1000, 0x2000, 0x01);
    }

    public static byte[] ReadBytes(IntPtr addr, int size)
    {
        byte[] buf = new byte[size];
        Marshal.Copy(addr, buf, 0, size);
        return buf;
    }

    public static int ReadInt32(IntPtr addr, int offset)
    {
        return Marshal.ReadInt32(addr, offset);
    }
}
"@

$Dll = [IO.Path]::GetFullPath($Dll)
$Out = [IO.Path]::GetFullPath($Out)

if ($Block -eq 1) {
    $reserved = [DumpNative]::ReservePreferredBase()
    Write-Host ("RESERVE=0x{0:X8}" -f $reserved.ToInt64())
}

$h = [DumpNative]::LoadLibraryW($Dll)
$err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
Write-Host "HMODULE=$h ERR=$err"
if ($h -eq [IntPtr]::Zero) {
    throw "LoadLibraryW failed: $err"
}

$e = [DumpNative]::ReadInt32($h, 0x3C)
$size = [DumpNative]::ReadInt32($h, $e + 24 + 56)
$entry = [DumpNative]::ReadInt32($h, $e + 24 + 16)
$pref = [DumpNative]::ReadInt32($h, $e + 24 + 28)

Write-Host ("BASE=0x{0:X8} SIZE=0x{1:X} ENTRY=0x{2:X} PREF=0x{3:X8}" -f `
    $h.ToInt64(), $size, $entry, $pref)

$bytes = [DumpNative]::ReadBytes($h, $size)
[IO.File]::WriteAllBytes($Out, $bytes)
Set-Content -LiteralPath ($Out + ".txt") -Value ("{0}|{1}|{2}" -f $h.ToInt64(), $size, $entry)

Write-Host "DUMPED $($bytes.Length) to $Out"
