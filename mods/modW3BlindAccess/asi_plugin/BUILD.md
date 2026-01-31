# Building the W3BA TTS ASI Plugin

## Prerequisites

1. **Visual Studio 2022** (or Build Tools) with C++ desktop workload
2. **CMake 3.15+**
3. **Tolk SDK** — download from https://github.com/dkager/tolk/releases
   - Place `Tolk.lib` in `asi_plugin/lib/`
   - Place `Tolk.dll` in `bin/x64/plugins/`
   - Place screen reader API DLLs in `bin/x64/plugins/` (e.g., `nvdaControllerClient64.dll`)

## Build Steps

```powershell
cd asi_plugin
mkdir build
cd build
cmake .. -G "Visual Studio 17 2022" -A x64
cmake --build . --config Release
```

This produces `W3BA_TTS.asi` in the build output directory.

## Installation

1. Install **Ultimate ASI Loader** — place `dinput8.dll` in `<Witcher 3>/bin/x64/`
2. Copy `W3BA_TTS.asi` to `<Witcher 3>/bin/x64/plugins/`
3. Copy `Tolk.dll` to `<Witcher 3>/bin/x64/plugins/`
4. Copy screen reader DLLs to `<Witcher 3>/bin/x64/plugins/`

## How It Works

1. Ultimate ASI Loader loads all `.asi` files from the plugins directory
2. `W3BA_TTS.asi` initializes Tolk and starts polling the game's `scriptslog.txt`
3. WitcherScript writes speech commands via `LogChannel('W3BA', ...)`
4. The ASI plugin parses commands and calls `Tolk_Output()` for each speech request
5. Tolk routes to the active screen reader (NVDA, JAWS, or SAPI fallback)
