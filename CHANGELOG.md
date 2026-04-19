# Changelog

> All notable changes to this project are documented in this file.

### v1.2 UI Polish & Detection Update
- Added `F5` FORCE STOP hotkey and aligned UI control behavior.
- Added `Auto Minimize` toggle support for start/pick/team actions.
- Updated Slot Detection output to show clean matched names and mark the last picked slot with `<--`.
- Removed unused functions and cleaned stale code paths.

### v1.1 UI & Control Update
- Added configurable modifier ranking via `Settings/modifier_ranks.ini`.
- Added in-app rank editor and persistence (`Ranks` button).
- Main UI refreshed: dynamic `Start/Stop`, renamed buttons, and removed hotkey text from button labels.
- Added `FORCE STOP` button and `F5` hotkey to immediately stop macro loop and request team-build stop.
- Added status color indicators: ON (green), OFF (red).

### v1.0 Release
- Initial public release of ACC Dungeon Macro for Roblox Anime Card Clash on AutoHotkey v2.
- OCR-driven modifier detection and auto-pick flow with score/rank priority logic.
- Manual and automated controls via hotkeys: `F4/F6/F7/F8/F9/F10`.
- UPG team build flow: clears existing cards first, then builds from team config sets.
- Readable team configuration with multiline `AttTeam1/AttTeam2/SuppTeam1/SuppTeam2` and `A | B` alternatives.
- Editable region calibration with overlay editor and persisted `Settings/region.ini`.
- Runtime action logging to `ACC_mod.log` and UI status feedback.
