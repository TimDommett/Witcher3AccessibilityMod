// W3BlindAccess - Core Manager
// Central coordinator for all accessibility modules

class W3BA_CoreManager
{
    private var config        : W3BA_Config;
    private var events        : W3BA_Events;
    private var ttsBridge     : W3BA_TTSBridge;
    private var speechQueue   : W3BA_SpeechQueue;
    private var audioManager  : W3BA_AudioManager;
    private var spatialAudio  : W3BA_SpatialAudio;
    private var beacon        : W3BA_NavigationBeacon;
    private var objectTracker : W3BA_ObjectTracker;
    private var combatMonitor : W3BA_CombatMonitor;
    private var combatCues    : W3BA_CombatCues;
    private var menuNarrator  : W3BA_MenuNarrator;
    private var invNarrator   : W3BA_InventoryNarrator;

    private var isInitialized : Bool;

    // ---------------------------------------------------------------
    // Lifecycle
    // ---------------------------------------------------------------

    public function Initialize()
    {
        if (isInitialized)
        {
            return;
        }

        // Config must come first so other modules can read settings
        config = new W3BA_Config in this;
        config.Load();

        events = new W3BA_Events in this;

        // TTS subsystem
        speechQueue = new W3BA_SpeechQueue in this;
        ttsBridge   = new W3BA_TTSBridge in this;
        ttsBridge.Initialize(speechQueue);

        // Audio subsystem
        audioManager = new W3BA_AudioManager in this;
        audioManager.Initialize();

        spatialAudio = new W3BA_SpatialAudio in this;
        spatialAudio.Initialize(audioManager);

        // Navigation subsystem
        beacon = new W3BA_NavigationBeacon in this;
        beacon.Initialize(config, audioManager, ttsBridge);

        objectTracker = new W3BA_ObjectTracker in this;
        objectTracker.Initialize(config, audioManager, ttsBridge);

        // Combat subsystem
        combatMonitor = new W3BA_CombatMonitor in this;
        combatMonitor.Initialize(events);

        combatCues = new W3BA_CombatCues in this;
        combatCues.Initialize(config, audioManager, ttsBridge, combatMonitor);

        // UI subsystem
        menuNarrator = new W3BA_MenuNarrator in this;
        menuNarrator.Initialize(ttsBridge, audioManager);

        invNarrator = new W3BA_InventoryNarrator in this;
        invNarrator.Initialize(ttsBridge);

        isInitialized = true;

        ttsBridge.Speak("W3 Blind Access mod loaded.", true, 0);
    }

    public function Shutdown()
    {
        if (!isInitialized)
        {
            return;
        }
        config.Save();
        isInitialized = false;
    }

    // ---------------------------------------------------------------
    // Per-frame update — called from game tick hook
    // ---------------------------------------------------------------

    public function Update(deltaTime : Float)
    {
        if (!isInitialized) { return; }

        beacon.Update(deltaTime);
        objectTracker.Update(deltaTime);
        combatMonitor.Update(deltaTime);
        combatCues.Update(deltaTime);
    }

    // ---------------------------------------------------------------
    // Module accessors
    // ---------------------------------------------------------------

    public function GetConfig()        : W3BA_Config            { return config; }
    public function GetEvents()        : W3BA_Events            { return events; }
    public function GetTTSBridge()     : W3BA_TTSBridge         { return ttsBridge; }
    public function GetAudioManager()  : W3BA_AudioManager      { return audioManager; }
    public function GetSpatialAudio()  : W3BA_SpatialAudio      { return spatialAudio; }
    public function GetBeacon()        : W3BA_NavigationBeacon   { return beacon; }
    public function GetObjectTracker() : W3BA_ObjectTracker      { return objectTracker; }
    public function GetCombatMonitor() : W3BA_CombatMonitor      { return combatMonitor; }
    public function GetCombatCues()    : W3BA_CombatCues         { return combatCues; }
    public function GetMenuNarrator()  : W3BA_MenuNarrator       { return menuNarrator; }
    public function GetInvNarrator()   : W3BA_InventoryNarrator  { return invNarrator; }
}
