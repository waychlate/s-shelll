import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

// Battery icon with a fill level and a percentage. Turns rose below 20%.
// Hidden on machines without a battery.
RowLayout {
    id: root

    readonly property var dev: UPower.displayDevice
    readonly property real level: {
        if (!dev) return 0;
        const p = dev.percentage;      // normalise in case it's reported as 0-100
        return p > 1 ? p / 100 : p;
    }

    visible: dev !== null && dev.isPresent
    spacing: Theme.px(6)

    Glyph {
        kind: "battery"
        level: root.level
        size: Theme.px(22)
        color: root.level < 0.2 ? Theme.hot : Theme.accents[2]
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        text: Math.round(root.level * 100) + "%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(15)
        color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.85)
        Layout.alignment: Qt.AlignVCenter
    }
}
