import QtQuick
import QtQuick.Layouts
import "../../theme" as Palette

Item {
    id: root

    property string kind: "volume"
    property real value: 0
    property string label: "0%"
    readonly property bool showMeter: kind === "volume" || kind === "brightness"
    readonly property string iconGlyph: kind === "brightness" ? (value < 0.5 ? "\ue1ab" : "\ue1ac") : (label === "Muted" || value <= 0.01 ? "\ue04f" : value < 0.5 ? "\ue04d" : "\ue050")

    implicitHeight: root.showMeter ? 24 : lockText.implicitHeight
    implicitWidth: root.showMeter ? 232 : lockText.implicitWidth + 20

    RowLayout {
        id: content
        anchors.fill: parent
        spacing: 12
        visible: root.showMeter

        Item {
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.fill: parent
                text: root.iconGlyph
                color: Palette.Theme.textPrimary
                font.family: Palette.Theme.fontIcons
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            id: track
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            radius: height / 2
            color: Palette.Theme.surfaceContainerHighest
            clip: true
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: parent.width * Math.max(0, Math.min(1, root.value))
                radius: height / 2
                color: Palette.Theme.accent

                Behavior on width {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        Text {
            text: root.label
            color: Palette.Theme.textPrimary
            font.family: Palette.Theme.fontMono
            font.pixelSize: 12
            horizontalAlignment: Text.AlignRight
            Layout.preferredWidth: 40
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Text {
        id: lockText
        anchors.centerIn: parent
        visible: !root.showMeter
        text: (root.kind === "capsLock" ? "Caps Lock " : "Num Lock ") + root.label
        color: Palette.Theme.textPrimary
        font.family: Palette.Theme.fontMono
        font.pixelSize: 12
    }
}
