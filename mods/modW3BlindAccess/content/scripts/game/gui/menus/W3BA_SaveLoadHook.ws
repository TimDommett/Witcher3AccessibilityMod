// W3BlindAccess - Save/Load Screen Hook
//
// Hooks into save/load menu events to narrate save slot information.
// Uses theGame.GetSaveInSlot() to extract save slot metadata.
// SSavegameInfo only has: filename, slotType, slotIndex, comboStatus.
// Use GetDisplayNameForSavedGame() for a human-readable save description.

// Narrate save slot information
function W3BA_NarrateSaveSlot(slotIndex : Int32, saveType : Int32)
{
    var saveInfo : SSavegameInfo;
    var text : String;
    var slotNum : Int32;
    var hasData : Bool;
    var displayName : String;

    slotNum = slotIndex + 1; // 1-based for user display

    // Try to get save info for this slot
    hasData = theGame.GetSaveInSlot(saveType, slotIndex, saveInfo);

    if (hasData)
    {
        // Build narration from available save info
        text = "Slot " + slotNum + ". ";

        // Get the display name which includes area, level, etc.
        displayName = theGame.GetDisplayNameForSavedGame(saveInfo);
        if (displayName != "")
        {
            text += displayName + ". ";
        }

        // Add save type
        text += W3BA_SaveTypeToString(saveInfo.slotType) + ".";
    }
    else
    {
        text = "Slot " + slotNum + ". Empty.";
    }

    W3BA_SpeakText(text, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

// Convert save game type enum to readable string
function W3BA_SaveTypeToString(saveType : ESaveGameType) : String
{
    if (saveType == SGT_AutoSave)         { return "Autosave"; }
    if (saveType == SGT_CheckPoint)       { return "Checkpoint"; }
    if (saveType == SGT_ForcedCheckPoint) { return "Checkpoint"; }
    if (saveType == SGT_QuickSave)        { return "Quick save"; }
    if (saveType == SGT_Manual)           { return "Manual save"; }
    return "Save";
}
