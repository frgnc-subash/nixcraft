import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../../theme" as Palette

// Picks between the horizontal (top) and vertical (left) bar. Deliberately
// not a search list like ThemePicker/ShaderPicker — there are only ever two
// options, so a couple of plain rows is simpler than reusing that machinery.
Item {
    id: root

    anchors.fill: parent
    visible: false

    required property var service
    property var launcher: null
    property var controlCenter: null
    property var powerMenu: null

    readonly property var options: [
        { value: false, label: "Top", desc: "Horizontal strip along the top edge" },
        { value: true, label: "Left", desc: "Vertical dock along the left edge" }
    ]
    readonly property int itemH: 52

    implicitWidth: 280
    implicitHeight: options.length * itemH + 16

    signal aboutToOpen
    signal aboutToClose

    IpcHandler {
        target: "barlayout"
        function toggle(): void {
            if (root.visible)
                root.close();
            else
                root.open();
        }
        function open(): void {
            root.open();
        }
        function close(): void {
            root.close();
        }
    }

    function select(vertical) {
        service.setVertical(vertical);
        close();
    }

    function open() {
        if (launcher && launcher.visible)
            launcher.closeLauncher(true);
        if (controlCenter && controlCenter.visible)
            controlCenter.closeControlCenter(true);
        if (powerMenu && powerMenu.visible)
            powerMenu.closePowerMenu(true);
        aboutToOpen();
        visible = true;
    }

    function close(immediate) {
        if (!root.visible)
            return;
        aboutToClose();
        if (immediate) {
            closeTimer.stop();
            visible = false;
            return;
        }
        closeTimer.restart();
    }

    Timer {
        id: closeTimer
        interval: 180
        onTriggered: root.visible = false
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        Repeater {
            model: root.options

            delegate: Item {
                id: row
                required property var modelData

                readonly property bool isActive: root.service && modelData.value === root.service.vertical

                Layout.fillWidth: true
                implicitHeight: root.itemH

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: Palette.Theme.surfaceContainerHigh
                    opacity: row.isActive ? 1 : (rowHover.containsMouse ? 0.6 : 0)
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: row.modelData.label
                            color: Palette.Theme.textPrimary
                            font.family: Palette.Theme.fontMono
                            font.pixelSize: 13
                            font.weight: Font.Medium
                        }
                        Text {
                            text: row.modelData.desc
                            color: Palette.Theme.textMuted
                            font.family: Palette.Theme.fontMono
                            font.pixelSize: 10
                        }
                    }

                    Text {
                        visible: row.isActive
                        text: ""
                        font.family: Palette.Theme.fontIcons
                        font.pixelSize: 16
                        color: Palette.Theme.accent
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    id: rowHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.select(row.modelData.value)
                }
            }
        }
    }
}
