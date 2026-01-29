// W3BlindAccess - Main Menu Hook
// Wraps CR4CommonMainMenu to narrate menu items on focus and selection
//
// The main menu uses Flash/Scaleform with items like:
//   "New Game", "Continue", "Load Game", "Options", "Credits", "Quit"
//
// We hook OnInputHandled to detect navigation, then read the current
// selection from the Flash layer and speak it.

@addField(CR4CommonMainMenu)
var w3ba_lastMainMenuIndex : int;

@addField(CR4CommonMainMenu)
var w3ba_menuInitialized : bool;

// Called when the menu's Flash UI is configured
@wrapMethod(CR4CommonMainMenu)
event /*flash*/ OnConfigUI()
{
    wrappedMethod();

    w3ba_lastMainMenuIndex = -1;
    w3ba_menuInitialized   = true;

    // Announce that we've entered the main menu
    W3BA_SpeakText("Main Menu.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// Called on every input action in the menu
@wrapMethod(CR4CommonMainMenu)
event /*flash*/ OnInputHandled(NavCode : string, KeyCode : int, ActionId : int)
{
    wrappedMethod(NavCode, KeyCode, ActionId);

    // After the game processes input, check if the focused item changed
    W3BA_NarrateMainMenuSelection(this);
}

// Reads the current selection and narrates if it changed
function W3BA_NarrateMainMenuSelection(menu : CR4CommonMainMenu)
{
    // The Flash menu stores the current selection index.
    // We attempt to read it from the Flash value storage.
    var flashStorage : CScriptedFlashValueStorage;
    flashStorage = menu.GetMenuFlashValueStorage();
    if (!flashStorage) { return; }

    // Main menu items are typically in a list component.
    // The exact Flash path depends on the SWF structure.
    // Common approach: read the "selectedIndex" data binding.
    var currentIndex : int;
    currentIndex = menu.GetCurrentMenuItemIndex();

    if (currentIndex == menu.w3ba_lastMainMenuIndex) { return; }
    menu.w3ba_lastMainMenuIndex = currentIndex;

    // Map index to label
    var label : string;
    label = W3BA_GetMainMenuLabel(currentIndex);

    if (label != "")
    {
        W3BA_SpeakText(label, true, 2);
        W3BA_PlayCue("ui_menu_focus");
    }
}

// Maps main menu indices to human-readable labels
// These match the standard Witcher 3 main menu order
function W3BA_GetMainMenuLabel(index : int) : string
{
    switch (index)
    {
        case 0: return "Continue";
        case 1: return "New Game";
        case 2: return "Load Game";
        case 3: return "Options";
        case 4: return "DLC";
        case 5: return "Credits";
        case 6: return "Exit";
        default: return "Menu item " + index;
    }
}

// Hook the close event to announce leaving
@wrapMethod(CR4CommonMainMenu)
event /*flash*/ OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}
