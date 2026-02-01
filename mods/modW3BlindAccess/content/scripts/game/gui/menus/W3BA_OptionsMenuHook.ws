// W3BlindAccess - Options/Settings Menu Hook
// Options are handled within CR4IngameMenu, not a separate class.
// We hook OnOptionValueChanged to narrate setting changes.

@wrapMethod(CR4IngameMenu)
function OnOptionValueChanged(optionName : string, optionValue : string)
{
    wrappedMethod(optionName, optionValue);

    W3BA_SpeakText(optionName + " set to " + optionValue, true, 2);
}
