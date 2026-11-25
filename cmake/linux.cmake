# The Linux app (linux/), included from CMakeLists.txt.
#
#   cmake -S . -B build-linux -G Ninja
#   cmake --install build-linux --prefix ~/.local   (optional)
#   AppImage: tools/make_appimage.sh (a build with -DENSO_STATIC_DEPS=ON)
#
# Run tools/build_linux_deps.sh first (linux; the AppImage also
# linux-static).
set(ENSO_LINUX_DEPS "${CMAKE_SOURCE_DIR}/third_party/linux" CACHE PATH "Linux dependency prefix")
set(ENSO_LINUX_STATIC_DEPS "${CMAKE_SOURCE_DIR}/third_party/linux-static" CACHE PATH
    "Linux static dependency prefix (ENSO_STATIC_DEPS)")
option(ENSO_STATIC_DEPS "Link curl, mpg123 and the text libraries statically (the AppImage)" OFF)
list(PREPEND CMAKE_PREFIX_PATH "${ENSO_LINUX_DEPS}")

find_package(SDL3 CONFIG REQUIRED COMPONENTS SDL3-static)
find_package(PkgConfig REQUIRED)
if(ENSO_STATIC_DEPS)
    # Everything from third_party/linux-static/, so the program needs only
    # glibc and what SDL loads at run time.
    set(enso_l "${ENSO_LINUX_STATIC_DEPS}/lib")
    foreach(lib curl mbedtls mbedx509 mbedcrypto everest p256m mpg123 faad vorbisfile vorbis
                opusfile opus FLAC ogg z freetype harfbuzz fribidi)
        if(NOT EXISTS "${enso_l}/lib${lib}.a")
            message(FATAL_ERROR "${enso_l}/lib${lib}.a is missing: run tools/build_linux_deps.sh linux-static")
        endif()
    endforeach()
    set(ENSO_CURL "${enso_l}/libcurl.a" "${enso_l}/libmbedtls.a" "${enso_l}/libmbedx509.a"
        "${enso_l}/libmbedcrypto.a" "${enso_l}/libeverest.a" "${enso_l}/libp256m.a" pthread)
    set(ENSO_MPG123 "${enso_l}/libmpg123.a" "${enso_l}/libfaad.a" "${enso_l}/libvorbisfile.a"
        "${enso_l}/libvorbis.a" "${enso_l}/libopusfile.a" "${enso_l}/libopus.a" "${enso_l}/libFLAC.a"
        "${enso_l}/libogg.a" "${enso_l}/libz.a")
    set(ENSO_TEXT "${enso_l}/libharfbuzz.a" "${enso_l}/libfreetype.a" "${enso_l}/libfribidi.a")
    set(ENSO_TEXT_INCLUDES "${ENSO_LINUX_STATIC_DEPS}/include"
        "${ENSO_LINUX_STATIC_DEPS}/include/freetype2" "${ENSO_LINUX_STATIC_DEPS}/include/harfbuzz"
        "${ENSO_LINUX_STATIC_DEPS}/include/fribidi" "${ENSO_LINUX_STATIC_DEPS}/include/opus")
    set(ENSO_PLATFORM_NAME "Linux")
else()
    pkg_check_modules(ENSO_PC REQUIRED IMPORTED_TARGET libcurl libmpg123 vorbisfile opusfile flac zlib)
    find_library(FAAD_LIB NAMES faad REQUIRED)
    pkg_check_modules(ENSO_TEXT_PC REQUIRED IMPORTED_TARGET freetype2 harfbuzz fribidi)
    set(ENSO_CURL PkgConfig::ENSO_PC)
    set(ENSO_MPG123 ${FAAD_LIB})
    set(ENSO_TEXT PkgConfig::ENSO_TEXT_PC)
    set(ENSO_TEXT_INCLUDES "")
    set(ENSO_PLATFORM_NAME "Linux")
endif()

add_executable(ensoradio_linux
    ${CORE_SOURCES}
    ${RB_SOURCES}
    linux/app.c
    linux/list_download.c
    linux/list_dialog.c
    linux/data.c
    linux/decode.c
    linux/draw.c
    linux/earth.c
    linux/font.c
    linux/fs.c
    linux/gallery.c
    linux/gl.c
    linux/globe_view.c
    linux/icons.c
    linux/library_view.c
    linux/log.c
    linux/main.c
    linux/player.c
    linux/theme.c
    linux/ui.c
    linux/ui_widgets.c
)
set_target_properties(ensoradio_linux PROPERTIES OUTPUT_NAME ensoradio C_EXTENSIONS ON)
target_include_directories(ensoradio_linux PRIVATE core linux ${ENSO_TEXT_INCLUDES})
target_compile_definitions(ensoradio_linux PRIVATE ENSO_VERSION="${ENSO_VERSION}"
                           ENSO_BUILD="${ENSO_BUILD}" ENSO_PLATFORM_NAME="${ENSO_PLATFORM_NAME}"
                           "STATION_FILE_MAX=(32u * 1024 * 1024)")
target_compile_options(ensoradio_linux PRIVATE -Wall -Wextra -O2 -g)
target_link_libraries(ensoradio_linux PRIVATE SDL3::SDL3-static ${ENSO_CURL} ${ENSO_MPG123}
                      ${ENSO_TEXT} m)
if(ENSO_STATIC_DEPS)
    # HarfBuzz is C++: its runtime goes in too, so the program doesn't need
    # this machine's libstdc++.
    target_compile_definitions(ensoradio_linux PRIVATE CURL_STATICLIB FRIBIDI_LIB_STATIC
                               FLAC__NO_DLL ENSO_STATIC_DEPS)
    target_link_options(ensoradio_linux PRIVATE -static-libstdc++ -static-libgcc)
    set_target_properties(ensoradio_linux PROPERTIES LINKER_LANGUAGE CXX)
    enable_language(CXX)
endif()

# What the app reads at run time, next to the executable: fonts/ and the
# bundled station list.
set(ENSO_LINUX_FONTS
    LiberationSans-Regular.ttf LiberationSans-Bold.ttf OFL-Liberation.txt
    NotoSans-Regular.ttf NotoSans-Bold.ttf NotoSansArabic-Regular.ttf
    NotoSansHebrew-Regular.ttf NotoSansThai-Regular.ttf NotoSansGeorgian-Regular.ttf
    NotoSansEthiopic-Regular.ttf NotoSansCJKsc-Subset.otf OFL.txt)
foreach(f ${ENSO_LINUX_FONTS})
    add_custom_command(TARGET ensoradio_linux POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${CMAKE_SOURCE_DIR}/assets/fonts/${f}" "$<TARGET_FILE_DIR:ensoradio_linux>/fonts/${f}")
endforeach()
add_custom_command(TARGET ensoradio_linux POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_SOURCE_DIR}/assets/stations/linux/stations.txt"
            "$<TARGET_FILE_DIR:ensoradio_linux>/stations.txt")
# The window icon (X11 title bars and task switchers).
add_custom_command(TARGET ensoradio_linux POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_SOURCE_DIR}/linux/share/systems.hiraeth.ensoradio.png"
            "$<TARGET_FILE_DIR:ensoradio_linux>/icon.png")
# The globe's imagery, built by tools/make_earth.py (not in git: 70 MB).
if(EXISTS "${CMAKE_SOURCE_DIR}/assets-build/earth-day.pack")
    add_custom_command(TARGET ensoradio_linux POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${CMAKE_SOURCE_DIR}/assets-build/earth-day.pack"
                "$<TARGET_FILE_DIR:ensoradio_linux>/earth-day.pack")
else()
    message(WARNING "assets-build/earth-day.pack is missing: run tools/make_earth.py "
                    "for the globe's imagery")
endif()

# Linux install layout (also the AppImage's): bin/ensoradio, the files it
# reads in share/systems.hiraeth.ensoradio/ (found from bin/), and a
# menu entry and icon named after the app ID SDL gives Wayland.
include(GNUInstallDirs)
install(TARGETS ensoradio_linux RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
# Not share/ensoradio/: with --prefix ~/.local that is the user's data folder.
set(ENSO_SHARE "${CMAKE_INSTALL_DATADIR}/systems.hiraeth.ensoradio")
foreach(f ${ENSO_LINUX_FONTS})
    install(FILES "${CMAKE_SOURCE_DIR}/assets/fonts/${f}" DESTINATION "${ENSO_SHARE}/fonts")
endforeach()
install(FILES "${CMAKE_SOURCE_DIR}/assets/stations/linux/stations.txt" DESTINATION "${ENSO_SHARE}")
install(FILES linux/share/systems.hiraeth.ensoradio.png DESTINATION "${ENSO_SHARE}"
        RENAME icon.png)
if(EXISTS "${CMAKE_SOURCE_DIR}/assets-build/earth-day.pack")
    install(FILES "${CMAKE_SOURCE_DIR}/assets-build/earth-day.pack" DESTINATION "${ENSO_SHARE}")
endif()
# The menu entry runs the program by its full path: desktops don't
# always have ~/.local/bin on their PATH (Plasma on Debian doesn't).
# Written at install time, so `cmake --install --prefix` is honoured.
install(CODE "
    set(enso_bin \"\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/ensoradio\")
    file(READ \"${CMAKE_SOURCE_DIR}/linux/share/systems.hiraeth.ensoradio.desktop\" enso_entry)
    string(REPLACE \"Exec=ensoradio\" \"Exec=\\\"\${enso_bin}\\\"\" enso_entry \"\${enso_entry}\")
    set(enso_out \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATADIR}/applications/systems.hiraeth.ensoradio.desktop\")
    message(STATUS \"Installing: \${enso_out}\")
    file(WRITE \"\${enso_out}\" \"\${enso_entry}\")
")
install(FILES linux/share/systems.hiraeth.ensoradio.png
        DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/128x128/apps")
