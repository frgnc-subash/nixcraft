import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../../components/material"
import "../../components/overlay"
import "../../theme" as Palette

Item {
    id: root

    anchors.fill: parent
    visible: false
    focus: visible
    property bool presented: false

    property var launcher: null
    property var controlCenter: null
    property int selectedIndex: 0
    property string confirmAction: ""
    property bool confirmChoiceSelected: false

    signal aboutToOpen
    signal aboutToClose

    readonly property var actions: [
        {
            name: "Lock",
            icon: "\ue897",
            command: ["qs", "ipc", "call", "lockscreen", "lock"]
        },
        {
            name: "Sleep",
            icon: "\ue51c",
            command: ["systemctl", "suspend"]
        },
        {
            name: "Logout",
            icon: "\ue9ba",
            command: ["uwsm", "stop"]
        },
        {
            name: "Reboot",
            icon: "\ue5d5",
            command: ["systemctl", "reboot"],
            dangerous: true
        },
        {
            name: "Shutdown",
            icon: "\ue8ac",
            command: ["systemctl", "poweroff"],
            dangerous: true
        }
    ]

    IpcHandler {
        target: "powermenu"
        function toggle(): void {
            root.togglePowerMenu();
        }
        function open(): void {
            root.openPowerMenu();
        }
        function close(): void {
            root.closePowerMenu();
        }
    }

    function openPowerMenu() {
        if (launcher && launcher.visible && typeof launcher.closeLauncher === "function")
            launcher.closeLauncher(true);
        if (controlCenter && controlCenter.visible && typeof controlCenter.closeControlCenter === "function")
            controlCenter.closeControlCenter(true);
        if (visible)
            return;
        selectedIndex = 0;
        confirmAction = "";
        confirmChoiceSelected = false;
        aboutToOpen();
        visible = true;
        appear.restart();
        forceActiveFocus();
    }

    function closePowerMenu(immediate) {
        if (!visible)
            return;
        confirmAction = "";
        aboutToClose();
        if (immediate) {
            appear.stop();
            hide.stop();
            presented = false;
            visible = false;
            return;
        }
        presented = false;
        hide.restart();
    }

    function togglePowerMenu() {
        if (visible)
            closePowerMenu();
        else
            openPowerMenu();
    }

    function choose(index) {
        var action = actions[index];
        if (action.dangerous) {
            confirmAction = action.name;
            // Enter must not perform a destructive action by default.
            confirmChoiceSelected = false;
            return;
        }
        run(action);
    }

    function run(action) {
        closePowerMenu(true);
        actionProcess.exec(action.command);
    }

    function confirm() {
        for (var i = 0; i < actions.length; i++) {
            if (actions[i].name === confirmAction) {
                run(actions[i]);
                return;
            }
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            event.accepted = true;
            if (confirmAction !== "")
                confirmAction = "";
            else
                closePowerMenu();
        } else if (confirmAction !== "" && (event.key === Qt.Key_Left || event.key === Qt.Key_Right)) {
            event.accepted = true;
            confirmChoiceSelected = !confirmChoiceSelected;
        } else if (confirmAction !== "" && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
            event.accepted = true;
            if (confirmChoiceSelected)
                confirm();
            else
                confirmAction = "";
        } else if (confirmAction === "" && event.key === Qt.Key_Left) {
            event.accepted = true;
            selectedIndex = (selectedIndex + actions.length - 1) % actions.length;
        } else if (confirmAction === "" && event.key === Qt.Key_Right) {
            event.accepted = true;
            selectedIndex = (selectedIndex + 1) % actions.length;
        } else if (confirmAction === "" && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
            event.accepted = true;
            choose(selectedIndex);
        }
    }

    Process {
        id: actionProcess
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.presented ? 0.30 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 180
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.closePowerMenu()
        }
    }

    CenterOverlayCard {
        id: card
        presented: root.presented
        width: Math.min(parent.width - 24, confirmAction === "" ? 262 : 220)
        height: content.implicitHeight + 16
        radius: 16

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6
                visible: confirmAction === ""

                Repeater {
                    model: root.actions

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        Layout.minimumWidth: 44
                        Layout.preferredWidth: 44
                        Layout.maximumWidth: 44
                        implicitHeight: 44
                        radius: 8
                        color: index === root.selectedIndex ? Palette.Theme.accent : Palette.Theme.surfaceContainerLow
                        border.width: 0

                        Item {
                            anchors.fill: parent

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: index === root.selectedIndex ? "#000000" : (modelData.dangerous ? "#ff8a80" : Palette.Theme.textPrimary)
                                font.family: Palette.Theme.fontIcons
                                font.pixelSize: 18
                            }
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.selectedIndex = index
                            onClicked: root.choose(index)
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: confirmAction !== ""
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: 8
                        color: root.confirmChoiceSelected ? Palette.Theme.accent : Palette.Theme.surfaceContainerLow

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "\ue5ca"
                                color: root.confirmChoiceSelected ? Palette.Theme.accentText : Palette.Theme.textPrimary
                                font.family: Palette.Theme.fontIcons
                                font.pixelSize: 16
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: confirmAction
                                color: root.confirmChoiceSelected ? Palette.Theme.accentText : Palette.Theme.textPrimary
                                font.family: Palette.Theme.fontMono
                                font.pixelSize: 9
                            }
                        }

                        MouseArea {
                            id: confirmMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.confirmChoiceSelected = true
                            onClicked: root.confirm()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: 8
                        // The primary background follows keyboard/mouse focus,
                        // including the X/Cancel choice.
                        color: !root.confirmChoiceSelected ? Palette.Theme.accent : Palette.Theme.surfaceContainerLow

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "\ue5cd"
                                color: !root.confirmChoiceSelected ? Palette.Theme.accentText : Palette.Theme.textPrimary
                                font.family: Palette.Theme.fontIcons
                                font.pixelSize: 16
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Cancel"
                                color: !root.confirmChoiceSelected ? Palette.Theme.accentText : Palette.Theme.textPrimary
                                font.family: Palette.Theme.fontMono
                                font.pixelSize: 9
                            }
                        }

                        MouseArea {
                            id: cancelMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.confirmChoiceSelected = false
                            onClicked: root.confirmAction = ""
                        }
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: appear
        PropertyAction {
            target: root
            property: "presented"
            value: false
        }
        PauseAnimation {
            duration: 1
        }
        PropertyAction {
            target: root
            property: "presented"
            value: true
        }
    }

    SequentialAnimation {
        id: hide
        PauseAnimation {
            duration: 180
        }
        PropertyAction {
            target: root
            property: "visible"
            value: false
        }
    }
}
