import QtQuick
import QtQuick.Layouts
import "../../theme" as Palette

Item {
    id: root

    property string iconSource: ""
    property string iconGlyph: ""
    property real value: 0
    property color accentColor: Palette.Theme.accent

    signal iconClicked
    signal iconRightClicked
    signal valueRequested(real value)

    readonly property real clampedValue: Math.max(0, Math.min(1, root.value))

    implicitWidth: 1
    implicitHeight: 44

    function requestFromX(x) {
        var usable = Math.max(1, track.width - track.iconSize);
        var v = (x - track.iconSize) / usable;
        root.valueRequested(Math.max(0, Math.min(1, v)));
    }

    Item {
        id: track

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: 28

        readonly property real iconSize: root.iconSource !== "" || root.iconGlyph !== "" ? height : 0
        readonly property real usableWidth: Math.max(0, width - iconSize)
        readonly property real fillWidth: iconSize + usableWidth * root.clampedValue

        // background track
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Palette.Theme.surfaceContainer
        }

        // filled pill (covers icon zone, extends to represent value)
        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: Math.max(track.iconSize, track.fillWidth)
            radius: height / 2
            color: root.accentColor

            Behavior on width {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }
        }

        // icon capsule, reserved zone at the left end of the track
        Rectangle {
            width: track.iconSize
            height: parent.height
            radius: width / 2
            // Match the filled track so the circular icon has no seam/gap.
            color: root.accentColor
            visible: root.iconSource !== "" || root.iconGlyph !== ""
            z: 2

            Image {
                anchors.centerIn: parent
                width: 16
                height: 16
                source: root.iconSource
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            Text {
                anchors.centerIn: parent
                visible: root.iconSource === "" && root.iconGlyph !== ""
                text: root.iconGlyph
                color: "#000000"
                font.family: Palette.Theme.fontIcons
                font.pixelSize: 16
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton)
                        root.iconRightClicked();
                    else
                        root.iconClicked();
                }
            }
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            anchors.margins: -10
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton
            preventStealing: true
            onPressed: mouse => root.requestFromX(track.mapFromItem(dragArea, mouse.x, 0).x)
            onPositionChanged: mouse => {
                if (mouse.buttons & Qt.LeftButton)
                    root.requestFromX(track.mapFromItem(dragArea, mouse.x, 0).x);
            }
        }
    }
}
