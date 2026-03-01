// W3BlindAccess - Main Menu Hook
// Wraps CR4CommonMainMenuBase to announce menu open/close.
// CR4CommonMainMenu is empty; OnConfigUI is defined in the base class.

// Track menu selection index for navigation announcements
@addField(CR4CommonMainMenuBase)
var w3ba_mainMenuIndex : array<Int32>;

@wrapMethod(CR4CommonMainMenuBase)
function OnConfigUI()
{
    wrappedMethod();

    // Initialize menu index to 0 (first item)
    this.w3ba_mainMenuIndex.Clear();
    this.w3ba_mainMenuIndex.PushBack(0);

    // Show a startup banner so the user knows the mod loaded successfully.
    LogChannel('W3BA', "STATUS|W3BlindAccess mod loaded successfully");
    theGame.GetGuiManager().ShowNotification("W3BlindAccess loaded - accessibility mod active", 6000);

    W3BA_SpeakText("Main Menu. Continue.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// OnInputHandled fires on all menu input including navigation
@wrapMethod(CR4CommonMainMenuBase)
function OnInputHandled(NavCode : String, KeyCode : Int32, ActionId : Int32)
{
    var currentIndex : Int32;
    var itemName : String;
    var maxItems : Int32;

    wrappedMethod(NavCode, KeyCode, ActionId);

    // Main menu typically has these items (may vary with saves available)
    maxItems = 7;

    // Get current index
    if (this.w3ba_mainMenuIndex.Size() > 0)
    {
        currentIndex = this.w3ba_mainMenuIndex[0];
    }
    else
    {
        currentIndex = 0;
    }

    // Handle navigation
    if (NavCode == "navigate_down" || NavCode == "down")
    {
        currentIndex = currentIndex + 1;
        if (currentIndex >= maxItems)
        {
            currentIndex = 0; // Wrap around
        }

        this.w3ba_mainMenuIndex.Clear();
        this.w3ba_mainMenuIndex.PushBack(currentIndex);

        itemName = W3BA_GetMainMenuItemName(currentIndex);
        W3BA_SpeakText(itemName, true, 2);
        W3BA_PlayCue("ui_menu_focus");
    }
    else if (NavCode == "navigate_up" || NavCode == "up")
    {
        currentIndex = currentIndex - 1;
        if (currentIndex < 0)
        {
            currentIndex = maxItems - 1; // Wrap around
        }

        this.w3ba_mainMenuIndex.Clear();
        this.w3ba_mainMenuIndex.PushBack(currentIndex);

        itemName = W3BA_GetMainMenuItemName(currentIndex);
        W3BA_SpeakText(itemName, true, 2);
        W3BA_PlayCue("ui_menu_focus");
    }
}

// NOTE: OnCloseMenu may not exist on CR4CommonMainMenuBase.
// Removed to avoid compilation errors.

// Helper to convert menu index to readable item names
function W3BA_GetMainMenuItemName(menuIndex : Int32) : String
{
    // Main menu items (order may vary based on save game availability)
    switch (menuIndex)
    {
        case 0:  return "Continue";
        case 1:  return "New Game";
        case 2:  return "Load Game";
        case 3:  return "Options";
        case 4:  return "Downloadable Content";
        case 5:  return "Credits";
        case 6:  return "Exit";
        default: return "Menu item " + menuIndex;
    }
}
