// W3BlindAccess - Meditation Menu Hook
// Wraps CR4MeditationMenu to narrate the current time and time selection.

@addField(CR4MeditationMenu)
var w3ba_lastMeditationHour : int;

// ---------------------------------------------------------------
// Menu open — announce current game time
// ---------------------------------------------------------------

@wrapMethod(CR4MeditationMenu)
function OnConfigUI()
{
    var gameHour : Int32;
    var text : String;

    wrappedMethod();

    w3ba_lastMeditationHour = -1;

    // Announce current in-game time
    gameHour = GameTimeHours(theGame.GetGameTime());

    text = "Meditation. Current time: " + W3BA_HourToTimeString(gameHour) + ". ";
    text += "Select hour to meditate until.";

    W3BA_SpeakText(text, true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// ---------------------------------------------------------------
// Input handling — detect time selection changes
// ---------------------------------------------------------------

@wrapMethod(CR4MeditationMenu)
function OnInputHandled(NavCode : string, KeyCode : int, ActionId : int)
{
    wrappedMethod(NavCode, KeyCode, ActionId);
    W3BA_NarrateMeditationTime(this);
}

// ---------------------------------------------------------------
// Menu close
// ---------------------------------------------------------------

@wrapMethod(CR4MeditationMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}

// ---------------------------------------------------------------
// Time narration
// ---------------------------------------------------------------

function W3BA_NarrateMeditationTime(menu : CR4MeditationMenu)
{
    var selectedHour : int;

    selectedHour = menu.GetCurrentMenuItemIndex();
    if (selectedHour == menu.w3ba_lastMeditationHour) { return; }
    menu.w3ba_lastMeditationHour = selectedHour;

    // The meditation clock lets you select an hour (0-23)
    // selectedHour should correspond to the target hour
    if (selectedHour >= 0 && selectedHour < 24)
    {
        W3BA_SpeakText("Meditate until " + W3BA_HourToTimeString(selectedHour), true, 2);
        W3BA_PlayCue("ui_menu_focus");
    }
}

function W3BA_HourToTimeString(hour : Int32) : String
{
    var period : String;
    var displayHour : Int32;

    if (hour == 0)       { return "midnight"; }
    if (hour == 12)      { return "noon"; }

    if (hour < 12)
    {
        period = "AM";
        displayHour = hour;
    }
    else
    {
        period = "PM";
        displayHour = hour - 12;
    }

    return displayHour + " " + period;
}
