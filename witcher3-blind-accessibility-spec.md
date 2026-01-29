# Witcher 3 Blind Accessibility Mod — Development Specification

> **Project Codename**: `W3BlindAccess`  
> **Target Game**: The Witcher 3: Wild Hunt (Next-Gen/4.x)  
> **Platform**: PC (Windows)  
> **Goal**: Enable fully blind players to complete the main story and core gameplay

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Current State Assessment](#2-current-state-assessment)
3. [Technical Architecture](#3-technical-architecture)
4. [Feature Specifications](#4-feature-specifications)
5. [Development Phases](#5-development-phases)
6. [File Structure & Code Locations](#6-file-structure--code-locations)
7. [Dependencies & Tools](#7-dependencies--tools)
8. [Testing Requirements](#8-testing-requirements)
9. [Open Questions & Risks](#9-open-questions--risks)

---

## 1. Executive Summary

### 1.1 Project Goal

Create a comprehensive accessibility mod that enables blind players to:
- Navigate all game menus independently
- Follow quest objectives through audio guidance
- Engage in combat using spatial audio cues
- Manage inventory, equipment, and crafting systems
- Experience the full narrative (already voice-acted)

### 1.2 Success Criteria

A blind player with no sighted assistance can:
- [ ] Start a new game and configure settings
- [ ] Complete the White Orchard tutorial area
- [ ] Navigate to quest objectives in open world
- [ ] Win combat encounters on Easy difficulty
- [ ] Manage inventory and equip items
- [ ] Save/load game progress
- [ ] Complete Act 1 of the main story

### 1.3 What Already Exists (We Can Leverage)

| Feature | Status | Notes |
|---------|--------|-------|
| Full voice acting for dialogue | ✅ Complete | All main/side quest dialogue is voiced |
| Subtitle system | ✅ Complete | Text strings extractable from .w3strings |
| Quest waypoint system | ✅ Complete | Minimap markers have world positions |
| REDkit modding tools | ✅ Available | Full script/UI/audio modification support |
| WitcherScript access | ✅ Available | All game logic is scriptable |
| Friendly HUD mod (reference) | ✅ Available | Shows 3D waypoint positioning code |
| Wwise audio integration | ✅ Available | Spatial audio fully supported |

### 1.4 What's Completely Missing (We Must Build)

| Feature | Priority | Complexity |
|---------|----------|------------|
| Screen reader (TTS) integration | 🔴 Critical | High |
| Menu narration system | 🔴 Critical | Medium |
| Combat audio cue system | 🔴 Critical | Very High |
| Quest waypoint audio beacons | 🔴 Critical | Medium |
| Enemy position sonification | 🔴 Critical | High |
| Interactable object detection | 🟡 Important | Medium |
| Inventory narration | 🟡 Important | Medium |
| Attack warning sounds | 🟡 Important | High |
| Object tracker/scanner | 🟢 Enhancement | Medium |
| Audio cue glossary | 🟢 Enhancement | Low |

---

## 2. Current State Assessment

### 2.1 Native Accessibility Features (Insufficient for Blind Players)

```
EXISTING IN GAME:
├── Subtitles (on/off, size scaling)
├── HUD element scaling
├── Colorblind mode for Witcher Senses
├── Full dialogue voice acting
├── Controller support with vibration
└── Difficulty settings (can reduce combat challenge)

NOT EXISTING:
├── Screen reader / TTS support
├── Audio menu navigation
├── Spatial audio cues for gameplay
├── Non-visual combat feedback
├── Quest guidance without minimap
└── Inventory management without visuals
```

### 2.2 Relevant Existing Mods (Reference Only)

| Mod | What We Can Learn |
|-----|-------------------|
| **Friendly HUD** | 3D world-space marker positioning, script hooks for quest data |
| **All Quest Objectives on Map** | Quest objective data extraction methods |
| **Debug Console Enabler** | Runtime script injection patterns |
| **Improved Sign Effects** | Audio trigger implementation examples |

### 2.3 Reference Implementations from Other Games

**The Last of Us Part II** (Gold Standard):
- Navigation assistance: Single button orients to objective
- Audio beacons: Directional ping toward waypoints
- Combat audio: Enemy position via 3D spatial sound
- Screen reader: Full TTS for all UI text
- Audio cue glossary: Preview all sounds before gameplay

**Stardew Access Mod** (Community Reference):
- GitHub: `github.com/khanshoaib3/stardew-access`
- Tolk library integration for screen readers
- Tile-based navigation with distance/direction
- Object tracker cycling through nearby items
- Category-based object filtering

**Minecraft Access Mod** (Community Reference):
- GitHub: `github.com/khanshoaib3/Minecraft-Access`  
- Entity tracking with spatial audio
- Coordinate-based navigation
- Block interaction narration

---

## 3. Technical Architecture

### 3.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        W3BlindAccess Mod                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │   TTS       │  │   Audio     │  │   Game State            │ │
│  │   Bridge    │  │   Manager   │  │   Monitor               │ │
│  │             │  │             │  │                         │ │
│  │ - Tolk.dll  │  │ - Wwise     │  │ - Menu state tracking   │ │
│  │ - NVDA      │  │ - 3D audio  │  │ - Combat state          │ │
│  │ - JAWS      │  │ - Cue lib   │  │ - Quest objectives      │ │
│  │ - Narrator  │  │             │  │ - Player position       │ │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘ │
│         │                │                     │               │
│         └────────────────┼─────────────────────┘               │
│                          │                                     │
│                    ┌─────▼─────┐                               │
│                    │  Core     │                               │
│                    │  Manager  │                               │
│                    │           │                               │
│                    │ - Config  │                               │
│                    │ - Hooks   │                               │
│                    │ - Events  │                               │
│                    └─────┬─────┘                               │
│                          │                                     │
├──────────────────────────┼─────────────────────────────────────┤
│                          ▼                                     │
│              WitcherScript Game Hooks                          │
│   (Menu events, combat events, quest updates, input)           │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Module Breakdown

#### Module 1: TTS Bridge (`ttsBridge`)
**Purpose**: Connect WitcherScript to Windows screen readers

```
Responsibilities:
- Load and interface with Tolk.dll (or alternative)
- Queue text for narration with priority levels
- Handle speech interruption for rapid navigation
- Provide fallback to Windows SAPI if no screen reader

Interface:
- Speak(text: string, interrupt: bool, priority: int)
- SpeakSync(text: string) — blocking call
- Silence() — stop current speech
- IsScreenReaderActive() -> bool
- GetActiveScreenReader() -> string
```

#### Module 2: Audio Manager (`audioManager`)
**Purpose**: Play spatial and non-spatial audio cues

```
Responsibilities:
- Load custom soundbank with accessibility cues
- Play 3D positioned sounds (enemy locations, waypoints)
- Play UI feedback sounds (menu navigation, selection)
- Manage audio cue volume separate from game audio

Interface:
- PlayCue(cueId: string)
- PlayCue3D(cueId: string, worldPosition: Vector3)
- PlayBeacon(worldPosition: Vector3, interval: float)
- StopBeacon()
- SetAccessibilityVolume(volume: float)
```

#### Module 3: Game State Monitor (`stateMonitor`)
**Purpose**: Track game state and trigger accessibility events

```
Responsibilities:
- Monitor current menu/screen state
- Track combat state (in combat, enemies, targeting)
- Track quest state (active objective, waypoint position)
- Monitor player state (health, position, facing)

Events Emitted:
- OnMenuChanged(menuId: string, menuState: object)
- OnMenuItemFocused(itemText: string, itemIndex: int)
- OnCombatStarted(enemies: array)
- OnEnemyAttacking(enemy: object, attackType: string)
- OnQuestObjectiveChanged(objective: object)
- OnHealthChanged(current: int, max: int)
```

#### Module 4: Core Manager (`coreManager`)
**Purpose**: Coordinate all modules and handle configuration

```
Responsibilities:
- Initialize all modules on game start
- Load/save accessibility settings
- Route events between modules
- Handle hotkey bindings for accessibility features

Configuration Options:
- TTS enabled (bool)
- TTS speech rate (float 0.5-2.0)
- Combat audio enabled (bool)
- Navigation beacon enabled (bool)
- Beacon interval (float seconds)
- Combat cue volume (float 0-1)
- Menu narration verbosity (low/medium/high)
```

### 3.3 Data Flow Examples

**Menu Navigation Flow:**
```
User presses DOWN in menu
    → Game updates menu selection
    → stateMonitor.OnMenuItemFocused("New Game", 0)
    → coreManager routes to TTS
    → ttsBridge.Speak("New Game", interrupt=true)
    → audioManager.PlayCue("ui_menu_move")
```

**Combat Enemy Detection Flow:**
```
Enemy enters aggro range
    → Game triggers combat state
    → stateMonitor.OnCombatStarted([enemy1, enemy2])
    → coreManager calculates relative positions
    → audioManager.PlayCue3D("enemy_detected", enemy1.position)
    → ttsBridge.Speak("2 enemies", interrupt=false)
```

**Quest Navigation Flow:**
```
User presses BEACON_KEY (configurable)
    → coreManager gets active quest waypoint
    → audioManager.PlayBeacon(waypointPosition, interval=2.0)
    → ttsBridge.Speak("Objective: 150 meters north", interrupt=true)
```

---

## 4. Feature Specifications

### 4.1 FEATURE: Menu Text-to-Speech

**ID**: `F001-MENU-TTS`  
**Priority**: 🔴 Critical (Phase 1)  
**Complexity**: Medium

#### Description
All menu text is read aloud via screen reader when focused/selected.

#### Acceptance Criteria
- [ ] Main menu options narrated on focus
- [ ] Settings menu options narrated with current values
- [ ] Dialogue choices narrated before selection
- [ ] Inventory item names narrated on focus
- [ ] Quest log entries narrated
- [ ] Save/load slot information narrated
- [ ] Confirmation dialogs narrated

#### Technical Approach
1. Hook into Flash UI focus change events
2. Extract text from focused UI element
3. Send to TTS bridge with appropriate priority
4. Play UI navigation sound cue

#### Script Hooks Required
```witcherscript
// File: mods/W3BlindAccess/content/scripts/game/gui/menus/menuBase.ws

// Hook menu item focus changes
event OnMenuItemFocused(itemIndex: int, itemData: CMenuItemData) {
    var itemText: string = itemData.GetLocalizedText();
    W3BA_SpeakText(itemText, true, PRIORITY_HIGH);
    W3BA_PlayCue("ui_focus");
}
```

#### Text Sources
| Menu | Text Location |
|------|---------------|
| Main Menu | `content/strings/en.w3strings` key `menu_*` |
| Inventory | Item definitions in `gameplay/items/` |
| Quest Log | Quest definitions + objective strings |
| Dialogue | `scenes/*.w2scene` dialogue entries |

---

### 4.2 FEATURE: Quest Waypoint Audio Beacon

**ID**: `F002-QUEST-BEACON`  
**Priority**: 🔴 Critical (Phase 2)  
**Complexity**: Medium

#### Description
Directional audio beacon guides player toward active quest objective.

#### Acceptance Criteria
- [ ] Beacon plays at configurable interval (default 2 seconds)
- [ ] Sound is spatially positioned toward objective
- [ ] Pitch/tone indicates distance (higher = closer)
- [ ] Can toggle beacon on/off with hotkey
- [ ] Announces distance and cardinal direction on activation
- [ ] Different beacon sound for main quest vs side quest

#### Technical Approach
1. Read active quest waypoint from quest manager
2. Calculate vector from player to waypoint
3. Convert to 3D audio position
4. Play looping beacon with Wwise spatial audio
5. Adjust pitch based on distance

#### Implementation Pseudocode
```witcherscript
// File: mods/W3BlindAccess/content/scripts/core/navigation.ws

class W3BA_NavigationBeacon {
    private var isActive: bool;
    private var beaconInterval: float;
    private var lastBeaconTime: float;
    
    public function Update(deltaTime: float) {
        if (!isActive) return;
        
        lastBeaconTime += deltaTime;
        if (lastBeaconTime >= beaconInterval) {
            PlayBeacon();
            lastBeaconTime = 0;
        }
    }
    
    private function PlayBeacon() {
        var player: CPlayer = thePlayer;
        var questManager: CQuestManager = theGame.GetQuestManager();
        var waypoint: Vector = questManager.GetActiveWaypointPosition();
        
        if (waypoint == Vector(0,0,0)) return;
        
        var distance: float = VecDistance(player.GetWorldPosition(), waypoint);
        var direction: Vector = VecNormalize(waypoint - player.GetWorldPosition());
        
        // Pitch modifier: 0.5 at 500m, 2.0 at 0m
        var pitch: float = MapRange(distance, 0, 500, 2.0, 0.5);
        
        W3BA_PlayCue3D("beacon_quest", waypoint, pitch);
    }
    
    public function AnnounceObjective() {
        var waypoint: Vector = GetActiveWaypoint();
        var distance: float = GetDistanceToWaypoint();
        var cardinal: string = GetCardinalDirection(waypoint);
        
        var text: string = "Objective: " + RoundToInt(distance) + " meters " + cardinal;
        W3BA_SpeakText(text, true, PRIORITY_HIGH);
    }
}
```

#### Audio Assets Required
| Cue ID | Description | Properties |
|--------|-------------|------------|
| `beacon_quest_main` | Main quest beacon ping | 3D, pitch-variable |
| `beacon_quest_side` | Side quest beacon ping | 3D, pitch-variable |
| `beacon_poi` | Point of interest beacon | 3D, softer tone |

---

### 4.3 FEATURE: Combat Audio Cues

**ID**: `F003-COMBAT-AUDIO`  
**Priority**: 🔴 Critical (Phase 2)  
**Complexity**: Very High

#### Description
Audio system providing spatial awareness of enemies and combat timing.

#### Acceptance Criteria
- [ ] Enemy positions indicated by 3D spatial audio
- [ ] Different sounds for enemy types (human, monster, boss)
- [ ] Attack wind-up has distinct warning sound
- [ ] Unblockable attacks have unique warning
- [ ] Successful hit confirmation sound
- [ ] Successful dodge/parry confirmation sound
- [ ] Low health warning (audio + TTS)
- [ ] Target lock confirmation sound
- [ ] Target switch confirmation sound

#### Combat Events to Hook

```witcherscript
// Events we need to capture from combat system

// File: gameplay/combat/combatManager.ws
event OnCombatStarted()
event OnCombatEnded()
event OnEnemySpawned(enemy: CActor)
event OnEnemyDied(enemy: CActor)

// File: gameplay/combat/attackHandler.ws  
event OnEnemyAttackStarted(enemy: CActor, attackType: EAttackType)
event OnPlayerHit(damage: float, attacker: CActor)
event OnPlayerDodged(attackType: EAttackType)
event OnPlayerParried(attacker: CActor)

// File: r4player.ws
event OnTargetLocked(target: CActor)
event OnTargetChanged(oldTarget: CActor, newTarget: CActor)
```

#### Audio Cue Design

| Situation | Audio Design | Timing |
|-----------|--------------|--------|
| Enemy detected | Low rumble from enemy direction | On aggro |
| Enemy attacking (light) | Quick ascending tone | 0.5s before hit |
| Enemy attacking (heavy) | Longer ascending tone | 0.8s before hit |
| Unblockable attack | Harsh buzzer + ascending tone | 1.0s before hit |
| Player hit | Impact thud + pain indicator | On hit |
| Player dodged | Whoosh + subtle chime | On successful dodge |
| Player parried | Metal clang + confirm tone | On successful parry |
| Low health (<25%) | Heartbeat + periodic warning | Continuous |
| Critical health (<10%) | Rapid heartbeat + urgent tone | Continuous |

#### Implementation Notes
- Combat timing is frame-dependent; audio cues must account for latency
- Enemy attack wind-up durations vary; need per-attack-type timing data
- Multiple simultaneous enemies = multiple audio streams = potential cacophony
- Consider "threat priority" system to emphasize most dangerous enemy

---

### 4.4 FEATURE: Interactable Object Detection

**ID**: `F004-OBJECT-DETECTION`  
**Priority**: 🟡 Important (Phase 2)  
**Complexity**: Medium

#### Description
Audio notification when near interactable objects (loot, doors, NPCs, herbs).

#### Acceptance Criteria
- [ ] Distinct sound for each object category
- [ ] Sound is spatially positioned at object
- [ ] Volume/intensity based on proximity
- [ ] Can filter categories (e.g., "only loot containers")
- [ ] Hotkey to announce nearest interactable with details

#### Object Categories

| Category | Sound Character | Example Objects |
|----------|-----------------|-----------------|
| Container | Wooden creak | Chests, barrels, crates |
| Herb | Soft natural chime | Herbs, flowers, ingredients |
| NPC | Voice murmur | Merchants, quest givers |
| Door | Metal/wood knock | Doors, gates |
| Loot | Coin jingle | Dropped items, bodies |
| Clue | Mystical hum | Witcher senses objects |
| Crafting | Anvil tap | Blacksmiths, armorers |

#### Detection Logic
```witcherscript
class W3BA_ObjectDetector {
    private var detectionRadius: float = 10.0;
    private var scanInterval: float = 0.5;
    
    public function ScanNearbyObjects() -> array<W3BA_InteractableInfo> {
        var player: CPlayer = thePlayer;
        var playerPos: Vector = player.GetWorldPosition();
        var results: array<W3BA_InteractableInfo>;
        
        // Query game's interactable system
        var interactables: array<CInteractableComponent>;
        theGame.GetInteractablesInRange(playerPos, detectionRadius, interactables);
        
        for (var i: int = 0; i < interactables.Size(); i += 1) {
            var info: W3BA_InteractableInfo;
            info.position = interactables[i].GetWorldPosition();
            info.category = ClassifyInteractable(interactables[i]);
            info.distance = VecDistance(playerPos, info.position);
            info.name = interactables[i].GetLocalizedName();
            results.PushBack(info);
        }
        
        // Sort by distance
        SortByDistance(results);
        return results;
    }
}
```

---

### 4.5 FEATURE: Inventory Narration

**ID**: `F005-INVENTORY-TTS`  
**Priority**: 🟡 Important (Phase 3)  
**Complexity**: Medium

#### Description
Full TTS support for inventory management, equipment, and item details.

#### Acceptance Criteria
- [ ] Item name read on focus
- [ ] Item category announced
- [ ] Item stats read (damage, armor, etc.)
- [ ] Item description available on secondary action
- [ ] Equipped vs unequipped status announced
- [ ] Comparison to currently equipped item
- [ ] Stack count for consumables
- [ ] Rarity level announced

#### Narration Template
```
[On item focus - brief]
"Steel Sword, Equipped, 85 damage"

[On detail request - verbose]  
"Viper Steel Sword. Relic quality. 
 Damage: 85 to 104. 
 Bonus: Plus 15% critical hit chance.
 Currently equipped in steel sword slot.
 Description: A blade forged by Witchers of the Viper school."

[On comparison]
"Viper Steel Sword. 85 damage.
 Compared to equipped: Plus 12 damage, minus 5% critical chance."
```

#### Data Extraction
Item data stored in:
- `gameplay/items/definitions/*.xml` — base item stats
- `localization/en/items.w3strings` — localized names/descriptions
- Player inventory state in `r4player.ws`

---

### 4.6 FEATURE: Object Tracker / Scanner

**ID**: `F006-OBJECT-TRACKER`  
**Priority**: 🟢 Enhancement (Phase 3)  
**Complexity**: Medium

#### Description
Cycle through nearby objects by category, with distance and direction.

#### Acceptance Criteria
- [ ] Hotkey to activate tracker mode
- [ ] Cycle forward/backward through objects
- [ ] Filter by category
- [ ] Announce: name, category, distance, direction
- [ ] Optional: auto-navigate toward selected object

#### User Interaction
```
[Press TRACKER_KEY]
"Object tracker active. 5 containers, 3 herbs, 1 NPC nearby."

[Press NEXT_OBJECT]
"Chest, 8 meters, northeast"

[Press NEXT_OBJECT]  
"Barrel, 12 meters, west"

[Press CATEGORY_FILTER]
"Filter: Herbs only"

[Press NEXT_OBJECT]
"Celandine, 5 meters, south"
```

---

## 5. Development Phases

### Phase 1: Foundation (Weeks 1-8)

**Goal**: Basic menu accessibility and TTS infrastructure

| Week | Tasks |
|------|-------|
| 1-2 | Set up REDkit development environment; create mod scaffold |
| 2-3 | Research and implement Tolk/TTS bridge (may require native DLL) |
| 3-4 | Hook main menu; implement basic narration |
| 4-5 | Extend to settings menu, save/load screens |
| 5-6 | Implement dialogue choice narration |
| 6-7 | Add pause menu accessibility (inventory list, journal, map—basic) |
| 7-8 | Create basic UI audio cue soundbank; implement navigation sounds |

**Deliverables**:
- [ ] TTS bridge functional with NVDA/JAWS/Narrator
- [ ] Main menu fully navigable by blind user
- [ ] Can start new game and configure basic settings
- [ ] Dialogue choices readable
- [ ] Save/load functional

### Phase 2: Core Gameplay (Weeks 9-20)

**Goal**: Combat playability and quest navigation

| Week | Tasks |
|------|-------|
| 9-10 | Implement quest waypoint beacon system |
| 10-11 | Add distance/direction announcements |
| 11-13 | Build combat state monitoring (enemy detection, targeting) |
| 13-15 | Design and implement combat audio cue vocabulary |
| 15-17 | Implement attack warning system |
| 17-18 | Add interactable object detection (passive) |
| 18-19 | Implement health/status audio feedback |
| 19-20 | Playtesting and iteration with blind testers |

**Deliverables**:
- [ ] Can navigate to quest objectives with audio beacon
- [ ] Combat encounters survivable with audio cues
- [ ] Can detect and interact with key objects
- [ ] Health status conveyed through audio

### Phase 3: Full System Access (Weeks 21-28)

**Goal**: Complete game system accessibility

| Week | Tasks |
|------|-------|
| 21-22 | Full inventory narration implementation |
| 22-23 | Equipment comparison and management |
| 23-24 | Crafting/alchemy narration |
| 24-25 | Object tracker / scanner implementation |
| 25-26 | Bestiary accessibility |
| 26-27 | Audio cue glossary / tutorial |
| 27-28 | Configuration menu for all accessibility options |

**Deliverables**:
- [ ] Full inventory management via TTS
- [ ] Crafting/alchemy usable
- [ ] Object tracker functional
- [ ] All features configurable

### Phase 4: Polish (Weeks 29+)

**Goal**: Refinement and advanced features

- Environmental audio descriptions for key locations
- Cutscene supplementary narration (visual-only story beats)
- Controller haptic patterns
- Performance optimization
- Documentation and user guide
- Community feedback integration

---

## 6. File Structure & Code Locations

### 6.1 Mod Directory Structure

```
mods/
└── W3BlindAccess/
    ├── content/
    │   ├── scripts/
    │   │   ├── local/
    │   │   │   └── W3BA_Init.ws              # Mod initialization
    │   │   ├── core/
    │   │   │   ├── W3BA_CoreManager.ws       # Central coordinator
    │   │   │   ├── W3BA_Config.ws            # Configuration handling
    │   │   │   └── W3BA_Events.ws            # Event system
    │   │   ├── tts/
    │   │   │   ├── W3BA_TTSBridge.ws         # Screen reader interface
    │   │   │   └── W3BA_SpeechQueue.ws       # Speech priority queue
    │   │   ├── audio/
    │   │   │   ├── W3BA_AudioManager.ws      # Audio cue playback
    │   │   │   └── W3BA_SpatialAudio.ws      # 3D positioning
    │   │   ├── navigation/
    │   │   │   ├── W3BA_Beacon.ws            # Quest waypoint beacon
    │   │   │   └── W3BA_ObjectTracker.ws     # Interactable scanner
    │   │   ├── combat/
    │   │   │   ├── W3BA_CombatMonitor.ws     # Combat state tracking
    │   │   │   └── W3BA_CombatCues.ws        # Combat audio cues
    │   │   ├── ui/
    │   │   │   ├── W3BA_MenuNarrator.ws      # Menu TTS
    │   │   │   └── W3BA_InventoryNarrator.ws # Inventory TTS
    │   │   └── game/
    │   │       └── gui/
    │   │           └── menus/
    │   │               └── [override files]   # Menu hooks
    │   ├── sounds/
    │   │   └── W3BA_Soundbank.bnk            # Custom Wwise soundbank
    │   └── strings/
    │       └── en.w3strings                   # Localized TTS strings
    ├── bin/
    │   └── x64/
    │       └── plugins/
    │           └── W3BA_Native.dll            # Native TTS bridge (if needed)
    └── README.md
```

### 6.2 Key Game Files to Hook/Modify

```
# Menu System
content0/scripts/game/gui/menus/
├── commonIngameMenu.ws          # Base menu class - ADD narration hooks
├── mainMenu.ws                  # Main menu - ADD focus narration
├── inventoryMenu.ws             # Inventory - ADD item narration
├── journalQuestMenu.ws          # Quest log - ADD quest narration
├── meditationMenu.ws            # Meditation - ADD time narration
└── mapMenu.ws                   # Map - ADD POI list narration

# Combat System
content0/scripts/game/gameplay/
├── combat/
│   ├── combatManager.ws         # Combat state - ADD event emitters
│   └── attackHandler.ws         # Attack detection - ADD warning events
└── player/
    └── r4player.ws              # Player state - ADD health monitoring

# Quest System  
content0/scripts/game/quests/
└── questManager.ws              # Quest tracking - ADD objective events

# HUD System
content0/scripts/game/gui/hud/
└── modules/
    ├── hudModuleMinimap.ws      # Minimap data - READ waypoint positions
    └── hudModuleQuests.ws       # Quest display - READ active objectives
```

### 6.3 Wwise Audio Setup

```
Wwise Project: W3BA_Audio.wproj

Events/
├── UI/
│   ├── ui_menu_focus
│   ├── ui_menu_select
│   ├── ui_menu_back
│   └── ui_error
├── Navigation/
│   ├── beacon_quest_main
│   ├── beacon_quest_side
│   └── beacon_poi
├── Combat/
│   ├── enemy_detected
│   ├── enemy_attack_light
│   ├── enemy_attack_heavy
│   ├── enemy_attack_unblockable
│   ├── player_hit
│   ├── player_dodge_success
│   ├── player_parry_success
│   ├── health_low_warning
│   └── health_critical_warning
└── Objects/
    ├── object_container
    ├── object_herb
    ├── object_npc
    ├── object_door
    └── object_loot
```

---

## 7. Dependencies & Tools

### 7.1 Required Development Tools

| Tool | Purpose | Download |
|------|---------|----------|
| **REDkit** | Official Witcher 3 mod tools | Steam (free with game) |
| **WolvenKit** | File extraction/packing | github.com/WolvenKit/WolvenKit |
| **Wwise** | Audio middleware | audiokinetic.com (free license) |
| **Visual Studio Code** | WitcherScript editing | code.visualstudio.com |
| **VS Code WitcherScript extension** | Syntax highlighting | Marketplace |

### 7.2 Runtime Dependencies

| Dependency | Purpose | Integration |
|------------|---------|-------------|
| **Tolk.dll** | Screen reader abstraction | github.com/dkager/tolk |
| **NVDA** (user's machine) | Primary screen reader | Optional user install |
| **Windows SAPI** | Fallback TTS | Built into Windows |

### 7.3 Reference Repositories

```
# Accessibility mod references
github.com/khanshoaib3/stardew-access    # Stardew Valley blind mod
github.com/khanshoaib3/Minecraft-Access  # Minecraft blind mod
github.com/dkager/tolk                   # Screen reader abstraction

# Witcher 3 modding references
github.com/nicoudelon/FriendlyHUD        # 3D marker positioning
github.com/WolvenKit/WolvenKit           # File tools
github.com/witcherscript/witcherscript   # Language documentation
```

---

## 8. Testing Requirements

### 8.1 Test Environment Setup

- Windows 10/11 with Witcher 3 Next-Gen (v4.x)
- NVDA screen reader installed
- REDkit and mod development environment
- Test save files at various game points

### 8.2 Testing Checklist by Feature

#### TTS/Menu Testing
```
[ ] NVDA announces main menu options
[ ] JAWS announces main menu options (if available)
[ ] Windows Narrator announces main menu options
[ ] Speech interrupts on rapid navigation
[ ] Settings values read with option names
[ ] Dialogue choices read before selection
[ ] No speech when TTS disabled in settings
```

#### Navigation Testing
```
[ ] Beacon plays toward active quest marker
[ ] Beacon pitch changes with distance
[ ] Distance announcement is accurate (±10%)
[ ] Cardinal directions are correct
[ ] Beacon stops when disabled
[ ] Works in all major zones (White Orchard, Velen, Novigrad, Skellige)
```

#### Combat Testing
```
[ ] Enemy detection triggers on aggro
[ ] Enemy position audio is directionally accurate
[ ] Light attack warning gives sufficient reaction time
[ ] Heavy attack warning distinguishable from light
[ ] Unblockable attack warning is urgent and distinct
[ ] Can complete White Orchard ghoul fight with audio only
[ ] Low health warning triggers at correct threshold
```

### 8.3 Blind Tester Protocol

**Required**: At least 2 blind testers involved from Phase 1

**Testing Sessions**:
1. Initial TTS verification (can they hear narration?)
2. Menu navigation (can they start a new game?)
3. Dialogue interaction (can they follow conversations?)
4. Combat (can they survive basic encounters?)
5. Navigation (can they reach quest objectives?)
6. Full gameplay session (30+ minutes)

**Feedback Collection**:
- Audio recording of testing sessions
- Real-time observation notes
- Post-session structured interview
- Pain point and confusion documentation

---

## 9. Open Questions & Risks

### 9.1 Technical Unknowns

| Question | Risk Level | Mitigation |
|----------|------------|------------|
| Can WitcherScript load native DLLs? | High | May need ASI loader or alternative injection |
| Are combat attack timings accessible in scripts? | Medium | May need to reverse-engineer attack data |
| Can Wwise soundbanks be added via mod? | Medium | Documented but complex; may need audio hooks |
| Flash UI focus events accessible? | Medium | May need UI element polling instead |

### 9.2 Known Risks

**Risk**: TTS bridge impossible in pure WitcherScript
- **Impact**: High — blocks all narration features
- **Mitigation**: Research ASI loader plugins; consider file-based IPC

**Risk**: Combat audio cues cause information overload
- **Impact**: Medium — makes combat unplayable
- **Mitigation**: Priority system; configurable verbosity; user testing early

**Risk**: Open world navigation fundamentally requires vision
- **Impact**: Medium — limits exploration
- **Mitigation**: Focus on quest-to-quest navigation; accept some limitations

**Risk**: Performance impact from continuous scanning
- **Impact**: Low-Medium — could affect gameplay
- **Mitigation**: Throttled scanning; efficient spatial queries

### 9.3 Scope Boundaries (Explicitly Out of Scope for v1.0)

- Gwent card game accessibility (complex mini-game)
- Horse race accessibility
- Detailed world map exploration (focus on quest waypoints only)
- Complete audio descriptions of all cutscenes
- Multiplayer (game is single-player)

---

## Appendix A: WitcherScript Quick Reference

### Basic Syntax
```witcherscript
// Class definition
class MyClass {
    private var myVar: int;
    
    public function MyFunction(param: string) -> bool {
        return true;
    }
}

// Getting player reference
var player: CPlayer = thePlayer;
var pos: Vector = player.GetWorldPosition();

// Getting game systems
var questMgr: CQuestManager = theGame.GetQuestManager();
var guiMgr: CR4GuiManager = theGame.GetGuiManager();

// Event handling
event OnSpawned(spawnData: SEntitySpawnData) {
    // Called when entity spawns
}

// Timer
theGame.GetTimerManager().AddTimer('MyTimer', 1.0, this, true);
timer function MyTimer(deltaTime: float) {
    // Called every 1.0 seconds
}
```

### Common Data Types
```witcherscript
int, float, bool, string
Vector (x, y, z, w)
EulerAngles (pitch, yaw, roll)
array<Type>
CName (hashed string identifier)
```

---

## Appendix B: Audio Cue Design Guidelines

### Principles for Blind-Accessible Audio

1. **Distinctiveness**: Each cue must be instantly recognizable
2. **Learnability**: Cues should be intuitive or quickly learnable
3. **Non-fatiguing**: Repeated cues shouldn't become annoying
4. **Prioritized**: Urgent cues cut through ambient noise
5. **Spatial**: Directional cues must be accurate in 3D space

### Recommended Audio Characteristics

| Cue Type | Characteristics |
|----------|-----------------|
| UI navigation | Short clicks, distinct pitch per direction |
| UI selection | Satisfying confirm sound, slightly longer |
| UI error | Distinct "blocked" sound, not harsh |
| Quest beacon | Organic ping, variable pitch for distance |
| Enemy position | Low ambient rumble, directional |
| Attack warning | Rising tone, urgency matches threat |
| Damage feedback | Impact + pain without being disturbing |
| Health warning | Heartbeat pattern, increases with danger |

---

## Appendix C: Contact & Community Resources

### Development Community
- **Witcher 3 Modding Discord**: Primary modding community
- **REDkit Discord**: Official CDPR modding support
- **Playability Discord**: Blind accessibility mod community

### Accessibility Consultants
- audiogames.net forum — blind gaming community
- r/blindgamers — Reddit community
- AppleVis — broader accessibility tech community

### Existing Documentation
- REDkit Wiki: cdprojektred.atlassian.net/wiki/spaces/W3REDkit/
- WitcherScript Docs: witcherscript.readthedocs.io
- Wwise Documentation: audiokinetic.com/documentation/

---

*Document Version: 1.0*  
*Last Updated: January 2025*  
*Status: Ready for Development*
