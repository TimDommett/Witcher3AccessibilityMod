// W3BlindAccess - Combat Monitor
// Tracks combat state: enemies, attacks, targeting, health

class W3BA_CombatMonitor
{
    private var events : W3BA_Events;

    private var inCombat         : Bool;
    private var trackedEnemies   : array<CActor>;
    private var currentTarget    : CActor;
    private var lastHealthPct    : Float;

    // Health thresholds for warnings
    private var lowHealthThreshold      : Float;
    private var criticalHealthThreshold : Float;

    // ---------------------------------------------------------------
    // Lifecycle
    // ---------------------------------------------------------------

    public function Initialize(evt : W3BA_Events)
    {
        events                  = evt;
        inCombat                = false;
        lastHealthPct           = 100.0;
        lowHealthThreshold      = 25.0;
        criticalHealthThreshold = 10.0;
    }

    // ---------------------------------------------------------------
    // Per-frame update
    // ---------------------------------------------------------------

    public function Update(deltaTime : Float)
    {
        CheckCombatState();
        if (inCombat)
        {
            UpdateEnemyTracking();
            CheckHealthState();
        }
    }

    // ---------------------------------------------------------------
    // Combat state detection
    // ---------------------------------------------------------------

    private function CheckCombatState()
    {
        // TODO: Hook into game combat state
        // var isNowInCombat : Bool = thePlayer.IsInCombat();
        //
        // if (isNowInCombat && !inCombat)
        // {
        //     OnCombatEntered();
        // }
        // else if (!isNowInCombat && inCombat)
        // {
        //     OnCombatExited();
        // }
        // inCombat = isNowInCombat;
    }

    private function OnCombatEntered()
    {
        var data : W3BA_CombatEventData;

        inCombat = true;
        RefreshEnemyList();

        data.enemyCount = trackedEnemies.Size();
        events.EmitCombatStarted(data);
    }

    private function OnCombatExited()
    {
        inCombat = false;
        trackedEnemies.Clear();
        events.EmitCombatEnded();
    }

    // ---------------------------------------------------------------
    // Enemy tracking
    // ---------------------------------------------------------------

    private function RefreshEnemyList()
    {
        trackedEnemies.Clear();
        // TODO: Query nearby hostile actors
        // theGame.GetActorsInRange(thePlayer, 30.0, trackedEnemies, true);
        // Filter to hostile only
    }

    private function UpdateEnemyTracking()
    {
        // TODO: Check for enemy attack wind-ups and emit warnings
        // For each tracked enemy:
        //   - Check if enemy is winding up an attack
        //   - Determine attack type (light, heavy, unblockable)
        //   - Emit appropriate warning event with timing
        //   - Check if enemy died and emit event
    }

    // ---------------------------------------------------------------
    // Health monitoring
    // ---------------------------------------------------------------

    private function CheckHealthState()
    {
        // TODO: Read player health
        // var currentHP : Float = thePlayer.GetStatPercents(BCS_Vitality) * 100.0;
        //
        // if (currentHP != lastHealthPct)
        // {
        //     var data : W3BA_HealthEventData;
        //     data.percentage = currentHP;
        //     events.EmitHealthChanged(data);
        //
        //     // Check threshold crossings
        //     if (currentHP <= criticalHealthThreshold && lastHealthPct > criticalHealthThreshold)
        //     {
        //         // Crossed into critical
        //     }
        //     else if (currentHP <= lowHealthThreshold && lastHealthPct > lowHealthThreshold)
        //     {
        //         // Crossed into low health
        //     }
        //     lastHealthPct = currentHP;
        // }
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
}
