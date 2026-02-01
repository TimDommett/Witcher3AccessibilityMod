// W3BlindAccess - Crafting Menu Hook
// Wraps CR4CraftingMenu to narrate schematic selection.
// CR4CraftingMenu has OnEntrySelected but not OnInputHandled or OnTabChanged.

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4CraftingMenu)
function OnConfigUI()
{
    wrappedMethod();

    W3BA_SpeakText("Crafting.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Entry selected — narrate schematic name
// ---------------------------------------------------------------

@wrapMethod(CR4CraftingMenu)
function OnEntrySelected(tag : name)
{
    wrappedMethod(tag);

    // tag is the internal name of the selected schematic
    // TODO: resolve to localized name
    W3BA_SpeakText("" + tag, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

// ---------------------------------------------------------------
// Menu close
// ---------------------------------------------------------------

@wrapMethod(CR4CraftingMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}
