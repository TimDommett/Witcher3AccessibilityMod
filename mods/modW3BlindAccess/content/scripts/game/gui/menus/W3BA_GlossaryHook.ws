// W3BlindAccess - Glossary & Bestiary Menu Hook
// Wraps CR4GlossaryBestiaryMenu to narrate creature entries and glossary info.

@addField(CR4GlossaryBestiaryMenu)
var w3ba_lastGlossaryItemIndex : int;

@addField(CR4GlossaryBestiaryMenu)
var w3ba_lastGlossaryTabIndex : int;

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4GlossaryBestiaryMenu)
function OnConfigUI()
{
    wrappedMethod();

    w3ba_lastGlossaryItemIndex = -1;
    w3ba_lastGlossaryTabIndex  = -1;
    W3BA_SpeakText("Bestiary and Glossary.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Input handling
// ---------------------------------------------------------------

@wrapMethod(CR4GlossaryBestiaryMenu)
function OnInputHandled(NavCode : string, KeyCode : int, ActionId : int)
{
    wrappedMethod(NavCode, KeyCode, ActionId);
    W3BA_NarrateGlossaryItem(this);
}

// ---------------------------------------------------------------
// Tab changes (Monsters, Characters, Places, etc.)
// ---------------------------------------------------------------

@wrapMethod(CR4GlossaryBestiaryMenu)
function OnTabChanged(tabIndex : int)
{
    var tabName : string;

    wrappedMethod(tabIndex);

    if (tabIndex == w3ba_lastGlossaryTabIndex) { return; }
    w3ba_lastGlossaryTabIndex  = tabIndex;
    w3ba_lastGlossaryItemIndex = -1;

    switch (tabIndex)
    {
        case 0: tabName = "Monsters";      break;
        case 1: tabName = "Characters";    break;
        case 2: tabName = "Places";        break;
        case 3: tabName = "Tutorial";      break;
        case 4: tabName = "Books";         break;
        default: tabName = "Tab " + tabIndex; break;
    }

    W3BA_SpeakText(tabName + ".", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Menu close
// ---------------------------------------------------------------

@wrapMethod(CR4GlossaryBestiaryMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}

// ---------------------------------------------------------------
// Entry narration
// ---------------------------------------------------------------

function W3BA_NarrateGlossaryItem(menu : CR4GlossaryBestiaryMenu)
{
    var currentIndex : int;

    currentIndex = menu.GetCurrentMenuItemIndex();
    if (currentIndex == menu.w3ba_lastGlossaryItemIndex) { return; }
    menu.w3ba_lastGlossaryItemIndex = currentIndex;

    // TODO: Extract bestiary/glossary entry data
    // Bestiary entries have:
    //   - Creature name
    //   - Category (Necrophages, Specters, etc.)
    //   - Description text
    //   - Weaknesses (signs, oils, bombs)
    //   - Loot drops
    //
    // Possible APIs:
    //   theGame.GetJournalManager().GetCreatureEntries()
    //   CJournalCreature.GetNameStringId(), GetDescriptionStringId()
    //   GetLocStringById(stringId)
    //
    // For now announce the index

    W3BA_SpeakText("Entry " + (currentIndex + 1), true, 2);
    W3BA_PlayCue("ui_menu_focus");
}
