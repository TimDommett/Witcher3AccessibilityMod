// W3BlindAccess - Navigation Beacon
// Provides directional audio beacon guiding player toward active quest objective

class W3BA_NavigationBeacon
{
    private var config       : W3BA_Config;
    private var audioManager : W3BA_AudioManager;
    private var ttsBridge    : W3BA_TTSBridge;

    private var isActive        : Bool;
    private var beaconInterval  : Float;
    private var timeSinceBeacon : Float;

    // ---------------------------------------------------------------
    // Lifecycle
    // ---------------------------------------------------------------

    public function Initialize(cfg : W3BA_Config, audio : W3BA_AudioManager, tts : W3BA_TTSBridge)
    {
        config       = cfg;
        audioManager = audio;
        ttsBridge    = tts;

        isActive        = false;
        beaconInterval  = cfg.GetBeaconInterval();
        timeSinceBeacon = 0.0;
    }

    // ---------------------------------------------------------------
    // Per-frame update
    // ---------------------------------------------------------------

    public function Update(deltaTime : Float)
    {
        if (!isActive) { return; }
        if (!config.IsNavigationBeaconEnabled()) { return; }

        timeSinceBeacon += deltaTime;
        if (timeSinceBeacon >= beaconInterval)
        {
            PlayBeaconPing();
            timeSinceBeacon = 0.0;
        }
    }

    // ---------------------------------------------------------------
    // Beacon control
    // ---------------------------------------------------------------

    public function ToggleBeacon()
    {
        isActive = !isActive;

        if (isActive)
        {
            timeSinceBeacon = beaconInterval; // play immediately
            ttsBridge.Speak("Navigation beacon on.", true, 2);
        }
        else
        {
            audioManager.StopBeacon();
            ttsBridge.Speak("Navigation beacon off.", true, 2);
        }
    }

    public function IsActive() : Bool
    {
        return isActive;
    }

    // ---------------------------------------------------------------
    // Announce current objective with distance and direction
    // ---------------------------------------------------------------

    public function AnnounceObjective()
    {
        var waypoint : Vector = GetActiveWaypointPosition();
        if (IsVectorZero(waypoint))
        {
            ttsBridge.Speak("No active waypoint.", true, 2);
            return;
        }

        var playerPos : Vector = thePlayer.GetWorldPosition();
        var distance  : Float  = VecDistance(playerPos, waypoint);
        var cardinal  : String = GetCardinalFromPlayer(waypoint);

        var text : String = "Objective: " + RoundF(distance) + " meters " + cardinal;
        ttsBridge.Speak(text, true, 2);
    }

    // ---------------------------------------------------------------
    // Internal helpers
    // ---------------------------------------------------------------

    private function PlayBeaconPing()
    {
        var waypoint : Vector = GetActiveWaypointPosition();
        if (IsVectorZero(waypoint)) { return; }

        var playerPos : Vector = thePlayer.GetWorldPosition();
        var distance  : Float  = VecDistance(playerPos, waypoint);

        // Pitch: higher when closer (2.0 at 0m, 0.5 at 500m)
        var pitch : Float = 2.0 - (ClampF(distance, 0.0, 500.0) / 500.0) * 1.5;

        // Choose cue based on quest type
        var cueId : String = "beacon_quest_main";
        // TODO: differentiate main vs side quest

        audioManager.PlayCue3D(cueId, waypoint, pitch);
    }

    private function GetActiveWaypointPosition() : Vector
    {
        // TODO: Extract from quest manager / minimap module
        // var mapManager = theGame.GetCommonMapManager();
        // return mapManager.GetCurrentQuestWaypoint();

        return Vector(0, 0, 0);
    }

    private function GetCardinalFromPlayer(target : Vector) : String
    {
        // TODO: Reuse W3BA_SpatialAudio.GetCompassDirection once wired
        var playerPos : Vector = thePlayer.GetWorldPosition();
        var toTarget  : Vector = target - playerPos;
        var angle     : Float  = Atan2(toTarget.Y, toTarget.X);

        while (angle < 0)    { angle += 360.0; }
        while (angle >= 360) { angle -= 360.0; }

        if      (angle < 22.5 || angle >= 337.5)  { return "east"; }
        else if (angle < 67.5)                     { return "northeast"; }
        else if (angle < 112.5)                    { return "north"; }
        else if (angle < 157.5)                    { return "northwest"; }
        else if (angle < 202.5)                    { return "west"; }
        else if (angle < 247.5)                    { return "southwest"; }
        else if (angle < 292.5)                    { return "south"; }
        else                                        { return "southeast"; }
    }

    private function IsVectorZero(v : Vector) : Bool
    {
        return v.X == 0 && v.Y == 0 && v.Z == 0;
    }
}
