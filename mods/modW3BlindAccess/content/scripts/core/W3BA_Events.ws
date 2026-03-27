// W3BlindAccess - Event System
// Lightweight event bus for decoupled module communication

// ---------------------------------------------------------------
// Event enums
// ---------------------------------------------------------------

enum W3BA_EventType
{
    W3BA_EVT_MENU_CHANGED,
    W3BA_EVT_MENU_ITEM_FOCUSED,
    W3BA_EVT_COMBAT_STARTED,
    W3BA_EVT_COMBAT_ENDED,
    W3BA_EVT_ENEMY_ATTACKING,
    W3BA_EVT_ENEMY_DIED,
    W3BA_EVT_QUEST_OBJECTIVE_CHANGED,
    W3BA_EVT_HEALTH_CHANGED,
    W3BA_EVT_PLAYER_HIT,
    W3BA_EVT_PLAYER_DODGED,
    W3BA_EVT_PLAYER_PARRIED
}

// ---------------------------------------------------------------
// Event data containers
// ---------------------------------------------------------------

struct W3BA_MenuEventData
{
    var menuId    : String;
    var itemText  : String;
    var itemIndex : Int32;
}

struct W3BA_CombatEventData
{
    var enemyCount   : Int32;
    var attackType   : String;
    var damage       : Float;
    var enemyName    : String;
    var enemyPosition: Vector;
}

struct W3BA_QuestEventData
{
    var objectiveText    : String;
    var waypointPosition : Vector;
    var distance         : Float;
}

struct W3BA_HealthEventData
{
    var currentHealth : Float;
    var maxHealth     : Float;
    var percentage    : Float;
}

// ---------------------------------------------------------------
// Event manager
// ---------------------------------------------------------------

class W3BA_Events
{
    // Callbacks are handled by direct module references for now.
    // A full observer pattern can be added later if needed.

    public function EmitMenuChanged(data : W3BA_MenuEventData)
    {
        // TODO: notify registered listeners
    }

    public function EmitMenuItemFocused(data : W3BA_MenuEventData)
    {
        // TODO: notify registered listeners
    }

    public function EmitCombatStarted(data : W3BA_CombatEventData)
    {
        // TODO: notify registered listeners
    }

    public function EmitCombatEnded()
    {
        // TODO: notify registered listeners
    }

    public function EmitEnemyAttacking(data : W3BA_CombatEventData)
    {
        // TODO: notify registered listeners
    }

    public function EmitEnemyDied(data : W3BA_CombatEventData)
    {
        // TODO: notify registered listeners
    }

    public function EmitQuestObjectiveChanged(data : W3BA_QuestEventData)
    {
        // TODO: notify registered listeners
    }

    public function EmitHealthChanged(data : W3BA_HealthEventData)
    {
        // TODO: notify registered listeners
    }

    public function EmitPlayerHit(data : W3BA_CombatEventData)
    {
        // TODO: notify registered listeners
    }

    public function EmitPlayerDodged()
    {
        // TODO: notify registered listeners
    }

    public function EmitPlayerParried()
    {
        // TODO: notify registered listeners
    }
}
