// W3BlindAccess - Inventory Menu Hook
// Wraps CR4InventoryMenu to narrate tab changes and menu open/close.
// CR4InventoryMenu has OnTabChanged but not OnInputHandled.

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4InventoryMenu)
function OnConfigUI()
{
    wrappedMethod();

    W3BA_SpeakText("Inventory.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Tab changes (Weapons, Armor, Potions, etc.)
// ---------------------------------------------------------------

@wrapMethod(CR4InventoryMenu)
function OnTabChanged(tabIndex : int)
{
    var tabName : string;

    wrappedMethod(tabIndex);

    switch (tabIndex)
    {
        case 0: tabName = "Weapons";       break;
        case 1: tabName = "Armor";         break;
        case 2: tabName = "Potions";       break;
        case 3: tabName = "Oils and Bombs"; break;
        case 4: tabName = "Quest Items";   break;
        case 5: tabName = "Crafting";      break;
        case 6: tabName = "Other";         break;
        default: tabName = "Tab " + tabIndex; break;
    }

    W3BA_SpeakText(tabName + ".", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Menu close
// ---------------------------------------------------------------

@wrapMethod(CR4InventoryMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}

function W3BA_QualityToString(quality : Int32) : String
{
    switch (quality)
    {
        case 1: return "Common";
        case 2: return "Master";
        case 3: return "Magic";
        case 4: return "Rare";
        case 5: return "Relic";
        default: return "Common";
    }
}
