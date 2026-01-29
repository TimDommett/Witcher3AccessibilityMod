// W3BlindAccess - Spatial Audio Utilities
// Helper functions for 3D audio positioning and direction calculation

class W3BA_SpatialAudio
{
    private var audioManager : W3BA_AudioManager;

    // ---------------------------------------------------------------
    // Lifecycle
    // ---------------------------------------------------------------

    public function Initialize(manager : W3BA_AudioManager)
    {
        audioManager = manager;
    }

    // ---------------------------------------------------------------
    // Direction & distance helpers
    // ---------------------------------------------------------------

    // Returns the cardinal direction string from player to a target position
    public function GetCardinalDirection(targetPosition : Vector) : String
    {
        var playerPos   : Vector = thePlayer.GetWorldPosition();
        var playerRot   : EulerAngles = thePlayer.GetWorldRotation();
        var toTarget    : Vector = targetPosition - playerPos;

        // Get angle in world space
        var angle : Float = Atan2(toTarget.Y, toTarget.X);
        // Convert to degrees relative to player facing
        var relativeAngle : Float = angle - playerRot.Yaw;

        // Normalize to 0-360
        while (relativeAngle < 0)    { relativeAngle += 360.0; }
        while (relativeAngle >= 360) { relativeAngle -= 360.0; }

        // Map to cardinal
        if      (relativeAngle < 22.5 || relativeAngle >= 337.5)  { return "ahead"; }
        else if (relativeAngle < 67.5)                             { return "ahead right"; }
        else if (relativeAngle < 112.5)                            { return "right"; }
        else if (relativeAngle < 157.5)                            { return "behind right"; }
        else if (relativeAngle < 202.5)                            { return "behind"; }
        else if (relativeAngle < 247.5)                            { return "behind left"; }
        else if (relativeAngle < 292.5)                            { return "left"; }
        else                                                        { return "ahead left"; }
    }

    // Returns compass cardinal direction (north/south/east/west)
    public function GetCompassDirection(targetPosition : Vector) : String
    {
        var playerPos : Vector = thePlayer.GetWorldPosition();
        var toTarget  : Vector = targetPosition - playerPos;

        var angle : Float = Atan2(toTarget.Y, toTarget.X);
        // Normalize to 0-360
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

    // Returns distance in meters from player to target
    public function GetDistance(targetPosition : Vector) : Float
    {
        return VecDistance(thePlayer.GetWorldPosition(), targetPosition);
    }

    // Maps a value from one range to another (utility)
    public function MapRange(value : Float, inMin : Float, inMax : Float, outMin : Float, outMax : Float) : Float
    {
        var clamped : Float = ClampF(value, inMin, inMax);
        return outMin + (outMax - outMin) * ((clamped - inMin) / (inMax - inMin));
    }
}
