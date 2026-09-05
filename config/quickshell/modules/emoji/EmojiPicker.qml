import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../../config/Ui.js" as Ui
import "../../theme" as Palette

Item {
    id: root
    anchors.fill: parent
    visible: false
    focus: visible

    required property var service
    property real maxWidth: 4000
    property real maxHeight: 4000
    property string query: ""
    property int selected: 0
    readonly property int columns: 8
    readonly property var entries: service ? service.entries.filter(entry => entry.name.toLowerCase().indexOf(query.toLowerCase()) !== -1) : []

    implicitWidth: Math.min(maxWidth - 20, Ui.clipboardOverlayWidth)
    implicitHeight: Math.min(maxHeight - 12, 390)

    signal aboutToOpen
    signal aboutToClose

    IpcHandler {
        target: "emoji"
        function toggle(): void {
            root.visible ? root.close() : root.open();
        }
        function open(): void {
            root.open();
        }
        function close(): void {
            root.close();
        }
    }

    function open() {
        query = "";
        selected = 0;
        aboutToOpen();
        visible = true;
        search.forceActiveFocus();
    }
    function close(immediate) {
        if (!visible)
            return;
        aboutToClose();
        if (immediate) {
            closeTimer.stop();
            visible = false;
            return;
        }
        closeTimer.restart();
    }
    function pick(index) {
        if (index >= 0 && index < entries.length) {
            var entry = entries[index];
            copyProcess.exec(["sh", "-c", "printf '%s' \"$1\" | wl-copy && notify-send 'Copied to Clipboard' \"$1\"", "emoji-copy", entry.char]);
            close();
        }
    }
    function move(delta) {
        if (entries.length)
            selected = Math.max(0, Math.min(entries.length - 1, selected + delta));
    }
    function handleKey(event) {
        if (event.key === Qt.Key_Escape) {
            close();
            event.accepted = true;
        } else if (event.key === Qt.Key_Left) {
            move(-1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            move(1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            move(-root.columns);
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            move(root.columns);
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            pick(selected);
            event.accepted = true;
        }
    }

    Process {
        id: copyProcess
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 14
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.bottomMargin: 22
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Emoji"
                color: Palette.Theme.textTitle
                font.family: Palette.Theme.fontMono
                font.pixelSize: 16
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }
            Text {
                text: root.entries.length + " results"
                color: Palette.Theme.textMuted
                font.family: Palette.Theme.fontMono
                font.pixelSize: 10
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            Layout.minimumHeight: 46
            Layout.maximumHeight: 46
            radius: 16
            color: Palette.Theme.surfaceContainerHigh
            border.width: search.activeFocus ? 1 : 0
            border.color: Palette.Theme.accent

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 13
                anchors.verticalCenter: parent.verticalCenter
                text: ""
                color: search.activeFocus ? Palette.Theme.accent : Palette.Theme.textMuted
                font.family: Palette.Theme.fontIcons
                font.pixelSize: 18
            }
            TextInput {
                id: search
                anchors.left: parent.left
                anchors.leftMargin: 42
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: Palette.Theme.textPrimary
                font.family: Palette.Theme.fontMono
                font.pixelSize: 13
                verticalAlignment: TextInput.AlignVCenter
                selectByMouse: true
                text: root.query
                onTextChanged: {
                    root.query = text;
                    root.selected = 0;
                }
                Keys.onPressed: function (event) {
                    root.handleKey(event);
                }
            }
            Text {
                anchors.left: parent.left
                anchors.leftMargin: 42
                anchors.verticalCenter: parent.verticalCenter
                visible: !search.text && !search.activeFocus
                text: "Search emoji"
                color: Palette.Theme.textMuted
                font.family: Palette.Theme.fontMono
                font.pixelSize: 13
            }
        }
        GridView {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            cellWidth: width / root.columns
            cellHeight: cellWidth
            model: root.entries
            delegate: Item {
                required property var modelData
                required property int index
                width: grid.cellWidth
                height: grid.cellHeight
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 3
                    radius: 10
                    color: index === root.selected ? Palette.Theme.surfaceContainerHigh : "transparent"
                    border.width: index === root.selected ? 2 : 0
                    border.color: Palette.Theme.accent

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.width { NumberAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.char
                        font.pixelSize: 22
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: root.selected = index
                        onClicked: root.pick(index)
                    }
                }
            }
        }
        Text {
            Layout.fillWidth: true
            visible: entries.length === 0
            text: "No matching emoji"
            color: Palette.Theme.textMuted
            font.family: Palette.Theme.fontMono
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            Layout.fillWidth: true
            visible: entries.length > 0 && selected >= 0 && selected < entries.length
            text: entries.length > 0 && selected < entries.length ? entries[selected].name : ""
            color: Palette.Theme.textMuted
            font.family: Palette.Theme.fontMono
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
        }
    }
    Timer {
        id: closeTimer
        interval: 180
        onTriggered: root.visible = false
    }
    Keys.onPressed: function (event) {
        root.handleKey(event);
    }
}
