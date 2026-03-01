// W3BlindAccess - Inventory Menu Hook
// Wraps CR4InventoryMenu to narrate tabs and item details.

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4InventoryMenu)
function OnConfigUI()
{
    wrappedMethod();

    W3BA_SpeakText("Inventory. Use left and right for tabs, up and down for items.", true, 2);
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
