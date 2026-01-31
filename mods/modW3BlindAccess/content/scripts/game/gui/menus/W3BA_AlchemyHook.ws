// W3BlindAccess - Alchemy Menu Hook
// Wraps CR4AlchemyMenu to narrate potion/oil/bomb recipes and crafting.

@addField(CR4AlchemyMenu)
var w3ba_lastAlchemyItemIndex : int;

@addField(CR4AlchemyMenu)
var w3ba_lastAlchemyTabIndex : int;

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4AlchemyMenu)
function OnConfigUI()
{
    wrappedMethod();

    w3ba_lastAlchemyItemIndex = -1;
    w3ba_lastAlchemyTabIndex  = -1;
    W3BA_SpeakText("Alchemy.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Input handling
// ---------------------------------------------------------------

@wrapMethod(CR4AlchemyMenu)
function OnInputHandled(NavCode : string, KeyCode : int, ActionId : int)
{
    wrappedMethod(NavCode, KeyCode, ActionId);
    W3BA_NarrateAlchemyItem(this);
}

// ---------------------------------------------------------------
// Tab changes (Potions, Oils, Bombs, Decoctions, etc.)
// ---------------------------------------------------------------

@wrapMethod(CR4AlchemyMenu)
function OnTabChanged(tabIndex : int)
{
    var tabName : string;

    wrappedMethod(tabIndex);

    if (tabIndex == w3ba_lastAlchemyTabIndex) { return; }
    w3ba_lastAlchemyTabIndex  = tabIndex;
    w3ba_lastAlchemyItemIndex = -1;

    switch (tabIndex)
    {
        case 0: tabName = "Potions";     break;
        case 1: tabName = "Oils";        break;
        case 2: tabName = "Bombs";       break;
        case 3: tabName = "Decoctions";  break;
        case 4: tabName = "Substances";  break;
        default: tabName = "Tab " + tabIndex; break;
    }

    W3BA_SpeakText(tabName + ".", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Menu close
// ---------------------------------------------------------------

@wrapMethod(CR4AlchemyMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}

// ---------------------------------------------------------------
// Recipe narration
// ---------------------------------------------------------------

function W3BA_NarrateAlchemyItem(menu : CR4AlchemyMenu)
{
    var currentIndex : int;

    currentIndex = menu.GetCurrentMenuItemIndex();
    if (currentIndex == menu.w3ba_lastAlchemyItemIndex) { return; }
    menu.w3ba_lastAlchemyItemIndex = currentIndex;

    // TODO: Extract recipe data from the alchemy system
    // The alchemy menu shows recipes (potions, oils, bombs).
    // Each recipe has:
    //   - Name (localized)
    //   - Whether it can be crafted (ingredients available)
    //   - Required ingredients list
    //   - Effect description
    //
    // Possible APIs:
    //   thePlayer.GetAlchemyRecipes() : array<name>
    //   inv.GetItemLocalizedNameByName(recipeName)
    //   GetLocStringByKeyExt("recipe_" + recipeName)
    //
    // For now announce the index

    W3BA_SpeakText("Recipe " + (currentIndex + 1), true, 2);
    W3BA_PlayCue("ui_menu_focus");
}
