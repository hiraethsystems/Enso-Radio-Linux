cmake_minimum_required(VERSION 3.16)

# Ensō Radio for Linux:
#   cmake -S . -B build-linux -G Ninja            the app, the tests and the list tool
#   cmake -S . -B build-test -DENSO_APP=OFF        core/ unit tests only (no SDL needed)
project(ensoradio C)

# Versions (README, "Versions"), in linux/:
#   VERSION  the release version, MAJOR.MINOR.PATCH, minor and patch 0-9.
#   BUILD    goes up by one for every build handed over for testing.
set(ENSO_APP_DIR "${CMAKE_SOURCE_DIR}/linux")
file(STRINGS "${ENSO_APP_DIR}/VERSION" ENSO_VERSION LIMIT_COUNT 1)
file(STRINGS "${ENSO_APP_DIR}/BUILD" ENSO_BUILD LIMIT_COUNT 1)
# Re-run CMake when either changes, so a bumped BUILD reaches the binary.
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
             "${ENSO_APP_DIR}/VERSION" "${ENSO_APP_DIR}/BUILD")
if(NOT ENSO_VERSION MATCHES "^([0-9]|[1-9][0-9])\\.([0-9])\\.([0-9])$")
    message(FATAL_ERROR "VERSION must be MAJOR.MINOR.PATCH with minor and patch 0-9, "
                        "e.g. 1.0.0: '${ENSO_VERSION}'")
endif()
if(NOT ENSO_BUILD MATCHES "^[1-9][0-9]*$")
    message(FATAL_ERROR "BUILD must be a whole number: '${ENSO_BUILD}'")
endif()

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Building a station list from Radio Browser (Linux only, not the Vita):
# portable C, plus zlib for GeoNames' zip.
set(RB_SOURCES
    core/json.c
    core/rb_build.c
    core/unitab.c
    core/ustr.c
    core/zip_read.c
)

set(CORE_SOURCES
    core/bidi_order.c
    core/config.c
    core/controls.c
    core/globe.c
    core/hls.c
    core/icy.c
    core/library.c
    core/load_report.c
    core/media_demux.c
    core/playlist.c
    core/ring_buffer.c
    core/search.c
    core/station.c
    core/stations_file.c
    core/stream_buffer.c
    core/stream_info.c
    core/strmap.c
    core/text.c
    core/track_info.c
    core/userlist.c
)

# The app (linux/). Libraries from tools/build_linux_deps.sh.
option(ENSO_APP "Build the app (off: core/ tests and the list tool only)" ON)
if(ENSO_APP)
    include(cmake/linux.cmake)
endif()

find_package(ZLIB REQUIRED)
add_executable(ensoradio_test
    ${CORE_SOURCES}
    ${RB_SOURCES}
    tests/test_rb.c
    tests/test_main.c
    tests/test_library.c
    tests/test_globe.c
    tests/test_controls.c
    tests/test_stationfiles.c
    tests/test_bidi.c
    tests/test_stream.c
    tests/test_hls.c
)
target_include_directories(ensoradio_test PRIVATE core)
target_compile_definitions(ensoradio_test PRIVATE
                           ENSO_TESTDATA_DIR="${CMAKE_SOURCE_DIR}/testdata")
target_compile_options(ensoradio_test PRIVATE -Wall -Wextra -Wpedantic -g)
target_compile_options(ensoradio_test PRIVATE -fsanitize=address,undefined)
target_link_options(ensoradio_test PRIVATE -fsanitize=address,undefined)
target_link_libraries(ensoradio_test ZLIB::ZLIB m)

# The station-list builder from the command line, to compare it with
# tools/rb_to_stations.py (tests/compare_listtool.sh).
add_executable(ensoradio_listtool ${CORE_SOURCES} ${RB_SOURCES} tests/listtool.c)
target_include_directories(ensoradio_listtool PRIVATE core)
target_compile_options(ensoradio_listtool PRIVATE -Wall -Wextra -O2 -g)
target_link_libraries(ensoradio_listtool ZLIB::ZLIB m)

enable_testing()
add_test(NAME core COMMAND ensoradio_test)
