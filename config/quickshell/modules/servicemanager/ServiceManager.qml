import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../../components/material"
import "../../components/overlay"
import "../../config/Ui.js" as Ui
import "../../theme" as Palette

Item {
    id: root
    anchors.fill: parent
    visible: false
    focus: visible

    property var entries: []
    property string query: ""
    property int selected: 0
    property bool presented: false
    readonly property var filtered: entries.filter(entry => entry.unit.toLowerCase().indexOf(query.toLowerCase()) !== -1 || entry.description.toLowerCase().indexOf(query.toLowerCase()) !== -1)

    signal aboutToOpen
    signal aboutToClose

    IpcHandler {
        target: "services"
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
        presented = true;
        refresh();
        search.forceActiveFocus();
    }

    function close(immediate) {
        if (!visible)
            return;
        aboutToClose();
        presented = false;
        if (immediate) {
            visible = false;
            return;
        }
        closeTimer.restart();
    }

    function refresh() {
        serviceRead.running = true;
    }

    function parseServices(text) {
        var parsed = [];
        var lines = text.trim() === "" ? [] : text.trim().split("\n");
        for (var i = 0; i < lines.length; ++i) {
            var match = lines[i].trim().match(/^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*(.*)$/);
            if (match)
                parsed.push({
                    unit: match[1],
                    load: match[2],
                    active: match[3],
                    sub: match[4],
                    description: match[5]
                });
        }
        entries = parsed;
    }

    function move(delta) {
        if (filtered.length === 0)
            return;
        selected = Math.max(0, Math.min(filtered.length - 1, selected + delta));
        serviceList.positionViewAtIndex(selected, ListView.Contain);
    }

    function action(unit, operation) {
        serviceAction.exec(["systemctl", "--user", operation, unit]);
    }

    function toggle(entry) {
        action(entry.unit, entry.active === "active" ? "stop" : "start");
    }

    function handleKey(event) {
        if (event.key === Qt.Key_Escape) {
            close();
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            move(-1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            move(1);
            event.accepted = true;
        } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && filtered.length > 0) {
            toggle(filtered[selected]);
            event.accepted = true;
        } else if ((event.key === Qt.Key_R || event.key === Qt.Key_r) && filtered.length > 0) {
            action(filtered[selected].unit, "restart");
            event.accepted = true;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000"
        opacity: root.presented ? 0.30 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 180
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    CenterOverlayCard {
        presented: root.presented
        radius: Palette.Theme.radiusLarge
        width: Math.min(parent.width - 20, 450)
        height: Math.min(parent.height - Ui.overlayTop - 12, 470)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Services"
                    color: Palette.Theme.textTitle
                    font.family: Palette.Theme.fontMono
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                }
                Text {
                    text: root.entries.length + " units"
                    color: Palette.Theme.textMuted
                    font.family: Palette.Theme.fontMono
                    font.pixelSize: 10
                }
                ActionChip {
                    label: "Refresh"
                    onClicked: root.refresh()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: 10
                color: Palette.Theme.surfaceContainerHigh
                border.width: search.activeFocus ? 1 : 0
                border.color: Palette.Theme.accent
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\ue8b6"
                    color: search.activeFocus ? Palette.Theme.accent : Palette.Theme.textMuted
                    font.family: Palette.Theme.fontIcons
                    font.pixelSize: 17
                }
                TextInput {
                    id: search
                    anchors.left: parent.left
                    anchors.leftMargin: 39
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: Palette.Theme.textPrimary
                    font.family: Palette.Theme.fontMono
                    font.pixelSize: 12
                    verticalAlignment: TextInput.AlignVCenter
                    text: root.query
                    selectByMouse: true
                    onTextChanged: {
                        root.query = text;
                        root.selected = 0;
                    }
                    Keys.onPressed: event => root.handleKey(event)
                }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 39
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !search.text && !search.activeFocus
                    text: "Filter user services"
                    color: Palette.Theme.textMuted
                    font.family: Palette.Theme.fontMono
                    font.pixelSize: 12
                }
            }

            ListView {
                id: serviceList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6
                model: root.filtered
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: serviceList.width
                    height: 58
                    radius: 10
                    color: index === root.selected ? Palette.Theme.surfaceContainerHigh : Palette.Theme.surfaceContainerLow
                    border.width: index === root.selected ? 1 : 0
                    border.color: Palette.Theme.accent

                    Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 7
                        height: 7
                        radius: 4
                        color: modelData.active === "active" ? Palette.Theme.success : Palette.Theme.textMuted
                    }
                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.leftMargin: 28
                        anchors.right: actions.left
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1
                        Text {
                            text: modelData.unit
                            color: Palette.Theme.textPrimary
                            font.family: Palette.Theme.fontMono
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            text: modelData.description || modelData.active + " · " + modelData.sub
                            color: Palette.Theme.textMuted
                            font.family: Palette.Theme.fontMono
                            font.pixelSize: 9
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                    RowLayout {
                        id: actions
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4
                        ActionChip {
                            label: modelData.active === "active" ? "Stop" : "Start"
                            onClicked: root.toggle(modelData)
                        }
                        ActionChip {
                            label: "Restart"
                            onClicked: root.action(modelData.unit, "restart")
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        z: -1
                        hoverEnabled: true
                        onEntered: root.selected = index
                    }
                }
            }

        }
    }

    Timer {
        id: closeTimer
        interval: 180
        onTriggered: root.visible = false
    }
    Process {
        id: serviceRead
        command: ["systemctl", "--user", "list-units", "--type=service", "--all", "--no-legend", "--plain", "--no-pager"]
        stdout: StdioCollector {
            onStreamFinished: root.parseServices(text)
        }
    }
    Process {
        id: serviceAction
        onExited: root.refresh()
    }
    Keys.onPressed: event => root.handleKey(event)
}
