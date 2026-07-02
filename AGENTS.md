# AGENTS.md — QuickFocus

## Project
Standalone WoW addon for setting focus via modifier+click on unit frames.
No ElvUI/WindTools dependency — fully independent.

## Architecture
```
Core.lua              — binding, HookFrame API, events, slash commands, options
Modules/
  Blizzard.lua        — Blizzard default frames (PlayerFrame, PartyMemberFrame, etc.)
  ElvUI.lua           — ElvUI (UF.units, UF.headers)
  EllesmereUI.lua     — EllesmereUI UnitFrames + RaidFrames
QuickFocus.toc         — addon manifest (controls load order)
```

## Module API
Any module calls these on `QuickFocus`:
- `HookFrame(frame)` — set focus attribute on a frame
- `HookChildren(frame)` — walk children recursively, hook those with `unit` attr
- `HookByName(name)` — _G lookup → HookFrame
- `HookChildrenByName(name)` — _G lookup → HookChildren
- `RegisterModule(name, func)` — register a hook function

To add a new UF addon: create `Modules/MyAddon.lua`, call `RegisterModule`, add to TOC.

## Key decisions
- Frame attributes (`shift-type1 = "focus") are set per-frame for direct integration.
- Global override binding (`/focus mouseover`) is the universal fallback.
- EllesmereUIRaidFrames uses hardcoded names (ERFGroupHeader*, ERFPartyHeader, etc.)
  because SecureGroupHeader children are unnamed and created dynamically.
- `EnumerateFrames()` brute-force is intentionally avoided — it hooks non-unit frames.
- Raid markers use `/tm ~N` (tilde prefix) to avoid overriding markers set by others.

## Building releases
Zip must contain ONLY addon files. Exclude:
- `.git/`, `.gitignore`, `CHANGELOG.md`, `AGENTS.md`, `.releaseignore`

Correct zip structure:
```
QuickFocus-1.0.1.zip
  QuickFocus/
    QuickFocus.toc
    Core.lua
    Modules/
      Blizzard.lua
      ElvUI.lua
      EllesmereUI.lua
    README.md
```
