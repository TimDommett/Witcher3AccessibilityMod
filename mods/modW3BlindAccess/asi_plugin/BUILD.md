# Building the W3BA TTS ASI Plugin

This ASI plugin bridges WitcherScript speech commands to your screen reader (NVDA, JAWS, or Windows SAPI).

## Prerequisites

### 1. Visual Studio 2022
Download from: https://visualstudio.microsoft.com/downloads/
- Install "Desktop development with C++" workload

### 2. CMake 3.15+
Download from: https://cmake.org/download/
- Add to PATH during installation

### 3. Tolk SDK
Download from: https://github.com/dkager/tolk/releases
- Extract the archive
- Copy `Tolk.lib` to `asi_plugin/lib/`
- Keep `Tolk.dll` for later installation

### 4. Ultimate ASI Loader
Download from: https://github.com/ThirteenAG/Ultimate-ASI-Loader/releases
- Get the x64 version (`dinput8.dll`)

## Build Steps

Open PowerShell/Command Prompt:

```powershell
cd asi_plugin
mkdir build
cd build
cmake .. -G "Visual Studio 17 2022" -A x64
cmake --build . --config Release
```

This produces `W3BA_TTS.asi` in `build/Release/`.

## Installation

Copy these files to your Witcher 3 installation:

1. **Ultimate ASI Loader**: Copy `dinput8.dll` to:
   ```
   <Witcher 3>/bin/x64/dinput8.dll
   ```

2. **Create plugins folder**:
   ```
   <Witcher 3>/bin/x64/plugins/
   ```

3. **ASI Plugin**: Copy `W3BA_TTS.asi` to:
   ```
   <Witcher 3>/bin/x64/plugins/W3BA_TTS.asi
   ```

4. **Tolk DLL**: Copy `Tolk.dll` to:
   ```
   <Witcher 3>/bin/x64/plugins/Tolk.dll
   ```

5. **Screen Reader DLLs** (from Tolk's lib folder):
   - For NVDA: Copy `nvdaControllerClient64.dll`
   - For JAWS: Copy `jfwapi64.dll`
   - For SAPI only: No additional DLLs needed

## How It Works

```
WitcherScript                          ASI Plugin (in-process)
    |                                       |
    |-- LogChannel('W3BA', "SPEAK|1|2|Hello")
    |   (writes to scriptslog.txt)          |
    |                                       |-- polls file at 60Hz
    |                                       |-- parses [W3BA] lines
    |                                       |-- Tolk_Output(L"Hello", true)
    |                                       |-- screen reader speaks
```

1. Ultimate ASI Loader loads all `.asi` files from the plugins directory
2. `W3BA_TTS.asi` initializes Tolk and starts polling `scriptslog.txt`
3. WitcherScript writes speech commands via `LogChannel('W3BA', ...)`
4. The ASI plugin parses commands and calls `Tolk_Output()` for TTS
5. Tolk routes to the active screen reader (NVDA, JAWS, or SAPI fallback)

## Troubleshooting

### No speech output
- Ensure your screen reader is running before launching the game
- Check that all DLLs are in the plugins folder
- Verify `scriptslog.txt` exists in `Documents/The Witcher 3/`

### Build errors
- Make sure `Tolk.lib` is in the `lib/` folder
- Use Visual Studio 2022 (not older versions)
- Use 64-bit build (`-A x64`)

### Testing without screen reader
- Tolk falls back to Windows SAPI if no screen reader is detected
- You should hear speech through your speakers
