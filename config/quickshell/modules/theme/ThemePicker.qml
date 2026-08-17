import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../../components/overlay"
import "../../config/Ui.js" as Ui
import "../../theme" as Palette

Item {
    id: root
    anchors.fill: parent
    visible: false
    focus: visible

    required property var service
    property var launcher: null
    property var controlCenter: null
    property var powerMenu: null
    property string query: ""
    property int selected: 0
    property bool presented: false
    readonly property var themes: service ? service.themes.filter(name => name.toLowerCase().indexOf(query.toLowerCase()) !== -1) : []

    signal aboutToOpen
    signal aboutToClose

    IpcHandler {
        target: "theme"
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
        if (launcher && launcher.visible)
            launcher.closeLauncher(true);
        if (controlCenter && controlCenter.visible)
            controlCenter.closeControlCenter(true);
        if (powerMenu && powerMenu.visible)
            powerMenu.closePowerMenu(true);
        query = "";
        selected = 0;
        aboutToOpen();
        visible = true;
        service.refresh();
        appear.restart();
        forceActiveFocus();
    }

    function close(immediate) {
        if (!visible)
            return;
        aboutToClose();
        presented = false;
        if (immediate) {
            appear.stop();
            hide.stop();
            visible = false;
            return;
        }
        hide.restart();
    }

    function apply(index) {
        if (index < 0 || index >= themes.length)
            return;
        service.apply(themes[index]);
        close();
    }

    function move(delta) {
        if (themes.length === 0)
            return;
        selected = Math.max(0, Math.min(themes.length - 1, selected + delta));
    }

    function accentFor(themeName) {
        var colors = {
            gruvbox: "#d79921",
            mocha: "#cba6f7",
            monochrome: "#d0d0d0",
            moonfly: "#78a8ff",
            ryo: "#8bd5ff",
            tokyonight: "#7aa2f7"
        };
        return colors[themeName] || Palette.Theme.accent;
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
            move(-3);
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            move(3);
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            apply(selected);
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
        id: card
        presented: root.presented
        radius: Palette.Theme.radiusLarge
        width: Math.min(parent.width - 20, Ui.themeOverlayWidth)
        height: Math.min(parent.height - Ui.overlayTop - 12, content.implicitHeight + 24)

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 12
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Theme"
                    color: Palette.Theme.textTitle
                    font.family: Palette.Theme.fontMono
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                }
                Text {
                    text: service.activeTheme
                    color: Palette.Theme.textMuted
                    font.family: Palette.Theme.fontMono
                    font.pixelSize: 11
                }
            }

            GridLayout {
                columns: 3
                columnSpacing: Ui.gridSpacing
                rowSpacing: Ui.gridSpacing
                Layout.fillWidth: true

                Repeater {
                    model: root.themes
                    delegate: Rectangle {
                        required property string modelData
                        required property int index
                        Layout.fillWidth: true
                        Layout.preferredHeight: 88
                        radius: 13
                        color: index === root.selected ? Palette.Theme.surfaceContainerHigh : Palette.Theme.surfaceContainerLow
                        border.width: index === root.selected ? 2 : 0
                        border.color: root.accentFor(modelData)

                        Behavior on border.width {
                            NumberAnimation {
                                duration: 110
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.margins: 12
                            width: 42
                            height: 16
                            radius: 8
                            color: root.accentFor(modelData)
                            opacity: 0.18
                        }
                        Repeater {
                            model: 3
                            delegate: Rectangle {
                                width: 15
                                height: 5
                                radius: 3
                                x: 14 + index * 18
                                y: 18
                                color: index === 0 ? root.accentFor(modelData) : Qt.lighter(root.accentFor(modelData), 1 + index * 0.18)
                            }
                        }
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 14
                            text: modelData.replace(/-/g, " ")
                            color: Palette.Theme.textPrimary
                            font.family: Palette.Theme.fontMono
                            font.pixelSize: 11
                            font.weight: index === root.selected ? Font.DemiBold : Font.Normal
                            elide: Text.ElideRight
                            width: parent.width - 28
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 15
                            text: modelData === service.activeTheme ? "●" : ""
                            color: root.accentFor(modelData)
                            font.pixelSize: 10
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.selected = index
                            onClicked: root.apply(index)
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
    Keys.onPressed: function (event) {
        root.handleKey(event);
    }
}
