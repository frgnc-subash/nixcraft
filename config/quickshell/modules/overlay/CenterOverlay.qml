import Quickshell
import Quickshell.Wayland
import QtQuick
import "../launcher"
import "../controlcenter"
import "../powermenu"
import "../theme"
import "../clipboard"
import "../servicemanager"
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
    readonly property bool active: launcherItem.visible || controlCenterItem.visible || powerMenuItem.visible || themePickerItem.visible || clipboardItem.visible || serviceManagerItem.visible

    property alias launcher: launcherItem
    property alias controlCenter: controlCenterItem
    property alias powerMenu: powerMenuItem
    property alias themePicker: themePickerItem
    property alias clipboard: clipboardItem
    property alias serviceManager: serviceManagerItem

    visible: true

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
    }

    ThemeService {
        id: themeService
    }

    ClipboardService {
        id: clipboardService
    }

    Launcher {
        id: launcherItem
        controlCenter: controlCenterItem
        serviceManager: serviceManagerItem
    }

    ControlCenter {
        id: controlCenterItem
        notificationCenter: root.notificationCenter
        bar: root.bar
    }

    PowerMenu {
        id: powerMenuItem
        launcher: launcherItem
        controlCenter: controlCenterItem
    }

    ThemePicker {
        id: themePickerItem
        service: themeService
        launcher: launcherItem
        controlCenter: controlCenterItem
        powerMenu: powerMenuItem
    }

    Clipboard {
        id: clipboardItem
        service: clipboardService
    }

    ServiceManager {
        id: serviceManagerItem
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
}
