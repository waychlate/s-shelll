# shadow-shell

A Quickshell shell for a Hyprland rice: a floating bar and a tile launcher, in the
Sorbet palette with Gelasio type. Design source: the Figma file "Hyprland Rice – Launcher"
(boards: "Tile launcher – simple", "Bar – floating pill", "Bar – tray states",
"Bar – workspace icons", "Full desktop mockup").

## Files

- `shell.qml`: entry point (add notifications / OSDs here later)
- `Theme.qml`: every color, font, radius and setting (palette swap lives here)
- `Glyph.qml`: the line icons from the Figma file, drawn as vector paths
- Launcher: `Launcher.qml`
- Bar: `Bar.qml` (window), `Workspaces.qml`, `Clock.qml`, `Media.qml`, `Tray.qml`,
  `Status.qml` (+ `PowerProfileButton.qml`, `VolumeButton.qml`, `WifiButton.qml`, `BatteryIndicator.qml`)
- `hyprland-snippet.conf`: keybind, autostart and blur rules to paste into your Hyprland config

## Run

1. Install `quickshell` (check your repos / AUR) and the Gelasio font
   (Google Fonts). Confirm with `fc-list | grep -i gelasio`.
2. `qs -p ~/projects/personal/shadow-shell`
3. Launcher toggle (second terminal): `qs -p ~/projects/personal/shadow-shell ipc call launcher toggle`

Launcher keys: type to search, Tab / arrows to move, Enter to launch, Esc to close.

## The bar

- **Workspaces:** only occupied workspaces (plus the focused one), number plus small app icons (max 3, then "+N"). Click to switch.
  Set `workspaceIconsOnly` in `Theme.qml` for the icons-only version.
- **Clock:** 24-hour (`timeFormat` / `dateFormat` in `Theme.qml`).
- **Media:** title and artist of the playing MPRIS player; click to play/pause. Hidden when idle.
- **Tray:** none = hidden, one app = its icon, several = a chevron that opens a popover on hover.
  Left click activates, right click opens the app's menu.
- **Status:** power profile (click cycles saver / balanced / performance), volume (click mutes,
  scroll adjusts), Wi-Fi (via `nmcli`), battery (rose under 20%).

## Tweaking

In `Theme.qml`: `palette` (sorbet / candy / lilac / matcha), `panelOpacity`
(lower = more see-through), `uiScale` / `barScale`, `pinned` (launcher fallback apps),
`tileCount`, `maxWorkspaceIcons`.

## Notes

- Written without being able to run Quickshell here, so expect small fixes on first launch.
  Run it from a terminal and read the errors. The Quickshell module APIs (Hyprland, SystemTray,
  Mpris, UPower, Pipewire) are the most likely places for a version mismatch.
- If the bar overlaps your windows or leaves too big a gap, adjust the bar's exclusive zone in
  `Bar.qml` and Hyprland's `gaps_out`.
- Icons on tiles, workspaces and the tray use your system icon theme, so they won't match the
  stroked glyphs from the Figma mockup.
- The blur comes from Hyprland, not Quickshell. See `hyprland-snippet.conf`.
