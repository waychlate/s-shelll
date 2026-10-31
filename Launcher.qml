import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

// Simple tile launcher: a search line and a few app tiles.
// Toggle from Hyprland:  qs -p <this folder> ipc call launcher toggle
Scope {
    id: root
    property bool open: false

    IpcHandler {
        target: "launcher"
        function toggle(): void { root.open = !root.open }
        function show(): void { root.open = true }
        function hide(): void { root.open = false }
    }

    // Launch counts per desktop entry id, kept in ~/.local/state/quickshell/by-shell/<id>/usage.json
    FileView {
        id: usageFile
        path: Quickshell.statePath("usage.json")
        blockLoading: true
        onLoadFailed: error => { if (error === FileViewError.FileNotFound) writeAdapter() }
        JsonAdapter {
            id: usage
            property var counts: ({})
        }
    }

    LazyLoader {
        active: root.open

        PanelWindow {
            id: win

            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "shadow-launcher"   // used by the Hyprland blur rule
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            // no anchors = centered on the screen by the layer shell
            readonly property real s: Theme.uiScale
            implicitWidth: 640 * s
            implicitHeight: content.implicitHeight + 48 * s

            property int selected: 0
            property bool navigated: false
            property var results: compute(input.text)

            function compute(query) {
                const all = DesktopEntries.applications.values;
                const q = query.trim().toLowerCase();
                const count = e => usage.counts[e.id] || 0;

                if (q === "") {
                    // most launched first, then pinned apps to fill the row
                    const used = all.filter(e => !e.noDisplay && count(e) > 0)
                                    .sort((a, b) => count(b) - count(a));
                    const pinned = Theme.pinned
                        .map(id => all.filter(e => e.id.toLowerCase().indexOf(id.toLowerCase()) >= 0
                                                || e.name.toLowerCase() === id.toLowerCase())[0])
                        .filter(e => e && used.indexOf(e) < 0);
                    return used.concat(pinned).slice(0, Theme.tileCount);
                }

                return all
                    .filter(e => !e.noDisplay && e.name.toLowerCase().indexOf(q) >= 0)
                    .sort((a, b) => {
                        const as = a.name.toLowerCase().indexOf(q) === 0 ? 0 : 1;
                        const bs = b.name.toLowerCase().indexOf(q) === 0 ? 0 : 1;
                        if (as !== bs) return as - bs;
                        return count(b) - count(a) || a.name.localeCompare(b.name);
                    })
                    .slice(0, Theme.tileCount);
            }

            function launch(entry) {
                const e = entry || results[selected];
                if (!e) return;
                const c = Object.assign({}, usage.counts);
                c[e.id] = (c[e.id] || 0) + 1;
                usage.counts = c;
                usageFile.writeAdapter();
                e.execute();
                root.open = false;
            }

            Component.onCompleted: input.forceActiveFocus()

            // ---- panel ----
            Rectangle {
                anchors.fill: parent
                radius: Theme.panelRadius
                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, Theme.panelOpacity)
                border.width: 1
                border.color: Theme.hairline

                ColumnLayout {
                    id: content
                    anchors.fill: parent
                    anchors.margins: 24 * win.s
                    spacing: 18 * win.s

                    // ---- search row ----
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 4 * win.s
                        Layout.rightMargin: 4 * win.s

                        TextInput {
                            id: input
                            Layout.fillWidth: true
                            color: Theme.fg
                            font.family: Theme.fontFamily
                            font.pixelSize: 24 * win.s
                            clip: true
                            cursorDelegate: Rectangle {
                                width: 2.5 * win.s; radius: 1; color: Theme.accent
                                // blink: hold, fade out, hold, fade in
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    PauseAnimation { duration: 450 }
                                    NumberAnimation { to: 0; duration: 120 }
                                    PauseAnimation { duration: 350 }
                                    NumberAnimation { to: 1; duration: 120 }
                                }
                            }

                            onTextChanged: { win.selected = 0; win.navigated = false }

                            Text {
                                visible: input.text === ""
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Start typing to search"
                                font: input.font
                                color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.4)
                            }

                            Keys.onPressed: event => {
                                const n = win.results.length;
                                if (event.key === Qt.Key_Escape) {
                                    root.open = false;
                                } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
                                    win.selected = Math.min(win.selected + 1, n - 1);
                                    win.navigated = true;
                                } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Backtab) {
                                    win.selected = Math.max(win.selected - 1, 0);
                                    win.navigated = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    win.launch();
                                } else {
                                    return;
                                }
                                event.accepted = true;
                            }
                        }

                        // magnifier icon
                        Canvas {
                            Layout.preferredWidth: 28 * win.s
                            Layout.preferredHeight: 28 * win.s
                            onPaint: {
                                const c = getContext("2d");
                                c.reset();
                                c.scale(win.s, win.s);
                                c.strokeStyle = input.text === "" ? "#8A8A8A" : Theme.accent;
                                c.lineWidth = 2.1;
                                c.lineCap = "round";
                                c.beginPath(); c.arc(12, 12, 7.6, 0, 2 * Math.PI); c.stroke();
                                c.beginPath(); c.moveTo(18.5, 18.5); c.lineTo(24, 24); c.stroke();
                            }
                            Connections {
                                target: input
                                function onTextChanged() { parent.requestPaint() }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Theme.hairline
                    }

                    // ---- tiles ----
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 14 * win.s

                        Repeater {
                            model: win.results

                            Rectangle {
                                id: tile
                                required property var modelData
                                required property int index
                                readonly property bool isSel: (input.text !== "" || win.navigated) && index === win.selected

                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                Layout.preferredHeight: 140 * win.s
                                radius: Theme.tileRadius
                                color: isSel ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.16) : Theme.tileFill
                                border.width: isSel ? 1 : 0
                                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.6)

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18 * win.s

                                    IconImage {
                                        implicitSize: 28 * win.s
                                        source: Quickshell.iconPath(tile.modelData.icon, "application-x-executable")
                                    }

                                    Item { Layout.fillHeight: true }

                                    Text {
                                        Layout.fillWidth: true
                                        text: tile.modelData.name
                                        elide: Text.ElideRight
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 17 * win.s
                                        font.weight: tile.isSel ? Font.DemiBold : Font.Normal
                                        color: tile.isSel ? Theme.accent : Theme.fg
                                        opacity: tile.isSel ? 1 : 0.85
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: { win.selected = tile.index; win.navigated = true }
                                    onClicked: win.launch(tile.modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
