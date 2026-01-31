// W3BlindAccess - Dialogue Choice Hook
// Narrates dialogue choices when presented during conversations
//
// The Witcher 3 dialogue system presents choices as a list.
// Choices can be: regular dialogue, Axii (charm), quest-critical, etc.
// The game voice-acts NPC lines but choice TEXT is shown visually only.

// ---------------------------------------------------------------------------
// Dialogue HUD Module Hook
// ---------------------------------------------------------------------------

// The dialogue choices are managed by CR4HudModuleDialog.
// When choices appear, we narrate the focused choice.
// When the player navigates up/down, we narrate the new selection.

@addField(CR4HudModuleDialog)
var w3ba_lastDialogueChoiceIndex : int;

@addField(CR4HudModuleDialog)
var w3ba_dialogueChoicesVisible : bool;

// Called when dialogue choices are shown to the player
@wrapMethod(CR4HudModuleDialog)
function ShowDialogChoices(choices : array<SSceneChoice>)
{
    var count : int;
    var announcement : string;

    wrappedMethod(choices);

    w3ba_dialogueChoicesVisible = true;
    w3ba_lastDialogueChoiceIndex = -1;

    // Announce the number of choices
    count = choices.Size();
    if (count > 0)
    {
        announcement = count + " dialogue options. ";

        // Read the first choice
        announcement += "1: " + W3BA_GetChoiceText(choices[0]);

        W3BA_SpeakText(announcement, true, 2);
        W3BA_PlayCue("ui_menu_select");

        w3ba_lastDialogueChoiceIndex = 0;
    }
}

// Called when the player navigates between dialogue choices
@wrapMethod(CR4HudModuleDialog)
function OnDialogChoiceFocused(choiceIndex : int)
{
    var choiceText : string;
    var prefix : string;

    wrappedMethod(choiceIndex);

    if (!w3ba_dialogueChoicesVisible) { return; }
    if (choiceIndex == w3ba_lastDialogueChoiceIndex) { return; }

    w3ba_lastDialogueChoiceIndex = choiceIndex;

    // Get the focused choice text
    choiceText = GetCurrentChoiceText(choiceIndex);
    prefix = (choiceIndex + 1) + ": ";

    W3BA_SpeakText(prefix + choiceText, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

// Called when dialogue choices are hidden (choice made or scene continues)
@wrapMethod(CR4HudModuleDialog)
function HideDialogChoices()
{
    wrappedMethod();

    w3ba_dialogueChoicesVisible  = false;
    w3ba_lastDialogueChoiceIndex = -1;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// Extract readable text from a dialogue choice, including any special markers
function W3BA_GetChoiceText(choice : SSceneChoice) : string
{
    var text : string;

    text = choice.description;

    // Annotate special choice types
    if (choice.emphasised)
    {
        // Quest-important choices are often emphasised
        text = "(Important) " + text;
    }

    // Check for Axii (mind control) dialogue options
    // These are typically indicated by a gameplay tag
    if (choice.previouslyChoosen)
    {
        text = text + " (already chosen)";
    }

    return text;
}

// Gets the display text for the currently focused choice
function GetCurrentChoiceText(choiceIndex : int) : string
{
    // TODO: Read from the active scene's choice array
    // var scene : CStoryScene = theGame.GetActiveScene();
    // var choices : array<SSceneChoice> = scene.GetCurrentChoices();
    // if (choiceIndex >= 0 && choiceIndex < choices.Size())
    // {
    //     return W3BA_GetChoiceText(choices[choiceIndex]);
    // }
    return "Choice " + (choiceIndex + 1);
}
