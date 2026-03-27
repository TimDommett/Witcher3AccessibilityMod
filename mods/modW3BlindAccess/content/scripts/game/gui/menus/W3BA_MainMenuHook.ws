// W3BlindAccess - Main Menu Hook
// Wraps CR4CommonMainMenuBase to announce menu open/close and submenu navigation.
// CR4CommonMainMenuBase does NOT have OnInputHandled — navigation is Flash-handled.

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

// OnRequestSubMenu fires when a menu option opens a submenu
@wrapMethod(CR4CommonMainMenuBase)
function OnRequestSubMenu(menuName : name, optional initData : IScriptable)
{
    var label : String;

    wrappedMethod(menuName, initData);

    label = W3BA_GetMainSubmenuName(menuName);
    if (label != "")
    {
        W3BA_SpeakText(label, true, 2);
        W3BA_PlayCue("ui_menu_focus");
    }
}

// NOTE: OnCloseMenu may not exist on CR4CommonMainMenuBase.
// Removed to avoid compilation errors.

// Convert submenu name to readable label
function W3BA_GetMainSubmenuName(menuName : name) : String
{
    switch (menuName)
    {
        case 'IngameMenu':    return "Options";
        case 'LoadGameMenu':  return "Load Game";
        case 'SaveGameMenu':  return "Save Game";
        case 'OptionsMenu':   return "Options";
        default:              return NameToString(menuName);
    }
}
