import QtQuick
import QtQuick.Layouts
import "../../theme" as Palette

Item {
    id: root

    property string iconSource: ""
    property string iconGlyph: ""
    property real value: 0
    property string label: "0%"

    implicitWidth: 208
    implicitHeight: 40

    RowLayout {
        anchors.fill: parent
        spacing: 12

        Item {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignVCenter

            Image {
                anchors.fill: parent
                source: root.iconSource
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                sourceSize.width: 20
                sourceSize.height: 20
            }

            Text {
                anchors.centerIn: parent
                visible: root.iconSource === "" && root.iconGlyph !== ""
                text: root.iconGlyph
                color: Palette.Theme.textPrimary
                font.family: Palette.Theme.fontIcons
                font.pixelSize: 20
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 8
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
            Layout.preferredWidth: 34
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
