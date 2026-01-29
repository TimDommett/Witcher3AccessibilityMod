// W3BlindAccess - Mod Initialization
// Entry point for the blind accessibility mod

// Global accessor for the core manager
function W3BA_GetCoreManager() : W3BA_CoreManager
{
    return theGame.W3BA_coreManager;
}

// Global convenience function: speak text via TTS
function W3BA_SpeakText(text : String, interrupt : Bool, optional priority : Int32)
{
    var core : W3BA_CoreManager;
    core = W3BA_GetCoreManager();
    if (core)
    {
        core.GetTTSBridge().Speak(text, interrupt, priority);
    }
}

// Global convenience function: play a UI audio cue
function W3BA_PlayCue(cueId : String)
{
    var core : W3BA_CoreManager;
    core = W3BA_GetCoreManager();
    if (core)
    {
        core.GetAudioManager().PlayCue(cueId);
    }
}

// Global convenience function: play a 3D positioned audio cue
function W3BA_PlayCue3D(cueId : String, worldPosition : Vector, optional pitch : Float)
{
    var core : W3BA_CoreManager;
    core = W3BA_GetCoreManager();
    if (core)
    {
        core.GetAudioManager().PlayCue3D(cueId, worldPosition, pitch);
    }
}
