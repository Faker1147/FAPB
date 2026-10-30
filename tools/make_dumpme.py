#!/usr/bin/env python3
"""Create a 'dump-me' copy of the original UPX-packed YAPB DLL.

The UPX stub decompresses the image and then jumps to the original entry
point (OEP = 0x1004437B).  For an unpacking dump we do not want YAPB's
DllMain to run, so the final jump in the stub is replaced with:

    mov eax, 1
    ret 0xC

This lets Windows load the DLL, run the UPX decompressor, apply the
original relocations, and return from DllMain without initialising the
plugin.  The result is a clean, unmodified image in memory.

Run this once, then use dump32.ps1 twice (normal + base-blocked) to
produce yapb_b1.bin / yapb_b2.bin.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "tools" / "artifacts"

# File offset of the stub's final "jmp 0x1004437B" instruction.
# UPX1 raw data starts at file offset 0x400, RVA 0x97000.
PATCH_OFFSET = 0x2C4F4
ORIGINAL = bytes.fromhex("e98212f8ff000000")
PATCH = bytes.fromhex("B801000000C20C00")


def main() -> None:
    src = ART / "yapb.dll"
    dst = ART / "yapb_dumpme.dll"
    data = bytearray(src.read_bytes())
    if data[PATCH_OFFSET:PATCH_OFFSET + len(ORIGINAL)] != ORIGINAL:
        raise SystemExit(
            f"unexpected bytes at 0x{PATCH_OFFSET:X}: "
            f"{data[PATCH_OFFSET:PATCH_OFFSET + 8].hex()}"
        )
    data[PATCH_OFFSET:PATCH_OFFSET + len(PATCH)] = PATCH
    dst.write_bytes(data)
    print(f"wrote {dst} ({len(data)} bytes)")


if __name__ == "__main__":
    main()
