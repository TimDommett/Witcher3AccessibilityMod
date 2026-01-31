// W3BlindAccess - Inventory Menu Hook
// Wraps CR4InventoryMenu to narrate item focus, selection, and comparison.
// Extracts real item data from CInventoryComponent.

@addField(CR4InventoryMenu)
var w3ba_lastInvItemIndex : int;

@addField(CR4InventoryMenu)
var w3ba_lastInvTabIndex : int;

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4InventoryMenu)
function OnConfigUI()
{
    wrappedMethod();

    w3ba_lastInvItemIndex = -1;
    w3ba_lastInvTabIndex  = -1;
    W3BA_SpeakText("Inventory.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Input handling — detect navigation through items
// ---------------------------------------------------------------

@wrapMethod(CR4InventoryMenu)
function OnInputHandled(NavCode : string, KeyCode : int, ActionId : int)
{
    wrappedMethod(NavCode, KeyCode, ActionId);
    W3BA_NarrateInventoryItem(this);
}

// ---------------------------------------------------------------
// Tab changes (Weapons, Armor, Potions, etc.)
// ---------------------------------------------------------------

@wrapMethod(CR4InventoryMenu)
function OnTabChanged(tabIndex : int)
{
    var tabName : string;

    wrappedMethod(tabIndex);

    if (tabIndex == w3ba_lastInvTabIndex) { return; }
    w3ba_lastInvTabIndex = tabIndex;
    w3ba_lastInvItemIndex = -1;

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

// ---------------------------------------------------------------
// Item narration logic
// ---------------------------------------------------------------

function W3BA_NarrateInventoryItem(menu : CR4InventoryMenu)
{
    var currentIndex : int;
    var inv : CInventoryComponent;
    var items : array<SItemUniqueId>;
    var itemId : SItemUniqueId;
    var itemName : String;
    var text : String;
    var isEquipped : Bool;
    var quantity : Int32;
    var quality : Int32;
    var qualityStr : String;

    currentIndex = menu.GetCurrentMenuItemIndex();
    if (currentIndex == menu.w3ba_lastInvItemIndex) { return; }
    menu.w3ba_lastInvItemIndex = currentIndex;

    // Try to get item data from player inventory
    inv = thePlayer.GetInventory();
    if (!inv) { return; }

    // Get all items and check if our index is valid
    inv.GetAllItems(items);
    if (currentIndex < 0 || currentIndex >= items.Size()) { return; }

    itemId = items[currentIndex];
    itemName = inv.GetItemLocalizedNameByUniqueID(itemId);
    if (itemName == "")
    {
        itemName = "Item " + (currentIndex + 1);
    }

    text = itemName;

    // Check if equipped
    isEquipped = inv.IsItemEquipped(itemId);
    if (isEquipped)
    {
        text += ", equipped";
    }

    // Get quantity for stackable items
    quantity = inv.GetItemQuantity(itemId);
    if (quantity > 1)
    {
        text += ", " + quantity;
    }

    // Get quality/rarity
    quality = inv.GetItemQuality(itemId);
    qualityStr = W3BA_QualityToString(quality);
    if (qualityStr != "Common")
    {
        text += ", " + qualityStr;
    }

    W3BA_SpeakText(text, true, 2);
    W3BA_PlayCue("ui_menu_focus");
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
