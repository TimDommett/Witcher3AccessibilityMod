// W3BlindAccess - Inventory Narrator
// Provides detailed TTS narration for inventory, equipment, and item details

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
        // Format: "Steel Sword, Equipped, 85 damage"
        var text : String = itemName;

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
        // Format: "Viper Steel Sword. Relic quality.
        //          Damage: 85 to 104.
        //          Bonus: Plus 15% critical hit chance.
        //          Currently equipped in steel sword slot.
        //          Description: A blade forged by Witchers of the Viper school."

        var text : String = itemName + ". ";

        if (rarity != "")
        {
            text += rarity + " quality. ";
        }

        // Append all stat lines
        var i : Int32;
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
        comparisons    : array<String>  // e.g. ["Plus 12 damage", "Minus 5% critical chance"]
    )
    {
        var text : String = itemName + ". " + primaryStat + ". ";
        text += "Compared to equipped: ";

        var i : Int32;
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
        var text : String = itemName;
        if (count > 1) { text += ", " + count + " in stack"; }
        if (effect != "") { text += ". Effect: " + effect; }

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
            case 1: return "Master";
            case 2: return "Magic";
            case 3: return "Rare";
            case 4: return "Relic";
            case 5: return "Witcher";
            default: return "Unknown";
        }
    }
}
