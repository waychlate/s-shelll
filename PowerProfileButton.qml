import QtQuick
import Quickshell.Services.UPower

// power-profiles-daemon icon: leaf (power saver), half circle (balanced), bolt (performance).
// Click cycles: balanced -> performance -> power saver -> balanced.
Item {
    id: root

    readonly property var profile: PowerProfiles.profile
    readonly property bool saver: profile === PowerProfile.PowerSaver
    readonly property bool perf: profile === PowerProfile.Performance

    implicitWidth: glyph.implicitWidth
    implicitHeight: glyph.implicitHeight

    Glyph {
        id: glyph
        size: Theme.px(20)
        kind: root.saver ? "saver" : (root.perf ? "perf" : "balanced")
        color: root.saver ? Theme.accents[2] : (root.perf ? Theme.accents[0] : Theme.accents[1])
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (root.saver) PowerProfiles.profile = PowerProfile.Balanced;
            else if (root.perf) PowerProfiles.profile = PowerProfile.PowerSaver;
            else PowerProfiles.profile = PowerProfiles.hasPerformanceProfile ? PowerProfile.Performance
                                                                           : PowerProfile.PowerSaver;
        }
    }
}
