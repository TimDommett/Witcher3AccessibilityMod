// W3BlindAccess - Mod Initialization
// Entry point for the blind accessibility mod
//
// This file provides:
//   - Global accessor for the core manager singleton
//   - Convenience functions callable from anywhere (hooks, menus, etc.)
//   - Audio cue ID constants for consistent usage across modules

// ---------------------------------------------------------------
// Audio Cue ID Constants
// ---------------------------------------------------------------

// UI sounds
const var W3BA_CUE_MENU_FOCUS  : String = "ui_menu_focus";
const var W3BA_CUE_MENU_SELECT : String = "ui_menu_select";
const var W3BA_CUE_MENU_BACK   : String = "ui_menu_back";
const var W3BA_CUE_UI_ERROR    : String = "ui_error";

// Navigation beacons
const var W3BA_CUE_BEACON_MAIN : String = "beacon_quest_main";
const var W3BA_CUE_BEACON_SIDE : String = "beacon_quest_side";
const var W3BA_CUE_BEACON_POI  : String = "beacon_poi";

// Combat
const var W3BA_CUE_ENEMY_DETECTED        : String = "enemy_detected";
const var W3BA_CUE_ENEMY_ATTACK_LIGHT    : String = "enemy_attack_light";
const var W3BA_CUE_ENEMY_ATTACK_HEAVY    : String = "enemy_attack_heavy";
const var W3BA_CUE_ENEMY_ATTACK_UNBLOCK  : String = "enemy_attack_unblockable";
const var W3BA_CUE_PLAYER_HIT            : String = "player_hit";
const var W3BA_CUE_PLAYER_DODGE          : String = "player_dodge_success";
const var W3BA_CUE_PLAYER_PARRY          : String = "player_parry_success";
const var W3BA_CUE_HEALTH_LOW            : String = "health_low_warning";
const var W3BA_CUE_HEALTH_CRITICAL       : String = "health_critical_warning";

// Object detection
const var W3BA_CUE_OBJ_CONTAINER : String = "object_container";
const var W3BA_CUE_OBJ_HERB      : String = "object_herb";
const var W3BA_CUE_OBJ_NPC       : String = "object_npc";
const var W3BA_CUE_OBJ_DOOR      : String = "object_door";
const var W3BA_CUE_OBJ_LOOT      : String = "object_loot";

// ---------------------------------------------------------------
// Core Manager Singleton
// ---------------------------------------------------------------

// The core manager is stored as a global variable.
// It is created once during game initialization.
var W3BA_g_coreManager : W3BA_CoreManager;

function W3BA_GetCoreManager() : W3BA_CoreManager
{
    return W3BA_g_coreManager;
}

function W3BA_EnsureInitialized()
{
    if (!W3BA_g_coreManager)
    {
        W3BA_g_coreManager = new W3BA_CoreManager;
        W3BA_g_coreManager.Initialize();
    }
}

// ---------------------------------------------------------------
// Global Convenience Functions
// ---------------------------------------------------------------

// Speak text via TTS. Safe to call even if mod not fully initialized.
function W3BA_SpeakText(text : String, interrupt : Bool, optional priority : Int32)
{
    W3BA_EnsureInitialized();

    var core : W3BA_CoreManager = W3BA_GetCoreManager();
    if (core && core.GetTTSBridge())
    {
        core.GetTTSBridge().Speak(text, interrupt, priority);
    }
}

// Play a non-spatial UI audio cue
function W3BA_PlayCue(cueId : String)
{
    var core : W3BA_CoreManager = W3BA_GetCoreManager();
    if (core && core.GetAudioManager())
    {
        core.GetAudioManager().PlayCue(cueId);
    }
}

// Play a 3D positioned audio cue
function W3BA_PlayCue3D(cueId : String, worldPosition : Vector, optional pitch : Float)
{
    var core : W3BA_CoreManager = W3BA_GetCoreManager();
    if (core && core.GetAudioManager())
    {
        core.GetAudioManager().PlayCue3D(cueId, worldPosition, pitch);
    }
}
