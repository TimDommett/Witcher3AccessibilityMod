// W3BlindAccess - Player Hooks
// Hooks into CR4Player for per-frame updates, combat events, and damage tracking.
// This is the bridge between the game's player systems and our accessibility modules.

// ---------------------------------------------------------------
// Timer setup — fire our update loop when the player entity spawns
// ---------------------------------------------------------------

@wrapMethod(CR4Player)
function OnSpawned(spawnData : SEntitySpawnData)
{
    wrappedMethod(spawnData);

    // Register a repeating timer at ~10 Hz for accessibility updates.
    // 0.1s is fast enough for combat responsiveness without heavy perf cost.
    AddTimer('W3BA_Update', 0.1, true);

    // Announce that in-game accessibility is active
    W3BA_EnsureInitialized();
    W3BA_SpeakText("In game. Accessibility active.", true, 2);
}

// ---------------------------------------------------------------
// Per-frame update timer
// ---------------------------------------------------------------

@addMethod(CR4Player)
timer function W3BA_Update(dt : float, id : int)
{
    var core : W3BA_CoreManager;

    W3BA_EnsureInitialized();
    core = W3BA_GetCoreManager();
    if (core)
    {
        core.Update(dt);
        W3BA_CheckInputActions(core);
    }
}

// ---------------------------------------------------------------
// Combat: player takes damage
// ---------------------------------------------------------------

@wrapMethod(CR4Player)
function ReactToBeingHit(damageAction : W3DamageAction, optional buffNotApplied : bool) : bool
{
    var result : bool;
    var core : W3BA_CoreManager;
    var attacker : CActor;
    var attackerPos : Vector;
    var damageDealt : Float;

    result = wrappedMethod(damageAction, buffNotApplied);

    core = W3BA_GetCoreManager();
    if (core && core.GetCombatCues())
    {
        attacker = (CActor)damageAction.attacker;
        if (attacker)
        {
            attackerPos = attacker.GetWorldPosition();
        }
        damageDealt = damageAction.GetDamageDealt();
        core.GetCombatCues().OnPlayerHit(damageDealt);
    }

    return result;
}

// ---------------------------------------------------------------
// Combat: player performs dodge
// ---------------------------------------------------------------

// NOTE: The exact method name may need verification against game scripts.
// Common dodge methods: PerformDodge, PlayerDodge, EvadePressed
// If this hook fails to compile, comment it out and rely on combat monitor polling.

/*
@wrapMethod(CR4Player)
function PerformDodge(dodgeType : EPlayerDodgeType)
{
    var core : W3BA_CoreManager;

    wrappedMethod(dodgeType);

    core = W3BA_GetCoreManager();
    if (core && core.GetCombatCues())
    {
        core.GetCombatCues().OnPlayerDodged();
    }
}
*/

// ---------------------------------------------------------------
// Target lock change detection
// ---------------------------------------------------------------

@wrapMethod(CR4Player)
function SetTarget(targetActor : CActor, optional forceSetTarget : bool)
{
    var core : W3BA_CoreManager;
    var targetName : String;
    var targetPos : Vector;

    wrappedMethod(targetActor, forceSetTarget);

    core = W3BA_GetCoreManager();
    if (core && core.GetCombatCues() && targetActor)
    {
        targetName = targetActor.GetDisplayName();
        targetPos  = targetActor.GetWorldPosition();
        core.GetCombatCues().OnTargetChanged(targetName, targetPos);
    }
}

// ---------------------------------------------------------------
// Global tick handler (called from timer)
// ---------------------------------------------------------------

function W3BA_OnPlayerTick(dt : Float)
{
    var core : W3BA_CoreManager;

    core = W3BA_GetCoreManager();
    if (core)
    {
        core.Update(dt);
    }
}
