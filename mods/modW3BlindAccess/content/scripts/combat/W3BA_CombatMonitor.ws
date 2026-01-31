// W3BlindAccess - Combat Monitor
// Tracks combat state: enemies, attacks, targeting, health
// Uses actual Witcher 3 game APIs for player state queries.

class W3BA_CombatMonitor
{
    private var combatCues : W3BA_CombatCues;
    private var events     : W3BA_Events;

    private var inCombat         : Bool;
    private var trackedEnemies   : array<CActor>;
    private var currentTarget    : CActor;
    private var lastHealthPct    : Float;
    private var lastEnemyCount   : Int32;

    // Health thresholds for warnings
    private var lowHealthThreshold      : Float;
    private var criticalHealthThreshold : Float;

    // Throttle enemy list refresh
    private var enemyRefreshTimer    : Float;
    private var enemyRefreshInterval : Float;

    // ---------------------------------------------------------------
    // Lifecycle
    // ---------------------------------------------------------------

    public function Initialize(evt : W3BA_Events)
    {
        events                  = evt;
        inCombat                = false;
        lastHealthPct           = 100.0;
        lastEnemyCount          = 0;
        lowHealthThreshold      = 25.0;
        criticalHealthThreshold = 10.0;
        enemyRefreshTimer       = 0.0;
        enemyRefreshInterval    = 1.0;
    }

    // Set combat cues reference for direct event routing
    public function SetCombatCues(cues : W3BA_CombatCues)
    {
        combatCues = cues;
    }

    // ---------------------------------------------------------------
    // Per-frame update (called at ~10 Hz from player timer)
    // ---------------------------------------------------------------

    public function Update(deltaTime : Float)
    {
        CheckCombatState();
        CheckHealthState();

        if (inCombat)
        {
            enemyRefreshTimer += deltaTime;
            if (enemyRefreshTimer >= enemyRefreshInterval)
            {
                RefreshEnemyList();
                enemyRefreshTimer = 0.0;
            }
            CheckTargetState();
        }
    }

    // ---------------------------------------------------------------
    // Combat state detection
    // ---------------------------------------------------------------

    private function CheckCombatState()
    {
        var isNowInCombat : Bool;

        if (!thePlayer) { return; }

        isNowInCombat = thePlayer.IsInCombat();

        if (isNowInCombat && !inCombat)
        {
            OnCombatEntered();
        }
        else if (!isNowInCombat && inCombat)
        {
            OnCombatExited();
        }
    }

    private function OnCombatEntered()
    {
        var data : W3BA_CombatEventData;

        inCombat = true;
        RefreshEnemyList();
        enemyRefreshTimer = 0.0;

        data.enemyCount = trackedEnemies.Size();
        events.EmitCombatStarted(data);

        // Route directly to combat cues
        if (combatCues)
        {
            combatCues.OnCombatStarted(trackedEnemies.Size());
        }
    }

    private function OnCombatExited()
    {
        inCombat = false;
        trackedEnemies.Clear();
        lastEnemyCount = 0;
        events.EmitCombatEnded();

        if (combatCues)
        {
            combatCues.OnCombatEnded();
        }
    }

    // ---------------------------------------------------------------
    // Enemy tracking
    // ---------------------------------------------------------------

    private function RefreshEnemyList()
    {
        var entities : array<CGameplayEntity>;
        var i : Int32;
        var actor : CActor;
        var playerPos : Vector;

        trackedEnemies.Clear();

        if (!thePlayer) { return; }

        playerPos = thePlayer.GetWorldPosition();

        // Find all gameplay entities within 30m of player
        FindGameplayEntitiesInRange(entities, playerPos, 30.0, 20);

        for (i = 0; i < entities.Size(); i += 1)
        {
            actor = (CActor)entities[i];
            if (actor && actor.IsAlive() && IsHostile(actor))
            {
                trackedEnemies.PushBack(actor);
            }
        }

        // Announce if enemy count changed significantly
        if (trackedEnemies.Size() != lastEnemyCount && combatCues && inCombat)
        {
            if (trackedEnemies.Size() > lastEnemyCount)
            {
                // New enemies appeared
                combatCues.OnNewEnemiesDetected(trackedEnemies.Size() - lastEnemyCount);
            }
        }
        lastEnemyCount = trackedEnemies.Size();
    }

    private function IsHostile(actor : CActor) : Bool
    {
        // Check if actor is hostile to the player
        if (!actor) { return false; }
        if (actor == thePlayer) { return false; }

        return actor.GetAttitude(thePlayer) == AIA_Hostile;
    }

    // ---------------------------------------------------------------
    // Target tracking
    // ---------------------------------------------------------------

    private function CheckTargetState()
    {
        var newTarget : CActor;
        var targetName : String;
        var targetPos : Vector;

        if (!thePlayer) { return; }

        newTarget = thePlayer.GetTarget();

        if (newTarget != currentTarget)
        {
            currentTarget = newTarget;
            if (currentTarget && combatCues)
            {
                targetName = currentTarget.GetDisplayName();
                targetPos  = currentTarget.GetWorldPosition();
                combatCues.OnTargetLocked(targetName, targetPos);
            }
        }
    }

    // ---------------------------------------------------------------
    // Health monitoring
    // ---------------------------------------------------------------

    private function CheckHealthState()
    {
        var currentHP : Float;
        var data : W3BA_HealthEventData;

        if (!thePlayer) { return; }

        // GetStatPercents returns 0.0-1.0, we use 0-100
        currentHP = thePlayer.GetStatPercents(BCS_Vitality) * 100.0;

        // Only act on meaningful changes (>1% difference avoids float noise)
        if (AbsF(currentHP - lastHealthPct) < 1.0) { return; }

        data.percentage = currentHP;
        events.EmitHealthChanged(data);

        if (combatCues)
        {
            combatCues.OnHealthChanged(currentHP);
        }

        lastHealthPct = currentHP;
    }

    // ---------------------------------------------------------------
    // Public queries
    // ---------------------------------------------------------------

    public function IsInCombat() : Bool
    {
        return inCombat;
    }

    public function GetEnemyCount() : Int32
    {
        return trackedEnemies.Size();
    }

    public function GetCurrentTarget() : CActor
    {
        return currentTarget;
    }

    public function GetTrackedEnemies() : array<CActor>
    {
        return trackedEnemies;
    }

    public function GetPlayerHealthPercent() : Float
    {
        return lastHealthPct;
    }
}
