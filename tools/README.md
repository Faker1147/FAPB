# FAPB build tools

These are the exact tools used to turn the original UPX-packed YAPB
2.55b DLL into `addon/dlls/fapb.dll`.

The original `yapb.zip` contained no C++ source, so the fork is done at
the binary level. The AI code is not edited; only strings and the PE
container are changed.

## Artifacts

| File | Purpose |
|---|---|
| `artifacts/yapb.dll` | original UPX-packed YAPB 2.55b DLL |
| `artifacts/yapb_dumpme.dll` | copy with the UPX stub patched to skip DllMain |
| `artifacts/yapb_b1.bin` | image dumped at preferred base `0x10000000` |
| `artifacts/yapb_b2.bin` | image dumped with `0x10000000` reserved (relocated) |
| `artifacts/*.bin.txt` | `base|size|entry` metadata from `dump32.ps1` |
| `artifacts/yapb-config/` | original YAPB configuration files |

## Requirements

- Windows (the target DLL is 32-bit x86)
- Python 3.10+
- 32-bit Windows PowerShell:
  `%WINDIR%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe`

Python packages: only the standard library is required for the build
scripts. The dump script uses .NET/Add-Type from PowerShell.

## Pipeline

```powershell
# 1. Patch the UPX stub so DllMain is skipped after decompression.
python tools/make_dumpme.py

# 2. Dump the loaded image at the preferred base.
%WINDIR%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -File tools\dump32.ps1 `
  -Dll tools/artifacts/yapb_dumpme.dll `
  -Out tools/artifacts/yapb_b1.bin -Block 0

# 3. Dump again with 0x10000000 reserved, forcing relocation.
%WINDIR%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -File tools\dump32.ps1 `
  -Dll tools/artifacts/yapb_dumpme.dll `
  -Out tools/artifacts/yapb_b2.bin -Block 1

# 4. Recover relocations, rebrand strings, rebuild the PE.
python tools/build_fapb.py

# 5. Regenerate fb_* configuration files.
python tools/make_configs.py
```

`build_fapb.py` prints the SHA256 of the rebuilt DLL. It should be:

```text
606e7a6ab8793553847bcbf2d5665d29edea0b3529eaca537d7e76de7b6e3553
```

## Why two dumps?

UPX replaces the original relocation table with its own small stub
relocation table. The unpacked image in memory is relocated, but the
on-disk relocation information for the original code is gone.

Dumping at two different load bases makes every base-dependent 32-bit
value change by exactly `base2 - base1`. `build_fapb.py` scans for those
values, writes a new `.reloc` section, and can therefore load the rebuilt
DLL at any base (including when AMXX occupies `0x10000000`).

## Notes

- `dump32.ps1` must run as a 32-bit process; the 64-bit PowerShell cannot
  load the 32-bit DLL (`ERROR_BAD_EXE_FORMAT`).
- The dump script writes a `.txt` sidecar with the actual load base. If
  you regenerate the dumps, keep the sidecars; `build_fapb.py` reads them.
- The `.data` section in the rebuilt PE is zero-filled; the original
  UPX1 packed area is intentionally discarded.
- `build_fapb.py` uses the original `.rsrc` from `yapb.dll`, not the
  dumped `.rsrc`, because the dump's IAT contains resolved kernel32
  addresses.
