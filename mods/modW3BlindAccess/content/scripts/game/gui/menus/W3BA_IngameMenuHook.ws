// W3BlindAccess - Ingame (Pause) Menu Hook
// Wraps CR4IngameMenu to narrate pause menu navigation.

// Track menu selection index for navigation announcements
@addField(CR4IngameMenu)
var w3ba_menuIndex : array<Int32>;

@wrapMethod(CR4IngameMenu)
function OnConfigUI()
{
    wrappedMethod();

    // Initialize menu index to 0 (first item)
    this.w3ba_menuIndex.Clear();
    this.w3ba_menuIndex.PushBack(0);

    W3BA_SpeakText("Pause Menu. Resume.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// OnInputHandled fires on all menu input including navigation
@wrapMethod(CR4IngameMenu)
function OnInputHandled(NavCode : String, KeyCode : Int32, ActionId : Int32)
{
    var currentIndex : Int32;
    var itemName : String;
    var maxItems : Int32;

    wrappedMethod(NavCode, KeyCode, ActionId);

    // Number of items in pause menu (adjust if needed)
    maxItems = 14;

    // Get current index
    if (this.w3ba_menuIndex.Size() > 0)
    {
        currentIndex = this.w3ba_menuIndex[0];
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

        this.w3ba_menuIndex.Clear();
        this.w3ba_menuIndex.PushBack(currentIndex);

        itemName = W3BA_GetIngameMenuItemName(currentIndex);
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

        this.w3ba_menuIndex.Clear();
        this.w3ba_menuIndex.PushBack(currentIndex);

        itemName = W3BA_GetIngameMenuItemName(currentIndex);
        W3BA_SpeakText(itemName, true, 2);
        W3BA_PlayCue("ui_menu_focus");
    }
}

@wrapMethod(CR4IngameMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_SpeakText("Resuming game.", true, 1);
    W3BA_PlayCue("ui_menu_back");
}

// Helper to convert menu index to readable item names
function W3BA_GetIngameMenuItemName(menuIndex : Int32) : String
{
    // Common pause menu items (may need adjustment based on game version)
    switch (menuIndex)
    {
        case 0:  return "Resume";
        case 1:  return "Inventory";
        case 2:  return "Character";
        case 3:  return "World Map";
        case 4:  return "Quests";
        case 5:  return "Meditation";
        case 6:  return "Alchemy";
        case 7:  return "Bestiary";
        case 8:  return "Glossary";
        case 9:  return "Crafting";
        case 10: return "Options";
        case 11: return "Save Game";
        case 12: return "Load Game";
        case 13: return "Exit";
        default: return "Menu item " + menuIndex;
    }
}
