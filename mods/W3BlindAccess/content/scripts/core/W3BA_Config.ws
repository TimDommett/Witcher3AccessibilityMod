// W3BlindAccess - Configuration
// Handles loading, saving, and exposing accessibility settings

class W3BA_Config
{
    // TTS settings
    private var ttsEnabled       : Bool;
    private var ttsSpeechRate    : Float;   // 0.5 – 2.0
    private var menuVerbosity    : Int32;   // 0=low, 1=medium, 2=high

    // Audio cue settings
    private var combatAudioEnabled    : Bool;
    private var combatCueVolume       : Float;   // 0.0 – 1.0

    // Navigation settings
    private var navigationBeaconEnabled : Bool;
    private var beaconInterval          : Float;  // seconds between pings

    // Object detection settings
    private var objectDetectionEnabled  : Bool;
    private var detectionRadius         : Float;  // meters
    private var objectScanInterval      : Float;  // seconds

    // ---------------------------------------------------------------
    // Defaults
    // ---------------------------------------------------------------

    private function SetDefaults()
    {
        ttsEnabled              = true;
        ttsSpeechRate           = 1.0;
        menuVerbosity           = 1;

        combatAudioEnabled      = true;
        combatCueVolume         = 0.8;

        navigationBeaconEnabled = true;
        beaconInterval          = 2.0;

        objectDetectionEnabled  = true;
        detectionRadius         = 10.0;
        objectScanInterval      = 0.5;
    }

    // ---------------------------------------------------------------
    // Persistence
    // ---------------------------------------------------------------

    public function Load()
    {
        SetDefaults();
        // TODO: Read from user config file / INI
    }

    public function Save()
    {
        // TODO: Write current settings to user config file / INI
    }

    // ---------------------------------------------------------------
    // Getters
    // ---------------------------------------------------------------

    public function IsTTSEnabled() : Bool                { return ttsEnabled; }
    public function GetTTSSpeechRate() : Float            { return ttsSpeechRate; }
    public function GetMenuVerbosity() : Int32            { return menuVerbosity; }

    public function IsCombatAudioEnabled() : Bool         { return combatAudioEnabled; }
    public function GetCombatCueVolume() : Float          { return combatCueVolume; }

    public function IsNavigationBeaconEnabled() : Bool    { return navigationBeaconEnabled; }
    public function GetBeaconInterval() : Float           { return beaconInterval; }

    public function IsObjectDetectionEnabled() : Bool     { return objectDetectionEnabled; }
    public function GetDetectionRadius() : Float          { return detectionRadius; }
    public function GetObjectScanInterval() : Float       { return objectScanInterval; }

    // ---------------------------------------------------------------
    // Setters
    // ---------------------------------------------------------------

    public function SetTTSEnabled(value : Bool)               { ttsEnabled = value; }
    public function SetTTSSpeechRate(value : Float)            { ttsSpeechRate = ClampF(value, 0.5, 2.0); }
    public function SetMenuVerbosity(value : Int32)            { menuVerbosity = Clamp(value, 0, 2); }

    public function SetCombatAudioEnabled(value : Bool)        { combatAudioEnabled = value; }
    public function SetCombatCueVolume(value : Float)          { combatCueVolume = ClampF(value, 0.0, 1.0); }

    public function SetNavigationBeaconEnabled(value : Bool)   { navigationBeaconEnabled = value; }
    public function SetBeaconInterval(value : Float)           { beaconInterval = ClampF(value, 0.5, 10.0); }

    public function SetObjectDetectionEnabled(value : Bool)    { objectDetectionEnabled = value; }
    public function SetDetectionRadius(value : Float)          { detectionRadius = ClampF(value, 1.0, 50.0); }
    public function SetObjectScanInterval(value : Float)       { objectScanInterval = ClampF(value, 0.1, 5.0); }
}
