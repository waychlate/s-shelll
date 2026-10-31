import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Overheat toast (Figma: "Overheat OSD"). Polls the CPU sensor; when it reaches
// Theme.heatLimit it shows a toast under the bar for a few seconds. It re-arms
// only after the CPU cools below Theme.heatClear and the cooldown has passed,
// so it doesn't nag while the temperature bounces around the limit.
// Test it:  qs -p <this folder> ipc call heat fake 85   (then: fake 60, fake -1 to stop faking)
Scope {
    id: root

    property string sensorPath: ""
    property real temp: 0
    property real fakeTemp: -1
    property bool armed: true
    property bool shown: false
    property double lastShown: 0

    readonly property real current: fakeTemp >= 0 ? fakeTemp : temp

    onCurrentChanged: {
        if (current < Theme.heatClear) {
            armed = true;
        } else if (armed && current >= Theme.heatLimit
                   && Date.now() - lastShown > Theme.heatCooldown * 1000) {
            armed = false;
            lastShown = Date.now();
            shown = true;
            hideTimer.restart();
        }
    }

    IpcHandler {
        target: "heat"
        function fake(c: real): void { root.fakeTemp = c }
    }

    // hwmon numbers change between boots, so find the CPU sensor by name
    // (k10temp = AMD, coretemp = Intel)
    Process {
        running: true
        command: ["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do case $(cat $h/name) in k10temp|coretemp) echo $h/temp1_input; exit;; esac; done"]
        stdout: StdioCollector { onStreamFinished: root.sensorPath = text.trim() }
    }

    FileView {
        id: sensor
        path: root.sensorPath
        onLoaded: root.temp = parseInt(text()) / 1000
    }

    Timer {
        interval: 3000
        repeat: true
        running: root.sensorPath !== ""
        triggeredOnStart: true
        onTriggered: sensor.reload()
    }

    Timer {
        id: hideTimer
        interval: 6000
        onTriggered: root.shown = false
    }

    LazyLoader {
        active: root.shown

        PanelWindow {
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "shadow-osd"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors.top: true
            margins.top: Theme.px(16) + Theme.barHeight + Theme.px(12)
            implicitWidth: Theme.px(364)
            implicitHeight: Theme.px(93)

            Rectangle {
                anchors.fill: parent
                radius: Theme.px(24)
                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.92)
                border.width: 1
                border.color: Qt.rgba(Theme.hot.r, Theme.hot.g, Theme.hot.b, 0.55)

                opacity: 0
                NumberAnimation on opacity { to: 1; duration: 180 }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.px(15)
                    anchors.rightMargin: Theme.px(25)
                    spacing: Theme.px(16)

                    // thermometer badge
                    Rectangle {
                        implicitWidth: Theme.px(44)
                        implicitHeight: Theme.px(44)
                        radius: width / 2
                        color: Qt.rgba(Theme.hot.r, Theme.hot.g, Theme.hot.b, 0.18)
                        Glyph {
                            anchors.centerIn: parent
                            kind: "therm"
                            size: Theme.px(22)
                            color: Theme.hot
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.px(6)

                        Text {
                            text: "Running hot"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.px(18)
                            font.weight: Font.DemiBold
                            color: Theme.fg
                        }

                        // gauge: 0..100°C
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: Theme.px(6)
                            radius: height / 2
                            color: Qt.rgba(1, 1, 1, 0.1)
                            Rectangle {
                                width: parent.width * Math.min(1, root.current / 100)
                                height: parent.height
                                radius: height / 2
                                color: Theme.hot
                            }
                        }

                        Text {
                            text: "CPU · limit " + Theme.heatLimit + "°C"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.px(12)
                            color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.55)
                        }
                    }

                    Text {
                        text: Math.round(root.current) + "°"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.px(38)
                        color: Theme.hot
                    }
                }
            }
        }
    }
}
