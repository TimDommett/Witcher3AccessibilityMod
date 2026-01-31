// W3BlindAccess - Inventory Narrator
// Provides detailed TTS narration for inventory, equipment, and item details.
// Includes item data extraction helpers using CInventoryComponent.

class W3BA_InventoryNarrator
{
    private var ttsBridge : W3BA_TTSBridge;

    // ---------------------------------------------------------------
    // Lifecycle
    // ---------------------------------------------------------------

    public function Initialize(tts : W3BA_TTSBridge)
    {
        ttsBridge = tts;
    }

    // ---------------------------------------------------------------
    // Brief item narration (on focus)
    // ---------------------------------------------------------------

    public function NarrateItemBrief(itemName : String, isEquipped : Bool, primaryStat : String)
    {
        var text : String;
        text = itemName;

        if (isEquipped)
        {
            text += ", Equipped";
        }

        if (primaryStat != "")
        {
            text += ", " + primaryStat;
        }

        ttsBridge.Speak(text, true, 2);
    }

    // ---------------------------------------------------------------
    // Full item narration from item ID (using game inventory APIs)
    // ---------------------------------------------------------------

    public function NarrateItemById(itemId : SItemUniqueId)
    {
        var inv : CInventoryComponent;
        var itemName : String;
        var text : String;
        var isEquipped : Bool;
        var quantity : Int32;
        var quality : Int32;

        inv = thePlayer.GetInventory();
        if (!inv) { return; }

        itemName = inv.GetItemLocalizedNameByUniqueID(itemId);
        if (itemName == "") { itemName = "Unknown item"; }

        text = itemName;

        isEquipped = inv.IsItemEquipped(itemId);
        if (isEquipped) { text += ". Equipped"; }

        quality = inv.GetItemQuality(itemId);
        if (quality > 1)
        {
            text += ". " + RarityToString(quality) + " quality";
        }

        quantity = inv.GetItemQuantity(itemId);
        if (quantity > 1) { text += ". Count: " + quantity; }

        text += ".";

        ttsBridge.Speak(text, true, 2);
    }

    // ---------------------------------------------------------------
    // Detailed item narration (on detail request)
    // ---------------------------------------------------------------

    public function NarrateItemDetail(
        itemName    : String,
        rarity      : String,
        category    : String,
        stats       : array<String>,
        isEquipped  : Bool,
        equipSlot   : String,
        description : String
    )
    {
        var text : String;
        var i : Int32;

        text = itemName + ". ";

        if (rarity != "")
        {
            text += rarity + " quality. ";
        }

        for (i = 0; i < stats.Size(); i += 1)
        {
            text += stats[i] + ". ";
        }

        if (isEquipped)
        {
            text += "Currently equipped";
            if (equipSlot != "") { text += " in " + equipSlot + " slot"; }
            text += ". ";
        }

        if (description != "")
        {
            text += "Description: " + description;
        }

        ttsBridge.Speak(text, true, 2);
    }

    // ---------------------------------------------------------------
    // Item comparison narration
    // ---------------------------------------------------------------

    public function NarrateComparison(
        itemName       : String,
        primaryStat    : String,
        comparisons    : array<String>
    )
    {
        var text : String;
        var i : Int32;

        text = itemName + ". " + primaryStat + ". ";
        text += "Compared to equipped: ";
        for (i = 0; i < comparisons.Size(); i += 1)
        {
            text += comparisons[i];
            if (i < comparisons.Size() - 1) { text += ", "; }
        }
        text += ".";

        ttsBridge.Speak(text, true, 2);
    }

    // ---------------------------------------------------------------
    // Consumable / stack info
    // ---------------------------------------------------------------

    public function NarrateConsumable(itemName : String, count : Int32, effect : String)
    {
        var text : String;
        text = itemName;
        if (count > 1) { text += ", " + count + " in stack"; }
        if (effect != "") { text += ". Effect: " + effect; }

        ttsBridge.Speak(text, true, 2);
    }

    // ---------------------------------------------------------------
    // Quick status report (callable from hotkey)
    // ---------------------------------------------------------------

    public function NarrateEquipmentStatus()
    {
        var inv : CInventoryComponent;
        var text : String;
        var items : array<SItemUniqueId>;
        var i : Int32;
        var equippedCount : Int32;
        var totalCount : Int32;

        inv = thePlayer.GetInventory();
        if (!inv)
        {
            ttsBridge.Speak("Inventory unavailable.", true, 2);
            return;
        }

        inv.GetAllItems(items);
        totalCount = items.Size();
        equippedCount = 0;

        for (i = 0; i < items.Size(); i += 1)
        {
            if (inv.IsItemEquipped(items[i]))
            {
                equippedCount += 1;
            }
        }

        text = totalCount + " items in inventory, " + equippedCount + " equipped.";
        ttsBridge.Speak(text, true, 2);
    }

    // ---------------------------------------------------------------
    // Rarity helper
    // ---------------------------------------------------------------

    public function RarityToString(rarityLevel : Int32) : String
    {
        switch (rarityLevel)
        {
            case 0: return "Common";
            case 1: return "Common";
            case 2: return "Master";
            case 3: return "Magic";
            case 4: return "Rare";
            case 5: return "Relic";
            default: return "Unknown";
        }
    }
}
