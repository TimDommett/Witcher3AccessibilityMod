// W3BlindAccess - Main Menu Hook
// Wraps CR4CommonMainMenu to announce menu open/close.
//
// NOTE: CR4CommonMainMenu does not have OnInputHandled, so we cannot
// detect per-item navigation. We announce the menu open event only.
// Individual item narration would require a Flash/ActionScript approach.

// Called when the menu's Flash UI is configured
@wrapMethod(CR4CommonMainMenu)
function OnConfigUI()
{
    wrappedMethod();

    // Show a startup banner so the user knows the mod loaded successfully.
    // This fires as soon as the main menu appears — the earliest visible point.
    LogChannel('W3BA', "STATUS|W3BlindAccess mod loaded successfully");
    theGame.GetGuiManager().ShowNotification("W3BlindAccess loaded - accessibility mod active", 6000);

    // Announce that we've entered the main menu
    W3BA_SpeakText("Main Menu.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// Hook the close event to announce leaving
@wrapMethod(CR4CommonMainMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}
