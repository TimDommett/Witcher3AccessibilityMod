// W3BlindAccess - Save/Load Screen Hook
//
// Hooks into save/load menu events to narrate save slot information.
// Uses theGame.GetSaveInSlot() to extract save slot metadata.

// NOTE: OnSaveSlotSelected may not exist on CR4IngameMenu.
// Save slot narration deferred until method name verified in-game.

// Narrate save slot information
function W3BA_NarrateSaveSlot(slotIndex : Int32, saveType : Int32)
{
    var saveInfo : SSavegameInfo;
    var text : String;
    var slotNum : Int32;
    var hasData : Bool;

    slotNum = slotIndex + 1; // 1-based for user display

    // Try to get save info for this slot
    hasData = theGame.GetSaveInSlot(saveType, slotIndex, saveInfo);

    if (hasData && saveInfo.slotType != SGT_None)
    {
        // Build detailed narration from save info
        text = "Slot " + slotNum + ". ";

        // Add area name if available
        if (saveInfo.areaName != "")
        {
            text += saveInfo.areaName + ". ";
        }

        // Add level
        if (saveInfo.playerLevel > 0)
        {
            text += "Level " + saveInfo.playerLevel + ". ";
        }

        // Add playtime (convert from seconds to hours/minutes)
        if (saveInfo.playTime > 0)
        {
            text += W3BA_FormatPlaytime(saveInfo.playTime) + ". ";
        }

        // Add difficulty if available
        if (saveInfo.difficulty > 0)
        {
            text += W3BA_DifficultyToString(saveInfo.difficulty) + ". ";
        }
    }
    else
    {
        text = "Slot " + slotNum + ". Empty.";
    }

    W3BA_SpeakText(text, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

// Format playtime in hours and minutes
function W3BA_FormatPlaytime(seconds : Int32) : String
{
    var hours : Int32;
    var minutes : Int32;

    hours = seconds / 3600;
    minutes = (seconds % 3600) / 60;

    if (hours > 0)
    {
        return hours + " hours " + minutes + " minutes";
    }
    else
    {
        return minutes + " minutes";
    }
}

// Convert difficulty ID to string
function W3BA_DifficultyToString(difficulty : Int32) : String
{
    switch (difficulty)
    {
        case 1: return "Just the Story";
        case 2: return "Story and Sword";
        case 3: return "Blood and Broken Bones";
        case 4: return "Death March";
        default: return "";
    }
}
