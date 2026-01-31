// W3BlindAccess - Character Menu Hook
// Wraps CR4CharacterMenu to narrate skills, abilities, and character stats.

@addField(CR4CharacterMenu)
var w3ba_lastCharTabIndex : int;

@addField(CR4CharacterMenu)
var w3ba_lastCharItemIndex : int;

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4CharacterMenu)
function OnConfigUI()
{
    wrappedMethod();

    w3ba_lastCharTabIndex  = -1;
    w3ba_lastCharItemIndex = -1;
    W3BA_SpeakText("Character.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Input handling
// ---------------------------------------------------------------

@wrapMethod(CR4CharacterMenu)
function OnInputHandled(NavCode : string, KeyCode : int, ActionId : int)
{
    wrappedMethod(NavCode, KeyCode, ActionId);
    W3BA_NarrateCharacterItem(this);
}

// ---------------------------------------------------------------
// Tab changes (e.g., Skills, Mutagens, General)
// ---------------------------------------------------------------

@wrapMethod(CR4CharacterMenu)
function OnTabChanged(tabIndex : int)
{
    var tabName : string;

    wrappedMethod(tabIndex);

    if (tabIndex == w3ba_lastCharTabIndex) { return; }
    w3ba_lastCharTabIndex  = tabIndex;
    w3ba_lastCharItemIndex = -1;

    switch (tabIndex)
    {
        case 0: tabName = "Combat Skills";  break;
        case 1: tabName = "Signs";          break;
        case 2: tabName = "Alchemy Skills"; break;
        case 3: tabName = "General Skills"; break;
        case 4: tabName = "Mutagens";       break;
        default: tabName = "Tab " + tabIndex; break;
    }

    W3BA_SpeakText(tabName + ".", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Menu close
// ---------------------------------------------------------------

@wrapMethod(CR4CharacterMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}

// ---------------------------------------------------------------
// Item narration
// ---------------------------------------------------------------

function W3BA_NarrateCharacterItem(menu : CR4CharacterMenu)
{
    var currentIndex : int;

    currentIndex = menu.GetCurrentMenuItemIndex();
    if (currentIndex == menu.w3ba_lastCharItemIndex) { return; }
    menu.w3ba_lastCharItemIndex = currentIndex;

    // Character menu items are skill slots.
    // The exact API for reading skill names/descriptions varies.
    // For now, announce the index. Flash may provide the actual text.
    // TODO: Extract skill name and level from thePlayer.GetSkillByIndex()
    //       or thePlayer.GetCharacterStats()

    W3BA_SpeakText("Skill " + (currentIndex + 1), true, 2);
    W3BA_PlayCue("ui_menu_focus");
}
