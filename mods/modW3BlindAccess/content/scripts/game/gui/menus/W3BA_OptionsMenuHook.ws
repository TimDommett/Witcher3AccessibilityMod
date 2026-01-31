// W3BlindAccess - Options/Settings Menu Hook
// Narrates settings names and current values when navigating options
//
// The options menu has multiple tabs: Video, Audio, Gameplay, Controls, etc.
// Each tab contains a list of settings with their current values.

@addField(CR4OptionsMenu)
var w3ba_lastOptionIndex : int;

@addField(CR4OptionsMenu)
var w3ba_lastOptionTabIndex : int;

@wrapMethod(CR4OptionsMenu)
function OnConfigUI()
{
    wrappedMethod();

    w3ba_lastOptionIndex    = -1;
    w3ba_lastOptionTabIndex = -1;

    W3BA_SpeakText("Options Menu.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// Narrate when switching between option tabs
@wrapMethod(CR4OptionsMenu)
function OnTabChanged(tabIndex : int)
{
    var tabName : string;

    wrappedMethod(tabIndex);

    if (tabIndex == w3ba_lastOptionTabIndex) { return; }
    w3ba_lastOptionTabIndex = tabIndex;
    w3ba_lastOptionIndex    = -1; // reset item tracking for new tab

    switch (tabIndex)
    {
        case 0: tabName = "Video";       break;
        case 1: tabName = "Graphics";    break;
        case 2: tabName = "Audio";       break;
        case 3: tabName = "Gameplay";    break;
        case 4: tabName = "Controls";    break;
        case 5: tabName = "HUD";         break;
        default: tabName = "Tab " + tabIndex; break;
    }

    W3BA_SpeakText(tabName + " settings.", true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// Narrate individual setting focus
@wrapMethod(CR4OptionsMenu)
function OnInputHandled(NavCode : string, KeyCode : int, ActionId : int)
{
    wrappedMethod(NavCode, KeyCode, ActionId);
    W3BA_NarrateOptionSelection(this);
}

function W3BA_NarrateOptionSelection(menu : CR4OptionsMenu)
{
    var currentIndex : int;
    var settingName  : string;
    var settingValue : string;
    var text : string;

    currentIndex = menu.GetCurrentMenuItemIndex();

    if (currentIndex == menu.w3ba_lastOptionIndex) { return; }
    menu.w3ba_lastOptionIndex = currentIndex;

    // Read the setting name and current value from the Flash layer
    // The options menu stores setting data in Flash.
    // We attempt to read the currently focused entry's label and value.
    settingName  = W3BA_GetOptionName(menu, currentIndex);
    settingValue = W3BA_GetOptionValue(menu, currentIndex);

    text = settingName;
    if (settingValue != "")
    {
        text += ": " + settingValue;
    }

    W3BA_SpeakText(text, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

function W3BA_GetOptionName(menu : CR4OptionsMenu, index : int) : string
{
    // TODO: Read from CInGameConfigWrapper or Flash data bindings
    // The game stores config entries with localized display names.
    //
    // var configWrapper : CInGameConfigWrapper = theGame.GetInGameConfigWrapper();
    // var groups : array<SConfigGroupEntry> = configWrapper.GetGroupEntries(currentTabGroup);
    // return groups[index].displayName;

    return "Setting " + (index + 1);
}

function W3BA_GetOptionValue(menu : CR4OptionsMenu, index : int) : string
{
    // TODO: Read current value from CInGameConfigWrapper
    // var configWrapper : CInGameConfigWrapper = theGame.GetInGameConfigWrapper();
    // return configWrapper.GetVarDisplayValue(currentTabGroup, entryName);

    return "";
}

// Narrate when a setting value is changed
@wrapMethod(CR4OptionsMenu)
function OnOptionValueChanged(optionName : string, optionValue : string)
{
    wrappedMethod(optionName, optionValue);

    // Read the localized display name if available
    W3BA_SpeakText(optionName + " set to " + optionValue, true, 2);
}

@wrapMethod(CR4OptionsMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}
