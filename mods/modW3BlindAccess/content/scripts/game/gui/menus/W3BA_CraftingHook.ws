// W3BlindAccess - Crafting Menu Hook
// Wraps CR4CraftingMenu to narrate schematic selection and crafting.

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4CraftingMenu)
function OnConfigUI()
{
    wrappedMethod();

    W3BA_SpeakText("Crafting. Select a schematic to craft.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Entry selected — narrate schematic name with details
// ---------------------------------------------------------------

@wrapMethod(CR4CraftingMenu)
function OnEntrySelected(tag : CName)
{
    var schematicName : String;
    var text : String;

    wrappedMethod(tag);

    // Try to get localized schematic name
    schematicName = GetLocStringByKeyExt(NameToString(tag));
    if (schematicName == "" || schematicName == NameToString(tag))
    {
        // Fallback: clean up the tag name for display
        schematicName = W3BA_CleanSchematicName(NameToString(tag));
    }

    text = schematicName;

    W3BA_SpeakText(text, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

// ---------------------------------------------------------------
// Clean up internal schematic names for display
// ---------------------------------------------------------------

function W3BA_CleanSchematicName(internalName : String) : String
{
    var result : String;

    result = internalName;

    // Remove common prefixes
    result = StrReplace(result, "Schematic for ", "");
    result = StrReplace(result, "schematic_", "");
    result = StrReplace(result, "crafting_", "");
    result = StrReplace(result, "_", " ");

    return result;
}

// ---------------------------------------------------------------
// Crafting result narration
// ---------------------------------------------------------------

@wrapMethod(CR4CraftingMenu)
function OnCraftingResult(success : Bool, itemName : CName)
{
    var text : String;
    var localizedName : String;

    wrappedMethod(success, itemName);

    localizedName = GetLocStringByKeyExt(NameToString(itemName));
    if (localizedName == "" || localizedName == NameToString(itemName))
    {
        localizedName = W3BA_CleanSchematicName(NameToString(itemName));
    }

    if (success)
    {
        text = "Crafted " + localizedName + ".";
    }
    else
    {
        text = "Cannot craft. Missing materials.";
    }

    W3BA_SpeakText(text, true, 2);
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
