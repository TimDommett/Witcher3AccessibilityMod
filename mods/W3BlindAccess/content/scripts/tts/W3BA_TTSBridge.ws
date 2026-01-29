// W3BlindAccess - TTS Bridge
// Interfaces with Windows screen readers (NVDA, JAWS, Narrator)
// via Tolk.dll or Windows SAPI as fallback

// Speech priority levels
const var W3BA_PRIORITY_LOW    : Int32 = 0;
const var W3BA_PRIORITY_MEDIUM : Int32 = 1;
const var W3BA_PRIORITY_HIGH   : Int32 = 2;
const var W3BA_PRIORITY_URGENT : Int32 = 3;

class W3BA_TTSBridge
{
    private var speechQueue       : W3BA_SpeechQueue;
    private var isScreenReaderActive : Bool;
    private var activeScreenReader   : String;

    // ---------------------------------------------------------------
    // Lifecycle
    // ---------------------------------------------------------------

    public function Initialize(queue : W3BA_SpeechQueue)
    {
        speechQueue = queue;
        DetectScreenReader();
    }

    // ---------------------------------------------------------------
    // Screen reader detection
    // ---------------------------------------------------------------

    private function DetectScreenReader()
    {
        // TODO: Call into native DLL (W3BA_Native.dll) to query Tolk
        // Tolk_DetectScreenReader() returns the active screen reader name
        // Fallback chain: NVDA -> JAWS -> Windows Narrator -> SAPI

        isScreenReaderActive = false;
        activeScreenReader   = "None";

        // Placeholder: assume SAPI fallback is always available on Windows
        isScreenReaderActive = true;
        activeScreenReader   = "SAPI";
    }

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

        if (interrupt)
        {
            Silence();
        }

        // TODO: Route through native bridge
        // For now, enqueue for processing
        speechQueue.Enqueue(text, priority);

        // Actual TTS call will go here:
        // NativeCall_TolkSpeak(text, interrupt);
    }

    public function SpeakSync(text : String)
    {
        if (!isScreenReaderActive) { return; }

        // TODO: Blocking TTS call via native bridge
        // NativeCall_TolkSpeakBlocking(text);
    }

    public function Silence()
    {
        if (!isScreenReaderActive) { return; }

        speechQueue.Clear();
        // TODO: NativeCall_TolkSilence();
    }
}
