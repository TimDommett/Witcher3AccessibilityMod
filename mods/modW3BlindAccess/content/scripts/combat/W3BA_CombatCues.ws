// W3BlindAccess - Combat Audio Cues
// Translates combat events into spatial audio feedback

class W3BA_CombatCues
{
    private var config        : W3BA_Config;
    private var audioManager  : W3BA_AudioManager;
    private var ttsBridge     : W3BA_TTSBridge;
    private var combatMonitor : W3BA_CombatMonitor;

    // Tracking state for continuous cues
    private var lowHealthWarningActive      : Bool;
    private var criticalHealthWarningActive : Bool;
    private var enemyPositionUpdateTimer    : Float;

    // How often to re-ping enemy positions (seconds)
    private var enemyPingInterval : Float;

    // ---------------------------------------------------------------
    // Lifecycle
    // ---------------------------------------------------------------

    public function Initialize(cfg : W3BA_Config, audio : W3BA_AudioManager, tts : W3BA_TTSBridge, monitor : W3BA_CombatMonitor)
    {
        config        = cfg;
        audioManager  = audio;
        ttsBridge     = tts;
        combatMonitor = monitor;

        lowHealthWarningActive      = false;
        criticalHealthWarningActive = false;
        enemyPositionUpdateTimer    = 0.0;
        enemyPingInterval           = 1.5;
    }

    // ---------------------------------------------------------------
    // Per-frame update
    // ---------------------------------------------------------------

    public function Update(deltaTime : Float)
    {
        if (!config.IsCombatAudioEnabled()) { return; }
        if (!combatMonitor.IsInCombat()) { return; }

        UpdateEnemyPositionPings(deltaTime);
    }

    // ---------------------------------------------------------------
    // Combat event handlers (called from event system)
    // ---------------------------------------------------------------

    public function OnCombatStarted(enemyCount : Int32)
    {
        audioManager.PlayCue("enemy_detected");
        ttsBridge.Speak(enemyCount + " enemies.", false, 2);
    }

    public function OnCombatEnded()
    {
        lowHealthWarningActive      = false;
        criticalHealthWarningActive = false;
        ttsBridge.Speak("Combat ended.", false, 1);
    }

    public function OnEnemyAttackLight(enemyPosition : Vector)
    {
        audioManager.PlayCue3D("enemy_attack_light", enemyPosition, 1.0);
    }

    public function OnEnemyAttackHeavy(enemyPosition : Vector)
    {
        audioManager.PlayCue3D("enemy_attack_heavy", enemyPosition, 1.0);
    }

    public function OnEnemyAttackUnblockable(enemyPosition : Vector)
    {
        audioManager.PlayCue3D("enemy_attack_unblockable", enemyPosition, 1.0);
    }

    public function OnPlayerHit(damage : Float)
    {
        audioManager.PlayCue("player_hit");
    }

    public function OnPlayerDodged()
    {
        audioManager.PlayCue("player_dodge_success");
    }

    public function OnPlayerParried()
    {
        audioManager.PlayCue("player_parry_success");
    }

    public function OnHealthChanged(percentage : Float)
    {
        if (percentage <= 10.0 && !criticalHealthWarningActive)
        {
            criticalHealthWarningActive = true;
            audioManager.PlayCue("health_critical_warning");
            ttsBridge.Speak("Critical health!", true, 3);
        }
        else if (percentage <= 25.0 && !lowHealthWarningActive)
        {
            lowHealthWarningActive = true;
            audioManager.PlayCue("health_low_warning");
            ttsBridge.Speak("Low health.", false, 2);
        }
        else if (percentage > 25.0)
        {
            lowHealthWarningActive      = false;
            criticalHealthWarningActive = false;
        }
    }

    public function OnTargetLocked(targetName : String, targetPosition : Vector)
    {
        audioManager.PlayCue3D("enemy_detected", targetPosition, 1.0);
        ttsBridge.Speak("Locked: " + targetName, true, 2);
    }

    public function OnTargetChanged(newTargetName : String, newTargetPosition : Vector)
    {
        audioManager.PlayCue3D("enemy_detected", newTargetPosition, 1.2);
        ttsBridge.Speak("Target: " + newTargetName, true, 2);
    }

    // ---------------------------------------------------------------
    // Continuous enemy position pings
    // ---------------------------------------------------------------

    private function UpdateEnemyPositionPings(deltaTime : Float)
    {
        enemyPositionUpdateTimer += deltaTime;
        if (enemyPositionUpdateTimer < enemyPingInterval) { return; }
        enemyPositionUpdateTimer = 0.0;

        // TODO: For each tracked enemy, play a quiet spatial cue
        // var enemies : array<CActor> = combatMonitor.GetTrackedEnemies();
        // for (i = 0; i < enemies.Size(); i += 1)
        // {
        //     audioManager.PlayCue3D("enemy_detected", enemies[i].GetWorldPosition(), 0.5);
        // }
    }
}
