// W3BlindAccess - Glossary & Bestiary Menu Hook
// Wraps CR4GlossaryBestiaryMenu to narrate entry selection.
// CR4GlossaryBestiaryMenu has OnEntrySelected but not OnInputHandled or OnTabChanged.

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4GlossaryBestiaryMenu)
function OnConfigUI()
{
    wrappedMethod();

    W3BA_SpeakText("Bestiary.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Entry selected — narrate bestiary entry
// ---------------------------------------------------------------

@wrapMethod(CR4GlossaryBestiaryMenu)
function OnEntrySelected(tag : name)
{
    wrappedMethod(tag);

    // tag is the internal name of the selected creature/entry
    // TODO: resolve to localized name via journal manager
    W3BA_SpeakText("" + tag, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}
