import QtQuick
import QtQuick.Layouts

// Power profile · volume · brightness · Wi-Fi · battery.
// The power profile button is loaded separately so that if your Quickshell build
// doesn't have the power-profiles API, only that icon is missing, not the whole bar.
RowLayout {
    spacing: Theme.px(14)

    Loader {
        source: "PowerProfileButton.qml"
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: item ? item.implicitWidth : 0
        Layout.preferredHeight: item ? item.implicitHeight : 0
    }

    VolumeButton { Layout.alignment: Qt.AlignVCenter }

    BrightnessButton { Layout.alignment: Qt.AlignVCenter }

    WifiButton { Layout.alignment: Qt.AlignVCenter }

    BatteryIndicator { Layout.alignment: Qt.AlignVCenter }
}
