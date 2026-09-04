import QtQuick
import QtQuick.Layouts
import "../../theme" as Palette

Item {
    id: root
    required property var bar
    property bool vertical: false
    property bool showPercent: true
    readonly property int percent: bar ? bar.batteryPercent : 0
    readonly property bool charging: bar ? bar.batteryCharging : false
    readonly property bool available: bar ? bar.batteryAvailable : false
    readonly property string iconFontFamily: Palette.Theme.fontIcons || "Material Symbols Outlined"

    readonly property color colorCritical: "#f38ba8" // red
    readonly property color colorLow: "#fab387"       // peach
    readonly property color colorMedium: "#f9e2af"    // yellow
    readonly property color colorGood: "#a6e3a1"      // green
    readonly property color colorCharging: "#89b4fa"  // blue

    readonly property string iconGlyph: {
        if (!available)
            return "";
        if (charging)
            return "battery_charging_full";
        if (percent <= 15)
            return "battery_alert";
        if (percent <= 30)
            return "battery_30";
        if (percent <= 60)
            return "battery_60";
        if (percent <= 90)
            return "battery_90";
        return "battery_std";
    }

    readonly property color iconColor: {
        if (charging)
            return colorCharging;
        if (percent <= 15)
            return colorCritical;
        if (percent <= 30)
            return colorLow;
        if (percent <= 60)
            return colorMedium;
        return colorGood;
    }

    visible: available
    implicitWidth: root.vertical ? Math.max(24, row.implicitWidth) : row.implicitWidth
    implicitHeight: root.vertical ? row.implicitHeight : 30

    GridLayout {
        id: row
        anchors.centerIn: parent
        columns: root.vertical ? 1 : 999
        rowSpacing: 3
        columnSpacing: 5

        Text {
            text: root.iconGlyph
            font.family: root.iconFontFamily
            font.pixelSize: 14
            color: root.iconColor
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }
        Text {
            visible: root.showPercent
            text: root.percent + "%"
            color: root.iconColor
            font.family: Palette.Theme.fontMono
            font.pixelSize: 13
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }
    }
}
