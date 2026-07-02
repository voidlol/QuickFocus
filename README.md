# QuickFocus

Standalone WoW addon — Shift+Click (or any modifier+click) on any unit frame to set focus. No dependencies required.

Supports Blizzard default frames, ElvUI, EllesmereUI, and any other addon via a simple module system.

## Features

- Modifier + Click on unit frames to set focus
- Configurable modifier key (Shift/Ctrl/Alt) and mouse button (1-5)
- Optional raid marker on focus with safe-mark mode
- Works with any unit frame addon via modules
- Slash commands: `/qf toggle`, `/qf status`, `/qf config`

## Installation

1. Download or clone this repo
2. Copy the `QuickFocus` folder into `World of Warcraft\_retail_\Interface\AddOns\`
3. Restart WoW and enable "QuickFocus" in the AddOns list

## Adding support for a new unit frame addon

Create a new file in `Modules/` (e.g. `Modules/MyAddon.lua`) and register a module:

```lua
QuickFocus:RegisterModule("MyAddon", function()
    local QF = QuickFocus

    -- Option 1: Hook frames by their global name
    QF:HookByName("MyUF_Player")
    QF:HookByName("MyUF_Target")

    -- Option 2: Walk a container's children (for dynamic frames like raid headers)
    QF:HookChildrenByName("MyRaidContainer")

    -- Option 3: Hook a frame object directly
    local frame = someFunction()
    QF:HookFrame(frame)
end)
```

Then add the file to `QuickFocus.toc`:

```
Core.lua
Modules\Blizzard.lua
Modules\ElvUI.lua
Modules\EllesmereUI.lua
Modules\MyAddon.lua
```

### Available API methods

| Method | Description |
|---|---|
| `QuickFocus:HookFrame(frame)` | Set focus attribute on a single frame |
| `QuickFocus:HookChildren(frame)` | Recursively walk children and hook any frame with a `unit` attribute |
| `QuickFocus:HookByName(name)` | Look up `_G[name]` and hook it |
| `QuickFocus:HookChildrenByName(name)` | Look up `_G[name]` and walk its children |
| `QuickFocus:RegisterModule(name, func)` | Register a module that runs on every hook pass |

## Slash Commands

| Command | Description |
|---|---|
| `/qf` or `/quickfocus` | Show help |
| `/qf toggle` | Enable/Disable |
| `/qf status` | Show current settings |
| `/qf config` | Open settings panel |

## License

MIT
