// W3BlindAccess - TTS Bridge
// Interfaces with Windows screen readers (NVDA, JAWS, Narrator)
// via file-based IPC to ASI plugin which loads Tolk.dll
//
// Architecture:
//   WitcherScript writes speech commands via LogChannel('W3BA', ...)
//   ASI plugin (W3BA_TTS.asi) polls scriptslog.txt each frame
//   ASI plugin calls Tolk_Output() for each W3BA command
//
// Speech command format (one per line in scriptslog.txt):
//   SPEAK|<interrupt 0/1>|<priority>|<text>
//   SILENCE
//   DETECT

class W3BA_TTSBridge
{
    private var speechQueue          : W3BA_SpeechQueue;
    private var isScreenReaderActive : Bool;
    private var activeScreenReader   : String;
    private var isProcessingQueue    : Bool;
    private var lastSpeechTime       : Float;

    // Deduplication: avoid repeating the same text rapidly
    private var lastSpokenText       : String;
    private var deduplicateWindow    : Float;  // seconds

    // Debug: show speech text on-screen when no ASI plugin is available
    private var debugOverlayEnabled  : Bool;

    // ---------------------------------------------------------------
    // Lifecycle
    // ---------------------------------------------------------------

    public function Initialize(queue : W3BA_SpeechQueue)
    {
        speechQueue          = queue;
        isProcessingQueue    = false;
        lastSpeechTime       = 0.0;
        lastSpokenText       = "";
        deduplicateWindow    = 0.15;

        // Assume active — the ASI plugin will handle actual detection.
        // If no ASI plugin is present, Log() calls are harmless.
        isScreenReaderActive = true;
        activeScreenReader   = "IPC";

        // Debug overlay: shows speech as on-screen notification.
        // Enable this for testing when the ASI plugin is not yet compiled.
        debugOverlayEnabled  = true;

        // Send a detect command so the ASI plugin logs which reader it found
        WriteSpeechCommand("DETECT");
    }

    // ---------------------------------------------------------------
    // Screen reader status
    // ---------------------------------------------------------------

    public function IsScreenReaderActive() : Bool
    {
        return isScreenReaderActive;
    }

    public function GetActiveScreenReader() : String
    {
        return activeScreenReader;
    }

    // ---------------------------------------------------------------
    // Speech output
    // ---------------------------------------------------------------

    public function Speak(text : String, interrupt : Bool, optional priority : Int32)
    {
        var interruptFlag : String;
        var cmd : String;

        if (!isScreenReaderActive) { return; }
        if (StrLen(text) == 0)     { return; }

        // Deduplicate rapid-fire identical text
        if (text == lastSpokenText && deduplicateWindow > 0.0)
        {
            return;
        }
        lastSpokenText = text;

        if (interrupt)
        {
            Silence();
        }

        // Write directly to IPC file for the ASI plugin to pick up
        if (interrupt) { interruptFlag = "1"; }
        else           { interruptFlag = "0"; }

        cmd = "SPEAK|" + interruptFlag + "|" + priority + "|" + text;
        WriteSpeechCommand(cmd);

        // Debug overlay: show on screen so you can verify hooks work
        // without needing the compiled ASI plugin
        if (debugOverlayEnabled)
        {
            theGame.GetGuiManager().ShowNotification("[W3BA] " + text, 4000);
        }

        // Also enqueue locally for any in-script consumers
        speechQueue.Enqueue(text, priority);
    }

    public function SpeakSync(text : String)
    {
        // In file-based IPC we can't truly block, so just speak with high priority
        Speak(text, true, W3BA_PRIORITY_URGENT());
    }

    public function Silence()
    {
        if (!isScreenReaderActive) { return; }

        speechQueue.Clear();
        WriteSpeechCommand("SILENCE");
    }

    // ---------------------------------------------------------------
    // Debug overlay control
    // ---------------------------------------------------------------

    public function SetDebugOverlay(enabled : Bool)
    {
        debugOverlayEnabled = enabled;
    }

    public function IsDebugOverlayEnabled() : Bool
    {
        return debugOverlayEnabled;
    }

    // ---------------------------------------------------------------
    // File-based IPC
    // ---------------------------------------------------------------

    // Writes a command line to the speech IPC channel.
    // The ASI plugin monitors scriptslog.txt for lines tagged [W3BA].
    private function WriteSpeechCommand(cmd : String)
    {
        LogChannel('W3BA', cmd);
    }
}
