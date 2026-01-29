// W3BlindAccess - TTS Bridge
// Interfaces with Windows screen readers (NVDA, JAWS, Narrator)
// via file-based IPC to ASI plugin which loads Tolk.dll
//
// Architecture:
//   WitcherScript writes speech commands to W3BA_speech.log
//   ASI plugin (W3BA_TTS.asi) polls this file each frame
//   ASI plugin calls Tolk_Output() for each line
//   File is truncated after reading
//
// Speech command format (one per line):
//   SPEAK|<interrupt 0/1>|<priority>|<text>
//   SILENCE
//   DETECT

// Speech priority levels
const var W3BA_PRIORITY_LOW    : Int32 = 0;
const var W3BA_PRIORITY_MEDIUM : Int32 = 1;
const var W3BA_PRIORITY_HIGH   : Int32 = 2;
const var W3BA_PRIORITY_URGENT : Int32 = 3;

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
        var interruptFlag : String;
        if (interrupt) { interruptFlag = "1"; }
        else           { interruptFlag = "0"; }

        var cmd : String = "SPEAK|" + interruptFlag + "|" + priority + "|" + text;
        WriteSpeechCommand(cmd);

        // Also enqueue locally for any in-script consumers
        speechQueue.Enqueue(text, priority);
    }

    public function SpeakSync(text : String)
    {
        // In file-based IPC we can't truly block, so just speak with high priority
        Speak(text, true, W3BA_PRIORITY_URGENT);
    }

    public function Silence()
    {
        if (!isScreenReaderActive) { return; }

        speechQueue.Clear();
        WriteSpeechCommand("SILENCE");
    }

    // ---------------------------------------------------------------
    // File-based IPC
    // ---------------------------------------------------------------

    // Writes a command line to the speech IPC file.
    // The ASI plugin monitors this file and processes commands.
    //
    // We use LogChannel() which writes to the game's script log.
    // The ASI plugin hooks into this log output or monitors the log file.
    private function WriteSpeechCommand(cmd : String)
    {
        // LogChannel is a built-in WitcherScript function that writes to
        // the script log at <UserDocs>/The Witcher 3/scriptslog.txt
        // Our ASI plugin monitors this file for lines prefixed with [W3BA]
        LogChannel('W3BA', cmd);
    }
}
