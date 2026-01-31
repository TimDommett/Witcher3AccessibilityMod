// W3BlindAccess - Menu Narrator
// Provides TTS narration for all game menus

class W3BA_MenuNarrator
{
    private var ttsBridge    : W3BA_TTSBridge;
    private var audioManager : W3BA_AudioManager;

    private var lastMenuId    : String;
    private var lastItemIndex : Int32;

    // ---------------------------------------------------------------
    // Lifecycle
    // ---------------------------------------------------------------

    public function Initialize(tts : W3BA_TTSBridge, audio : W3BA_AudioManager)
    {
        ttsBridge    = tts;
        audioManager = audio;
        lastMenuId   = "";
        lastItemIndex = -1;
    }

    // ---------------------------------------------------------------
    // Menu change events (called from UI hooks)
    // ---------------------------------------------------------------

    public function OnMenuOpened(menuId : String)
    {
        var menuName : String;

        if (menuId == lastMenuId) { return; }
        lastMenuId    = menuId;
        lastItemIndex = -1;

        menuName = GetMenuDisplayName(menuId);
        ttsBridge.Speak(menuName + " menu.", true, 2);
        audioManager.PlayCue("ui_menu_select");
    }

    public function OnMenuClosed()
    {
        lastMenuId    = "";
        lastItemIndex = -1;
    }

    // ---------------------------------------------------------------
    // Item focus events
    // ---------------------------------------------------------------

    public function OnItemFocused(itemText : String, itemIndex : Int32)
    {
        if (itemIndex == lastItemIndex) { return; }
        lastItemIndex = itemIndex;

        ttsBridge.Speak(itemText, true, 2);
        audioManager.PlayCue("ui_menu_focus");
    }

    public function OnItemSelected(itemText : String)
    {
        ttsBridge.Speak("Selected: " + itemText, true, 2);
        audioManager.PlayCue("ui_menu_select");
    }

    public function OnMenuBack()
    {
        audioManager.PlayCue("ui_menu_back");
    }

    // ---------------------------------------------------------------
    // Settings menu helpers
    // ---------------------------------------------------------------

    public function OnSettingFocused(settingName : String, currentValue : String)
    {
        ttsBridge.Speak(settingName + ": " + currentValue, true, 2);
        audioManager.PlayCue("ui_menu_focus");
    }

    public function OnSettingChanged(settingName : String, newValue : String)
    {
        ttsBridge.Speak(settingName + " set to " + newValue, true, 2);
    }

    // ---------------------------------------------------------------
    // Dialogue choice narration
    // ---------------------------------------------------------------

    public function OnDialogueChoicesPresented(choices : array<String>)
    {
        var text : String;

        if (choices.Size() == 0) { return; }

        text = choices.Size() + " dialogue options. ";
        text += "1: " + choices[0];
        ttsBridge.Speak(text, true, 2);
    }

    public function OnDialogueChoiceFocused(choiceText : String, choiceIndex : Int32)
    {
        ttsBridge.Speak((choiceIndex + 1) + ": " + choiceText, true, 2);
        audioManager.PlayCue("ui_menu_focus");
    }

    // ---------------------------------------------------------------
    // Save / load narration
    // ---------------------------------------------------------------

    public function OnSaveSlotFocused(slotName : String, dateTime : String, playTime : String)
    {
        var text : String;
        text = slotName;
        if (dateTime != "") { text += ". " + dateTime; }
        if (playTime != "") { text += ". Play time: " + playTime; }
        ttsBridge.Speak(text, true, 2);
        audioManager.PlayCue("ui_menu_focus");
    }

    // ---------------------------------------------------------------
    // Confirmation dialogs
    // ---------------------------------------------------------------

    public function OnConfirmationDialog(message : String)
    {
        ttsBridge.Speak(message, true, 3);
    }

    // ---------------------------------------------------------------
    // Internal helpers
    // ---------------------------------------------------------------

    private function GetMenuDisplayName(menuId : String) : String
    {
        // TODO: Map internal menu IDs to human-readable names
        if      (menuId == "CommonMainMenu")     { return "Main"; }
        else if (menuId == "IngameMenu")         { return "Pause"; }
        else if (menuId == "InventoryMenu")      { return "Inventory"; }
        else if (menuId == "JournalQuestMenu")   { return "Quest Journal"; }
        else if (menuId == "MapMenu")            { return "Map"; }
        else if (menuId == "MeditationMenu")     { return "Meditation"; }
        else if (menuId == "CharacterMenu")      { return "Character"; }
        else if (menuId == "GlossaryBestiaryMenu") { return "Bestiary"; }
        else if (menuId == "AlchemyMenu")        { return "Alchemy"; }
        else if (menuId == "CraftingMenu")       { return "Crafting"; }
        else if (menuId == "OptionsMenu")        { return "Options"; }
        else                                      { return menuId; }
    }
}
