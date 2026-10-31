# FAPB installer for Counter-Strike 1.6 (Metamod)
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\install_fapb.ps1
#   powershell -ExecutionPolicy Bypass -File .\install_fapb.ps1 -GameDir "D:\Games\CS1.6训练版V5"
#   powershell -ExecutionPolicy Bypass -File .\install_fapb.ps1 -KeepOtherBots
#
# This script works in two layouts:
#   1. inside the FAPB addon folder: ...\addons\fapb\install_fapb.ps1
#   2. at the package root next to a "fapb" folder
#
# By default it comments out other bot cores (YAPB, SYPB, PODBot, EBot,
# CSBot Enabler) and the duplicate AMXX binary-logging module, because
# loading more than one bot core at the same time crashes fapb.dll.

param(
    [string]$GameDir = "",
    [switch]$KeepOtherBots,
    [switch]$KeepYapb
)

$ErrorActionPreference = "Stop"

if (-not $GameDir) {
    $GameDir = Read-Host "CS 1.6 root folder (the folder that contains hl.exe)"
}
$GameDir = $GameDir.Trim().Trim('"')
$cstrike = Join-Path $GameDir "cstrike"

if (-not (Test-Path -LiteralPath (Join-Path $GameDir "hl.exe"))) {
    throw "hl.exe not found under: $GameDir"
}
if (-not (Test-Path -LiteralPath $cstrike)) {
    throw "cstrike folder not found: $cstrike"
}

# Find the FAPB payload: either this folder, or a sibling "fapb" folder.
$here = $PSScriptRoot
if (Test-Path -LiteralPath (Join-Path $here "dlls\fapb.dll")) {
    $src = $here
} elseif (Test-Path -LiteralPath (Join-Path $here "fapb\dlls\fapb.dll")) {
    $src = Join-Path $here "fapb"
} else {
    throw "Cannot find fapb\dlls\fapb.dll next to this script: $here"
}

$dst = Join-Path $cstrike "addons\fapb"
$srcFull = (Resolve-Path -LiteralPath $src).Path.TrimEnd('\')
$dstFull = [IO.Path]::GetFullPath($dst).TrimEnd('\')

if ($srcFull -ne $dstFull) {
    Write-Host "Installing FAPB files to: $dst"
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    Copy-Item -Path (Join-Path $src "*") -Destination $dst -Recurse -Force
} else {
    Write-Host "FAPB files are already in place: $dst"
}

$plugins = Join-Path $cstrike "addons\metamod\plugins.ini"
if (-not (Test-Path -LiteralPath $plugins)) {
    throw "Metamod plugins.ini not found: $plugins"
}

$backup = "$plugins.fapb.bak"
Copy-Item -LiteralPath $plugins -Destination $backup -Force
Write-Host "Backup: $backup"

$lines = Get-Content -LiteralPath $plugins
$out = New-Object System.Collections.Generic.List[string]
$disabledBots = 0
$hasAmxxMain = [bool]($lines | Where-Object { $_ -match '^\s*win32\s+addons[\\/]amxmodx[\\/]dlls[\\/]amxmodx_mm\.dll' })

foreach ($line in $lines) {
    if ($line -match '^\s*win32\s+addons[\\/]fapb[\\/]dlls[\\/]fapb\.dll') {
        continue
    }

    # Keep only ONE bot core. FAPB + YAPB/SYPB/PODBot/EBot/CSBot at the same
    # time corrupts the Metamod hook chain and crashes fapb.dll.
    if ($line -match '^\s*win32\s+addons[\\/](yapb|sypb|podbot|ebot|csbot_enabler)[\\/]') {
        if (-not $KeepOtherBots) {
            $out.Add("; " + $line)
            $disabledBots++
            continue
        }
    }

    if ($line -match '^\s*Enable this instead') {
        $out.Add("; " + $line)
        continue
    }

    # amxmodx_mm + amxmodx_bl_mm both loaded is also a conflict.
    if ($hasAmxxMain -and $line -match '^\s*win32\s+addons[\\/]amxmodx[\\/]dlls[\\/]amxmodx_bl_mm\.dll') {
        $out.Add("; " + $line)
        $disabledBots++
        continue
    }

    $out.Add($line)
}

$out.Add("win32 addons/fapb/dlls/fapb.dll")
Set-Content -LiteralPath $plugins -Value $out -Encoding ASCII

if ($disabledBots -gt 0) {
    Write-Warning "Disabled $disabledBots conflicting bot/AMXX line(s)."
    Write-Warning "Only one bot core (FAPB) is active. See $backup for the old file."
}
if ($KeepOtherBots) {
    Write-Warning "KeepOtherBots specified: other bot cores were left enabled."
    Write-Warning "Loading FAPB together with YAPB/SYPB/PODBot/EBot WILL crash the game."
}

$liblist = Join-Path $cstrike "liblist.gam"
if (Test-Path -LiteralPath $liblist) {
    $gl = Get-Content -LiteralPath $liblist -Raw
    if ($gl -notmatch 'metamod') {
        Write-Warning "liblist.gam does not appear to load Metamod."
        Write-Warning "Set: gamedll `"addons\metamod\dlls\metamod.dll`""
    }
}

Write-Host ""
Write-Host "FAPB installed."
Write-Host "Start the game/server, then check the console:"
Write-Host "  meta list"
Write-Host "  fapb version"
Write-Host "  fapb menu"
Write-Host ""
Write-Host "Native team menu: bind v `"fapb menu`""
Write-Host "Then press V -> 1 (team management)."
Write-Host ""
Write-Host "To switch back to YAPB: restore $backup or edit plugins.ini."
