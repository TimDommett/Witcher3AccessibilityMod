// W3BlindAccess - Ingame (Pause) Menu Hook
// Wraps CR4IngameMenu to narrate pause menu open/close.
//
// NOTE: CR4IngameMenu does not have OnInputHandled or OnTabChanged.
// Per-item navigation narration is not available without Flash hooks.

@wrapMethod(CR4IngameMenu)
function OnConfigUI()
{
    wrappedMethod();

    W3BA_SpeakText("Pause Menu.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

@wrapMethod(CR4IngameMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_SpeakText("Resuming game.", true, 1);
    W3BA_PlayCue("ui_menu_back");
}
