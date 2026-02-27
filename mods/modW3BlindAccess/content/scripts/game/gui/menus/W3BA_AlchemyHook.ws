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
// Tab changes (Potions, Oils, Bombs, Decoctions, etc.)
// ---------------------------------------------------------------

@wrapMethod(CR4AlchemyMenu)
function OnTabChanged(tabIndex : Int32)
{
    var tabName : String;

    wrappedMethod(tabIndex);

    switch (tabIndex)
    {
        case 0: tabName = "Potions";     break;
        case 1: tabName = "Oils";        break;
        case 2: tabName = "Bombs";       break;
        case 3: tabName = "Decoctions";  break;
        case 4: tabName = "Substances";  break;
        default: tabName = "Tab " + tabIndex; break;
    }

    W3BA_SpeakText(tabName + ".", true, 2);
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
// Crafting result narration
// ---------------------------------------------------------------

@wrapMethod(CR4AlchemyMenu)
function OnAlchemyResult(success : Bool, itemName : CName)
{
    var text : String;
    var localizedName : String;

    wrappedMethod(success, itemName);

    localizedName = GetLocStringByKeyExt(NameToString(itemName));
    if (localizedName == "" || localizedName == NameToString(itemName))
    {
        localizedName = W3BA_CleanRecipeName(NameToString(itemName));
    }

    if (success)
    {
        text = "Crafted " + localizedName + ".";
    }
    else
    {
        text = "Cannot craft. Missing ingredients.";
    }

    W3BA_SpeakText(text, true, 2);
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
