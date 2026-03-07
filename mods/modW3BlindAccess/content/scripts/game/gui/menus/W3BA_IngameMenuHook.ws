// W3BlindAccess - Ingame (Pause) Menu Hook
// Wraps CR4IngameMenu to narrate pause menu navigation.
// CR4IngameMenu does NOT have OnInputHandled — it uses OnRequestSubMenu for panel navigation.

@wrapMethod(CR4IngameMenu)
function OnConfigUI()
{
    wrappedMethod();
    W3BA_SpeakText("Pause Menu.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// OnRequestSubMenu fires when navigating to different panels (Inventory, Map, etc.)
@wrapMethod(CR4IngameMenu)
function OnRequestSubMenu(menuName : name, optional initData : IScriptable)
{
    var panelLabel : String;

    wrappedMethod(menuName, initData);

    panelLabel = W3BA_GetIngamePanelName(menuName);
    if (panelLabel != "")
    {
        W3BA_SpeakText(panelLabel, true, 2);
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

// Convert submenu name to readable panel label
function W3BA_GetIngamePanelName(menuName : name) : String
{
    switch (menuName)
    {
        case 'IngameMenu':          return "Pause Menu";
        case 'InventoryMenu':       return "Inventory";
        case 'CharacterMenu':       return "Character";
        case 'MapMenu':             return "World Map";
        case 'JournalQuestMenu':    return "Quests";
        case 'MeditationClockMenu': return "Meditation";
        case 'AlchemyMenu':         return "Alchemy";
        case 'GlossaryBestiaryMenu':return "Bestiary";
        case 'GlossaryMenu':        return "Glossary";
        case 'CraftingMenu':        return "Crafting";
        case 'OptionsMenu':         return "Options";
        case 'SaveGameMenu':        return "Save Game";
        case 'LoadGameMenu':        return "Load Game";
        default:                    return NameToString(menuName);
    }
}
