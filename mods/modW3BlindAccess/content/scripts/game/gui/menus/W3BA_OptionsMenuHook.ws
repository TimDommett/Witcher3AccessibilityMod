// W3BlindAccess - Options/Settings Menu Hook
// Narrates settings names and current values when navigating options
//
// The options menu has multiple tabs: Video, Audio, Gameplay, Controls, etc.
// Each tab contains a list of settings with their current values.

// Options/settings are handled within CR4IngameMenu, not a separate class.
// This file adds option-specific narration hooks to the same CR4IngameMenu class.
// Multiple @wrapMethod on the same class from different files chain together.

@addField(CR4IngameMenu)
var w3ba_lastOptionIndex : int;

@addField(CR4IngameMenu)
var w3ba_lastOptionTabIndex : int;

// Narrate when a setting value is changed
@wrapMethod(CR4IngameMenu)
function OnOptionValueChanged(optionName : string, optionValue : string)
{
    wrappedMethod(optionName, optionValue);

    // Read the localized display name if available
    W3BA_SpeakText(optionName + " set to " + optionValue, true, 2);
}
