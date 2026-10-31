import QtQuick
import Quickshell

// Brightness icon. Scroll changes screen brightness (needs brightnessctl).
Item {
    implicitWidth: glyph.implicitWidth
    implicitHeight: glyph.implicitHeight

    Glyph {
        id: glyph
        kind: "sun"
        size: Theme.px(20)
    }

    MouseArea {
        anchors.fill: parent
        onWheel: wheel => Quickshell.execDetached(["brightnessctl", "-q", "set", wheel.angleDelta.y > 0 ? "5%+" : "5%-"])
    }
}
