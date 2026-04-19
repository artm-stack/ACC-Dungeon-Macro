# ACC Dungeon Macro - Wiki

Welcome to the ACC Dungeon Macro wiki. This guide covers what users need to run, configure, and troubleshoot the current script behavior.

---

## Table of Contents

1. [Core Concepts](#1-core-concepts)
2. [Getting Started](#2-getting-started)
3. [Hotkeys and Controls](#3-hotkeys-and-controls)
4. [Modifier Auto-Pick Flow](#4-modifier-auto-pick-flow)
5. [Modifier Ranking](#5-modifier-ranking)
6. [UPG Team Build Flow](#6-upg-team-build-flow)
7. [Team Config Reference](#7-team-config-reference)
8. [Region Calibration Guide](#8-region-calibration-guide)
9. [Files and Logging](#9-files-and-logging)
10. [Troubleshooting](#10-troubleshooting)
11. [Compatibility Notes](#11-compatibility-notes)
12. [FAQ](#12-faq)

---

## 1) Core Concepts

ACC Dungeon Macro is built around two systems:

- Modifier picking automation using OCR.
- Team building automation from card lists in config.

The script reads game UI text, then makes decisions based on:

- Modifier rank/priority and score tracking.
- Team set order (`AttTeam1`, `AttTeam2`, `SuppTeam1`, `SuppTeam2`).
- Region coordinates saved in `Settings/region.ini`.

---

## 2) Getting Started

1. Install [AutoHotkey v2](https://www.autohotkey.com/v2/).
2. Keep files in this structure:
   `ACC_Dungeon.ahk`, `Lib/OCR.ahk`, `Settings/region.ini`, `Settings/team_cards.ini`, `Settings/modifier_ranks.ini`.
3. Launch [Roblox](https://www.roblox.com/).
4. Open [Anime Card Clash](https://www.roblox.com/games/110829983956014/Anime-Card-Clash).
5. Run `ACC_Dungeon.ahk`.
6. Press `F4` and calibrate regions if needed.
7. Press `F6` to enable modifier automation.
8. Press `F9` to run UPG team build manually.
9. Use `F5` or `FORCE STOP` for immediate emergency stop.

---

## 3) Hotkeys and Controls

- `F4` Toggle region overlay editor.
- `F6` Toggle modifier macro ON/OFF.
- `F5` Force stop macro loop and request team-build stop.
- `F7` Force one modifier pick now.
- `F8` Reset modifier scores.
- `F9` Run manual UPG team build.
- `F10` Exit script.

Main UI buttons:

- `Start` / `Stop` (dynamic label based on running state)
- `FORCE STOP`
- `Pick Now`
- `Reset Count`
- `Build Team`
- `Ranks`
- `Edit Regions`
- `Auto Jump` toggle
- `Auto Minimize` toggle

Status colors:

- ON = green
- OFF = red

UPG behavior on `F9`:

- Existing attack/support cards are removed first.
- Team UI opens, picks are performed, then UI closes with `Z`.

Slot Detection panel:

- Shows matched modifier names for `S1/S2/S3`.
- Marks the last selected slot with `<--`.
- Shows `(none)` when a slot is empty, or `Unknown` when OCR text does not match known modifiers.

---

## 4) Modifier Auto-Pick Flow

When enabled (`F6`), the script loops and:

1. Checks Roblox window is active.
2. Runs optional Auto Jump on cooldown.
3. Detects prompt states (dismiss) and sends `Z` when needed.
4. Detects modifier screen via OCR.
5. Scans slot text using OCR and matches known modifier aliases.
6. Picks the best candidate by rank/score rules.
7. Updates internal score tracking and logs the action.

Manual single-run pick (`F7`) performs a one-shot version of this flow.

---

## 5) Modifier Ranking

Lower rank value means higher priority.

Current selection priority order:

1. Defense
2. Health
3. Piercing
4. Healing
5. Damage
6. Bloodthirst
7. Ackerman
8. Lucky
9. High Roller

When OCR matches multiple valid modifiers, the script prefers the highest-priority modifier from this list.

---

## 6) UPG Team Build Flow

`F9` runs `BuildTeamFromConfig` in clear-deck mode.

Flow summary:

1. Open team UI (key `T`) with OCR verification retries.
2. Remove existing attack/support cards.
3. Pick attack set in order:
   - `AttTeam1` first.
   - If unavailable, clear and try next attack set.
4. Support starts from the same successful set index.
5. Pick support set in order:
   - If unavailable, clear and move to next support set.
6. Fill remaining support slots from `SupportFallback` if needed.
7. Close UI with `Z`.

Behavior rule:

- If `AttTeam1` fails and the script moves to `AttTeam2`, then `SuppTeam1` is skipped and support starts from `SuppTeam2`.

---

## 7) Team Config Reference

Config file: `Settings/team_cards.ini`

Primary keys:

- `AttTeam1`
- `AttTeam2`
- `SuppTeam1`
- `SuppTeam2`
- `SupportFallback` (optional)

Format rules:

- One card per line is supported.
- Commas separate entries.
- `A | B` means alternatives for one pick slot.

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

SupportFallback=
Binding Vow,
Binding Light,
Demonic Gift
```

Backward compatibility:

- Legacy keys like `PrimaryAttack` and `PrimarySupport` are still read if new keys are missing.

---

## 8) Region Calibration Guide

Config file: `Settings/region.ini`

How to calibrate:

1. Press `F4` to open region overlays.
2. Drag/resize regions to match your current resolution/UI scale.
3. Close overlay (`F4`) to save regions.
4. Validate with `F7` and `F9`.

Notes:

- If `region.ini` does not exist, defaults are generated.
- If old `modifier_only_regions.ini` exists, it is migrated to `region.ini` automatically.

---

## 9) Files and Logging

Main runtime/config files:

- `ACC_Dungeon.ahk` main script.
- `Lib/OCR.ahk` OCR dependency.
- `Settings/region.ini` saved regions.
- `Settings/team_cards.ini` team definitions.
- `Settings/modifier_ranks.ini` modifier ranking priority config.
- `Settings/modifier_scores.ini` modifier counts/scores.
- `ACC_mod.log` runtime log output.

`ACC_mod.log` includes events such as:

- Script actions and hotkey outcomes.
- OCR detection snapshots.
- Team build retries/failures.
- Region migration notices.

---

## 10) Troubleshooting

Script does nothing:

- Confirm AutoHotkey v2 is installed.
- Confirm Roblox window title matches expected `Roblox`.
- Confirm script is ON (`F6`).

Modifier not detected:

- Recalibrate with `F4`.
- Verify OCR regions (`ScreenCheckRegion`, slot regions).
- Check `ACC_mod.log` for OCR text and mismatch clues.

Team build fails to open UI:

- Ensure `T` opens your team interface in-game.
- Recalibrate `TeamUiCheckRegion` and search regions.
- Check `ACC_mod.log` for "Team UI OCR not detected" entries.

Wrong cards picked:

- Update `Settings/team_cards.ini` names to match in-game search text.
- Use `A | B` alternatives for OCR/search variations.

---

## 11) Compatibility Notes

- Requires Windows + AutoHotkey v2.
- Requires `Lib/OCR.ahk` beside script.
- Region/profile values depend on your resolution and UI scale.
- Team flow assumes default input keys (`T`, `E`, `Z`) unless edited in script globals.

---

## 12) FAQ

Q. Does `F9` clear cards first?

A. Yes. `F9` runs UPG flow and removes existing attack/support cards before picking.

Q. Why is `SuppTeam1` skipped sometimes?

A. Support starts from the attack set index that succeeded. If attack falls back to set 2, support also starts at set 2.

Q. Where do I see what the macro is doing?

A. Check `ACC_mod.log` for action logs and OCR/debug traces.

Q. What does FORCE STOP do?

A. It immediately stops the macro timer and signals team-build loops to stop on their next stop-check.

Q. What does Slot Detection show?

A. It shows the matched modifier name per slot (`S1/S2/S3`) and an arrow on the last selected slot.
