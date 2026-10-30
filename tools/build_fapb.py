#!/usr/bin/env python3
"""Build the FAPB DLL from the two unpacked YAPB memory dumps.

Inputs (tools/artifacts):
  yapb.dll             original UPX-packed YAPB 2.55b DLL
  yapb_b1.bin          image dumped at preferred base 0x10000000
  yapb_b2.bin          image dumped with 0x10000000 blocked (relocated)
  *.bin.txt            base|size|entry metadata from dump32.ps1

Output:
  addon/dlls/fapb.dll

The AI code is not touched.  Only these byte strings are renamed:
  YAPB / YaPB / Yapb / yapb   -> FAPB / FAPB / Fapb / fapb
  yb_* cvars                  -> fb_*
  standalone "yb" command     -> "fb"
  default name prefix |yb|    -> |fb|

The original relocation table was destroyed by UPX; diffing the two
dumps recovers every 32-bit address that changes with the load base.
Those offsets are written into a new .reloc section, so the rebuilt DLL
is fully relocatable.
"""
from __future__ import annotations

import hashlib
import struct
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "tools" / "artifacts"
OUT = ROOT / "addon" / "dlls"

IMAGE_BASE = 0x10000000
IMAGE_SIZE = 0xC6000
TEXT_RVA = 0x1000
TEXT_SIZE = 0x96000
RSRC_RVA = 0xC4000
RSRC_FILE_OFFSET = 0x2C600
RSRC_SIZE = 0x1A00
RELOC_RVA = 0xC6000

EXPECTED_SHA256 = "606e7a6ab8793553847bcbf2d5665d29edea0b3529eaca537d7e76de7b6e3553"


def align(value: int, alignment: int) -> int:
    return (value + alignment - 1) // alignment * alignment


def read_meta(path: Path) -> tuple[int, int, int]:
    sidecar = Path(str(path) + ".txt")
    if sidecar.exists():
        base, size, entry = (int(x) for x in sidecar.read_text().strip().split("|"))
        return base, size, entry
    # Fallbacks for the dumps committed to this repository.
    if path.name == "yapb_b1.bin":
        return 0x10000000, IMAGE_SIZE, 0xC2F10
    if path.name == "yapb_b2.bin":
        return 0x0A630000, IMAGE_SIZE, 0xC2F10
    raise SystemExit(f"missing metadata: {sidecar}")


def recover_relocations(b1: bytes, b2: bytes, base1: int, base2: int) -> list[int]:
    delta = (base2 - base1) & 0xFFFFFFFF
    relocs: list[int] = []
    for off in range(TEXT_RVA, TEXT_RVA + TEXT_SIZE - 3):
        v1 = struct.unpack_from("<I", b1, off)[0]
        if not (base1 <= v1 < base1 + IMAGE_SIZE):
            continue
        v2 = struct.unpack_from("<I", b2, off)[0]
        if ((v2 - v1) & 0xFFFFFFFF) == delta:
            relocs.append(off)
    return relocs


def make_reloc_section(relocs: list[int]) -> bytes:
    pages: dict[int, list[int]] = defaultdict(list)
    for rva in relocs:
        pages[rva & 0xFFFFF000].append(rva & 0xFFF)

    out = bytearray()
    for page in sorted(pages):
        entries = sorted(set(pages[page]))
        for i in range(0, len(entries), 0x3F0):
            chunk = entries[i:i + 0x3F0]
            size = 8 + 2 * len(chunk)
            pad = 2 if size % 4 else 0
            if pad:
                size += 2
            out += struct.pack("<II", page, size)
            out += b"".join(struct.pack("<H", entry | 0x3000) for entry in chunk)
            if pad:
                out += b"\x00\x00"
    return bytes(out)


def patch_branding(text: bytearray, rsrc: bytearray) -> None:
    replacements = [
        (b"YAPB", b"FAPB"),
        (b"YaPB", b"FAPB"),
        (b"Yapb", b"Fapb"),
        (b"yapb", b"fapb"),
        (b"yb_", b"fb_"),
        (b"\x00yb\x00", b"\x00fb\x00"),
        (b"|yb|", b"|fb|"),
    ]
    for buf in (text, rsrc):
        for old, new in replacements:
            buf[:] = bytes(buf).replace(old, new)
        for old, new in (("YAPB", "FAPB"), ("YaPB", "FAPB"), ("Yapb", "Fapb"), ("yapb", "fapb")):
            buf[:] = bytes(buf).replace(old.encode("utf-16le"), new.encode("utf-16le"))
        # Keep the original authors' attribution in version/about output.
        buf[:] = bytes(buf).replace(b"FAPB Development Team", b"YaPB Development Team")
        buf[:] = bytes(buf).replace(b"FAPB Dev Team", b"YaPB Dev Team")


def build_headers(packed: bytes, reloc: bytes) -> bytearray:
    out = bytearray(packed[:0x400])
    pe = 0x100
    opt = pe + 24

    struct.pack_into("<H", out, pe + 6, 4)                  # NumberOfSections
    struct.pack_into("<I", out, opt + 16, 0x4437B)          # AddressOfEntryPoint (OEP)
    struct.pack_into("<I", out, opt + 56, 0xCC000)          # SizeOfImage
    struct.pack_into("<I", out, opt + 60, 0x400)            # SizeOfHeaders
    struct.pack_into("<I", out, opt + 64, 0)                # CheckSum
    struct.pack_into("<I", out, opt + 4, TEXT_SIZE)         # SizeOfCode
    struct.pack_into("<I", out, opt + 8, RSRC_SIZE + align(len(reloc), 0x200))
    struct.pack_into("<I", out, opt + 12, 0x2D000)          # SizeOfUninitializedData
    struct.pack_into("<I", out, opt + 20, TEXT_RVA)         # BaseOfCode
    struct.pack_into("<I", out, opt + 24, 0x97000)          # BaseOfData

    # The old LoadConfig directory pointed into the discarded UPX1 area.
    struct.pack_into("<II", out, opt + 96 + 10 * 8, 0, 0)
    # New relocation directory.
    struct.pack_into("<II", out, opt + 96 + 5 * 8, RELOC_RVA, len(reloc))

    sec = opt + struct.unpack_from("<H", out, pe + 20)[0]

    def section(name: str, vsize: int, va: int, rawsize: int, rawptr: int, chars: int) -> bytes:
        return struct.pack(
            "<8sIIIIIIHHI",
            name.encode().ljust(8, b"\0"), vsize, va, rawsize, rawptr, 0, 0, 0, 0, chars,
        )

    out[sec:sec + 40] = section(".text", TEXT_SIZE, TEXT_RVA, TEXT_SIZE, 0x400, 0xE0000080)
    out[sec + 40:sec + 80] = section(".data", 0x2D000, 0x97000, 0, 0, 0xC0000040)
    out[sec + 80:sec + 120] = section(
        ".rsrc", 0x2000, RSRC_RVA, RSRC_SIZE, 0x400 + TEXT_SIZE, 0x40000040
    )
    reloc_raw = align(0x400 + TEXT_SIZE + RSRC_SIZE, 0x200)
    out[sec + 120:sec + 160] = section(
        ".reloc", len(reloc), RELOC_RVA, align(len(reloc), 0x200), reloc_raw, 0x42000040
    )
    return out


def main() -> None:
    packed = (ART / "yapb.dll").read_bytes()
    b1 = (ART / "yapb_b1.bin").read_bytes()
    b2 = (ART / "yapb_b2.bin").read_bytes()

    base1, size1, _ = read_meta(ART / "yapb_b1.bin")
    base2, size2, _ = read_meta(ART / "yapb_b2.bin")
    if base1 != IMAGE_BASE:
        raise SystemExit(f"b1 must be dumped at 0x{IMAGE_BASE:X}, got 0x{base1:X}")
    if size1 != IMAGE_SIZE or size2 != IMAGE_SIZE:
        raise SystemExit(f"unexpected image size: {size1:#x}, {size2:#x}")

    relocs = recover_relocations(b1, b2, base1, base2)
    if not relocs:
        raise SystemExit("no relocations recovered")

    reloc = make_reloc_section(relocs)

    text = bytearray(b1[TEXT_RVA:TEXT_RVA + TEXT_SIZE])
    rsrc = bytearray(packed[RSRC_FILE_OFFSET:RSRC_FILE_OFFSET + RSRC_SIZE])
    patch_branding(text, rsrc)

    # The original .rsrc is used (not the dump), because the dump's IAT
    # contains already-resolved kernel32 addresses.
    buf = build_headers(packed, reloc)
    buf += text
    buf += rsrc
    if len(buf) != 0x97E00:
        raise SystemExit(f"unexpected layout: {len(buf):#x}")
    buf += reloc
    buf += b"\0" * (align(len(buf), 0x200) - len(buf))

    OUT.mkdir(parents=True, exist_ok=True)
    dst = OUT / "fapb.dll"
    dst.write_bytes(buf)

    digest = hashlib.sha256(buf).hexdigest()
    print(f"relocations: {len(relocs)}")
    print(f"reloc bytes: {len(reloc)}")
    print(f"wrote: {dst} ({len(buf)} bytes)")
    print(f"sha256: {digest}")
    if digest != EXPECTED_SHA256:
        print(f"WARNING: expected {EXPECTED_SHA256}")


if __name__ == "__main__":
    main()
