#!/usr/bin/env python3
"""Generate FAPB configuration files from the original YAPB configs.

Renames:
  yb_*            -> fb_*
  yapb            -> fapb
  YaPB/Yapb/YAPB  -> FAPB/Fapb/FAPB
  _ybpw           -> _fbpw

The main fapb.cfg gets FAPB branding, menu aliases and a default quota
of 10 bots.  Original copyright/attribution lines are preserved.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "tools" / "artifacts" / "yapb-config"
DST = ROOT / "addon" / "config"

HEADER = b"""// ==========================================================================
// FAPB - Counter-Strike 1.6 Third-Party Bot
// Based on YAPB 2.55b core (aim / shooting / behaviour kept intact)
// Commands: fapb <subcommand>     Cvars: fb_*
// Menu: fapb cmenu                Shortcut: fapb_menu
// ==========================================================================

// Independent FAPB menu / command shortcuts (server console aliases)
alias fapb_menu "fapb cmenu"
alias fapb_help "fapb help"
alias fapb_list "fapb list"
alias fapb_add "fapb add"
alias fapb_add_t "fapb add_t"
alias fapb_add_ct "fapb add_ct"
alias fapb_fill "fapb fill"
alias fapb_kickall "fapb kickall"
alias fapb_killbots "fapb killbots"

"""


def convert(data: bytes) -> bytes:
    for old, new in (
        (b"_ybpw", b"_fbpw"),
        (b"YAPB", b"FAPB"),
        (b"YaPB", b"FAPB"),
        (b"Yapb", b"Fapb"),
        (b"yapb", b"fapb"),
        (b"yb_", b"fb_"),
        (b"FAPB Development Team", b"YaPB Development Team"),
        (b"FAPB Dev Team", b"YaPB Dev Team"),
    ):
        data = data.replace(old, new)
    return data


def main() -> None:
    DST.mkdir(parents=True, exist_ok=True)

    for src_name, dst_name in (
        ("yapb.cfg", "fapb.cfg"),
        ("yapb_against.cfg", "fapb_against.cfg"),
        ("general.cfg", "general.cfg"),
        ("chatter.cfg", "chatter.cfg"),
    ):
        data = convert((SRC / src_name).read_bytes())
        if dst_name == "fapb.cfg":
            data = HEADER + data
            data = data.replace(b'bind "=" "fapb menu"', b'bind "=" "fapb_menu"')
            data = data.replace(b'fb_quota "0"', b'fb_quota "10"', 1)
            data = data.replace(b'fb_nameprefix "Fapb |"', b'fb_nameprefix "FAPB |"', 1)
        (DST / dst_name).write_bytes(data)

    lang_src = SRC / "language"
    lang_dst = DST / "language"
    lang_dst.mkdir(exist_ok=True)
    for path in lang_src.iterdir():
        if path.is_file():
            (lang_dst / path.name).write_bytes(convert(path.read_bytes()))

    print(f"wrote configs to {DST}")


if __name__ == "__main__":
    main()
