pragma Singleton

import Quickshell
import QtQuick

// One place for every design token. Mirrors the Figma file
// ("Simple tile launcher · Gelasio"). Swap `palette` to restyle everything.
Singleton {
    // ---- settings you'll actually touch ----------------------------------
    property string palette: "sorbet"      // sorbet | candy | lilac | matcha
    property real panelOpacity: 0.72       // lower = more see-through
    property string fontFamily: "Gelasio"
    property int tileCount: 3
    property real uiScale: 0.8           // overall launcher size (1 = original)

    // Fallback tiles before you type, used until launch history fills the row.
    // Matched loosely (substring of the entry id, or exact name), so
    // "firefox" finds "firefox.desktop" and "kitty" finds "kitty.desktop".
    property var pinned: ["firefox", "kitty", "dolphin"]

    // ---- palettes (from the Figma board) ---------------------------------
    readonly property var palettes: ({
        sorbet: { surface: "#1C1C1C", fg: "#EFEFEF", acc: ["#FFA98A", "#7FE3EA", "#CDF57F", "#FF8FB8"] },
        candy:  { surface: "#1A1A1E", fg: "#ECECF1", acc: ["#FF8FB8", "#8FF0C6", "#B9A4FF", "#FFE08A"] },
        lilac:  { surface: "#1B1C20", fg: "#E9EAF0", acc: ["#A7B8FF", "#D9A9FF", "#FF9EC7", "#8EE3FF"] },
        matcha: { surface: "#1B1C1A", fg: "#ECEDE8", acc: ["#B8E68F", "#FFF0B3", "#FFB87A", "#FFB5CB"] }
    })

    readonly property var current: palettes[palette]
    readonly property color surface: current.surface
    readonly property color fg: current.fg
    readonly property color accent: current.acc[0]
    readonly property var accents: current.acc

    // ---- shared shapes ----------------------------------------------------
    readonly property color hairline: Qt.rgba(1, 1, 1, 0.14)
    readonly property color tileFill: Qt.rgba(1, 1, 1, 0.07)
    readonly property real panelRadius: 28 * uiScale
    readonly property real tileRadius: 18 * uiScale

    // ---- bar --------------------------------------------------------------
    property real barScale: uiScale        // bar size; set separately if you want it bigger/smaller
    property bool workspaceIconsOnly: false // true = occupied workspaces show icons instead of the number
    property int maxWorkspaceIcons: 3       // more than this collapses to "+N"
    property string timeFormat: "HH:mm"     // 24-hour
    property string dateFormat: "ddd, MMM d"

    // ---- overheat toast ---------------------------------------------------
    property int heatLimit: 80       // °C, show the toast at or above this
    property int heatClear: 75       // °C, must cool below this before it can show again
    property int heatCooldown: 300   // seconds, minimum gap between toasts

    readonly property color accentInk: "#111111"   // text/icons drawn on an accent fill
    readonly property color hot: accents[3]       // warnings (low battery, overheat)

    // scale a design-pixel value by barScale
    function px(n) { return Math.round(n * barScale) }
    readonly property int barHeight: px(52)
}
