// W3BlindAccess - Glossary & Bestiary Menu Hook
// Wraps CR4GlossaryBestiaryMenu to narrate entry selection.

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4GlossaryBestiaryMenu)
function OnConfigUI()
{
    wrappedMethod();

    W3BA_SpeakText("Bestiary and Glossary.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Tab changes (Monsters, Characters, Places, etc.)
// ---------------------------------------------------------------

@wrapMethod(CR4GlossaryBestiaryMenu)
function OnTabChanged(tabIndex : Int32)
{
    var tabName : String;

    wrappedMethod(tabIndex);

    switch (tabIndex)
    {
        case 0: tabName = "Monsters";   break;
        case 1: tabName = "Characters"; break;
        case 2: tabName = "Places";     break;
        case 3: tabName = "Tutorial";   break;
        case 4: tabName = "Books";      break;
        default: tabName = "Tab " + tabIndex; break;
    }

    W3BA_SpeakText(tabName + ".", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Entry selected — narrate bestiary/glossary entry
// ---------------------------------------------------------------

@wrapMethod(CR4GlossaryBestiaryMenu)
function OnEntrySelected(tag : CName)
{
    var entryName : String;
    var text : String;

    wrappedMethod(tag);

    // Try to get localized entry name
    entryName = GetLocStringByKeyExt(NameToString(tag));
    if (entryName == "" || entryName == NameToString(tag))
    {
        // Fallback: clean up the tag name
        entryName = W3BA_CleanGlossaryName(NameToString(tag));
    }

    text = entryName;

    W3BA_SpeakText(text, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

// ---------------------------------------------------------------
// Clean up internal glossary names for display
// ---------------------------------------------------------------

function W3BA_CleanGlossaryName(internalName : String) : String
{
    var result : String;

    result = internalName;

    // Remove common prefixes and clean underscores
    result = StrReplace(result, "bestiary_", "");
    result = StrReplace(result, "glossary_", "");
    result = StrReplace(result, "character_", "");
    result = StrReplace(result, "place_", "");
    result = StrReplace(result, "_", " ");

    return result;
}

// ---------------------------------------------------------------
// Menu close
// ---------------------------------------------------------------

@wrapMethod(CR4GlossaryBestiaryMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}
