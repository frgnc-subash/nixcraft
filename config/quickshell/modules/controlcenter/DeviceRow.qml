import QtQuick
import QtQuick.Layouts
import "../../theme" as Palette

Item {
    id: root

    property string iconSource: ""
    property string iconGlyph: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    signal clicked

    implicitWidth: 1
    implicitHeight: 46

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: rowMouse.containsMouse ? Palette.Theme.surfaceContainerHigh : "transparent"
        border.width: 0

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        Rectangle {
            implicitWidth: 28
            implicitHeight: 28
            radius: 14
            color: root.active ? Palette.Theme.surfaceContainerHighest : Palette.Theme.surfaceContainerHigh
            Layout.alignment: Qt.AlignVCenter

            Image {
                anchors.centerIn: parent
                width: 15
                height: 15
                source: root.iconSource
                visible: root.iconSource !== ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            Text {
                anchors.centerIn: parent
                visible: root.iconSource === "" && root.iconGlyph !== ""
                text: root.iconGlyph
                color: root.active ? Palette.Theme.info : Palette.Theme.textSecondary
                font.family: Palette.Theme.fontIcons
                font.pixelSize: 17
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: root.title
                color: Palette.Theme.textPrimary
                font.family: Palette.Theme.fontMono
                font.pixelSize: 12
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: root.subtitle
                color: Palette.Theme.textMuted
                font.family: Palette.Theme.fontMono
                font.pixelSize: 10
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: text !== ""
            }
        }
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
