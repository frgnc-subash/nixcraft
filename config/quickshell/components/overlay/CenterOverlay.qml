import Quickshell
import Quickshell.Wayland
import QtQuick
import "../material"
import "../../modules/launcher"
import "../../modules/controlcenter"
import "../../modules/powermenu"
import "../../modules/theme"
import "../../modules/shader"
import "../../modules/clipboard"
import "../../modules/servicemanager"
import "../../modules/bar"
import "../../modules/wayclick"
import "../../modules/emoji"
import "../../modules/toolmenu"
import "../../modules/barlayout"
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
    property var idleService: null
    property var barLayout: null
    readonly property bool verticalBar: barLayout ? barLayout.vertical : false
    readonly property bool active: launcherItem.visible || controlCenterItem.visible || powerMenuItem.visible || themePickerItem.visible || shaderPickerItem.visible || wayclickPackPickerItem.visible || clipboardItem.visible || serviceManagerItem.visible || mediaPanelItem.visible || toolMenuItem.visible || emojiPickerItem.visible || barLayoutPickerItem.visible

    // Central modules origin edge:
    // Top origin: Control Center, Power Menu, Tool Menu, Media Panel.
    // Bottom origin: all other panels (Launcher, Theme, Shader, Wayclick,
    // Clipboard, Service Manager, Emoji, Bar Layout).
    // Applies in both horizontal and vertical bar modes.
    function isTopModule(panel) {
        return panel === controlCenterItem
            || panel === powerMenuItem
            || panel === toolMenuItem
            || panel === mediaPanelItem;
    }

    property var currentTargetPanel: null
    property bool lastOriginTop: true

    readonly property bool activeIsTopOrigin: {
        if (currentTargetPanel && currentTargetPanel.visible)
            return isTopModule(currentTargetPanel);
        if (controlCenterItem.visible || powerMenuItem.visible || toolMenuItem.visible || mediaPanelItem.visible)
            return true;
        if (launcherItem.visible || themePickerItem.visible || shaderPickerItem.visible || wayclickPackPickerItem.visible || clipboardItem.visible || serviceManagerItem.visible || emojiPickerItem.visible || barLayoutPickerItem.visible)
            return false;
        return lastOriginTop;
    }

    onActivePanelChanged: {
        if (activePanel)
            lastOriginTop = isTopModule(activePanel);
    }

    property alias launcher: launcherItem
    property alias controlCenter: controlCenterItem
    property alias powerMenu: powerMenuItem
    property alias themePicker: themePickerItem
    property alias shaderPicker: shaderPickerItem
    property alias wayclickPackPicker: wayclickPackPickerItem
    property alias clipboard: clipboardItem
    property alias serviceManager: serviceManagerItem
    property alias mediaPanel: mediaPanelItem
    property alias toolMenu: toolMenuItem
    property alias emojiPicker: emojiPickerItem
    property alias barLayoutPicker: barLayoutPickerItem

    visible: true

    // Every central module renders as content inside one shared notch-shaped
    // surface — matching the bar's own notch — instead of each getting its
    // own detached floating card. Only one is ever visible at a time, so this
    // just picks whichever that is; the stage below reads its implicit size
    // to know how far to grow.
    readonly property var activePanel: {
        if (currentTargetPanel && currentTargetPanel.visible)
            return currentTargetPanel;
        if (controlCenterItem.visible)
            return controlCenterItem;
        if (powerMenuItem.visible)
            return powerMenuItem;
        if (toolMenuItem.visible)
            return toolMenuItem;
        if (mediaPanelItem.visible)
            return mediaPanelItem;
        if (launcherItem.visible)
            return launcherItem;
        if (themePickerItem.visible)
            return themePickerItem;
        if (shaderPickerItem.visible)
            return shaderPickerItem;
        if (wayclickPackPickerItem.visible)
            return wayclickPackPickerItem;
        if (clipboardItem.visible)
            return clipboardItem;
        if (serviceManagerItem.visible)
            return serviceManagerItem;
        if (emojiPickerItem.visible)
            return emojiPickerItem;
        if (barLayoutPickerItem.visible)
            return barLayoutPickerItem;
        return null;
    }

    // The launcher and control center are meant to feel like an extension of
    // the desktop, so they don't dim it; the rest are more like modal
    // utilities and darken the backdrop behind them.
    readonly property bool activeDims: powerMenuItem.visible || themePickerItem.visible || shaderPickerItem.visible || wayclickPackPickerItem.visible || clipboardItem.visible || serviceManagerItem.visible || mediaPanelItem.visible || toolMenuItem.visible || emojiPickerItem.visible || barLayoutPickerItem.visible

    // All center-origin panels share this layer surface. Closing every other
    // panel before a new one appears prevents stacked backdrops and focus.
    function presentOnly(panel) {
        currentTargetPanel = panel;
        lastOriginTop = isTopModule(panel);
        if (panel !== launcherItem && launcherItem.visible)
            launcherItem.closeLauncher(true);
        if (panel !== controlCenterItem && controlCenterItem.visible)
            controlCenterItem.closeControlCenter(true);
        if (panel !== powerMenuItem && powerMenuItem.visible)
            powerMenuItem.closePowerMenu(true);
        if (panel !== themePickerItem && themePickerItem.visible)
            themePickerItem.close(true);
        if (panel !== shaderPickerItem && shaderPickerItem.visible)
            shaderPickerItem.close(true);
        if (panel !== wayclickPackPickerItem && wayclickPackPickerItem.visible)
            wayclickPackPickerItem.close(true);
        if (panel !== clipboardItem && clipboardItem.visible)
            clipboardItem.close(true);
        if (panel !== serviceManagerItem && serviceManagerItem.visible)
            serviceManagerItem.close(true);
        if (panel !== mediaPanelItem && mediaPanelItem.visible)
            mediaPanelItem.close(true);
        if (panel !== toolMenuItem && toolMenuItem.visible)
            toolMenuItem.closeToolMenu(true);
        if (panel !== emojiPickerItem && emojiPickerItem.visible)
            emojiPickerItem.close(true);
        if (panel !== barLayoutPickerItem && barLayoutPickerItem.visible)
            barLayoutPickerItem.close(true);
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
        else if (shaderPickerItem.visible)
            shaderPickerItem.close();
        else if (wayclickPackPickerItem.visible)
            wayclickPackPickerItem.close();
        else if (clipboardItem.visible)
            clipboardItem.close();
        else if (serviceManagerItem.visible)
            serviceManagerItem.close();
        else if (mediaPanelItem.visible)
            mediaPanelItem.close();
        else if (toolMenuItem.visible)
            toolMenuItem.closeToolMenu();
        else if (emojiPickerItem.visible)
            emojiPickerItem.close();
        else if (barLayoutPickerItem.visible)
            barLayoutPickerItem.close();
    }

    ThemeService {
        id: themeService
    }

    ShaderService {
        id: shaderService
    }

    WayclickPackService {
        id: wayclickPackService
    }

    ClipboardService {
        id: clipboardService
    }

    EmojiService {
        id: emojiService
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
    // overlay appearing on top of it. The vertical bar has no top notch to
    // seed from, so the stage just starts flat (zero height) and grows
    // from whichever edge (top or bottom) the next panel opens from.
    readonly property real barSlabWidth: bar ? (bar.centerCapsuleSlabWidth || 120) : 120
    readonly property real barSlabHeight: root.stageAtTop ? (root.verticalBar ? 0 : (bar ? bar.height : 34)) : 0
    readonly property bool stageAtTop: root.activeIsTopOrigin

    Notch {
        id: stage
        anchors.horizontalCenter: parent.horizontalCenter
        // A plain `y` binding instead of toggling which anchor line
        // (top/bottom) is active — flipping anchors on a still-animating
        // item was the cause of the "opens from the wrong edge sometimes"
        // flakiness: for a frame or two both edges could end up anchored at
        // once, which forces Qt Quick to stretch the item between them
        // (overriding the height the grow animation was driving). A single
        // deterministic `y` expression has no such transient double-anchor
        // state.
        y: root.stageAtTop ? 0 : (parent.height - height)
        bottomAligned: !root.stageAtTop
        wingSize: 9

        readonly property var panel: root.activePanel
        slabRadius: 20

        // When no panel is active collapse back to bar notch size so the
        // next open always grows from the right seed, not from zero.
        slabWidth: panel ? panel.implicitWidth : root.barSlabWidth
        slabHeight: panel ? panel.implicitHeight : root.barSlabHeight
        opacity: panel ? 1 : 0

        Behavior on slabWidth {
            NumberAnimation {
                duration: 240
                easing.type: Easing.OutBack
                easing.overshoot: 0.6
            }
        }
        Behavior on slabHeight {
            NumberAnimation {
                duration: 240
                easing.type: Easing.OutBack
                easing.overshoot: 0.6
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutCubic
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
            idleService: root.idleService
        }

        PowerMenu {
            id: powerMenuItem
            maxWidth: root.width
            launcher: launcherItem
            controlCenter: controlCenterItem
        }

        ToolMenu {
            id: toolMenuItem
            maxWidth: root.width
            launcher: launcherItem
            controlCenter: controlCenterItem
        }

        EmojiPicker {
            id: emojiPickerItem
            maxWidth: root.width
            maxHeight: root.height
            service: emojiService
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

        ShaderPicker {
            id: shaderPickerItem
            maxWidth: root.width
            service: shaderService
            launcher: launcherItem
            controlCenter: controlCenterItem
            powerMenu: powerMenuItem
        }

        WayclickPackPicker {
            id: wayclickPackPickerItem
            maxWidth: root.width
            service: wayclickPackService
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

        BarLayoutPicker {
            id: barLayoutPickerItem
            service: root.barLayout
            launcher: launcherItem
            controlCenter: controlCenterItem
            powerMenu: powerMenuItem
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
        target: shaderPickerItem
        function onAboutToOpen() { root.presentOnly(shaderPickerItem); }
    }
    Connections {
        target: wayclickPackPickerItem
        function onAboutToOpen() { root.presentOnly(wayclickPackPickerItem); }
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
    Connections {
        target: toolMenuItem
        function onAboutToOpen() { root.presentOnly(toolMenuItem); }
    }
    Connections {
        target: emojiPickerItem
        function onAboutToOpen() { root.presentOnly(emojiPickerItem); }
    }
    Connections {
        target: barLayoutPickerItem
        function onAboutToOpen() { root.presentOnly(barLayoutPickerItem); }
    }
}
