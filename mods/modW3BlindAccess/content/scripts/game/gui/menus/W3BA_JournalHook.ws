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

// NOTE: OnCloseMenu may not exist on CR4JournalQuestMenu.
