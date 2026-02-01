// W3BlindAccess - Dialogue Choice Hook
// Narrates dialogue choices when presented during conversations.
//
// CR4HudModuleDialog actual methods:
//   OnDialogChoicesSet(choices : array<SSceneChoice>, alternativeUI : bool)
//   OnDialogOptionSelected(index : int)
//   OnDialogSentenceSet(text : string, optional alternativeUI : bool)

// ---------------------------------------------------------------------------
// Dialogue choices shown
// ---------------------------------------------------------------------------

@wrapMethod(CR4HudModuleDialog)
function OnDialogChoicesSet(choices : array<SSceneChoice>, alternativeUI : bool)
{
    var count : int;
    var announcement : string;

    wrappedMethod(choices, alternativeUI);

    count = choices.Size();
    if (count > 0)
    {
        announcement = count + " dialogue options. ";
        announcement += "1: " + W3BA_GetChoiceText(choices[0]);

        W3BA_SpeakText(announcement, true, 2);
        W3BA_PlayCue("ui_menu_select");
    }
}

// ---------------------------------------------------------------------------
// Dialogue option selected (player picks a choice)
// ---------------------------------------------------------------------------

@wrapMethod(CR4HudModuleDialog)
function OnDialogOptionSelected(index : int)
{
    wrappedMethod(index);

    W3BA_SpeakText("Selected option " + (index + 1), true, 2);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function W3BA_GetChoiceText(choice : SSceneChoice) : string
{
    var text : string;

    text = choice.description;

    if (choice.emphasised)
    {
        text = "(Important) " + text;
    }

    if (choice.previouslyChoosen)
    {
        text = text + " (already chosen)";
    }

    return text;
}
