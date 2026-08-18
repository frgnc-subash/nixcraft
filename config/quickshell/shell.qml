import Quickshell
import Quickshell.Io
import QtQuick
import "ThemeWatcher.qml" as ThemeWatch
import "modules/bar"
import "components/overlay"
import "modules/notification"
import "modules/osd"
import "modules/wallpicker"
import "modules/lockscreen"
import "modules/idle"

ShellRoot {
    id: root
    NotificationCenter {
        id: notificationCenter
    }
    CenterOverlay {
        id: overlay
        notificationCenter: notificationCenter
        bar: mainBar
    }
    WallpaperPicker {
        id: wallpicker
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
    Bar {
        id: mainBar
        osd: mainOsd
        launcher: overlay.launcher
        controlCenter: overlay.controlCenter
        powerMenu: overlay.powerMenu
        themePicker: overlay.themePicker
        clipboard: overlay.clipboard
        ensureControlCenter: function () {
            return overlay.controlCenter;
        }
    }
}
