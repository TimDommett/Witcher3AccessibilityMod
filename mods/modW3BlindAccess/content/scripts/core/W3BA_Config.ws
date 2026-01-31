// W3BlindAccess - Configuration
// Handles loading, saving, and exposing accessibility settings
//
// Persistence uses theGame.GetInGameConfigWrapper() which reads/writes
// the user.settings INI file at <UserDocs>/The Witcher 3/user.settings
// under a custom [W3BlindAccess] section.

class W3BA_Config
{
    // INI section name
    private var sectionName : CName;

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
        sectionName = 'W3BlindAccess';

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
    // Persistence via user.settings INI
    // ---------------------------------------------------------------

    public function Load()
    {
        var config : CInGameConfigWrapper;

        SetDefaults();

        config = theGame.GetInGameConfigWrapper();
        if (!config)
        {
            return;
        }

        // Read each value; fall back to default if key is missing
        ttsEnabled              = ReadBool(config, 'ttsEnabled', ttsEnabled);
        ttsSpeechRate           = ReadFloat(config, 'ttsSpeechRate', ttsSpeechRate);
        menuVerbosity           = ReadInt(config, 'menuVerbosity', menuVerbosity);

        combatAudioEnabled      = ReadBool(config, 'combatAudioEnabled', combatAudioEnabled);
        combatCueVolume         = ReadFloat(config, 'combatCueVolume', combatCueVolume);

        navigationBeaconEnabled = ReadBool(config, 'navigationBeaconEnabled', navigationBeaconEnabled);
        beaconInterval          = ReadFloat(config, 'beaconInterval', beaconInterval);

        objectDetectionEnabled  = ReadBool(config, 'objectDetectionEnabled', objectDetectionEnabled);
        detectionRadius         = ReadFloat(config, 'detectionRadius', detectionRadius);
        objectScanInterval      = ReadFloat(config, 'objectScanInterval', objectScanInterval);
    }

    public function Save()
    {
        var config : CInGameConfigWrapper;

        config = theGame.GetInGameConfigWrapper();
        if (!config)
        {
            return;
        }

        WriteBool(config, 'ttsEnabled', ttsEnabled);
        WriteFloat(config, 'ttsSpeechRate', ttsSpeechRate);
        WriteInt(config, 'menuVerbosity', menuVerbosity);

        WriteBool(config, 'combatAudioEnabled', combatAudioEnabled);
        WriteFloat(config, 'combatCueVolume', combatCueVolume);

        WriteBool(config, 'navigationBeaconEnabled', navigationBeaconEnabled);
        WriteFloat(config, 'beaconInterval', beaconInterval);

        WriteBool(config, 'objectDetectionEnabled', objectDetectionEnabled);
        WriteFloat(config, 'detectionRadius', detectionRadius);
        WriteFloat(config, 'objectScanInterval', objectScanInterval);

        theGame.SaveUserSettings();
    }

    // ---------------------------------------------------------------
    // INI read helpers
    // ---------------------------------------------------------------

    private function ReadBool(config : CInGameConfigWrapper, key : CName, defaultVal : Bool) : Bool
    {
        var raw : String;
        raw = config.GetVarValue(sectionName, key);
        if (raw == "")       { return defaultVal; }
        if (raw == "true")   { return true; }
        if (raw == "1")      { return true; }
        return false;
    }

    private function ReadInt(config : CInGameConfigWrapper, key : CName, defaultVal : Int32) : Int32
    {
        var raw : String;
        raw = config.GetVarValue(sectionName, key);
        if (raw == "") { return defaultVal; }
        return StringToInt(raw);
    }

    private function ReadFloat(config : CInGameConfigWrapper, key : CName, defaultVal : Float) : Float
    {
        var raw : String;
        raw = config.GetVarValue(sectionName, key);
        if (raw == "") { return defaultVal; }
        return StringToFloat(raw);
    }

    // ---------------------------------------------------------------
    // INI write helpers
    // ---------------------------------------------------------------

    private function WriteBool(config : CInGameConfigWrapper, key : CName, value : Bool)
    {
        if (value) { config.SetVarValue(sectionName, key, "true"); }
        else       { config.SetVarValue(sectionName, key, "false"); }
    }

    private function WriteInt(config : CInGameConfigWrapper, key : CName, value : Int32)
    {
        config.SetVarValue(sectionName, key, IntToString(value));
    }

    private function WriteFloat(config : CInGameConfigWrapper, key : CName, value : Float)
    {
        config.SetVarValue(sectionName, key, FloatToString(value));
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
