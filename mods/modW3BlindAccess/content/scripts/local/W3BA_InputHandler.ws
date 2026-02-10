// W3BlindAccess - Input Handler
// Checks for accessibility hotkey actions each tick.
//
// Witcher 3 input system uses named actions defined in input.settings.
// Since we can't easily add custom bindings, we check for specific
// existing unused actions or key combinations.
//
// Current approach: Uses the game's input action system where possible,
// with fallback to polling key states for mod-specific actions.
//
// Accessibility Hotkeys (checked each tick):
//   - W3BA_ToggleBeacon    : Toggle navigation beacon on/off
//   - W3BA_AnnounceObjective : Announce distance/direction to objective
//   - W3BA_ToggleTracker   : Toggle object tracker on/off
//   - W3BA_NextObject      : Cycle to next tracked object
//   - W3BA_PrevObject      : Cycle to previous tracked object
//   - W3BA_AnnounceHealth  : Announce current health percentage
//   - W3BA_AnnounceStatus  : Announce combat/location status summary
//
// TODO: Define custom input.settings entries for these actions
// TODO: Add configuration UI for remapping hotkeys

// Cooldown tracking to prevent rapid-fire hotkey triggers
// Using CR4Player instead of CR4Game to avoid const assignment issues.
@addField(CR4Player)
var w3ba_inputCooldown : Float;

function W3BA_CheckInputActions(core : W3BA_CoreManager)
{
    if (!thePlayer) { return; }

    // Decrement cooldown
    if (thePlayer.w3ba_inputCooldown > 0)
    {
        thePlayer.w3ba_inputCooldown -= 0.1;
        return;
    }

    // Don't process hotkeys during menus
    if (theGame.IsDialogOrCutscenePlaying()) { return; }

    // Check each accessibility action
    // These use theInput.IsActionJustPressed() which checks the game's
    // input action bindings. If the actions aren't defined in input.settings,
    // these calls will silently return false.

    if (theInput.IsActionJustPressed('W3BA_ToggleBeacon'))
    {
        core.GetBeacon().ToggleBeacon();
        thePlayer.w3ba_inputCooldown = 0.3;
        return;
    }

    if (theInput.IsActionJustPressed('W3BA_AnnounceObj'))
    {
        core.GetBeacon().AnnounceObjective();
        thePlayer.w3ba_inputCooldown = 0.3;
        return;
    }

    if (theInput.IsActionJustPressed('W3BA_ToggleTracker'))
    {
        core.GetObjectTracker().ToggleTracker();
        thePlayer.w3ba_inputCooldown = 0.3;
        return;
    }

    if (theInput.IsActionJustPressed('W3BA_NextObject'))
    {
        core.GetObjectTracker().NextObject();
        thePlayer.w3ba_inputCooldown = 0.2;
        return;
    }

    if (theInput.IsActionJustPressed('W3BA_PrevObject'))
    {
        core.GetObjectTracker().PreviousObject();
        thePlayer.w3ba_inputCooldown = 0.2;
        return;
    }

    if (theInput.IsActionJustPressed('W3BA_AnnounceHealth'))
    {
        W3BA_AnnounceHealthStatus(core);
        thePlayer.w3ba_inputCooldown = 0.3;
        return;
    }

    if (theInput.IsActionJustPressed('W3BA_AnnounceStatus'))
    {
        W3BA_AnnounceFullStatus(core);
        thePlayer.w3ba_inputCooldown = 0.5;
        return;
    }
}

// ---------------------------------------------------------------
// Status announcement helpers
// ---------------------------------------------------------------

function W3BA_AnnounceHealthStatus(core : W3BA_CoreManager)
{
    var healthPct : Float;
    var text : String;

    if (!thePlayer) { return; }

    healthPct = thePlayer.GetStatPercents(BCS_Vitality) * 100.0;
    text = "Health: " + RoundMath(healthPct) + " percent.";

    if (core.GetCombatMonitor().IsInCombat())
    {
        text += " In combat, " + core.GetCombatMonitor().GetEnemyCount() + " enemies.";
    }

    core.GetTTSBridge().Speak(text, true, 2);
}

function W3BA_AnnounceFullStatus(core : W3BA_CoreManager)
{
    var text : String;
    var healthPct : Float;
    var areaName : String;

    if (!thePlayer) { return; }

    healthPct = thePlayer.GetStatPercents(BCS_Vitality) * 100.0;

    text = "Status: ";
    text += "Health " + RoundMath(healthPct) + " percent. ";

    // Combat state
    if (core.GetCombatMonitor().IsInCombat())
    {
        text += "In combat with " + core.GetCombatMonitor().GetEnemyCount() + " enemies. ";
    }
    else
    {
        text += "Out of combat. ";
    }

    // Beacon state
    if (core.GetBeacon().IsActive())
    {
        text += "Beacon active. ";
    }

    // Player level
    text += "Level " + thePlayer.GetLevel() + ". ";

    core.GetTTSBridge().Speak(text, true, 2);
}
