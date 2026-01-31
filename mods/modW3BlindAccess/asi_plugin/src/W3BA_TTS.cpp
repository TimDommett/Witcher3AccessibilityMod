// W3BlindAccess - ASI Plugin for TTS Bridge
//
// Loaded by Ultimate ASI Loader (dinput8.dll proxy) into the Witcher 3 process.
// Monitors the game's script log for W3BA speech commands and routes them
// to the active screen reader via Tolk.dll.
//
// Build: Compile as a DLL, rename to W3BA_TTS.asi, place in bin/x64/plugins/
// Requires: Tolk.dll + screen reader API DLLs in same directory
//
// Dependencies:
//   - Tolk.h / Tolk.dll (github.com/dkager/tolk)
//   - Ultimate ASI Loader (github.com/ThirteenAG/Ultimate-ASI-Loader)

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <string>
#include <fstream>
#include <sstream>
#include <vector>
#include <mutex>
#include <filesystem>
#include "Tolk.h"

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

// How often to poll the log file (milliseconds)
static const DWORD POLL_INTERVAL_MS = 16; // ~60 Hz, once per frame

// The LogChannel tag we look for in scriptslog.txt
static const char* LOG_PREFIX = "[W3BA]";

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

static HANDLE g_pollThread = NULL;
static bool   g_running    = false;
static std::mutex g_mutex;

// Path to the script log file
static std::wstring g_logFilePath;

// Track our read position in the log file
static std::streampos g_lastReadPos = 0;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

static std::wstring GetUserDocumentsPath()
{
    wchar_t path[MAX_PATH];
    if (SUCCEEDED(SHGetFolderPathW(NULL, CSIDL_PERSONAL, NULL, 0, path)))
    {
        return std::wstring(path);
    }
    return L"";
}

static std::wstring Utf8ToWide(const std::string& utf8)
{
    if (utf8.empty()) return L"";
    int size = MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(), -1, NULL, 0);
    std::wstring wide(size, 0);
    MultiByteToWideChar(CP_UTF8, 0, utf8.c_str(), -1, &wide[0], size);
    // Remove trailing null
    if (!wide.empty() && wide.back() == L'\0') wide.pop_back();
    return wide;
}

// ---------------------------------------------------------------------------
// Command processing
// ---------------------------------------------------------------------------

// Parse and execute a single W3BA command line
// Format: SPEAK|<interrupt>|<priority>|<text>
//         SILENCE
//         DETECT
static void ProcessCommand(const std::string& cmd)
{
    if (cmd == "SILENCE")
    {
        Tolk_Silence();
        return;
    }

    if (cmd == "DETECT")
    {
        const wchar_t* reader = Tolk_DetectScreenReader();
        if (reader)
        {
            std::wstring msg = L"Screen reader detected: ";
            msg += reader;
            Tolk_Output(msg.c_str(), false);
        }
        else
        {
            Tolk_Output(L"No screen reader detected. Using SAPI fallback.", false);
        }
        return;
    }

    // Parse SPEAK command: SPEAK|interrupt|priority|text
    if (cmd.substr(0, 6) == "SPEAK|")
    {
        // Split by '|'
        std::vector<std::string> parts;
        std::istringstream stream(cmd);
        std::string part;
        int partIndex = 0;
        while (std::getline(stream, part, '|'))
        {
            parts.push_back(part);
            partIndex++;
            // After 4th delimiter, the rest is the text (which may contain '|')
            if (partIndex == 4)
            {
                std::string remaining;
                std::getline(stream, remaining);
                if (!remaining.empty())
                {
                    parts.back() += "|" + remaining;
                }
                break;
            }
        }

        if (parts.size() >= 4)
        {
            bool interrupt = (parts[1] == "1");
            // parts[2] is priority (not used by Tolk directly)
            std::wstring text = Utf8ToWide(parts[3]);

            if (!text.empty())
            {
                Tolk_Output(text.c_str(), interrupt);
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Log file monitoring
// ---------------------------------------------------------------------------

// Read new lines from scriptslog.txt and process W3BA commands
static void PollLogFile()
{
    std::ifstream file;
    file.open(std::filesystem::path(g_logFilePath), std::ios::in);
    if (!file.is_open()) return;

    // Seek to where we left off
    file.seekg(g_lastReadPos);

    std::string line;
    while (std::getline(file, line))
    {
        // Look for our log channel prefix: "[W3BA] <command>"
        // The game's log format is typically: [ChannelName] message
        size_t pos = line.find("[W3BA]");
        if (pos != std::string::npos)
        {
            // Extract the command after "[W3BA] "
            std::string cmd = line.substr(pos + 7); // 7 = strlen("[W3BA] ")
            // Trim leading/trailing whitespace
            size_t start = cmd.find_first_not_of(" \t\r\n");
            size_t end   = cmd.find_last_not_of(" \t\r\n");
            if (start != std::string::npos)
            {
                cmd = cmd.substr(start, end - start + 1);
                ProcessCommand(cmd);
            }
        }
    }

    // Remember where we stopped
    file.clear(); // clear EOF flag
    g_lastReadPos = file.tellg();
    file.close();
}

// ---------------------------------------------------------------------------
// Poll thread
// ---------------------------------------------------------------------------

static DWORD WINAPI PollThreadProc(LPVOID)
{
    while (g_running)
    {
        {
            std::lock_guard<std::mutex> lock(g_mutex);
            PollLogFile();
        }
        Sleep(POLL_INTERVAL_MS);
    }
    return 0;
}

// ---------------------------------------------------------------------------
// Initialization / Shutdown
// ---------------------------------------------------------------------------

static void Initialize()
{
    // Locate the script log file
    std::wstring docs = GetUserDocumentsPath();
    if (docs.empty())
    {
        // Fallback: try relative path
        g_logFilePath = L"scriptslog.txt";
    }
    else
    {
        g_logFilePath = docs + L"\\The Witcher 3\\scriptslog.txt";
    }

    // Initialize Tolk
    Tolk_Load();
    Tolk_TrySAPI(true); // Enable Windows SAPI as fallback

    const wchar_t* reader = Tolk_DetectScreenReader();
    if (reader)
    {
        Tolk_Output(L"W3 Blind Access: TTS bridge loaded.", false);
    }

    // Start the polling thread
    g_running = true;
    g_pollThread = CreateThread(NULL, 0, PollThreadProc, NULL, 0, NULL);
}

static void Shutdown()
{
    // Stop polling thread
    g_running = false;
    if (g_pollThread)
    {
        WaitForSingleObject(g_pollThread, 2000);
        CloseHandle(g_pollThread);
        g_pollThread = NULL;
    }

    // Cleanup Tolk
    Tolk_Silence();
    Tolk_Unload();
}

// ---------------------------------------------------------------------------
// DLL Entry Point
// ---------------------------------------------------------------------------

BOOL APIENTRY DllMain(HMODULE hModule, DWORD reason, LPVOID)
{
    switch (reason)
    {
    case DLL_PROCESS_ATTACH:
        DisableThreadLibraryCalls(hModule);
        Initialize();
        break;

    case DLL_PROCESS_DETACH:
        Shutdown();
        break;
    }
    return TRUE;
}
