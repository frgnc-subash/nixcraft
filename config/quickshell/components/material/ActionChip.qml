import QtQuick
import QtQuick.Layouts
import "../../theme" as Palette

Rectangle {
    id: root

    required property string label
    property bool active: false
    signal clicked

    implicitHeight: 28
    implicitWidth: chipText.implicitWidth + 20
    radius: height / 2
    color: root.active ? Palette.Theme.primaryContainer : (actionMouse.containsMouse ? Palette.Theme.secondaryContainerHover : Palette.Theme.secondaryContainer)

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    SequentialAnimation {
        id: pressBounce
        NumberAnimation {
            target: root
            property: "scale"
            to: 0.92
            duration: 80
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root
            property: "scale"
            to: 1
            duration: 200
            easing.type: Easing.OutBack
            easing.overshoot: 3
        }
    }

    Text {
        id: chipText
        anchors.centerIn: parent
        text: root.label
        color: root.active ? Palette.Theme.primaryText : Palette.Theme.secondaryText
        font.family: Palette.Theme.fontMono
        font.pixelSize: 11
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    MouseArea {
        id: actionMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            pressBounce.restart();
            root.clicked();
        }
    }
}
