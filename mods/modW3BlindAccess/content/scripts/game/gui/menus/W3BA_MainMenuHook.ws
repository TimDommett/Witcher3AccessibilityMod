// W3BlindAccess - Main Menu Hook
// Wraps CR4CommonMainMenuBase to announce menu open/close.
// CR4CommonMainMenu is empty; OnConfigUI is defined in the base class.

@wrapMethod(CR4CommonMainMenuBase)
function OnConfigUI()
{
    wrappedMethod();

    // Show a startup banner so the user knows the mod loaded successfully.
    LogChannel('W3BA', "STATUS|W3BlindAccess mod loaded successfully");
    theGame.GetGuiManager().ShowNotification("W3BlindAccess loaded - accessibility mod active", 6000);

    W3BA_SpeakText("Main Menu.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

@wrapMethod(CR4CommonMainMenuBase)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}
