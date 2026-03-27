// W3BlindAccess - Character Menu Hook
// Wraps CR4CharacterMenu to narrate menu open/close with player stats.
// CR4CharacterMenu only exposes OnConfigUI and OnCloseMenu for wrapping.

// ---------------------------------------------------------------
// Menu open with player stats summary
// ---------------------------------------------------------------

@wrapMethod(CR4CharacterMenu)
function OnConfigUI()
{
    var level : Int32;
    var text : String;

    wrappedMethod();

    level = thePlayer.GetLevel();

    text = "Character. Level " + level + ".";

    W3BA_SpeakText(text, true, 2);
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
