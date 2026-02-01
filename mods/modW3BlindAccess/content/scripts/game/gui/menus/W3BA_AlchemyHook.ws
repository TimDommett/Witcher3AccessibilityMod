// W3BlindAccess - Alchemy Menu Hook
// Wraps CR4AlchemyMenu to narrate recipe selection.
// CR4AlchemyMenu has OnEntrySelected but not OnInputHandled or OnTabChanged.

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4AlchemyMenu)
function OnConfigUI()
{
    wrappedMethod();

    W3BA_SpeakText("Alchemy.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Entry selected — narrate recipe name
// ---------------------------------------------------------------

@wrapMethod(CR4AlchemyMenu)
function OnEntrySelected(tag : name)
{
    wrappedMethod(tag);

    // tag is the internal name of the selected recipe
    // TODO: resolve to localized name via GetLocStringByKeyExt()
    W3BA_SpeakText("" + tag, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

// ---------------------------------------------------------------
// Menu close
// ---------------------------------------------------------------

@wrapMethod(CR4AlchemyMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}
