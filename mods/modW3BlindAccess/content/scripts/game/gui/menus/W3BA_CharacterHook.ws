// W3BlindAccess - Character Menu Hook
// Wraps CR4CharacterMenu to narrate skill tab changes.
// CR4CharacterMenu has OnTabChanged but not OnInputHandled.

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4CharacterMenu)
function OnConfigUI()
{
    wrappedMethod();

    W3BA_SpeakText("Character.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Tab changes (Combat, Signs, Alchemy, General, Mutagens)
// ---------------------------------------------------------------

@wrapMethod(CR4CharacterMenu)
function OnTabChanged(tabIndex : int)
{
    var tabName : string;

    wrappedMethod(tabIndex);

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
