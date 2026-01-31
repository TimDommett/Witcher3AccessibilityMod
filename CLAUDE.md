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
| **Core Manager** | `scripts/core/W3BA_CoreManager.ws` | **Implemented** | Initializes all modules, runs per-frame `Update()`, wires combat events |
| **Config** | `scripts/core/W3BA_Config.ws` | **Implemented** | Persistence via `user.settings` INI using `CInGameConfigWrapper` |
| **Events** | `scripts/core/W3BA_Events.ws` | Scaffolded | Event enums, typed data structs, emit stubs. Direct routing used instead. |
| **TTS Bridge** | `scripts/tts/W3BA_TTSBridge.ws` | **Implemented** | File-based IPC via `LogChannel('W3BA', ...)` to ASI plugin. Deduplication. |
| **Speech Queue** | `scripts/tts/W3BA_SpeechQueue.ws` | **Implemented** | Priority-sorted queue with `Enqueue`, `Dequeue`, `Peek`, `Clear`. |
| **Audio Manager** | `scripts/audio/W3BA_AudioManager.ws` | Scaffolded | `PlayCue()`, `PlayCue3D()`, beacon start/stop. Wwise integration TODO. |
| **Spatial Audio** | `scripts/audio/W3BA_SpatialAudio.ws` | **Implemented** | Cardinal direction (relative + compass), distance, `MapRange()`. |
| **Player Hook** | `scripts/game/player/W3BA_PlayerHook.ws` | **Implemented** | Timer-based tick loop, combat damage hook, target change hook |
| **Navigation Beacon** | `scripts/navigation/W3BA_Beacon.ws` | **Implemented** | Beacon toggle, interval ping, pitch-by-distance, direction. Waypoint API TODO. |
| **Object Tracker** | `scripts/navigation/W3BA_ObjectTracker.ws` | **Implemented** | Entity scanning, category classification, distance sort, direction |
| **Combat Monitor** | `scripts/combat/W3BA_CombatMonitor.ws` | **Implemented** | Real combat detection, enemy tracking, health monitoring, target tracking |
| **Combat Cues** | `scripts/combat/W3BA_CombatCues.ws` | **Implemented** | Enemy pings, health warnings, target announcements, speech throttling |
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

### Phase 2: Core Gameplay (Done — code written, needs in-game testing)

#### Player Hook (`W3BA_PlayerHook.ws`) — NEW
- Hooks `CR4Player.OnSpawned()` to register a repeating timer at 10 Hz
- Timer calls `CoreManager.Update(dt)` each tick for combat, beacon, object tracker
- Hooks `CR4Player.ReactToBeingHit()` to detect player damage → routes to combat cues
- Hooks `CR4Player.SetTarget()` to detect target changes → announces target name
- "In game" TTS announcement when player spawns

#### Combat Monitor — Real Game API Integration
- `thePlayer.IsInCombat()` for combat state detection (enter/exit)
- `FindGameplayEntitiesInRange()` + hostility filter for enemy tracking
- `thePlayer.GetStatPercents(BCS_Vitality)` for health monitoring
- `thePlayer.GetTarget()` for target lock tracking
- Direct event routing to CombatCues (no event bus needed)

#### Combat Cues — Fully Wired
- Combat start/end announcements with enemy count
- New enemy detection announcements
- Enemy position pings every 1.5s using spatial audio
- Health threshold warnings (low ≤25%, critical ≤10%)
- Target lock/change announcements with name
- TTS speech throttling (0.5s cooldown) to prevent overload
- Unblockable attack dodge warning

#### Navigation Beacon — Enhanced
- Waypoint caching (refreshes every 2s) to reduce per-tick overhead
- Player-relative direction (ahead/behind/left/right) + compass direction
- Distance-based pitch modulation for beacon ping
- Structure ready for waypoint API — currently returns zero (see TODO below)

#### Object Tracker — Real Entity Scanning
- `FindGameplayEntitiesInRange()` for spatial queries within configurable radius
- Entity classification by type: NPC (via `CNewNPC` cast), containers, herbs, doors, loot, clues, crafting (via entity tags)
- Hostile NPC filtering (handled by combat monitor instead)
- `GetDisplayName()` for entity names with fallback to category
- Distance-sorted results with insertion sort
- Player-relative direction announcements (ahead/left/right/behind)

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

### Phase 2 Remaining TODOs

1. **Quest waypoint position extraction** (HIGHEST PRIORITY)
   - `W3BA_Beacon.TryGetQuestObjectivePosition()` returns zero — needs real API
   - Candidates: `CCommonMapManager.GetEntityMapPins()`, journal manager quest tracking
   - Without this, the navigation beacon can't guide the player

2. **Dodge/parry hook verification**
   - `CR4Player.PerformDodge()` hook is commented out — needs method signature verification
   - Parry detection not yet hooked

3. **Entity tag verification for object tracker**
   - Entity tags like `'container'`, `'herb'`, `'door'` are assumed — need verification
   - May need direct class casts (`W3Container`, `W3Herb`) instead of tag checks

4. **Attack wind-up detection**
   - CombatMonitor doesn't detect enemy attack animations yet
   - Need to check `CActor` for attack state methods (e.g., `IsAttacking()`, `GetCurrentActionType()`)

5. **Wwise soundbank** — still no `.bnk` file; audio cues are silent
6. **ASI plugin not compiled** — C++ source is written but needs Windows build

### Phase 3+ TODO Items

- Full inventory narration with item data extraction
- Equipment comparison
- Crafting/alchemy narration
- Bestiary accessibility
- Audio cue glossary / tutorial
- Accessibility config menu with hotkeys

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

### Phase 2: Core Gameplay — DONE (code written, needs in-game testing)
- [x] Player hook with timer-based update loop
- [x] Combat state monitoring (enter/exit detection)
- [x] Enemy tracking via spatial entity queries
- [x] Health monitoring with threshold warnings
- [x] Target lock/change announcements
- [x] Enemy position spatial audio pings
- [x] Player damage detection hook
- [x] Combat speech throttling
- [x] Navigation beacon system (structure + direction)
- [x] Object tracker with entity scanning + classification
- [x] Distance/direction announcements (relative + compass)
- [ ] Quest waypoint position extraction (API verification needed)
- [ ] Attack wind-up warning system (needs animation state access)
- [ ] Dodge/parry detection hooks (method signatures unverified)
- [ ] Wwise soundbank creation

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

## WitcherScript Syntax Rules (Learned from Compilation)

These rules were discovered through in-game compilation testing. Follow them strictly:

1. **No file-level `const` or `var`** — WitcherScript does not allow variable or constant declarations at file scope. Use `@addField(ClassName)` to attach state to game classes, or wrap constants in functions: `function MY_CONST() : String { return "value"; }`

2. **`@wrapMethod` must use `function`, not `event`** — Even if the original method is declared as an event (e.g., Flash callbacks like `OnConfigUI`), the `@wrapMethod` wrapper must use the `function` keyword.

3. **Reserved keywords cannot be used as identifiers** — These words cause compilation errors when used as variable names, struct fields, or function parameters:
   - `entry`, `name`, `parent`, `state`, `out`, `in`
   - Use alternatives like `speechItem` instead of `entry`, `objectName` instead of `name`

4. **All `var` declarations must be at the TOP of function bodies** — Before any executable statements (assignments, function calls, if/return, etc.). This is the most common error source.
   ```
   // WRONG:
   function Foo() {
       DoSomething();
       var x : Int32;     // ERROR: var after executable
   }

   // CORRECT:
   function Foo() {
       var x : Int32;
       DoSomething();
   }
   ```

5. **No inline variable initialization** — `var x : Int32 = 5;` is invalid. Split into declaration then assignment:
   ```
   // WRONG:
   var x : Int32 = 5;

   // CORRECT:
   var x : Int32;
   x = 5;
   ```

6. **`new ClassName` requires `in ownerObject`** — Object instantiation must specify an owner: `new W3BA_Config in this` or `new W3BA_CoreManager in theGame`.

7. **`RoundF()` does not exist** — Use `RoundMath()` for rounding floats to integers.

8. **Mod folder naming** — The mod folder must start with `mod` prefix (e.g., `modW3BlindAccess`) or the game ignores it entirely.

---

## Key Technical Risks

1. **ASI plugin log parsing** — `scriptslog.txt` write frequency and buffering behavior needs testing; may need to hook the log write function directly in the ASI plugin instead of polling the file
2. **Flash UI events** — `@wrapMethod` on `OnInputHandled` is proven in other mods, but the exact class names and method signatures need verification against the actual game scripts
3. **Menu item index mapping** — hardcoded index-to-label maps (main menu, pause menu) may break with DLC or other mods that add menu items
4. **Combat timing** — attack wind-up durations are per-animation and may require reverse engineering (Phase 2)

## Testing Phase 1 (Without ASI Plugin)

A debug overlay has been added so you can visually verify all hook wiring without needing the compiled ASI plugin. When `debugOverlayEnabled` is `true` (the default), every `W3BA_SpeakText()` call shows the text as an on-screen notification via `ShowNotification()`.

### Installation Steps

1. Copy the entire `mods/modW3BlindAccess/` folder into your Witcher 3 installation's `Mods/` directory:
   ```
   <Witcher 3 Install>/Mods/modW3BlindAccess/
   ```
   **Important**: The folder name must start with `mod` or the game will ignore it.
2. Launch the game. The Script Compiler will compile the WitcherScript files on startup.

### What to Check

#### Step 1: Script Compilation
- Launch the game. If the mod has script errors, the game will show a compilation error dialog at startup.
- **Pass**: Game launches to main menu without script errors.
- **Fail**: Note the exact error text — it will identify which file and line has a syntax/type issue.

#### Step 2: Main Menu Narration
- At the main menu, press Up/Down to navigate between items.
- **Expected**: A `[W3BA] Continue`, `[W3BA] New Game`, etc. notification appears on screen when each item is focused.
- **Verify in log**: Open `<UserDocs>/The Witcher 3/scriptslog.txt` and look for lines containing `[W3BA]SPEAK|`.

#### Step 3: Options Menu
- Open Options from the main menu.
- Navigate between tabs and settings.
- **Expected**: `[W3BA] Video settings.`, `[W3BA] Setting 1`, etc. notifications appear.

#### Step 4: Save/Load Screen
- Open Load Game from the main menu.
- Navigate between save slots.
- **Expected**: `[W3BA] Save slot 1`, etc. notifications appear.

#### Step 5: In-Game Pause Menu
- Load a save, then press Escape to open the pause menu.
- Navigate between menu items and tab panels.
- **Expected**: `[W3BA] Resume`, `[W3BA] Inventory panel`, etc. notifications.

#### Step 6: Dialogue Choices
- Enter a dialogue with an NPC.
- **Expected**: `[W3BA] 3 dialogue choices.` and `[W3BA] Choice 1` etc. on focus.

### Known Issues for Testing

- Menu item labels may be wrong — some hooks use hardcoded index-to-label maps that may not match your game version / DLC configuration. Report which indices map to which actual labels.
- Options menu setting names show as "Setting 1", "Setting 2" — the actual `CInGameConfigWrapper` wiring is TODO.
- Save slot descriptions are placeholders.
- `GetCurrentMenuItemIndex()` may not exist on all menu classes — if you see errors referencing this, note which class it fails on.
- Dialogue hook method signatures are assumed — may cause script compilation errors.

### Disabling Debug Overlay

Once the ASI plugin is compiled and working, disable the overlay by adding to `user.settings`:
```ini
[W3BlindAccess]
debugOverlay=false
```
Or via the debug console: the `SetDebugOverlay(false)` method on the TTSBridge.

---

## File Tree

```
mods/modW3BlindAccess/
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
│   │   ├── game/player/
│   │   │   └── W3BA_PlayerHook.ws    # Timer tick, combat hooks, target hooks
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
