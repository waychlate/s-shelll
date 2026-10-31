import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

// Workspace pills. Each shows its number and small icons for the apps on it
// (capped at Theme.maxWorkspaceIcons, then "+N"). Click to switch.
RowLayout {
    id: root
    spacing: Theme.px(4)

    function iconFor(cls) {
        DesktopEntries.applications.values;   // re-run once desktop entries finish loading at startup
        const entry = DesktopEntries.heuristicLookup(cls);
        return Quickshell.iconPath(entry ? entry.icon : cls.toLowerCase(), "application-x-executable");
    }

    // window class names (for icons) are only fetched on demand. Don't also call
    // refreshWorkspaces() here: doing that at startup leaves every workspace at id -1.
    Component.onCompleted: Hyprland.refreshToplevels()

    // re-read class names on window events
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name.indexOf("window") >= 0 || event.name.indexOf("workspace") >= 0)
                Hyprland.refreshToplevels();
        }
    }

    Repeater {
        // workspaces with windows, plus the focused one so you can see where you are
        model: Hyprland.workspaces.values
            .filter(w => w.id > 0 && (w.toplevels.values.length > 0
                                      || (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === w.id)))
            .map(w => w.id)
            .sort((a, b) => a - b)

        Rectangle {
            id: pill

            required property int modelData
            readonly property int wsId: modelData
            readonly property var ws: Hyprland.workspaces.values.filter(w => w.id === wsId)[0] || null
            readonly property bool active: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === wsId
            readonly property var apps: {
                if (!ws) return [];
                return ws.toplevels.values
                    .map(t => (t.lastIpcObject && t.lastIpcObject.class) ? t.lastIpcObject.class
                                                                         : (t.wayland ? t.wayland.appId : ""))
                    .filter((c, i, a) => c !== "" && a.indexOf(c) === i);
            }
            readonly property bool occupied: apps.length > 0
            readonly property bool showNumber: !Theme.workspaceIconsOnly || !occupied

            Layout.alignment: Qt.AlignVCenter
            implicitHeight: Theme.px(26)
            implicitWidth: content.implicitWidth + Theme.px(18)
            radius: height / 2
            color: active ? Theme.accent : "transparent"

            RowLayout {
                id: content
                anchors.centerIn: parent
                spacing: Theme.px(5)

                Text {
                    visible: pill.showNumber
                    text: pill.wsId
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.px(14)
                    font.weight: pill.active ? Font.DemiBold : Font.Normal
                    color: pill.active ? Theme.accentInk
                                       : Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, pill.occupied ? 0.85 : 0.4)
                }

                Repeater {
                    model: pill.apps.slice(0, Theme.maxWorkspaceIcons)

                    IconImage {
                        required property string modelData
                        implicitSize: Theme.px(14)
                        source: root.iconFor(modelData)
                    }
                }

                Text {
                    visible: pill.apps.length > Theme.maxWorkspaceIcons
                    text: "+" + (pill.apps.length - Theme.maxWorkspaceIcons)
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.px(11)
                    font.weight: Font.DemiBold
                    color: pill.active ? Theme.accentInk : Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.7)
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + pill.wsId)
            }
        }
    }
}
