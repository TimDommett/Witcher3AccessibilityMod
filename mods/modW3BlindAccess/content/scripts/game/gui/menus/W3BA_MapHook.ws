// W3BlindAccess - Map Menu Hook
// Wraps CR4MapMenu to narrate current location, POIs, and waypoint placement.
// The visual map is inaccessible to blind players, so we provide a text-based
// summary of the player's location and nearby points of interest.

@addField(CR4MapMenu)
var w3ba_mapAnnounced : bool;

// ---------------------------------------------------------------
// Menu open — announce current location
// ---------------------------------------------------------------

@wrapMethod(CR4MapMenu)
function OnConfigUI()
{
    wrappedMethod();

    w3ba_mapAnnounced = false;
    W3BA_SpeakText("Map.", true, 2);
    W3BA_PlayCue("ui_menu_select");

    W3BA_AnnounceMapLocation();
}

// ---------------------------------------------------------------
// Input handling
// ---------------------------------------------------------------

@wrapMethod(CR4MapMenu)
function OnInputHandled(NavCode : string, KeyCode : int, ActionId : int)
{
    wrappedMethod(NavCode, KeyCode, ActionId);

    // The map menu is primarily visual. Navigation is limited to
    // panning/zooming which isn't useful for blind players.
    // We focus on providing location info when the map opens.
    if (!w3ba_mapAnnounced)
    {
        W3BA_AnnounceMapLocation();
        w3ba_mapAnnounced = true;
    }
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

    // Get current area/region name
    areaName = W3BA_GetCurrentAreaName();

    text = "Current location: " + areaName + ". ";
    text += "Position: " + RoundMath(playerPos.X) + ", " + RoundMath(playerPos.Y) + ". ";

    // TODO: List nearby discovered POIs from map manager
    // var mapManager : CCommonMapManager;
    // mapManager = theGame.GetCommonMapManager();
    // Iterate known map pins near player and list them

    W3BA_SpeakText(text, false, 2);
}

function W3BA_GetCurrentAreaName() : String
{
    var area : EAreaName;

    area = theGame.GetCommonMapManager().GetCurrentArea();

    switch (area)
    {
        case AN_WhiteOrchard:   return "White Orchard";
        case AN_NMLandNovigrad: return "Velen and Novigrad";
        case AN_Skellige:       return "Skellige";
        case AN_KaerMorhen:     return "Kaer Morhen";
        case AN_Prologue:       return "Kaer Morhen (Prologue)";
        default:                return "Unknown area";
    }
}
