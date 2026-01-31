// Tolk.h - Screen Reader Abstraction Library
// https://github.com/dkager/tolk
// LGPL v3 License
//
// This header declares the Tolk API. The actual implementation is in Tolk.dll.
// Include this header in your project and link against Tolk.lib (or LoadLibrary).

#ifndef TOLK_H
#define TOLK_H

#ifdef __cplusplus
extern "C" {
#endif

#ifdef TOLK_EXPORTS
#define TOLK_DLL __declspec(dllexport)
#else
#define TOLK_DLL __declspec(dllimport)
#endif

// Lifecycle
TOLK_DLL void    __cdecl Tolk_Load(void);
TOLK_DLL bool    __cdecl Tolk_IsLoaded(void);
TOLK_DLL void    __cdecl Tolk_Unload(void);

// Configuration
TOLK_DLL void    __cdecl Tolk_TrySAPI(bool trySAPI);
TOLK_DLL void    __cdecl Tolk_PreferSAPI(bool preferSAPI);

// Detection
TOLK_DLL const wchar_t* __cdecl Tolk_DetectScreenReader(void);
TOLK_DLL bool           __cdecl Tolk_HasSpeech(void);
TOLK_DLL bool           __cdecl Tolk_HasBraille(void);

// Output
TOLK_DLL bool    __cdecl Tolk_Output(const wchar_t *str, bool interrupt);
TOLK_DLL bool    __cdecl Tolk_Speak(const wchar_t *str, bool interrupt);
TOLK_DLL bool    __cdecl Tolk_Braille(const wchar_t *str);

// Control
TOLK_DLL bool    __cdecl Tolk_IsSpeaking(void);
TOLK_DLL bool    __cdecl Tolk_Silence(void);

#ifdef __cplusplus
}
#endif

#endif // TOLK_H
