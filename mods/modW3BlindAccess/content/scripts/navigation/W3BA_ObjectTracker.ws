// W3BlindAccess - Object Tracker / Scanner
// Detects and cycles through nearby interactable objects by category.
// Uses FindGameplayEntitiesInRange() for spatial entity queries.

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
    var objectName  : String;
    var objCategory : W3BA_ObjectCategory;
    var position    : Vector;
    var distance    : Float;
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
    // Internal: scanning using game entity queries
    // ---------------------------------------------------------------

    private function ScanNearbyObjects()
    {
        var entities : array<CGameplayEntity>;
        var playerPos : Vector;
        var radius : Float;
        var i : Int32;
        var info : W3BA_InteractableInfo;
        var entityCat : W3BA_ObjectCategory;
        var dist : Float;
        var entityName : String;

        nearbyObjects.Clear();

        if (!thePlayer) { return; }

        playerPos = thePlayer.GetWorldPosition();
        radius    = config.GetDetectionRadius();

        // Query all gameplay entities within detection radius
        FindGameplayEntitiesInRange(entities, playerPos, radius, 50);

        for (i = 0; i < entities.Size(); i += 1)
        {
            if (!entities[i]) { continue; }

            // Skip the player
            if (entities[i] == thePlayer) { continue; }

            // Classify the entity
            entityCat = ClassifyEntity(entities[i]);

            // Apply category filter if active
            if (activeFilter >= 0 && (Int32)entityCat != activeFilter) { continue; }

            // Skip unknown objects unless no filter is active
            if (entityCat == W3BA_OBJ_UNKNOWN && activeFilter < 0) { continue; }

            dist = VecDistance(playerPos, entities[i].GetWorldPosition());
            entityName = GetEntityDisplayName(entities[i]);

            if (entityName == "") { continue; }

            info.objectName  = entityName;
            info.objCategory = entityCat;
            info.position    = entities[i].GetWorldPosition();
            info.distance    = dist;

            nearbyObjects.PushBack(info);
        }

        // Sort by distance (simple insertion sort for small arrays)
        SortByDistance();
    }

    private function ClassifyEntity(entity : CGameplayEntity) : W3BA_ObjectCategory
    {
        var actor : CActor;
        var npc : CNewNPC;

        // Check if it's an NPC
        npc = (CNewNPC)entity;
        if (npc)
        {
            // Skip hostile NPCs (combat monitor handles them)
            actor = (CActor)npc;
            if (actor && actor.GetAttitude(thePlayer) == AIA_Hostile)
            {
                return W3BA_OBJ_UNKNOWN;
            }
            return W3BA_OBJ_NPC;
        }

        // Check for containers (chests, barrels, etc.)
        if (entity.HasTag('container') || entity.HasTag('chest'))
        {
            return W3BA_OBJ_CONTAINER;
        }

        // Check for herbs / gatherable items
        if (entity.HasTag('herb') || entity.HasTag('plant'))
        {
            return W3BA_OBJ_HERB;
        }

        // Check for doors
        if (entity.HasTag('door') || entity.HasTag('gate'))
        {
            return W3BA_OBJ_DOOR;
        }

        // Check for loot (dropped items)
        if (entity.HasTag('loot') || entity.HasTag('item'))
        {
            return W3BA_OBJ_LOOT;
        }

        // Check for Witcher senses clues
        if (entity.HasTag('clue') || entity.HasTag('investigation'))
        {
            return W3BA_OBJ_CLUE;
        }

        // Check for crafting stations
        if (entity.HasTag('crafting') || entity.HasTag('blacksmith') || entity.HasTag('armorer'))
        {
            return W3BA_OBJ_CRAFTING;
        }

        // Fallback: check if entity has any interactable component
        // If it does, classify as unknown (still trackable with filter)
        // TODO: Check for W3Container, W3Herb class types directly
        //       e.g. (W3Container)entity, (W3Herb)entity for more accurate classification

        return W3BA_OBJ_UNKNOWN;
    }

    private function GetEntityDisplayName(entity : CGameplayEntity) : String
    {
        var displayName : String;
        var actor : CActor;

        // Try getting display name from actor
        actor = (CActor)entity;
        if (actor)
        {
            displayName = actor.GetDisplayName();
            if (displayName != "") { return displayName; }
        }

        // Try localized name
        displayName = entity.GetDisplayName();
        if (displayName != "") { return displayName; }

        // Fallback to category name
        return CategoryToSingular(ClassifyEntity(entity));
    }

    // ---------------------------------------------------------------
    // Internal: sorting
    // ---------------------------------------------------------------

    private function SortByDistance()
    {
        var i : Int32;
        var j : Int32;
        var temp : W3BA_InteractableInfo;

        // Insertion sort — good for small arrays (typically <50 items)
        for (i = 1; i < nearbyObjects.Size(); i += 1)
        {
            temp = nearbyObjects[i];
            j = i - 1;
            while (j >= 0 && nearbyObjects[j].distance > temp.distance)
            {
                nearbyObjects[j + 1] = nearbyObjects[j];
                j -= 1;
            }
            nearbyObjects[j + 1] = temp;
        }
    }

    // ---------------------------------------------------------------
    // Internal: announcements
    // ---------------------------------------------------------------

    private function AnnounceCurrentObject()
    {
        var obj : W3BA_InteractableInfo;
        var text : String;
        var cueId : String;
        var direction : String;

        if (currentIndex < 0 || currentIndex >= nearbyObjects.Size()) { return; }

        obj = nearbyObjects[currentIndex];

        // Build announcement with relative direction
        direction = GetRelativeDirection(obj.position);
        text = obj.objectName + ", " + RoundMath(obj.distance) + " meters, " + direction;

        ttsBridge.Speak(text, true, 1);

        // Play spatial cue at object position
        cueId = GetCueForCategory(obj.objCategory);
        audioManager.PlayCue3D(cueId, obj.position, 1.0);
    }

    private function BuildSummary() : String
    {
        return nearbyObjects.Size() + " objects nearby.";
    }

    // ---------------------------------------------------------------
    // Direction helper (player-relative)
    // Uses VecHeading to get angle from vector (WitcherScript built-in)
    // ---------------------------------------------------------------

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

        // VecHeading returns the heading angle in degrees from a 2D vector
        angle = VecHeading(toTarget);
        relativeAngle = angle - playerRot.Yaw;

        while (relativeAngle < -180.0) { relativeAngle += 360.0; }
        while (relativeAngle > 180.0)  { relativeAngle -= 360.0; }

        // Convert to 0-360 range for easier comparison
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

    private function CategoryToSingular(cat : W3BA_ObjectCategory) : String
    {
        switch (cat)
        {
            case W3BA_OBJ_CONTAINER: return "Container";
            case W3BA_OBJ_HERB:      return "Herb";
            case W3BA_OBJ_NPC:       return "NPC";
            case W3BA_OBJ_DOOR:      return "Door";
            case W3BA_OBJ_LOOT:      return "Loot";
            case W3BA_OBJ_CLUE:      return "Clue";
            case W3BA_OBJ_CRAFTING:  return "Crafting station";
            default:                 return "Object";
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
