import Quickshell
import Quickshell.Wayland
import QtQuick
import "../material"
import "../../modules/launcher"
import "../../modules/controlcenter"
import "../../modules/powermenu"
import "../../modules/theme"
import "../../modules/clipboard"
import "../../modules/servicemanager"
import "../../modules/bar"
import "../../services"

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    exclusiveZone: -1
    color: "transparent"
    mask: Region {
        width: root.active ? root.width : 0
        height: root.active ? root.height : 0
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-center-overlay"
    WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property var bar: null
    property var notificationCenter: null
    readonly property bool active: launcherItem.visible || controlCenterItem.visible || powerMenuItem.visible || themePickerItem.visible || clipboardItem.visible || serviceManagerItem.visible || mediaPanelItem.visible

    property alias launcher: launcherItem
    property alias controlCenter: controlCenterItem
    property alias powerMenu: powerMenuItem
    property alias themePicker: themePickerItem
    property alias clipboard: clipboardItem
    property alias serviceManager: serviceManagerItem
    property alias mediaPanel: mediaPanelItem

    visible: true

    // Every central module renders as content inside one shared notch-shaped
    // surface — matching the bar's own notch — instead of each getting its
    // own detached floating card. Only one is ever visible at a time, so this
    // just picks whichever that is; the stage below reads its implicit size
    // to know how far to grow.
    readonly property var activePanel: {
        if (launcherItem.visible)
            return launcherItem;
        if (controlCenterItem.visible)
            return controlCenterItem;
        if (powerMenuItem.visible)
            return powerMenuItem;
        if (themePickerItem.visible)
            return themePickerItem;
        if (clipboardItem.visible)
            return clipboardItem;
        if (serviceManagerItem.visible)
            return serviceManagerItem;
        if (mediaPanelItem.visible)
            return mediaPanelItem;
        return null;
    }

    // The launcher and control center are meant to feel like an extension of
    // the desktop, so they don't dim it; the rest are more like modal
    // utilities and darken the backdrop behind them.
    readonly property bool activeDims: powerMenuItem.visible || themePickerItem.visible || clipboardItem.visible || serviceManagerItem.visible || mediaPanelItem.visible

    // All center-origin panels share this layer surface. Closing every other
    // panel before a new one appears prevents stacked backdrops and focus.
    function presentOnly(panel) {
        if (panel !== launcherItem && launcherItem.visible)
            launcherItem.closeLauncher(true);
        if (panel !== controlCenterItem && controlCenterItem.visible)
            controlCenterItem.closeControlCenter(true);
        if (panel !== powerMenuItem && powerMenuItem.visible)
            powerMenuItem.closePowerMenu(true);
        if (panel !== themePickerItem && themePickerItem.visible)
            themePickerItem.close(true);
        if (panel !== clipboardItem && clipboardItem.visible)
            clipboardItem.close(true);
        if (panel !== serviceManagerItem && serviceManagerItem.visible)
            serviceManagerItem.close(true);
        if (panel !== mediaPanelItem && mediaPanelItem.visible)
            mediaPanelItem.close(true);
    }

    function closeActive() {
        if (launcherItem.visible)
            launcherItem.closeLauncher();
        else if (controlCenterItem.visible)
            controlCenterItem.closeControlCenter();
        else if (powerMenuItem.visible)
            powerMenuItem.closePowerMenu();
        else if (themePickerItem.visible)
            themePickerItem.close();
        else if (clipboardItem.visible)
            clipboardItem.close();
        else if (serviceManagerItem.visible)
            serviceManagerItem.close();
        else if (mediaPanelItem.visible)
            mediaPanelItem.close();
    }

    ThemeService {
        id: themeService
    }

    ClipboardService {
        id: clipboardService
    }

    // Dims the desktop behind modal-style panels. Sits below the notch so it
    // never darkens the panel's own content.
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.activeDims ? 0.30 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 180
            }
        }

        MouseArea {
            anchors.fill: parent
            visible: root.active
            onClicked: root.closeActive()
        }
    }

    // Seed dimensions: the bar's collapsed notch width and height.
    // When a panel opens the stage grows from these values, creating a
    // seamless expansion from the clock/cava notch rather than a separate
    // overlay appearing on top of it.
    readonly property real barSlabWidth: bar ? (bar.centerCapsuleSlabWidth || 120) : 120
    readonly property real barSlabHeight: bar ? bar.height : 34

    Notch {
        id: stage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        wingSize: 9
        slabRadius: 24

        readonly property var panel: root.activePanel

        // When no panel is active collapse back to bar notch size so the
        // next open always grows from the right seed, not from zero.
        slabWidth: panel ? panel.implicitWidth : root.barSlabWidth
        slabHeight: panel ? panel.implicitHeight : root.barSlabHeight
        opacity: panel ? 1 : 0

        Behavior on slabWidth {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        Behavior on slabHeight {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutQuad
            }
        }

        Launcher {
            id: launcherItem
            maxWidth: root.width
            controlCenter: controlCenterItem
            serviceManager: serviceManagerItem
        }

        ControlCenter {
            id: controlCenterItem
            maxWidth: root.width
            maxHeight: root.height
            notificationCenter: root.notificationCenter
            bar: root.bar
        }

        PowerMenu {
            id: powerMenuItem
            maxWidth: root.width
            launcher: launcherItem
            controlCenter: controlCenterItem
        }

        ThemePicker {
            id: themePickerItem
            maxWidth: root.width
            maxHeight: root.height
            service: themeService
            launcher: launcherItem
            controlCenter: controlCenterItem
            powerMenu: powerMenuItem
        }

        Clipboard {
            id: clipboardItem
            maxWidth: root.width
            maxHeight: root.height
            service: clipboardService
        }

        ServiceManager {
            id: serviceManagerItem
            maxWidth: root.width
            maxHeight: root.height
        }

        MediaPanel {
            id: mediaPanelItem
        }
    }

    Connections {
        target: launcherItem
        function onAboutToOpen() { root.presentOnly(launcherItem); }
    }
    Connections {
        target: controlCenterItem
        function onAboutToOpen() { root.presentOnly(controlCenterItem); }
    }
    Connections {
        target: powerMenuItem
        function onAboutToOpen() { root.presentOnly(powerMenuItem); }
    }
    Connections {
        target: themePickerItem
        function onAboutToOpen() { root.presentOnly(themePickerItem); }
    }
    Connections {
        target: clipboardItem
        function onAboutToOpen() { root.presentOnly(clipboardItem); }
    }
    Connections {
        target: serviceManagerItem
        function onAboutToOpen() { root.presentOnly(serviceManagerItem); }
    }
    Connections {
        target: mediaPanelItem
        function onAboutToOpen() { root.presentOnly(mediaPanelItem); }
    }
}
