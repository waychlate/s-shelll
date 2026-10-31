import QtQuick
import QtQuick.Layouts
import Quickshell

// One row of a tray menu (Figma: "Tray menu item"): a separator, a normal or
// checkable item, or a submenu. Submenus expand inline, indented, below their row.
ColumnLayout {
    id: root

    property var entry: null        // QsMenuEntry, or a plain object with the same fields
    property int depth: 0
    property bool danger: false     // rose text, for Quit
    property bool expanded: false
    signal activated()

    spacing: 0

    // DBus menus mark keyboard mnemonics with "_" ("_Quit"); "__" is a literal underscore
    function label(t) { return (t || "").replace(/_(_)?/g, "$1") }

    Item {
        visible: !!(root.entry && root.entry.isSeparator)
        Layout.fillWidth: true
        implicitHeight: Theme.px(9)
        Rectangle {
            anchors.centerIn: parent
            width: parent.width - Theme.px(12)
            height: 1
            color: Qt.rgba(1, 1, 1, 0.09)
        }
    }

    Rectangle {
        id: row
        visible: !!(root.entry && !root.entry.isSeparator)
        readonly property bool hot: !!(hover.hovered && root.entry && root.entry.enabled)
        readonly property color ink: root.danger ? Theme.hot : hot ? Theme.accent : Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.9)

        Layout.fillWidth: true
        implicitHeight: Theme.px(34)
        radius: Theme.px(9)
        color: hot ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.16) : "transparent"
        opacity: root.entry && root.entry.enabled ? 1 : 0.35

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.px(10) + root.depth * Theme.px(14)
            anchors.rightMargin: Theme.px(10)
            spacing: Theme.px(10)

            // leading slot: check mark for checked toggles / radio items
            Item {
                implicitWidth: Theme.px(16)
                implicitHeight: Theme.px(16)
                Glyph {
                    visible: root.entry && root.entry.buttonType !== QsMenuButtonType.None
                             && root.entry.checkState === Qt.Checked
                    kind: "check"
                    size: Theme.px(16)
                    color: Theme.accent
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.label(root.entry ? root.entry.text : "")
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(15)
                color: row.ink
            }

            Glyph {
                visible: !!(root.entry && root.entry.hasChildren)
                kind: root.expanded ? "chevDown" : "chevRight"
                size: Theme.px(14)
                color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.5)
            }
        }

        HoverHandler { id: hover }

        MouseArea {
            anchors.fill: parent
            enabled: !!(root.entry && root.entry.enabled)
            onClicked: {
                if (root.entry.hasChildren) {
                    root.expanded = !root.expanded;
                } else {
                    root.entry.triggered();
                    root.activated();
                }
            }
        }
    }

    // submenu entries, rendered with this same component
    Loader {
        active: root.expanded
        Layout.fillWidth: true
        sourceComponent: ColumnLayout {
            spacing: 0
            QsMenuOpener { id: sub; menu: root.entry }
            Repeater {
                model: sub.children
                Loader {
                    required property var modelData
                    Layout.fillWidth: true
                    Component.onCompleted: setSource("TrayMenuEntry.qml", { entry: modelData, depth: root.depth + 1 })
                    onLoaded: item.activated.connect(root.activated)
                }
            }
        }
    }
}
