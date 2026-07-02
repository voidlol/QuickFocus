# Changelog

## [1.0.1] - 2026-07-02

### Fixed
- Raid marker macro syntax: condition now placed before argument (`/tm [@focus,exists] ~3`)

### Changed
- Raid markers now use `~` prefix to avoid overriding markers placed by other raid members

## [1.0.0] - 2026-07-02

### Added
- Initial release
- Modifier + Click on any unit frame to set focus
- Configurable modifier key (Shift/Ctrl/Alt) and mouse button (1-5)
- Optional raid marker on focus with safe-mark mode
- Slash commands: `/qf toggle`, `/qf status`, `/qf config`
- Settings panel under Interface > AddOns > QuickFocus

### Modules
- Blizzard default unit frames
- ElvUI unit frames
- EllesmereUI UnitFrames + RaidFrames
- Modular API for adding new UF addon support
