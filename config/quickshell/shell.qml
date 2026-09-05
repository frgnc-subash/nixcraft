//@ pragma DropExpensiveFonts
import Quickshell
import Quickshell.Io
import QtQuick
import "modules/bar"
import "components/overlay"
import "modules/notification"
import "modules/osd"
import "modules/workspaces"
import "modules/lockscreen"
import "modules/idle"
import "services"

ShellRoot {
    id: root
    NotificationCenter {
        id: notificationCenter
    }
    BarLayoutService {
        id: barLayoutService
    }
    CenterOverlay {
        id: overlay
        notificationCenter: notificationCenter
        bar: mainBar
        idleService: idleService
        barLayout: barLayoutService
    }
    WorkspacesService {
        id: workspacesService
    }
    WorkspaceOverview {
        id: workspaceOverview
        service: workspacesService
    }
    Osd {
        id: mainOsd
    }
    LockScreen {
        id: lockScreen
    }
    IdleService {
        id: idleService
        lockScreen: lockScreen
    }
    IpcHandler {
        target: "controlcenter"
        function toggle(): void {
            root.toggleControlCenter();
        }
        function open(): void {
            root.openControlCenter();
        }
        function close(): void {
            root.closeControlCenter();
        }
    }
    function openControlCenter() {
        if (overlay.controlCenter)
            overlay.controlCenter.openControlCenter();
    }
    function closeControlCenter() {
        if (overlay.controlCenter)
            overlay.controlCenter.closeControlCenter();
    }
    function toggleControlCenter() {
        if (overlay.controlCenter)
            overlay.controlCenter.toggleControlCenter();
    }
    IpcHandler {
        target: "mediapanel"
        function toggle(): void {
            root.toggleMediaPanel();
        }
    }
    function toggleMediaPanel() {
        if (overlay.mediaPanel)
            overlay.mediaPanel.toggleMediaPanel();
    }
    IpcHandler {
        target: "shell"
        function reload(): void {
            Quickshell.reload(false);
        }
    }
    Bar {
        id: mainBar
        osd: mainOsd
        barLayout: barLayoutService
        workspacesService: workspacesService
        launcher: overlay.launcher
        controlCenter: overlay.controlCenter
        powerMenu: overlay.powerMenu
        themePicker: overlay.themePicker
        clipboard: overlay.clipboard
        mediaPanel: overlay.mediaPanel
        toolMenu: overlay.toolMenu
        emojiPicker: overlay.emojiPicker
        ensureControlCenter: function () {
            return overlay.controlCenter;
        }
    }
}
