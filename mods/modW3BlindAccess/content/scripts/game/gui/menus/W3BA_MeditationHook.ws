// W3BlindAccess - Meditation Menu Hook
// Wraps CR4MeditationClockMenu to narrate the current time.
// CR4MeditationClockMenu has OnConfigUI, OnCloseMenu, OnMeditate
// but not OnInputHandled or OnTabChanged.

// ---------------------------------------------------------------
// Menu open — announce current game time
// ---------------------------------------------------------------

@wrapMethod(CR4MeditationClockMenu)
function OnConfigUI()
{
    var gameHour : Int32;
    var text : String;

    wrappedMethod();

    gameHour = GameTimeHours(theGame.GetGameTime());

    text = "Meditation. Current time: " + W3BA_HourToTimeString(gameHour) + ". ";
    text += "Select hour to meditate until.";

    W3BA_SpeakText(text, true, 2);
    W3BA_PlayCue("ui_menu_select");
}

// NOTE: OnMeditate and OnCloseMenu may not exist on CR4MeditationClockMenu.
// Removed to avoid compilation errors.

// ---------------------------------------------------------------
// Time formatting helper
// ---------------------------------------------------------------

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
