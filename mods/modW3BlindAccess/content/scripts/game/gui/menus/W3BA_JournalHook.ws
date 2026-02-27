// W3BlindAccess - Journal / Quest Menu Hook
// Wraps CR4JournalQuestMenu to narrate quest selection and tracking.

// ---------------------------------------------------------------
// Menu open with tracked quest info
// ---------------------------------------------------------------

@wrapMethod(CR4JournalQuestMenu)
function OnConfigUI()
{
    wrappedMethod();

    W3BA_SpeakText("Quest Journal.", true, 2);
    W3BA_PlayCue("ui_menu_select");

    // Announce tracked quest info
    W3BA_AnnounceTrackedQuest();
}

// ---------------------------------------------------------------
// Tab changes (Main Quests, Secondary, Contracts, Treasure Hunts)
// ---------------------------------------------------------------

@wrapMethod(CR4JournalQuestMenu)
function OnTabChanged(tabIndex : Int32)
{
    var tabName : String;

    wrappedMethod(tabIndex);

    switch (tabIndex)
    {
        case 0: tabName = "Main Quests";     break;
        case 1: tabName = "Secondary Quests"; break;
        case 2: tabName = "Witcher Contracts"; break;
        case 3: tabName = "Treasure Hunts";  break;
        default: tabName = "Tab " + tabIndex; break;
    }

    W3BA_SpeakText(tabName + ".", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Entry selected — narrate quest name and status
// ---------------------------------------------------------------

@wrapMethod(CR4JournalQuestMenu)
function OnEntrySelected(tag : CName)
{
    var questName : String;
    var text : String;

    wrappedMethod(tag);

    // Try to get localized quest name
    questName = GetLocStringByKeyExt(NameToString(tag));
    if (questName == "" || questName == NameToString(tag))
    {
        // Fallback: use the tag name
        questName = NameToString(tag);
    }

    text = questName;

    W3BA_SpeakText(text, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

// ---------------------------------------------------------------
// Tracked quest announcement
// ---------------------------------------------------------------

function W3BA_AnnounceTrackedQuest()
{
    var jm : CWitcherJournalManager;
    var trackedQuest : CJournalQuest;
    var questTitle : String;
    var text : String;

    jm = theGame.GetJournalManager();
    if (!jm) { return; }

    trackedQuest = jm.GetTrackedQuest();
    if (!trackedQuest) { return; }

    // Get quest title using localization
    questTitle = GetLocStringById(trackedQuest.GetTitleStringId());
    if (questTitle == "")
    {
        questTitle = "Unknown quest";
    }

    text = "Currently tracking: " + questTitle;
    W3BA_SpeakText(text, false, 1);
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
