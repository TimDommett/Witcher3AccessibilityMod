// W3BlindAccess - Map Menu Hook
// Wraps CR4MapMenu to narrate current location.
// CR4MapMenu has OnEntrySelected but not OnInputHandled.

// ---------------------------------------------------------------
// Menu open — announce current location
// ---------------------------------------------------------------

@wrapMethod(CR4MapMenu)
function OnConfigUI()
{
    wrappedMethod();

    W3BA_SpeakText("Map.", true, 2);
    W3BA_PlayCue("ui_menu_select");

    W3BA_AnnounceMapLocation();
}

// ---------------------------------------------------------------
// Entry selected — a map pin was selected
// ---------------------------------------------------------------

@wrapMethod(CR4MapMenu)
function OnEntrySelected(tag : name)
{
    wrappedMethod(tag);

    W3BA_SpeakText("" + tag, true, 2);
    W3BA_PlayCue("ui_menu_focus");
}

// ---------------------------------------------------------------
// Menu close
// ---------------------------------------------------------------

@wrapMethod(CR4MapMenu)
function OnCloseMenu()
{
    wrappedMethod();
    W3BA_PlayCue("ui_menu_back");
}

// ---------------------------------------------------------------
// Location announcement
// ---------------------------------------------------------------

function W3BA_AnnounceMapLocation()
{
    var text : String;
    var areaName : String;
    var playerPos : Vector;

    if (!thePlayer) { return; }

    playerPos = thePlayer.GetWorldPosition();

    areaName = W3BA_GetCurrentAreaName();

    text = "Current location: " + areaName + ". ";
    text += "Position: " + RoundMath(playerPos.X) + ", " + RoundMath(playerPos.Y) + ". ";

    W3BA_SpeakText(text, false, 2);
}

function W3BA_GetCurrentAreaName() : String
{
    var area : EAreaName;

    area = theGame.GetCommonMapManager().GetCurrentArea();

    switch (area)
    {
        case AN_Prologue_Village:    return "White Orchard";
        case AN_NMLandNovigrad:      return "Velen and Novigrad";
        case AN_Velen:               return "Velen";
        case AN_Skellige_ArdSkellig: return "Skellige";
        case AN_Kaer_Morhen:         return "Kaer Morhen";
        case AN_Wyzima:              return "Vizima";
        default:                     return "Unknown area";
    }
}
