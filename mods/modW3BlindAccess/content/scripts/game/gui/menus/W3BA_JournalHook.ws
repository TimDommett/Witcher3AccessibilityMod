// W3BlindAccess - Journal / Quest Menu Hook
// Wraps CR4JournalQuestMenu to narrate quest list, objectives, and details.

@addField(CR4JournalQuestMenu)
var w3ba_lastJournalItemIndex : int;

@addField(CR4JournalQuestMenu)
var w3ba_lastJournalTabIndex : int;

// ---------------------------------------------------------------
// Menu open
// ---------------------------------------------------------------

@wrapMethod(CR4JournalQuestMenu)
function OnConfigUI()
{
    wrappedMethod();

    w3ba_lastJournalItemIndex = -1;
    w3ba_lastJournalTabIndex  = -1;

    W3BA_SpeakText("Quest Journal.", true, 2);
    W3BA_PlayCue("ui_menu_select");

    // Announce tracked quest info
    W3BA_AnnounceTrackedQuest();
}

// ---------------------------------------------------------------
// Input handling
// ---------------------------------------------------------------

@wrapMethod(CR4JournalQuestMenu)
function OnInputHandled(NavCode : string, KeyCode : int, ActionId : int)
{
    wrappedMethod(NavCode, KeyCode, ActionId);
    W3BA_NarrateJournalItem(this);
}

// ---------------------------------------------------------------
// Tab changes (Main Quests, Secondary, Witcher Contracts, Treasure Hunts)
// ---------------------------------------------------------------

@wrapMethod(CR4JournalQuestMenu)
function OnTabChanged(tabIndex : int)
{
    var tabName : string;

    wrappedMethod(tabIndex);

    if (tabIndex == w3ba_lastJournalTabIndex) { return; }
    w3ba_lastJournalTabIndex  = tabIndex;
    w3ba_lastJournalItemIndex = -1;

    switch (tabIndex)
    {
        case 0: tabName = "Main Quests";       break;
        case 1: tabName = "Secondary Quests";  break;
        case 2: tabName = "Witcher Contracts"; break;
        case 3: tabName = "Treasure Hunts";    break;
        default: tabName = "Tab " + tabIndex;  break;
    }

    W3BA_SpeakText(tabName + ".", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Menu close
// ---------------------------------------------------------------

@wrapMethod(CR4JournalQuestMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}

// ---------------------------------------------------------------
// Quest narration
// ---------------------------------------------------------------

function W3BA_NarrateJournalItem(menu : CR4JournalQuestMenu)
{
    var currentIndex : int;

    currentIndex = menu.GetCurrentMenuItemIndex();
    if (currentIndex == menu.w3ba_lastJournalItemIndex) { return; }
    menu.w3ba_lastJournalItemIndex = currentIndex;

    // The journal menu lists quests. Index corresponds to visible quest list.
    // TODO: Extract quest title from CWitcherJournalManager
    //   var jm : CWitcherJournalManager;
    //   jm = theGame.GetJournalManager();
    //   var quest : CJournalQuest = jm.GetQuestByIndex(currentIndex);
    //   var title : String = GetLocStringById(quest.GetTitleStringId());

    W3BA_SpeakText("Quest " + (currentIndex + 1), true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

function W3BA_AnnounceTrackedQuest()
{
    var jm : CWitcherJournalManager;
    var trackedQuest : CJournalQuest;
    var text : String;

    jm = theGame.GetJournalManager();
    if (!jm) { return; }

    trackedQuest = jm.GetTrackedQuest();
    if (!trackedQuest) { return; }

    // TODO: Extract quest title. CJournalQuest may have GetTitleStringId()
    // For now, announce that a quest is tracked.
    text = "Tracked quest active.";

    // TODO: Get current objective text
    // var objectives : array<CJournalQuestObjective>;
    // trackedQuest.GetObjectives(objectives);
    // for each active objective, append text

    W3BA_SpeakText(text, false, 1);
}
