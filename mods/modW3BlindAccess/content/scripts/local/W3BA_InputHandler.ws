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

// Cooldown tracking using timestamp approach - no mutable field needed.
// Store last action time and compare with current time.
@addField(CR4Player)
var w3ba_lastInputTime : array<Float>;

function W3BA_GetInputCooldownRemaining() : Float
{
    var lastTime : Float;
    var currentTime : Float;

    if (!thePlayer) { return 1.0; }
    if (thePlayer.w3ba_lastInputTime.Size() == 0) { return 0.0; }

    lastTime = thePlayer.w3ba_lastInputTime[0];
    currentTime = theGame.GetEngineTimeAsSeconds();

    return lastTime - currentTime;
}

function W3BA_SetInputCooldown(duration : Float)
{
    var targetTime : Float;

    if (!thePlayer) { return; }

    targetTime = theGame.GetEngineTimeAsSeconds() + duration;

    if (thePlayer.w3ba_lastInputTime.Size() == 0)
    {
        thePlayer.w3ba_lastInputTime.PushBack(targetTime);
    }
    else
    {
        thePlayer.w3ba_lastInputTime[0] = targetTime;
    }
}

function W3BA_CheckInputActions(core : W3BA_CoreManager)
{
    if (!thePlayer) { return; }

    // Check cooldown using timestamp
    if (W3BA_GetInputCooldownRemaining() > 0)
    {
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
        W3BA_SetInputCooldown(0.3);
        return;
    }

    if (theInput.IsActionJustPressed('W3BA_AnnounceObj'))
    {
        core.GetBeacon().AnnounceObjective();
        W3BA_SetInputCooldown(0.3);
        return;
    }

    if (theInput.IsActionJustPressed('W3BA_ToggleTracker'))
    {
        core.GetObjectTracker().ToggleTracker();
        W3BA_SetInputCooldown(0.3);
        return;
    }

    if (theInput.IsActionJustPressed('W3BA_NextObject'))
    {
        core.GetObjectTracker().NextObject();
        W3BA_SetInputCooldown(0.2);
        return;
    }

    if (theInput.IsActionJustPressed('W3BA_PrevObject'))
    {
        core.GetObjectTracker().PreviousObject();
        W3BA_SetInputCooldown(0.2);
        return;
    }

    if (theInput.IsActionJustPressed('W3BA_AnnounceHealth'))
    {
        W3BA_AnnounceHealthStatus(core);
        W3BA_SetInputCooldown(0.3);
        return;
    }

    if (theInput.IsActionJustPressed('W3BA_AnnounceStatus'))
    {
        W3BA_AnnounceFullStatus(core);
        W3BA_SetInputCooldown(0.5);
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
