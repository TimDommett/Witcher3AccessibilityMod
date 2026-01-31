// W3BlindAccess - Object Tracker / Scanner
// Detects and cycles through nearby interactable objects by category

// ---------------------------------------------------------------
// Object categories
// ---------------------------------------------------------------

enum W3BA_ObjectCategory
{
    W3BA_OBJ_CONTAINER,
    W3BA_OBJ_HERB,
    W3BA_OBJ_NPC,
    W3BA_OBJ_DOOR,
    W3BA_OBJ_LOOT,
    W3BA_OBJ_CLUE,
    W3BA_OBJ_CRAFTING,
    W3BA_OBJ_UNKNOWN
}

struct W3BA_InteractableInfo
{
    var objectName : String;
    var category   : W3BA_ObjectCategory;
    var position   : Vector;
    var distance   : Float;
}

// ---------------------------------------------------------------
// Object tracker
// ---------------------------------------------------------------

class W3BA_ObjectTracker
{
    private var config       : W3BA_Config;
    private var audioManager : W3BA_AudioManager;
    private var ttsBridge    : W3BA_TTSBridge;

    private var isActive          : Bool;
    private var timeSinceScan     : Float;
    private var nearbyObjects     : array<W3BA_InteractableInfo>;
    private var currentIndex      : Int32;
    private var activeFilter      : Int32;  // -1 = all categories

    // ---------------------------------------------------------------
    // Lifecycle
    // ---------------------------------------------------------------

    public function Initialize(cfg : W3BA_Config, audio : W3BA_AudioManager, tts : W3BA_TTSBridge)
    {
        config       = cfg;
        audioManager = audio;
        ttsBridge    = tts;

        isActive      = false;
        currentIndex  = -1;
        activeFilter  = -1;
        timeSinceScan = 0.0;
    }

    // ---------------------------------------------------------------
    // Per-frame update — periodic background scanning
    // ---------------------------------------------------------------

    public function Update(deltaTime : Float)
    {
        if (!config.IsObjectDetectionEnabled()) { return; }

        timeSinceScan += deltaTime;
        if (timeSinceScan >= config.GetObjectScanInterval())
        {
            ScanNearbyObjects();
            timeSinceScan = 0.0;
        }
    }

    // ---------------------------------------------------------------
    // Tracker activation
    // ---------------------------------------------------------------

    public function ToggleTracker()
    {
        var summary : String;

        isActive = !isActive;

        if (isActive)
        {
            ScanNearbyObjects();
            currentIndex = -1;
            summary = BuildSummary();
            ttsBridge.Speak("Object tracker active. " + summary, true, 2);
        }
        else
        {
            ttsBridge.Speak("Object tracker off.", true, 2);
        }
    }

    // ---------------------------------------------------------------
    // Cycle through objects
    // ---------------------------------------------------------------

    public function NextObject()
    {
        if (!isActive || nearbyObjects.Size() == 0) { return; }

        currentIndex = (currentIndex + 1) % nearbyObjects.Size();
        AnnounceCurrentObject();
    }

    public function PreviousObject()
    {
        if (!isActive || nearbyObjects.Size() == 0) { return; }

        currentIndex -= 1;
        if (currentIndex < 0) { currentIndex = nearbyObjects.Size() - 1; }
        AnnounceCurrentObject();
    }

    // ---------------------------------------------------------------
    // Category filter cycling
    // ---------------------------------------------------------------

    public function CycleFilter()
    {
        var filterName : String;

        activeFilter += 1;
        if (activeFilter > 7) { activeFilter = -1; } // -1 = all

        currentIndex = -1;
        ScanNearbyObjects();

        if (activeFilter == -1) { filterName = "All"; }
        else { filterName = CategoryToString(activeFilter); }

        ttsBridge.Speak("Filter: " + filterName + ". " + nearbyObjects.Size() + " found.", true, 2);
    }

    // ---------------------------------------------------------------
    // Internal: scanning
    // ---------------------------------------------------------------

    private function ScanNearbyObjects()
    {
        nearbyObjects.Clear();

        // TODO: Query game interactable system
        // var playerPos : Vector = thePlayer.GetWorldPosition();
        // var radius : Float = config.GetDetectionRadius();
        // Query nearby entities, classify, populate nearbyObjects array
        // Sort by distance
    }

    // ---------------------------------------------------------------
    // Internal: announcements
    // ---------------------------------------------------------------

    private function AnnounceCurrentObject()
    {
        var obj : W3BA_InteractableInfo;
        var text : String;
        var cueId : String;

        if (currentIndex < 0 || currentIndex >= nearbyObjects.Size()) { return; }

        obj = nearbyObjects[currentIndex];
        text = obj.objectName + ", " + RoundMath(obj.distance) + " meters, ";
        // TODO: append relative direction from W3BA_SpatialAudio
        text += "nearby";

        ttsBridge.Speak(text, true, 1);

        // Play spatial cue at object position
        cueId = GetCueForCategory(obj.category);
        audioManager.PlayCue3D(cueId, obj.position, 1.0);
    }

    private function BuildSummary() : String
    {
        return nearbyObjects.Size() + " objects nearby.";
        // TODO: Break down by category counts
    }

    // ---------------------------------------------------------------
    // Internal: category helpers
    // ---------------------------------------------------------------

    private function CategoryToString(cat : Int32) : String
    {
        switch (cat)
        {
            case 0: return "Containers";
            case 1: return "Herbs";
            case 2: return "NPCs";
            case 3: return "Doors";
            case 4: return "Loot";
            case 5: return "Clues";
            case 6: return "Crafting";
            default: return "Unknown";
        }
    }

    private function GetCueForCategory(cat : W3BA_ObjectCategory) : String
    {
        switch (cat)
        {
            case W3BA_OBJ_CONTAINER: return "object_container";
            case W3BA_OBJ_HERB:      return "object_herb";
            case W3BA_OBJ_NPC:       return "object_npc";
            case W3BA_OBJ_DOOR:      return "object_door";
            case W3BA_OBJ_LOOT:      return "object_loot";
            case W3BA_OBJ_CLUE:      return "object_clue";
            case W3BA_OBJ_CRAFTING:  return "object_crafting";
            default:                 return "object_container";
        }
    }
}
