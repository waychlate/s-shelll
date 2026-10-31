import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// Floating pill bar, one per screen.
// Left: workspaces (with app icons)  ·  Center: date + time  ·  Right: media, tray, status
Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData

            color: "transparent"
            WlrLayershell.namespace: "shadow-bar"   // used by the Hyprland blur rule

            anchors {
                top: true
                left: true
                right: true
            }
            margins {
                top: Theme.px(16)
                left: Theme.px(24)
                right: Theme.px(24)
            }
            implicitHeight: Theme.barHeight

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, Theme.panelOpacity)
                border.width: 1
                border.color: Theme.hairline

                Workspaces {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.px(10)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Clock {
                    anchors.centerIn: parent
                }

                RowLayout {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.px(20)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.px(16)

                    Media { id: media; Layout.alignment: Qt.AlignVCenter }

                    Rectangle {
                        visible: media.visible
                        implicitWidth: 1
                        implicitHeight: Theme.px(18)
                        color: Qt.rgba(1, 1, 1, 0.18)
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Tray { barWindow: win; Layout.alignment: Qt.AlignVCenter }

                    Status { Layout.alignment: Qt.AlignVCenter }
                }
            }
        }
    }
}
