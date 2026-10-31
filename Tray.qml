import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets

// System tray, Windows-style:
//   0 apps  -> nothing
//   1 app   -> that app's own icon
//   2+ apps -> one chevron button; hovering it opens a popover with all of them
// Right-click any tray icon for its menu (Figma: "Bar – tray context menu").
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
        } else if (!menuItem) {
            closeTimer.restart();
        }
    }
    Timer {
        id: closeTimer
        interval: 250
        onTriggered: root.shown = false
    }

    // ---- right-click menu state ----
    property var menuItem: null          // SystemTrayItem whose menu is open
    property Item menuAnchor: null
    property bool menuAlignRight: false

    function openMenu(item, anchorItem, alignRight) {
        menuAnchor = anchorItem;
        menuAlignRight = alignRight;
        menuItem = item;
    }
    function closeMenu() {
        menuItem = null;
        if (!hovering) closeTimer.restart();
    }
    function quitApp(item) {
        Quickshell.execDetached(["sh", Quickshell.shellPath("tray-quit.sh"), item.id]);
    }

    // ---- the button in the bar ----
    Rectangle {
        id: button
        width: Theme.px(28)
        height: Theme.px(28)
        radius: Theme.px(10)
        color: (root.count > 1 && root.shown) || btnHover.hovered || (root.count === 1 && root.menuItem)
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
                if (mouse.button === Qt.RightButton) root.openMenu(it, button, true);
                else it.activate();
            }
        }
    }

    // ---- popover with every tray app ----
    PopupWindow {
        visible: (root.shown || root.menuItem !== null) && root.count > 1
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
                            color: cellHover.hovered || root.menuItem === cell.modelData ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.16) : "transparent"

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
                                    if (mouse.button === Qt.RightButton) root.openMenu(cell.modelData, cell, false);
                                    else cell.modelData.activate();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ---- right-click menu: the app's own entries, then our Quit ----
    PopupWindow {
        id: menuWin
        visible: root.menuItem !== null && root.menuAnchor !== null
        color: "transparent"

        anchor.item: root.menuAnchor
        anchor.edges: Edges.Bottom | (root.menuAlignRight ? Edges.Right : Edges.Left)
        anchor.gravity: Edges.Bottom | (root.menuAlignRight ? Edges.Left : Edges.Right)

        // the grab only takes once the popup is actually mapped, so arm it a beat after showing
        onVisibleChanged: if (visible) armGrab.restart(); else grab.active = false
        Timer { id: armGrab; interval: 50; onTriggered: grab.active = true }
        implicitWidth: menuPanel.width
        implicitHeight: menuPanel.height + Theme.px(8)

        // click outside closes it
        HyprlandFocusGrab {
            id: grab
            windows: [menuWin]
            onCleared: root.closeMenu()
        }

        QsMenuOpener {
            id: opener
            menu: root.menuItem && root.menuItem.hasMenu ? root.menuItem.menu : null
        }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: root.closeMenu()

            Rectangle {
                id: menuPanel
                y: Theme.px(8)
                width: Theme.px(224)
                height: menuCol.implicitHeight + Theme.px(12)
                radius: Theme.px(14)
                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.92)
                border.width: 1
                border.color: Theme.hairline

                ColumnLayout {
                    id: menuCol
                    x: Theme.px(6)
                    y: Theme.px(6)
                    width: parent.width - Theme.px(12)
                    spacing: 0

                    // header: app icon + name
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: Theme.px(10)
                        Layout.rightMargin: Theme.px(10)
                        Layout.preferredHeight: Theme.px(34)
                        spacing: Theme.px(10)
                        IconImage {
                            implicitSize: Theme.px(16)
                            source: root.menuItem ? root.menuItem.icon : ""
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.menuItem ? (root.menuItem.title || root.menuItem.tooltipTitle || root.menuItem.id) : ""
                            elide: Text.ElideRight
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.px(15)
                            font.weight: Font.DemiBold
                            color: Theme.fg
                        }
                    }

                    TrayMenuEntry { Layout.fillWidth: true; entry: ({ isSeparator: true }) }

                    Repeater {
                        model: opener.children
                        TrayMenuEntry {
                            required property var modelData
                            Layout.fillWidth: true
                            entry: modelData
                            onActivated: root.closeMenu()
                        }
                    }

                    TrayMenuEntry {
                        visible: opener.children.values.length > 0
                        Layout.fillWidth: true
                        entry: ({ isSeparator: true })
                    }

                    TrayMenuEntry {
                        Layout.fillWidth: true
                        danger: true
                        entry: ({
                            text: "Quit", enabled: true, isSeparator: false, hasChildren: false,
                            buttonType: QsMenuButtonType.None, checkState: Qt.Unchecked,
                            triggered: () => root.quitApp(root.menuItem)
                        })
                        onActivated: root.closeMenu()
                    }
                }
            }
        }
    }
}
