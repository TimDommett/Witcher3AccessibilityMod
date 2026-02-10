// W3BlindAccess - Ingame (Pause) Menu Hook
// Wraps CR4IngameMenu to narrate pause menu navigation.

@wrapMethod(CR4IngameMenu)
function OnConfigUI()
{
    wrappedMethod();

    W3BA_SpeakText("Pause Menu. Use up and down to navigate.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// OnItemActivated fires when a menu item is selected/activated
@wrapMethod(CR4IngameMenu)
function OnItemActivated(actionType : int, menuTag : int) : void
{
    var itemName : String;

    wrappedMethod(actionType, menuTag);

    // Map menuTag to readable names (these values may vary by game version)
    itemName = W3BA_GetIngameMenuItemName(menuTag);
    if (itemName != "")
    {
        W3BA_SpeakText(itemName, true, 2);
        W3BA_PlayCue("ui_menu_focus");
    }
}

@wrapMethod(CR4IngameMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_SpeakText("Resuming game.", true, 1);
    W3BA_PlayCue("ui_menu_back");
}

// Helper to convert menu tags to readable item names
function W3BA_GetIngameMenuItemName(menuTag : int) : String
{
    // Common pause menu item tags (may need adjustment based on game version)
    switch (menuTag)
    {
        case 0:  return "Resume";
        case 1:  return "Inventory";
        case 2:  return "Character";
        case 3:  return "World Map";
        case 4:  return "Quests";
        case 5:  return "Meditation";
        case 6:  return "Alchemy";
        case 7:  return "Bestiary";
        case 8:  return "Glossary";
        case 9:  return "Crafting";
        case 10: return "Options";
        case 11: return "Save Game";
        case 12: return "Load Game";
        case 13: return "Exit";
        default: return "Menu item " + menuTag;
    }
}
