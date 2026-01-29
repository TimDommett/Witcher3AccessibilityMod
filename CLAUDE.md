# W3BlindAccess — Development Progress

## Project Overview

Accessibility mod for The Witcher 3 enabling blind players to complete the main story via TTS narration, spatial audio cues, and audio-guided navigation.

See `witcher3-blind-accessibility-spec.md` for the full development specification.

---

## Completed Work

### Project Scaffold (Done)

Full mod directory structure and WitcherScript module stubs for all 4 subsystems:

| Module | File | Status | Notes |
|--------|------|--------|-------|
| **Init** | `scripts/local/W3BA_Init.ws` | **Implemented** | Global singleton, lazy init, audio cue constants, convenience functions |
| **Core Manager** | `scripts/core/W3BA_CoreManager.ws` | Scaffolded | Initializes all modules, runs per-frame `Update()`, exposes accessors |
| **Config** | `scripts/core/W3BA_Config.ws` | **Implemented** | Persistence via `user.settings` INI using `CInGameConfigWrapper` |
| **Events** | `scripts/core/W3BA_Events.ws` | Scaffolded | Event enums, typed data structs, emit stubs. No listener registration yet. |
| **TTS Bridge** | `scripts/tts/W3BA_TTSBridge.ws` | **Implemented** | File-based IPC via `LogChannel('W3BA', ...)` to ASI plugin. Deduplication. |
| **Speech Queue** | `scripts/tts/W3BA_SpeechQueue.ws` | **Implemented** | Priority-sorted queue with `Enqueue`, `Dequeue`, `Peek`, `Clear`. |
| **Audio Manager** | `scripts/audio/W3BA_AudioManager.ws` | Scaffolded | `PlayCue()`, `PlayCue3D()`, beacon start/stop. Wwise integration TODO. |
| **Spatial Audio** | `scripts/audio/W3BA_SpatialAudio.ws` | **Implemented** | Cardinal direction (relative + compass), distance, `MapRange()`. |
| **Navigation Beacon** | `scripts/navigation/W3BA_Beacon.ws` | Scaffolded | Beacon toggle, interval ping, pitch-by-distance. Waypoint extraction TODO. |
| **Object Tracker** | `scripts/navigation/W3BA_ObjectTracker.ws` | Scaffolded | Category enum, scan loop, cycle next/prev, filter. Game query TODO. |
| **Combat Monitor** | `scripts/combat/W3BA_CombatMonitor.ws` | Scaffolded | Combat state check, enemy list, health monitoring. Game hooks TODO. |
| **Combat Cues** | `scripts/combat/W3BA_CombatCues.ws` | Scaffolded | All combat event handlers, health warnings. Monitor wiring TODO. |
| **Menu Narrator** | `scripts/ui/W3BA_MenuNarrator.ws` | Scaffolded | Menu/dialogue/save TTS narration templates. |
| **Inventory Narrator** | `scripts/ui/W3BA_InventoryNarrator.ws` | Scaffolded | Brief/detail/comparison/consumable narration. Item data extraction TODO. |

### Phase 1: Foundation (Done)

#### TTS Bridge — File-based IPC Architecture
- **Approach**: WitcherScript cannot call native DLLs directly. We use `LogChannel('W3BA', cmd)` to write speech commands to `scriptslog.txt`, which an ASI plugin polls.
- **Command protocol**: `SPEAK|<interrupt>|<priority>|<text>`, `SILENCE`, `DETECT`
- **ASI Plugin**: Full C++ source in `asi_plugin/src/W3BA_TTS.cpp`
  - Loads Tolk.dll, polls scriptslog.txt at 60 Hz
  - Parses W3BA commands, calls `Tolk_Output()` for speech
  - Supports NVDA, JAWS, and Windows SAPI fallback
  - Build system: CMake, targets Visual Studio 2022
  - See `asi_plugin/BUILD.md` for build/install instructions
- **Deduplication**: Rapid identical speech is suppressed (150ms window)

#### Config Persistence
- Uses `theGame.GetInGameConfigWrapper()` for INI read/write
- Stores under `[W3BlindAccess]` section in `user.settings`
- Helper functions for Bool/Int/Float with defaults on missing keys
- Calls `theGame.SaveUserSettings()` to persist

#### Menu Hooks (via `@wrapMethod` / `@addField`)
All hooks are in `scripts/game/gui/menus/`:

| Hook File | Target Class | What It Narrates |
|-----------|-------------|------------------|
| `W3BA_MainMenuHook.ws` | `CR4CommonMainMenu` | Main menu items (Continue, New Game, Load, Options, etc.) |
| `W3BA_IngameMenuHook.ws` | `CR4IngameMenu` | Pause menu items + tab panels (Inventory, Map, Journal, etc.) |
| `W3BA_OptionsMenuHook.ws` | `CR4OptionsMenu` | Settings tabs, setting names + values, value changes |
| `W3BA_SaveLoadHook.ws` | `CR4SaveGameMenu`, `CR4LoadGameMenu`, `CR4OverlayPopup` | Save/load slots, confirmation dialogs |
| `W3BA_DialogueHook.ws` | `CR4HudModuleDialog` | Dialogue choice count, choice text, special markers (Important, Axii, already chosen) |

#### Audio Cue Constants
All Wwise event IDs defined as constants in `W3BA_Init.ws`:
- UI: `ui_menu_focus`, `ui_menu_select`, `ui_menu_back`, `ui_error`
- Navigation: `beacon_quest_main`, `beacon_quest_side`, `beacon_poi`
- Combat: 9 cue IDs for detection, attacks, dodge, parry, health
- Objects: 5 cue IDs for containers, herbs, NPCs, doors, loot

---

## What's NOT Fully Implemented Yet

### Remaining TODOs in Phase 1 Files

1. **Menu item text extraction** (all hook files)
   - Hooks detect input/navigation but some use index-to-label mapping instead of reading the actual Flash text
   - `GetCurrentMenuItemIndex()` is assumed available on menu classes — needs verification against actual game API
   - Options menu `W3BA_GetOptionName()` / `W3BA_GetOptionValue()` return placeholders; need to wire `CInGameConfigWrapper.GetGroupEntries()`

2. **Save slot metadata** (`W3BA_SaveLoadHook.ws`)
   - `W3BA_BuildSaveSlotDescription()` returns placeholder text
   - Need to extract area name, date/time, play time from Flash data bindings

3. **Dialogue choice data** (`W3BA_DialogueHook.ws`)
   - `ShowDialogChoices()` and `OnDialogChoiceFocused()` signatures assumed — need to verify actual `CR4HudModuleDialog` API
   - `GetCurrentChoiceText()` returns placeholder

4. **Confirmation dialog text** (`W3BA_SaveLoadHook.ws`)
   - `CR4OverlayPopup` hook speaks generic "Confirmation dialog" — need to extract actual message

5. **Wwise soundbank** — no actual `.bnk` file exists yet; audio cues will be silent until created

6. **ASI plugin not compiled** — C++ source is written but needs Windows build environment

### Phase 2+ TODO Items (Unchanged from Scaffold)

- Quest waypoint extraction (`W3BA_Beacon.ws`)
- Game interactable spatial queries (`W3BA_ObjectTracker.ws`)
- Combat state hooks into `r4Player.ws` / `CActor` (`W3BA_CombatMonitor.ws`)
- Wwise soundbank creation and integration (`W3BA_AudioManager.ws`)
- Event listener registration pattern (`W3BA_Events.ws`)

---

## Development Phases

### Phase 1: Foundation — DONE (code written, needs in-game testing)
- [x] TTS bridge architecture (file-based IPC via LogChannel + ASI plugin)
- [x] ASI plugin source (C++ with Tolk integration)
- [x] Config persistence (user.settings INI)
- [x] Main menu narration hook
- [x] Pause/ingame menu narration hook
- [x] Options menu narration hook
- [x] Save/load screen narration hook
- [x] Dialogue choice narration hook
- [x] Audio cue ID constants
- [x] Global init / singleton pattern
- [ ] In-game testing and Flash API verification
- [ ] Wwise soundbank creation

### Phase 2: Core Gameplay
- [ ] Quest waypoint audio beacon
- [ ] Distance/direction announcements
- [ ] Combat state monitoring + audio cues
- [ ] Attack warning system
- [ ] Interactable object detection
- [ ] Health/status audio feedback

### Phase 3: Full System Access
- [ ] Full inventory narration
- [ ] Equipment comparison
- [ ] Crafting/alchemy narration
- [ ] Object tracker/scanner
- [ ] Bestiary accessibility
- [ ] Audio cue glossary
- [ ] Accessibility config menu

### Phase 4: Polish
- [ ] Environmental audio descriptions
- [ ] Cutscene supplementary narration
- [ ] Controller haptics
- [ ] Performance optimization
- [ ] User documentation

---

## Architecture Notes

### TTS IPC Flow
```
WitcherScript                          ASI Plugin (in-process)
    |                                       |
    |-- LogChannel('W3BA', "SPEAK|1|2|Hello") -->|
    |   (writes to scriptslog.txt)          |-- polls file at 60Hz
    |                                       |-- parses [W3BA] lines
    |                                       |-- Tolk_Output(L"Hello", true)
    |                                       |-- screen reader speaks
```

### Module Ownership
- All modules instantiated and owned by `W3BA_CoreManager`
- Per-frame work: `CoreManager.Update(dt)` → beacon, tracker, combat monitor, combat cues
- Menu hooks use global `W3BA_SpeakText()` / `W3BA_PlayCue()` (no module reference needed)
- Lazy initialization via `W3BA_EnsureInitialized()` — safe to call from any hook

### Speech Priority Levels
| Level | Value | Use Case |
|-------|-------|----------|
| LOW | 0 | Background info, object details |
| MEDIUM | 1 | Menu navigation, item focus |
| HIGH | 2 | Menu announcements, dialogue choices |
| URGENT | 3 | Combat warnings, critical health |

### Key Technical Decisions
1. **LogChannel IPC** chosen over direct DLL calls — WitcherScript has no FFI
2. **`@wrapMethod`** for menu hooks — non-destructive, compatible with other mods
3. **Singleton with lazy init** — handles unpredictable game initialization order
4. **CInGameConfigWrapper** for config — uses the game's native settings system

## Key Technical Risks

1. **ASI plugin log parsing** — `scriptslog.txt` write frequency and buffering behavior needs testing; may need to hook the log write function directly in the ASI plugin instead of polling the file
2. **Flash UI events** — `@wrapMethod` on `OnInputHandled` is proven in other mods, but the exact class names and method signatures need verification against the actual game scripts
3. **Menu item index mapping** — hardcoded index-to-label maps (main menu, pause menu) may break with DLC or other mods that add menu items
4. **Combat timing** — attack wind-up durations are per-animation and may require reverse engineering (Phase 2)

## File Tree

```
mods/W3BlindAccess/
├── asi_plugin/
│   ├── CMakeLists.txt
│   ├── BUILD.md
│   └── src/
│       ├── W3BA_TTS.cpp          # ASI plugin: Tolk integration + log polling
│       └── Tolk.h                # Tolk API header
├── content/
│   ├── scripts/
│   │   ├── local/W3BA_Init.ws    # Singleton, globals, audio cue constants
│   │   ├── core/
│   │   │   ├── W3BA_CoreManager.ws
│   │   │   ├── W3BA_Config.ws    # INI persistence via CInGameConfigWrapper
│   │   │   └── W3BA_Events.ws
│   │   ├── tts/
│   │   │   ├── W3BA_TTSBridge.ws # LogChannel IPC, deduplication
│   │   │   └── W3BA_SpeechQueue.ws
│   │   ├── audio/
│   │   │   ├── W3BA_AudioManager.ws
│   │   │   └── W3BA_SpatialAudio.ws
│   │   ├── navigation/
│   │   │   ├── W3BA_Beacon.ws
│   │   │   └── W3BA_ObjectTracker.ws
│   │   ├── combat/
│   │   │   ├── W3BA_CombatMonitor.ws
│   │   │   └── W3BA_CombatCues.ws
│   │   ├── ui/
│   │   │   ├── W3BA_MenuNarrator.ws
│   │   │   └── W3BA_InventoryNarrator.ws
│   │   └── game/gui/menus/       # Game class hooks (@wrapMethod)
│   │       ├── W3BA_MainMenuHook.ws
│   │       ├── W3BA_IngameMenuHook.ws
│   │       ├── W3BA_OptionsMenuHook.ws
│   │       ├── W3BA_SaveLoadHook.ws
│   │       └── W3BA_DialogueHook.ws
│   ├── sounds/.gitkeep
│   └── strings/.gitkeep
└── bin/x64/plugins/.gitkeep
```
