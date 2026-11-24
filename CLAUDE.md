# Project brief: DX Garden for Linux

Name: **DX Garden**. Internal/folder name: `dxgarden` (data folder `~/.local/share/dxgarden/`, app id `club.hiraeth.dxgarden`).

## What this is

A Radio Garden style radio explorer for the Linux desktop: spin a globe, move over a city, and hear live radio from there. Written in C on SDL3 and OpenGL, released as an AppImage.

It should feel like Radio Garden to use, but with its own visual identity. Do not copy Radio Garden's artwork, logo, colours, icons or text.

## Where it came from (my decision, 2026-11-24)

DX Garden started as a PS Vita homebrew app. The Vita app stays in its own repository, `hiraethsystems/DX-Garden`, and is frozen. This repository (`hiraethsystems/DX-Garden-Linux`) is the Linux app only, split out with its history on 2026-11-24. `core/` here is the Linux app's own copy and may change freely; it no longer has to build for the Vita. Keep it portable C99 with its own unit tests all the same.

I will test every build on my PC and report back. Work in small milestones, and stop at the end of each one so I can test before you continue.

## Station data (important)

Stations come from the user's own station file, imports, URLs they type in, and the bundled list:

- `~/.local/share/dxgarden/stations.txt` in a simple documented format: name, stream URL, country, city, latitude, longitude, plus optional genre and notes.
- M3U/PLS files placed in `~/.local/share/dxgarden/import/` (these lack coordinates; let the user assign a place to them in the app).
- Add station by URL.

**One directory is allowed: Radio Browser (radio-browser.info).** A desktop script (`tools/rb_to_stations.py`) downloads stations from it once and writes a normal `stations.txt`; `core/rb_build.c` does the same inside the app and must write the same lines (`tests/compare_listtool.sh`).

**Bundled list:** one snapshot made with that script (`--bundle <version>`) ships in the AppImage as `assets/stations/linux/stations.txt`: every format the app plays, HLS included, stations without coordinates placed as in `NOTES.md` (F6). On first run it becomes `~/.local/share/dxgarden/stations.txt`; the app never overwrites an existing one. The README says the list is correct as of the release date and that changes are the user's responsibility.

**Country labels follow where a station actually is, whatever Radio Browser says (my decision):** Ukraine's territory, including Crimea and the occupied east and south, is labelled Ukraine; Palestinian territory is labelled Gaza or Occupied West Bank; UK stations are labelled by nation (England, Scotland, Wales, Northern Ireland), and the Crown Dependencies by their own names (Isle of Man, Jersey, Guernsey). Stations placed only by country go in that country's Country-wide place ("United Kingdom, Country-wide", "Palestine, Country-wide"). The same rules apply to every list.

Bundle no other list, and do not use Radio Garden's own API or data in any form (including entries that point back at Radio Garden).

**Downloads (my decision, 2026-11-22):** the app may download Radio Browser station data, the GeoNames cities and admin1 files and Natural Earth country borders, to build a new `stations.txt`, when the user asks for it (a dialog with filters, never in the background). No other directory or live lookup without asking me first.

Keep all station loading behind the `station_source` interface in `core/` so another source could be added later, but only if I explicitly decide to. If a feature would need a directory or a live lookup, stop and ask me.

## Architecture

- `core/`: portable C99, no SDL or OpenGL. Station file and playlist parsing, ICY and stream metadata, HLS, stream buffering, grouping stations into places, config, the station-list builder. Unit tests in `tests/` (`dxgarden_test`), built without SDL.
- `linux/`: the app: SDL3 window and input, OpenGL globe, decoders (mpg123, faad2, Vorbis, Opus, FLAC), libcurl networking, its own widget toolkit and looks (Classic, Breeze, Adwaita).
- `tools/`: `rb_to_stations.py`, `build_linux_deps.sh`, `make_appimage.sh`, `make_earth.py`, font and Unicode table generators.

Prefer libraries already packaged on Debian, or built by `tools/build_linux_deps.sh`, over vendoring. Tell me what you propose before adding a new library. Any map, imagery or font must have a licence that allows redistribution in the AppImage; tell me which and its licence.

## How to work with me

- Explain decisions in plain terms and keep a running `NOTES.md` of design decisions and known issues.
- Before each milestone, give a short plan; after it, give me a test checklist for the Linux desktop.
- Bump `linux/BUILD` for every build so I can tell builds apart; the app, log and AppImage name show it. `linux/VERSION` (MAJOR.MINOR.PATCH, minor and patch 0-9) changes only when we decide the next release; releases are tagged `linux-vX.Y.Z`.
- If something is uncertain (performance on other machines, a distribution or desktop I haven't tried), say so instead of guessing, and suggest how I can test it.
- Keep the README honest: a player and explorer for streams, shipping a dated Radio Browser snapshot as a default list that is the user's to maintain. The app downloads a directory only when the user asks.
