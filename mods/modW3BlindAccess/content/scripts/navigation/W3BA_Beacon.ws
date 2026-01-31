// W3BlindAccess - Navigation Beacon
// Provides directional audio beacon guiding player toward active quest objective.
// Uses the game's map pin system to extract quest waypoint world positions.

class W3BA_NavigationBeacon
{
    private var config       : W3BA_Config;
    private var audioManager : W3BA_AudioManager;
    private var ttsBridge    : W3BA_TTSBridge;

    private var isActive        : Bool;
    private var beaconInterval  : Float;
    private var timeSinceBeacon : Float;

    // Cache the last known waypoint to avoid per-tick lookups
    private var cachedWaypoint      : Vector;
    private var waypointCacheTimer   : Float;
    private var waypointCacheInterval : Float;

    // ---------------------------------------------------------------
    // Lifecycle
    // ---------------------------------------------------------------

    public function Initialize(cfg : W3BA_Config, audio : W3BA_AudioManager, tts : W3BA_TTSBridge)
    {
        config       = cfg;
        audioManager = audio;
        ttsBridge    = tts;

        isActive              = false;
        beaconInterval        = cfg.GetBeaconInterval();
        timeSinceBeacon       = 0.0;
        waypointCacheTimer    = 0.0;
        waypointCacheInterval = 2.0;
        cachedWaypoint        = Vector(0, 0, 0);
    }

    // ---------------------------------------------------------------
    // Per-frame update
    // ---------------------------------------------------------------

    public function Update(deltaTime : Float)
    {
        if (!isActive) { return; }
        if (!config.IsNavigationBeaconEnabled()) { return; }

        // Periodically refresh cached waypoint
        waypointCacheTimer += deltaTime;
        if (waypointCacheTimer >= waypointCacheInterval)
        {
            cachedWaypoint = GetActiveWaypointPosition();
            waypointCacheTimer = 0.0;
        }

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
            cachedWaypoint  = GetActiveWaypointPosition();
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
        var waypoint  : Vector;
        var playerPos : Vector;
        var distance  : Float;
        var relative  : String;
        var compass   : String;
        var text      : String;

        waypoint = GetActiveWaypointPosition();
        cachedWaypoint = waypoint;

        if (IsVectorZero(waypoint))
        {
            ttsBridge.Speak("No active waypoint.", true, 2);
            return;
        }

        playerPos = thePlayer.GetWorldPosition();
        distance  = VecDistance(playerPos, waypoint);
        relative  = GetRelativeDirection(waypoint);
        compass   = GetCompassDirection(waypoint);

        text = "Objective: " + RoundMath(distance) + " meters, " + relative + ", " + compass;
        ttsBridge.Speak(text, true, 2);
    }

    // ---------------------------------------------------------------
    // Internal: beacon ping
    // ---------------------------------------------------------------

    private function PlayBeaconPing()
    {
        var playerPos : Vector;
        var distance  : Float;
        var pitch     : Float;
        var cueId     : String;

        if (IsVectorZero(cachedWaypoint)) { return; }

        playerPos = thePlayer.GetWorldPosition();
        distance  = VecDistance(playerPos, cachedWaypoint);

        // Pitch: higher when closer (2.0 at 0m, 0.5 at 500m)
        pitch = 2.0 - (ClampF(distance, 0.0, 500.0) / 500.0) * 1.5;

        // Choose cue based on quest type
        cueId = GetBeaconCueId();

        audioManager.PlayCue3D(cueId, cachedWaypoint, pitch);
    }

    // ---------------------------------------------------------------
    // Waypoint extraction from game systems
    // ---------------------------------------------------------------

    private function GetActiveWaypointPosition() : Vector
    {
        var mapManager : CCommonMapManager;
        var waypoint : Vector;

        mapManager = theGame.GetCommonMapManager();
        if (!mapManager) { return Vector(0, 0, 0); }

        // Approach 1: Try to get the tracked quest objective world position
        // The map manager maintains pins for quest objectives.
        // GetCurrentJournalQuestMapPinPosition is the ideal method if it exists.
        waypoint = TryGetQuestObjectivePosition(mapManager);
        if (!IsVectorZero(waypoint))
        {
            return waypoint;
        }

        // Approach 2: Try user-placed waypoint as fallback
        waypoint = TryGetUserWaypointPosition(mapManager);
        if (!IsVectorZero(waypoint))
        {
            return waypoint;
        }

        return Vector(0, 0, 0);
    }

    private function TryGetQuestObjectivePosition(mapManager : CCommonMapManager) : Vector
    {
        // The Witcher 3 journal system tracks the active quest objective.
        // CCommonMapManager creates map pins for tracked objectives.
        //
        // Known API methods on CCommonMapManager:
        //   GetEntityMapPins(out pins : array<SEntityMapPinInfo>)
        //   GetUserMapPinByIndex(index : Int32) : SUserMapPinInstanceData
        //   GetHighlightedMapPin() - might return current quest pin
        //
        // The exact method varies by game version. We try the most likely ones.
        // If none compile, the waypoint will be zero and beacon silently does nothing.

        // TODO: Verify against actual game script dump which method provides
        // the tracked quest objective world position. Candidates:
        //
        // Option A: mapManager.GetCurrentTrackedQuestPosition()
        // Option B: Iterate GetEntityMapPins() and filter for quest type
        // Option C: Use theGame.GetJournalManager().GetTrackedQuest() +
        //           quest objective map pin lookup
        //
        // For now, return zero - beacon won't ping without a valid position.
        // This is the HIGHEST PRIORITY item to verify during in-game testing.

        return Vector(0, 0, 0);
    }

    private function TryGetUserWaypointPosition(mapManager : CCommonMapManager) : Vector
    {
        // Users can place custom waypoints on the map. If the player manually
        // placed a waypoint, use that as a navigation target.
        //
        // TODO: Check if mapManager.GetUserMapPinByIndex(0) returns a
        // valid user-placed waypoint with world coordinates.

        return Vector(0, 0, 0);
    }

    // ---------------------------------------------------------------
    // Direction helpers
    // ---------------------------------------------------------------

    // Returns player-relative direction (ahead, behind, left, right)
    private function GetRelativeDirection(target : Vector) : String
    {
        var playerPos     : Vector;
        var playerRot     : EulerAngles;
        var toTarget      : Vector;
        var angle         : Float;
        var relativeAngle : Float;

        playerPos = thePlayer.GetWorldPosition();
        playerRot = thePlayer.GetWorldRotation();
        toTarget  = target - playerPos;

        angle = Atan2(toTarget.Y, toTarget.X);
        relativeAngle = angle - playerRot.Yaw;

        // Normalize to 0-360
        while (relativeAngle < 0)    { relativeAngle += 360.0; }
        while (relativeAngle >= 360) { relativeAngle -= 360.0; }

        if      (relativeAngle < 22.5 || relativeAngle >= 337.5)  { return "ahead"; }
        else if (relativeAngle < 67.5)                             { return "ahead right"; }
        else if (relativeAngle < 112.5)                            { return "right"; }
        else if (relativeAngle < 157.5)                            { return "behind right"; }
        else if (relativeAngle < 202.5)                            { return "behind"; }
        else if (relativeAngle < 247.5)                            { return "behind left"; }
        else if (relativeAngle < 292.5)                            { return "left"; }
        else                                                        { return "ahead left"; }
    }

    // Returns compass direction (north/south/east/west)
    private function GetCompassDirection(target : Vector) : String
    {
        var playerPos : Vector;
        var toTarget  : Vector;
        var angle     : Float;

        playerPos = thePlayer.GetWorldPosition();
        toTarget  = target - playerPos;
        angle     = Atan2(toTarget.Y, toTarget.X);

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

    // ---------------------------------------------------------------
    // Beacon cue selection
    // ---------------------------------------------------------------

    private function GetBeaconCueId() : String
    {
        // TODO: Differentiate main quest vs side quest vs POI
        // var trackedQuest : CJournalQuest;
        // trackedQuest = theGame.GetJournalManager().GetTrackedQuest();
        // if (trackedQuest.IsMainQuest()) return "beacon_quest_main";
        // else return "beacon_quest_side";

        return "beacon_quest_main";
    }

    // ---------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------

    private function IsVectorZero(v : Vector) : Bool
    {
        return v.X == 0 && v.Y == 0 && v.Z == 0;
    }
}
