// W3BlindAccess - Speech Priority Queue
// Manages queued TTS utterances with priority ordering

struct W3BA_SpeechEntry
{
    var text     : String;
    var priority : Int32;
}

class W3BA_SpeechQueue
{
    private var entries : array<W3BA_SpeechEntry>;

    // ---------------------------------------------------------------
    // Queue operations
    // ---------------------------------------------------------------

    public function Enqueue(text : String, priority : Int32)
    {
        var entry : W3BA_SpeechEntry;
        entry.text     = text;
        entry.priority = priority;

        // Insert sorted by priority (highest first)
        var inserted : Bool = false;
        var i : Int32;
        for (i = 0; i < entries.Size(); i += 1)
        {
            if (priority > entries[i].priority)
            {
                entries.Insert(i, entry);
                inserted = true;
                break;
            }
        }

        if (!inserted)
        {
            entries.PushBack(entry);
        }
    }

    public function Dequeue() : W3BA_SpeechEntry
    {
        var entry : W3BA_SpeechEntry;
        if (entries.Size() > 0)
        {
            entry = entries[0];
            entries.Erase(0);
        }
        return entry;
    }

    public function Peek() : W3BA_SpeechEntry
    {
        var entry : W3BA_SpeechEntry;
        if (entries.Size() > 0)
        {
            entry = entries[0];
        }
        return entry;
    }

    public function Clear()
    {
        entries.Clear();
    }

    public function IsEmpty() : Bool
    {
        return entries.Size() == 0;
    }

    public function GetSize() : Int32
    {
        return entries.Size();
    }
}
