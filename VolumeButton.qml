import QtQuick
import Quickshell.Services.Pipewire

// Volume icon. Click toggles mute, scroll changes volume.
Item {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null

    implicitWidth: glyph.implicitWidth
    implicitHeight: glyph.implicitHeight

    PwObjectTracker { objects: root.sink ? [root.sink] : [] }

    Glyph {
        id: glyph
        kind: "volume"
        size: Theme.px(20)
        color: root.audio && root.audio.muted ? Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.35) : Theme.fg
    }

    MouseArea {
        anchors.fill: parent
        onClicked: if (root.audio) root.audio.muted = !root.audio.muted
        onWheel: wheel => {
            if (!root.audio) return;
            const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            root.audio.volume = Math.max(0, Math.min(1, root.audio.volume + step));
        }
    }
}
