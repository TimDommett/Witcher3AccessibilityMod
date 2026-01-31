cmake_minimum_required(VERSION 3.15)
project(W3BA_TTS LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build as a shared library (DLL)
add_library(W3BA_TTS SHARED
    src/W3BA_TTS.cpp
    src/Tolk.h
)

# Link against Tolk import library
# Users must place Tolk.lib in the lib/ directory
target_link_directories(W3BA_TTS PRIVATE ${CMAKE_SOURCE_DIR}/lib)
target_link_libraries(W3BA_TTS PRIVATE Tolk shell32)

# Output as .asi instead of .dll
set_target_properties(W3BA_TTS PROPERTIES
    SUFFIX ".asi"
    OUTPUT_NAME "W3BA_TTS"
)

# Install to the mod's plugins directory
install(TARGETS W3BA_TTS
    RUNTIME DESTINATION "${CMAKE_SOURCE_DIR}/../bin/x64/plugins/"
)
