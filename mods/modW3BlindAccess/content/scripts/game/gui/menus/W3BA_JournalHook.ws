// W3BlindAccess - Journal / Quest Menu Hook
// Wraps CR4JournalQuestMenu to narrate quest selection.
// CR4JournalQuestMenu has OnEntrySelected but not OnInputHandled or OnTabChanged.

// ---------------------------------------------------------------
// Menu open
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
// Entry selected — narrate quest
// ---------------------------------------------------------------

@wrapMethod(CR4JournalQuestMenu)
function OnEntrySelected(tag : name)
{
    wrappedMethod(tag);

    // tag is the internal name of the selected quest
    // TODO: resolve to localized quest title
    W3BA_SpeakText("" + tag, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

// ---------------------------------------------------------------
// Tracked quest announcement
// ---------------------------------------------------------------

function W3BA_AnnounceTrackedQuest()
{
    var jm : CWitcherJournalManager;
    var trackedQuest : CJournalQuest;
    var text : String;

    jm = theGame.GetJournalManager();
    if (!jm) { return; }

    trackedQuest = jm.GetTrackedQuest();
    if (!trackedQuest) { return; }

    // TODO: Extract quest title via GetTitleStringId() + GetLocStringById()
    text = "Tracked quest active.";

    W3BA_SpeakText(text, false, 1);
}
