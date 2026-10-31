# shadow-shell

A Quickshell launcher for a Hyprland rice: frosted panel, "Start typing to search",
a few app tiles. Design source: the Figma file "Hyprland Rice – Launcher"
(board: "Tile launcher – simple").

## Files

- `shell.qml`: entry point (add the bar / notifications here later)
- `Launcher.qml`: the launcher window, search, tiles, keyboard handling
- `Theme.qml`: every color, font, radius and setting (palette swap lives here)
- `hyprland-snippet.conf`: keybind, autostart and blur rule to paste into your Hyprland config

## Run

1. Install `quickshell` (check your repos / AUR) and the Gelasio font
   (Google Fonts). Confirm with `fc-list | grep -i gelasio`.
2. `qs -p ~/projects/personal/shadow-shell`
3. In another terminal: `qs -p ~/projects/personal/shadow-shell ipc call launcher toggle`

Keys: type to search, Tab / arrows to move, Enter to launch, Esc to close.

## Tweaking

In `Theme.qml`: `palette` (sorbet / candy / lilac / matcha), `panelOpacity`
(lower = more see-through), `pinned` (apps shown before you type), `tileCount`.

## Notes

- Written without being able to run Quickshell here, so expect small fixes on first launch.
  Run it from a terminal and read the errors.
- Tile icons use your system icon theme, so they won't match the stroked glyphs from the
  Figma mockup. Pick an icon theme that fits the palette, or draw custom icons later.
- The blur comes from Hyprland, not Quickshell. See `hyprland-snippet.conf`.
