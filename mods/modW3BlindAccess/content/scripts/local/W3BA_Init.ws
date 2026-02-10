// W3BlindAccess - Mod Initialization
// Entry point for the blind accessibility mod
//
// This file provides:
//   - Global accessor for the core manager singleton
//   - Convenience functions callable from anywhere (hooks, menus, etc.)
//   - Audio cue ID helper functions

// ---------------------------------------------------------------
// Audio Cue ID Functions
// WitcherScript does not support file-level const or var declarations,
// so we use functions that return constant strings.
// ---------------------------------------------------------------

// UI sounds
function W3BA_CUE_MENU_FOCUS()  : String { return "ui_menu_focus"; }
function W3BA_CUE_MENU_SELECT() : String { return "ui_menu_select"; }
function W3BA_CUE_MENU_BACK()   : String { return "ui_menu_back"; }
function W3BA_CUE_UI_ERROR()    : String { return "ui_error"; }

// Navigation beacons
function W3BA_CUE_BEACON_MAIN() : String { return "beacon_quest_main"; }
function W3BA_CUE_BEACON_SIDE() : String { return "beacon_quest_side"; }
function W3BA_CUE_BEACON_POI()  : String { return "beacon_poi"; }

// Combat
function W3BA_CUE_ENEMY_DETECTED()       : String { return "enemy_detected"; }
function W3BA_CUE_ENEMY_ATTACK_LIGHT()   : String { return "enemy_attack_light"; }
function W3BA_CUE_ENEMY_ATTACK_HEAVY()   : String { return "enemy_attack_heavy"; }
function W3BA_CUE_ENEMY_ATTACK_UNBLOCK() : String { return "enemy_attack_unblockable"; }
function W3BA_CUE_PLAYER_HIT()           : String { return "player_hit"; }
function W3BA_CUE_PLAYER_DODGE()         : String { return "player_dodge_success"; }
function W3BA_CUE_PLAYER_PARRY()         : String { return "player_parry_success"; }
function W3BA_CUE_HEALTH_LOW()           : String { return "health_low_warning"; }
function W3BA_CUE_HEALTH_CRITICAL()      : String { return "health_critical_warning"; }

// Object detection
function W3BA_CUE_OBJ_CONTAINER() : String { return "object_container"; }
function W3BA_CUE_OBJ_HERB()      : String { return "object_herb"; }
function W3BA_CUE_OBJ_NPC()       : String { return "object_npc"; }
function W3BA_CUE_OBJ_DOOR()      : String { return "object_door"; }
function W3BA_CUE_OBJ_LOOT()      : String { return "object_loot"; }

// ---------------------------------------------------------------
// Speech priority helpers
// ---------------------------------------------------------------

function W3BA_PRIORITY_LOW()    : int { return 0; }
function W3BA_PRIORITY_MEDIUM() : int { return 1; }
function W3BA_PRIORITY_HIGH()   : int { return 2; }
function W3BA_PRIORITY_URGENT() : int { return 3; }

// ---------------------------------------------------------------
// Core Manager Singleton
// ---------------------------------------------------------------

// Store the core manager on the player via @addField.
// Using CR4Player instead of CR4Game to avoid const assignment issues.
// WitcherScript does not support file-level var declarations.
@addField(CR4Player)
var w3ba_coreManager : W3BA_CoreManager;

function W3BA_GetCoreManager() : W3BA_CoreManager
{
    if (!thePlayer) { return NULL; }
    return thePlayer.w3ba_coreManager;
}

function W3BA_EnsureInitialized()
{
    if (!thePlayer) { return; }

    if (!thePlayer.w3ba_coreManager)
    {
        thePlayer.w3ba_coreManager = new W3BA_CoreManager in thePlayer;
        thePlayer.w3ba_coreManager.Initialize();
    }
}

// ---------------------------------------------------------------
// Global Convenience Functions
// ---------------------------------------------------------------

// Speak text via TTS. Safe to call even if mod not fully initialized.
function W3BA_SpeakText(text : String, interrupt : Bool, optional priority : Int32)
{
    var core : W3BA_CoreManager;

    W3BA_EnsureInitialized();

    core = W3BA_GetCoreManager();
    if (core && core.GetTTSBridge())
    {
        core.GetTTSBridge().Speak(text, interrupt, priority);
    }
}

// Play a non-spatial UI audio cue
function W3BA_PlayCue(cueId : String)
{
    var core : W3BA_CoreManager;
    core = W3BA_GetCoreManager();
    if (core && core.GetAudioManager())
    {
        core.GetAudioManager().PlayCue(cueId);
    }
}

// Play a 3D positioned audio cue
function W3BA_PlayCue3D(cueId : String, worldPosition : Vector, optional pitch : Float)
{
    var core : W3BA_CoreManager;
    core = W3BA_GetCoreManager();
    if (core && core.GetAudioManager())
    {
        core.GetAudioManager().PlayCue3D(cueId, worldPosition, pitch);
    }
}
