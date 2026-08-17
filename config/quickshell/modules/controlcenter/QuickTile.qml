import QtQuick
import QtQuick.Layouts
import "../../theme" as Palette

Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string iconSource: ""
    property string iconGlyph: ""
    property bool active: false
    property bool compact: false
    property color accentColor: Palette.Theme.accent
    property color activeIconColor: "#000000"
    signal clicked()
    signal rightClicked()

    implicitWidth: 180
    implicitHeight: root.compact ? 76 : 82

    Rectangle {
        anchors.fill: parent
        radius: Palette.Theme.radiusLarge
        color: Palette.Theme.surfaceContainerHighest
        border.width: 0
    }

    Rectangle {
        anchors.fill: parent
        radius: Palette.Theme.radiusLarge
        color: root.accentColor
        opacity: root.active ? 0.12 : 0

        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }
    }

    Rectangle {
        id: iconContainer
        width: 32
        height: 32
        radius: 9
        anchors {
            left: parent.left
            leftMargin: root.compact ? 12 : 10
            top: root.compact ? undefined : parent.top
            topMargin: root.compact ? 0 : 10
            verticalCenter: root.compact ? parent.verticalCenter : undefined
        }
        color: root.active ? root.accentColor : Palette.Theme.surfaceContainer
        border.width: 0

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Image {
            anchors.centerIn: parent
            width: 18
            height: 18
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
            color: root.active ? root.activeIconColor : Palette.Theme.textPrimary
            font.family: Palette.Theme.fontIcons
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    ColumnLayout {
        anchors {
            // In compact mode, anchor to the icon itself. This avoids any
            // overlap when the tile is resized by the right-side column.
            left: root.compact ? iconContainer.right : parent.left
            right: parent.right
            leftMargin: 12
            rightMargin: root.compact ? 10 : 12
            top: root.compact ? undefined : iconContainer.bottom
            topMargin: root.compact ? 0 : 6
            verticalCenter: root.compact ? parent.verticalCenter : undefined
        }
        spacing: 2

        Text {
            text: root.title
            color: root.active ? "#ffffff" : Palette.Theme.textPrimary
            font.family: Palette.Theme.fontMono
            font.pixelSize: 13
            font.weight: root.active ? Font.Medium : Font.Normal
            elide: Text.ElideRight
            Layout.fillWidth: true

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }

    }

    Rectangle {
        anchors.fill: parent
        radius: Palette.Theme.radiusLarge
        color: "#ffffff"
        opacity: tileMouse.containsMouse ? 0.03 : 0

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    MouseArea {
        id: tileMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                root.rightClicked()
            else
                root.clicked()
        }
    }
}
