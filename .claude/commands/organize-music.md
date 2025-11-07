# Organize Music - Consolidate Split Albums

Runs the music organization script to consolidate albums split across multiple artist folders.

## Quick Reference

**Usage:** `/organize-music [--dry-run] [--json] [--music-dir PATH]`

**What it does:**
Runs `scripts/utils/organize-music.py` with the provided arguments. The script consolidates albums that have been split across artist folders (e.g., "Tweaker" vs "Tweaker & David Sylvian") and handles compilation albums.

**Default music directory:** `/Volumes/media/TuneFab/Apple Music`

---

## Usage

```
/organize-music --dry-run              # Preview changes (always recommended first)
/organize-music                       # Execute consolidation
/organize-music --dry-run --json      # JSON output for automation
/organize-music --music-dir "/path"   # Custom directory
```

**Arguments:** (passed directly to the script)
- `--dry-run`: Preview changes without making them
- `--json`: Output results in JSON format
- `--music-dir PATH`: Custom path to music directory

---

## Workflow

1. **Always preview first:** `/organize-music --dry-run`
2. **Review the output** - Check what will be consolidated
3. **Execute:** `/organize-music` (without `--dry-run`)

---

## Documentation

For detailed information, see:
- **Script help:** `python3 scripts/utils/organize-music.py --help`
- **Full documentation:** [[scripts/README#organize-musicpy]]
- **Script location:** `scripts/utils/organize-music.py`

The script handles:
- Multi-artist folder consolidation (e.g., "Tweaker & X" → "Tweaker")
- Compilation albums (creates "Various Artists" folder)
- Track completeness validation
- Empty directory cleanup
