// W3BlindAccess - Crafting Menu Hook
// Wraps CR4CraftingMenu to narrate crafting schematics, materials, and results.

@addField(CR4CraftingMenu)
var w3ba_lastCraftItemIndex : int;

@addField(CR4CraftingMenu)
var w3ba_lastCraftTabIndex : int;

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4CraftingMenu)
function OnConfigUI()
{
    wrappedMethod();

    w3ba_lastCraftItemIndex = -1;
    w3ba_lastCraftTabIndex  = -1;
    W3BA_SpeakText("Crafting.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Input handling
// ---------------------------------------------------------------

@wrapMethod(CR4CraftingMenu)
function OnInputHandled(NavCode : string, KeyCode : int, ActionId : int)
{
    wrappedMethod(NavCode, KeyCode, ActionId);
    W3BA_NarrateCraftingItem(this);
}

// ---------------------------------------------------------------
// Tab changes (Weapons, Armor, etc.)
// ---------------------------------------------------------------

@wrapMethod(CR4CraftingMenu)
function OnTabChanged(tabIndex : int)
{
    var tabName : string;

    wrappedMethod(tabIndex);

    if (tabIndex == w3ba_lastCraftTabIndex) { return; }
    w3ba_lastCraftTabIndex  = tabIndex;
    w3ba_lastCraftItemIndex = -1;

    switch (tabIndex)
    {
        case 0: tabName = "Weapons";       break;
        case 1: tabName = "Armor";         break;
        case 2: tabName = "Upgrades";      break;
        case 3: tabName = "Components";    break;
        default: tabName = "Tab " + tabIndex; break;
    }

    W3BA_SpeakText(tabName + ".", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Menu close
// ---------------------------------------------------------------

@wrapMethod(CR4CraftingMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}

// ---------------------------------------------------------------
// Schematic narration
// ---------------------------------------------------------------

function W3BA_NarrateCraftingItem(menu : CR4CraftingMenu)
{
    var currentIndex : int;

    currentIndex = menu.GetCurrentMenuItemIndex();
    if (currentIndex == menu.w3ba_lastCraftItemIndex) { return; }
    menu.w3ba_lastCraftItemIndex = currentIndex;

    // TODO: Extract crafting schematic data
    // Schematics have:
    //   - Result item name
    //   - Required materials with quantities
    //   - Whether craftable (materials available)
    //   - Required crafting level
    //
    // Possible APIs:
    //   thePlayer.GetCraftingSchematicsNames() : array<name>
    //   inv.GetItemLocalizedNameByName(schematicResult)
    //
    // For now announce the index

    W3BA_SpeakText("Schematic " + (currentIndex + 1), true, 2);
    W3BA_PlayCue("ui_menu_focus");
}
