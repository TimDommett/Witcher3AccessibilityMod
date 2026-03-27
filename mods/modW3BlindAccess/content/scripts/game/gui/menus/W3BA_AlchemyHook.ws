// W3BlindAccess - Alchemy Menu Hook
// Wraps CR4AlchemyMenu to narrate recipe selection and crafting.

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4AlchemyMenu)
function OnConfigUI()
{
    wrappedMethod();

    W3BA_SpeakText("Alchemy. Select a recipe to craft.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Entry selected — narrate recipe name with details
// ---------------------------------------------------------------

@wrapMethod(CR4AlchemyMenu)
function OnEntrySelected(tag : CName)
{
    var recipeName : String;
    var recipeType : String;
    var text : String;
    var inv : CInventoryComponent;
    var quantity : Int32;
    var canCraft : Bool;

    wrappedMethod(tag);

    // Try to get localized recipe name
    recipeName = GetLocStringByKeyExt(NameToString(tag));
    if (recipeName == "" || recipeName == NameToString(tag))
    {
        // Fallback: clean up the tag name for display
        recipeName = W3BA_CleanRecipeName(NameToString(tag));
    }

    text = recipeName;

    // Check if player has this item already
    inv = thePlayer.GetInventory();
    if (inv)
    {
        quantity = inv.GetItemQuantityByName(tag);
        if (quantity > 0)
        {
            text += ". " + quantity + " in inventory";
        }
    }

    W3BA_SpeakText(text, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

// ---------------------------------------------------------------
// Clean up internal recipe names for display
// ---------------------------------------------------------------

function W3BA_CleanRecipeName(internalName : String) : String
{
    var result : String;

    result = internalName;

    // Remove common prefixes
    result = StrReplace(result, "Recipe for ", "");
    result = StrReplace(result, "recipe_", "");
    result = StrReplace(result, "alchemy_", "");
    result = StrReplace(result, "_", " ");

    return result;
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
