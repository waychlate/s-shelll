import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

// Now playing: note icon, title, artist. Click to play/pause. Hidden when nothing is playing.
Item {
    id: root

    readonly property var player: {
        const ps = Mpris.players.values;
        return ps.filter(p => p.isPlaying)[0] || ps[0] || null;
    }

    visible: player !== null && player.trackTitle !== ""
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row
        spacing: Theme.px(8)

        Glyph {
            kind: "note"
            size: Theme.px(20)
            color: Theme.accent
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.player ? root.player.trackTitle : ""
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(15)
            font.weight: Font.DemiBold
            color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.92)
            Layout.maximumWidth: Theme.px(220)
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: text !== ""
            text: root.player ? root.player.trackArtist : ""
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(15)
            color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.5)
            Layout.maximumWidth: Theme.px(160)
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: if (root.player && root.player.canTogglePlaying) root.player.togglePlaying()
    }
}
