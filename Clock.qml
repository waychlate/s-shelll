import QtQuick
import QtQuick.Layouts
import Quickshell

// "Sat, Oct 31 · 03:49" (24-hour, formats come from Theme)
RowLayout {
    spacing: Theme.px(10)

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        text: Qt.formatDateTime(clock.date, Theme.dateFormat)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(15)
        color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.55)
        Layout.alignment: Qt.AlignVCenter
    }

    Rectangle {
        implicitWidth: Theme.px(4)
        implicitHeight: Theme.px(4)
        radius: width / 2
        color: Theme.accent
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        text: Qt.formatDateTime(clock.date, Theme.timeFormat)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(17)
        font.weight: Font.DemiBold
        color: Theme.fg
        Layout.alignment: Qt.AlignVCenter
    }
}
