# NOTICE

FAPB is an **unofficial rebrand** of YAPB (Yet Another PodBot) 2.55b.

## Upstream

- Project: YAPB — a third-party bot for Counter-Strike 1.6
- Authors: YaPB Dev Team, based on PODBot code
- Upstream repository: <https://github.com/yapb/yapb>
- Upstream license: The Unlicense (public domain)

FAPB is not affiliated with, endorsed by, or supported by the YAPB project.

## What was changed

Only presentation and namespace strings were changed in the original binary:

- plugin name: `YaPB` → `FAPB`
- console command: `yapb` / `yb` → `fapb` / `fb`
- cvars: `yb_*` → `fb_*`
- menu titles/text: `YaPB` → `FAPB`
- config path: `addons/yapb/` → `addons/fapb/`
- waypoint path: `addons/yapb/wptdefault/` → `addons/fapb/wptdefault/`
- the original UPX packer was removed and the PE relocation table was rebuilt

The AI code, aim model, shooting logic, tactics, experience system and bot
behaviour were **not modified**. The original authors' attribution
(`YaPB Dev Team`) is kept in the version/about output and configuration
copyright lines.

## Files

- `tools/artifacts/yapb.dll` is the original, unmodified, UPX-packed DLL
  from the YAPB 2.55b distribution.
- `addon/dlls/fapb.dll` is the rebranded derivative built from it.
- `tools/artifacts/yapb_b1.bin` and `yapb_b2.bin` are memory dumps used
  only to recover the relocation table.

## License

Both the original YAPB work and this rebrand are distributed under the
Unlicense. See [LICENSE](LICENSE).

## No warranty

This software is provided "as is", without warranty of any kind. Use at
your own risk. Back up your server configuration before installing.
