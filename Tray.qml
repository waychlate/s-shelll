import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

// System tray, Windows-style:
//   0 apps  -> nothing
//   1 app   -> that app's own icon
//   2+ apps -> one chevron button; hovering it opens a popover with all of them
Item {
    id: root

    required property var barWindow

    readonly property var items: SystemTray.items.values
    readonly property int count: items.length

    visible: count > 0
    implicitWidth: button.width
    implicitHeight: button.height

    // ---- hover logic: stay open while the pointer is over the button OR the popover ----
    property bool shown: false
    readonly property bool hovering: btnHover.hovered || popupHover.hovered
    onHoveringChanged: {
        if (hovering) {
            closeTimer.stop();
            shown = true;
        } else {
            closeTimer.restart();
        }
    }
    Timer {
        id: closeTimer
        interval: 250
        onTriggered: root.shown = false
    }

    function openMenu(item, anchorItem) {
        if (!item.hasMenu) return;
        const p = anchorItem.mapToItem(root.barWindow.contentItem, 0, anchorItem.height);
        item.display(root.barWindow, p.x, p.y);
    }

    // ---- the button in the bar ----
    Rectangle {
        id: button
        width: Theme.px(28)
        height: Theme.px(28)
        radius: Theme.px(10)
        color: (root.count > 1 && root.shown) || btnHover.hovered
            ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.16)
            : "transparent"

        IconImage {
            visible: root.count === 1
            anchors.centerIn: parent
            implicitSize: Theme.px(20)
            source: root.count === 1 ? root.items[0].icon : ""
        }

        Glyph {
            visible: root.count > 1
            anchors.centerIn: parent
            size: Theme.px(20)
            kind: root.shown ? "chevUp" : "chevDown"
            color: root.shown ? Theme.accent : Theme.fg
        }

        HoverHandler { id: btnHover }

        // single-app mode: behave like a normal tray icon
        MouseArea {
            anchors.fill: parent
            enabled: root.count === 1
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                const it = root.items[0];
                if (mouse.button === Qt.RightButton) root.openMenu(it, button);
                else it.activate();
            }
        }
    }

    // ---- popover with every tray app ----
    PopupWindow {
        visible: root.shown && root.count > 1
        color: "transparent"

        anchor.item: button
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left

        implicitWidth: panel.width
        implicitHeight: panel.height + Theme.px(10)

        // the transparent strip above the panel belongs to this window too, so the
        // pointer can cross the gap between button and popover without it closing
        Item {
            anchors.fill: parent
            HoverHandler { id: popupHover }

            Rectangle {
                id: panel
                y: Theme.px(10)
                width: cells.implicitWidth + Theme.px(16)
                height: cells.implicitHeight + Theme.px(16)
                radius: Theme.px(18)
                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, Math.min(1, Theme.panelOpacity + 0.14))
                border.width: 1
                border.color: Theme.hairline

                Row {
                    id: cells
                    anchors.centerIn: parent
                    spacing: Theme.px(4)

                    Repeater {
                        model: root.items

                        Rectangle {
                            id: cell
                            required property var modelData

                            width: Theme.px(38)
                            height: Theme.px(38)
                            radius: Theme.px(12)
                            color: cellHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.16) : "transparent"

                            IconImage {
                                anchors.centerIn: parent
                                implicitSize: Theme.px(22)
                                source: cell.modelData.icon
                            }

                            HoverHandler { id: cellHover }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton) root.openMenu(cell.modelData, button);
                                    else cell.modelData.activate();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
