// W3BlindAccess - Ingame (Pause) Menu Hook
// Wraps CR4IngameMenu to narrate pause menu items
//
// The ingame menu appears when pressing ESC during gameplay.
// Items: "Resume", "Save Game", "Load Game", "Options", "Quit to Main Menu"
// Sub-panels: Inventory, Character, Journal, Map, Alchemy, Crafting, etc.

@addField(CR4IngameMenu)
var w3ba_lastIngameMenuIndex : int;

@wrapMethod(CR4IngameMenu)
function OnConfigUI()
{
    wrappedMethod();

    w3ba_lastIngameMenuIndex = -1;
    W3BA_SpeakText("Pause Menu.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

@wrapMethod(CR4IngameMenu)
function OnInputHandled(NavCode : string, KeyCode : int, ActionId : int)
{
    wrappedMethod(NavCode, KeyCode, ActionId);
    W3BA_NarrateIngameMenuSelection(this);
}

function W3BA_NarrateIngameMenuSelection(menu : CR4IngameMenu)
{
    var currentIndex : int;
    var label : string;

    currentIndex = menu.GetCurrentMenuItemIndex();

    if (currentIndex == menu.w3ba_lastIngameMenuIndex) { return; }
    menu.w3ba_lastIngameMenuIndex = currentIndex;

    label = W3BA_GetIngameMenuLabel(currentIndex);

    if (label != "")
    {
        W3BA_SpeakText(label, true, 2);
        W3BA_PlayCue("ui_menu_focus");
    }
}

function W3BA_GetIngameMenuLabel(index : int) : string
{
    switch (index)
    {
        case 0: return "Resume";
        case 1: return "Save Game";
        case 2: return "Load Game";
        case 3: return "Options";
        case 4: return "Quit to Main Menu";
        case 5: return "Quit to Desktop";
        default: return "Menu item " + index;
    }
}

@wrapMethod(CR4IngameMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_SpeakText("Resuming game.", true, 1);
    W3BA_PlayCue("ui_menu_back");
}

// Hook tab changes for the panel sub-menus (Inventory, Map, Journal, etc.)
@wrapMethod(CR4IngameMenu)
function OnTabChanged(tabIndex : int)
{
    var tabName : string;

    wrappedMethod(tabIndex);

    switch (tabIndex)
    {
        case 0: tabName = "Inventory";     break;
        case 1: tabName = "Character";     break;
        case 2: tabName = "Map";           break;
        case 3: tabName = "Quest Journal"; break;
        case 4: tabName = "Alchemy";       break;
        case 5: tabName = "Crafting";      break;
        case 6: tabName = "Bestiary";      break;
        case 7: tabName = "Glossary";      break;
        case 8: tabName = "Meditation";    break;
        default: tabName = "Tab " + tabIndex; break;
    }

    W3BA_SpeakText(tabName + " panel.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}
