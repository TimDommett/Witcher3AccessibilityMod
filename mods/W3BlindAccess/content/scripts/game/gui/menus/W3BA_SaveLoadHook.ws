// W3BlindAccess - Save/Load Screen Hook
// Wraps save and load menus to narrate slot information
//
// Save slots show: slot name, date/time, play time, area name
// We narrate this info when a slot gains focus.

// ---------------------------------------------------------------------------
// Save Game Menu
// ---------------------------------------------------------------------------

@addField(CR4SaveGameMenu)
var w3ba_lastSaveSlotIndex : int;

@wrapMethod(CR4SaveGameMenu)
event /*flash*/ OnConfigUI()
{
    wrappedMethod();

    w3ba_lastSaveSlotIndex = -1;
    W3BA_SpeakText("Save Game.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

@wrapMethod(CR4SaveGameMenu)
event /*flash*/ OnInputHandled(NavCode : string, KeyCode : int, ActionId : int)
{
    wrappedMethod(NavCode, KeyCode, ActionId);
    W3BA_NarrateSaveSlotSelection(this);
}

function W3BA_NarrateSaveSlotSelection(menu : CR4SaveGameMenu)
{
    var currentIndex : int;
    currentIndex = menu.GetCurrentMenuItemIndex();

    if (currentIndex == menu.w3ba_lastSaveSlotIndex) { return; }
    menu.w3ba_lastSaveSlotIndex = currentIndex;

    // Try to get slot info from the menu's data
    var slotText : string;
    slotText = W3BA_BuildSaveSlotDescription(menu, currentIndex);

    if (slotText != "")
    {
        W3BA_SpeakText(slotText, true, 2);
        W3BA_PlayCue("ui_menu_focus");
    }
}

function W3BA_BuildSaveSlotDescription(menu : CR4SaveGameMenu, index : int) : string
{
    // The save menu populates Flash with save slot data arrays.
    // We construct a readable description from the slot metadata.
    //
    // Typical info: "Slot 3. Velen - Crow's Perch. 2025-01-15. Play time: 42 hours."
    // For empty slots: "Empty slot"

    // TODO: Extract actual slot data from Flash value storage
    // var flashStorage : CScriptedFlashValueStorage = menu.GetMenuFlashValueStorage();
    // Read slot name, area, datetime, playtime from the Flash data bindings

    if (index == 0)
    {
        return "New save slot.";
    }

    return "Save slot " + index + ".";
}

// ---------------------------------------------------------------------------
// Load Game Menu
// ---------------------------------------------------------------------------

@addField(CR4LoadGameMenu)
var w3ba_lastLoadSlotIndex : int;

@wrapMethod(CR4LoadGameMenu)
event /*flash*/ OnConfigUI()
{
    wrappedMethod();

    w3ba_lastLoadSlotIndex = -1;
    W3BA_SpeakText("Load Game.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

@wrapMethod(CR4LoadGameMenu)
event /*flash*/ OnInputHandled(NavCode : string, KeyCode : int, ActionId : int)
{
    wrappedMethod(NavCode, KeyCode, ActionId);
    W3BA_NarrateLoadSlotSelection(this);
}

function W3BA_NarrateLoadSlotSelection(menu : CR4LoadGameMenu)
{
    var currentIndex : int;
    currentIndex = menu.GetCurrentMenuItemIndex();

    if (currentIndex == menu.w3ba_lastLoadSlotIndex) { return; }
    menu.w3ba_lastLoadSlotIndex = currentIndex;

    var slotText : string;
    // TODO: Extract actual save metadata (area, date, playtime)
    slotText = "Save slot " + (currentIndex + 1) + ".";

    W3BA_SpeakText(slotText, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

// ---------------------------------------------------------------------------
// Confirmation dialogs (overwrite save, load confirmation)
// ---------------------------------------------------------------------------

// The game uses a generic confirmation popup. We hook it to narrate the message.
@wrapMethod(CR4OverlayPopup)
event /*flash*/ OnConfigUI()
{
    wrappedMethod();

    // Attempt to read the popup message text
    var flashStorage : CScriptedFlashValueStorage;
    flashStorage = this.GetMenuFlashValueStorage();

    // The popup typically has a message string and Yes/No buttons
    // TODO: Extract the actual message text from Flash bindings
    W3BA_SpeakText("Confirmation dialog.", true, 3);
    W3BA_PlayCue("ui_menu_select");
}
