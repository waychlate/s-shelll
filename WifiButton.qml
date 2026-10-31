import QtQuick
import Quickshell.Io

// Wi-Fi icon: aqua when connected, dim when not. Checks NetworkManager every 5 seconds.
Item {
    id: root

    property bool connected: false

    implicitWidth: glyph.implicitWidth
    implicitHeight: glyph.implicitHeight

    Process {
        id: proc
        command: ["nmcli", "-t", "-f", "TYPE,STATE", "device"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.connected = text.indexOf("wifi:connected") >= 0
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }

    Glyph {
        id: glyph
        kind: "wifi"
        size: Theme.px(20)
        color: root.connected ? Theme.accents[1] : Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.35)
    }
}
