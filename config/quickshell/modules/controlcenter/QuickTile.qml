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
    property bool iconOnly: false
    property color accentColor: Palette.Theme.accent
    property color activeIconColor: "#000000"
    signal clicked()
    signal rightClicked()

    implicitWidth: root.iconOnly ? 62 : 180
    implicitHeight: root.iconOnly ? 62 : (root.compact ? 76 : 82)

    SequentialAnimation {
        id: toggleBounce
        NumberAnimation {
            target: root
            property: "scale"
            to: 1.08
            duration: 100
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root
            property: "scale"
            to: 1
            duration: 220
            easing.type: Easing.OutBack
            easing.overshoot: 3
        }
    }

    onActiveChanged: toggleBounce.restart()

    Rectangle {
        anchors.fill: parent
        radius: Palette.Theme.radiusMedium
        color: root.iconOnly && root.active ? root.accentColor : Palette.Theme.surfaceContainerHighest
        border.width: 0

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Rectangle {
        visible: !root.iconOnly
        anchors.fill: parent
        radius: Palette.Theme.radiusMedium
        color: root.accentColor
        opacity: root.active ? 0.12 : 0

        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }
    }

    Text {
        visible: root.iconOnly
        anchors.centerIn: parent
        text: root.iconGlyph
        color: root.active ? root.activeIconColor : Palette.Theme.textMuted
        font.family: Palette.Theme.fontIcons
        font.pixelSize: 22
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Rectangle {
        id: iconContainer
        visible: !root.iconOnly
        width: 36
        height: 36
        radius: 11

        anchors {
            left: parent.left
            leftMargin: root.compact ? 12 : 11
            top: root.compact ? undefined : parent.top
            topMargin: root.compact ? 0 : 11
            verticalCenter: root.compact ? parent.verticalCenter : undefined
        }
        color: root.active ? root.accentColor : Palette.Theme.surfaceContainer
        border.width: 0

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Image {
            anchors.centerIn: parent
            width: 24
            height: 24
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
            font.pixelSize: 22

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    ColumnLayout {
        visible: !root.iconOnly
        anchors {
            // In compact mode, anchor to the icon itself. This avoids any
            // overlap when the tile is resized by the right-side column.
            left: root.compact ? iconContainer.right : parent.left
            right: parent.right
            leftMargin: 13
            rightMargin: root.compact ? 12 : 12
            top: root.compact ? undefined : iconContainer.bottom
            topMargin: root.compact ? 0 : 8
            verticalCenter: root.compact ? parent.verticalCenter : undefined
        }
        spacing: 1

        Text {
            text: root.title
            color: root.active ? "#ffffff" : Palette.Theme.textPrimary
            font.family: Palette.Theme.fontMono
            font.pixelSize: 13
            font.weight: root.active ? Font.DemiBold : Font.Medium
            elide: Text.ElideRight
            Layout.fillWidth: true

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }

        Text {
            visible: root.subtitle !== ""
            text: root.subtitle
            color: root.active ? Qt.lighter(root.accentColor, 1.35) : Palette.Theme.textMuted
            font.family: Palette.Theme.fontMono
            font.pixelSize: 10
            elide: Text.ElideRight
            Layout.fillWidth: true

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Palette.Theme.radiusMedium
        color: "#ffffff"
        opacity: tileMouse.containsMouse ? 0.04 : 0

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
