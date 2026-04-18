# ACC Dungeon Macro

AutoHotkey v2 macro for modifier picking and team build automation in Roblox ACC.

## Included Files

- `ACC_Dungeon.ahk` (main script)
- `Lib/OCR.ahk` (required dependency)
- `Settings/region.ini` (region template)
- `Settings/team_cards.ini` (team config template)

## Hotkeys

- `F4` Toggle region overlay editor
- `F6` Toggle macro ON/OFF
- `F7` Force one modifier pick
- `F8` Reset modifier scores
- `F9` Manual UPG team build (clears cards first, then open with `T`, close with `Z`)
- `F10` Exit script

## Setup

1. Install [AutoHotkey v2](https://www.autohotkey.com/).
2. Keep this folder structure intact (`Lib` and `Settings` must sit beside the main script).
3. Run `ACC_Dungeon.ahk`.
4. Press `F6` to start/stop and `F9` to run team build.

## Region Calibration

1. Start the script and press `F4` to open the region editor.
2. Drag/resize regions so they match your Roblox window and UI scale.
3. Save/close the editor.
4. Re-test with `F7` (single pick) and `F9` (team build).

## Team Config Format

`Settings/team_cards.ini` supports one card per line and `A | B` alternatives.

Example:

```ini
[Cards]

AttTeam1=
Cosmic Villain,
Awakened Eclipseborn Hawk,
King of Helheim | The Almighty,
Divine Emperor | Lion of Justice | Wrathful Sin

AttTeam2=
Cosmic Villain,
Awakened Eclipseborn Hawk,
Divine Emperor | Lion of Justice | Wrathful Sin,
Herald of Fate | Sacred Arch Priestess

SuppTeam1=
Binding Vow | Binding Light,
Binding Vow,
Demonic Gift,
Binding Vow

SuppTeam2=
Binding Vow,
Binding Light,
Binding Vow,
Binding Vow
```

Behavior notes:
- `F9` runs as UPG flow: it removes existing attack/support cards before picking from team config.
- If `AttTeam1` fails, `SuppTeam1` is skipped.

## Runtime Files

- Log output is written to `ACC_mod.log`.
