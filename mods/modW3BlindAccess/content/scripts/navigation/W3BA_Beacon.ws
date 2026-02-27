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
        var jm : CWitcherJournalManager;
        var trackedQuest : CJournalQuest;
        var objectives : array<CJournalQuestObjective>;
        var pinInstances : array<SCommonMapPinInstance>;
        var area : EAreaName;
        var worldPath : String;
        var i, j : Int32;
        var objStatus : EJournalStatus;

        jm = theGame.GetJournalManager();
        if (!jm) { return Vector(0, 0, 0); }

        trackedQuest = jm.GetTrackedQuest();
        if (!trackedQuest) { return Vector(0, 0, 0); }

        // Get current area for map pin query
        area = theGame.GetCommonMapManager().GetCurrentJournalArea();
        worldPath = theGame.GetWorld().GetDepotPath();

        // Get all map pins in current area
        pinInstances = mapManager.GetMapPinInstances(worldPath);

        // Iterate through pins to find quest objective pins
        for (i = 0; i < pinInstances.Size(); i += 1)
        {
            // Check if this is a quest-related pin type
            if (mapManager.IsQuestPinType(pinInstances[i].type))
            {
                // Return the first quest pin position found
                // This is typically the tracked objective
                if (pinInstances[i].position.X != 0 || pinInstances[i].position.Y != 0)
                {
                    return pinInstances[i].position;
                }
            }
        }

        return Vector(0, 0, 0);
    }

    private function TryGetUserWaypointPosition(mapManager : CCommonMapManager) : Vector
    {
        var userPin : SUserMapPinInstanceData;
        var hasUserPin : Bool;

        // Check if user has placed a custom waypoint on the map
        hasUserPin = mapManager.GetUserMapPinByIndex(0, userPin);
        if (hasUserPin)
        {
            if (userPin.position.X != 0 || userPin.position.Y != 0)
            {
                return userPin.position;
            }
        }

        return Vector(0, 0, 0);
    }

    // ---------------------------------------------------------------
    // Direction helpers
    // ---------------------------------------------------------------

    // Returns player-relative direction (ahead, behind, left, right)
    // Uses VecHeading to get heading angle in degrees from a 2D vector
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

        // VecHeading returns heading angle in degrees
        angle = VecHeading(toTarget);
        relativeAngle = angle - playerRot.Yaw;

        // Normalize to -180 to 180, then to 0-360
        while (relativeAngle < -180.0) { relativeAngle += 360.0; }
        while (relativeAngle > 180.0)  { relativeAngle -= 360.0; }
        if (relativeAngle < 0) { relativeAngle += 360.0; }

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
    // Uses VecHeading for world-space angle calculation
    private function GetCompassDirection(target : Vector) : String
    {
        var playerPos : Vector;
        var toTarget  : Vector;
        var angle     : Float;

        playerPos = thePlayer.GetWorldPosition();
        toTarget  = target - playerPos;
        // VecHeading returns heading angle in degrees
        angle = VecHeading(toTarget);

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
