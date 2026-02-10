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
// Item focus - OnGetItemData is called when item tooltip is needed
// ---------------------------------------------------------------

@wrapMethod(CR4InventoryMenu)
function OnGetItemData(item : SItemUniqueId, compareItemType : int)
{
    var inv : CInventoryComponent;
    var itemName : String;
    var isEquipped : Bool;
    var quality : Int32;
    var text : String;

    wrappedMethod(item, compareItemType);

    // Get item details for narration
    inv = thePlayer.GetInventory();
    if (inv)
    {
        itemName = inv.GetItemLocalizedNameByUniqueID(item);
        if (itemName != "")
        {
            text = itemName;

            // Check if equipped
            isEquipped = inv.IsItemMounted(item) || inv.IsItemHeld(item);
            if (isEquipped) { text += ", Equipped"; }

            // Get quality
            quality = inv.GetItemQuality(item);
            if (quality > 1) { text += ", " + W3BA_QualityToString(quality); }

            W3BA_SpeakText(text, true, 1);
        }
    }
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
