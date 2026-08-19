import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Widgets
import "../../components/material"
import "../../theme" as Palette

PanelWindow {
    id: bar
    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: 0
        right: 0
        left: 0
        bottom: 0
    }
    implicitHeight: 34
    color: "transparent"

    property string centerMode: "normal"
    property var launcher: null
    property var controlCenter: null
    property var powerMenu: null
    property var themePicker: null
    property var clipboard: null
    property var mediaPanel: null
    property var ensureControlCenter: null
    property real osdValue: 0
    property string osdLabel: "0%"
    property var osd: null

    // Exposed so CenterOverlay can seed its stage from the bar notch's
    // current collapsed width, creating a seamless expand transition.
    readonly property real centerCapsuleSlabWidth: centerCapsule ? centerCapsule.slabWidth : 120

    readonly property real minLevel: 0.05

    property real currentVolume: 0.5
    property real currentBrightness: 0.5
    property bool currentVolumeMuted: false
    property bool suppressVolumeOsd: false
    property bool suppressBrightnessOsd: false
    property string appClass: ""
    property string appTitle: "Desktop"

    property var player: {
        var list = Mpris.players.values;
        if (list.length === 0)
            return null;
        for (var i = 0; i < list.length; i++) {
            if (list[i].playbackState === MprisPlaybackState.Playing)
                return list[i];
        }
        return list[0];
    }

    property bool mediaPlaying: {
        var list = Mpris.players.values;
        for (var i = 0; i < list.length; i++) {
            if (list[i].playbackState === MprisPlaybackState.Playing)
                return true;
        }
        return false;
    }

    property int batteryPercent: 0
    property bool batteryCharging: false
    property bool batteryAvailable: false

    Component.onCompleted: {
        readVolume(true);
        readBrightness(true);
        readBattery();
    }

    function showOsd(kind, value, label) {
        osdValue = Math.max(0, Math.min(1, value));
        osdLabel = label !== undefined ? label : (Math.round(osdValue * 100) + "%");
        if (osd)
            osd.showMeter(kind, osdValue, osdLabel);
    }

    function showLockOsd(kind, enabled) {
        if (osd)
            osd.showLock(kind, enabled);
    }

    function syncControlCenterVolume() {
        var panel = getControlCenter(false);
        if (panel && typeof panel.syncVolumeFromBar === "function")
            panel.syncVolumeFromBar(currentVolume, currentVolumeMuted);
    }

    function syncControlCenterBrightness() {
        var panel = getControlCenter(false);
        if (panel && typeof panel.syncBrightnessFromBar === "function")
            panel.syncBrightnessFromBar(currentBrightness);
    }

    function syncVolumeFromControlCenter(value, muted, show) {
        currentVolume = Math.max(0, Math.min(1, value));
        currentVolumeMuted = muted;
        if (show)
            showOsd("volume", currentVolume, muted ? "Muted" : undefined);
    }

    function syncBrightnessFromControlCenter(value, show) {
        currentBrightness = Math.max(0, Math.min(1, value));
        if (show)
            showOsd("brightness", currentBrightness);
    }

    function parseVolume(data) {
        var match = data.match(/Volume:\s+([0-9.]+)/);
        if (!match || match.length < 2)
            return;
        var volume = Number(match[1]);
        if (isNaN(volume))
            return;
        currentVolume = volume;
        currentVolumeMuted = /MUTED/.test(data);
        syncControlCenterVolume();
        if (!suppressVolumeOsd)
            showOsd("volume", volume, currentVolumeMuted ? "Muted" : undefined);
        suppressVolumeOsd = false;
    }

    function adjustVolume(delta) {
        var target = Math.max(minLevel, Math.min(1, currentVolume + delta));
        volumeAction.exec(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.round(target * 100) + "%"]);
    }

    function toggleMute() {
        volumeAction.exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
    }

    function readVolume(silent) {
        if (silent)
            suppressVolumeOsd = true;
        volumeRead.exec(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]);
    }

    function parseBrightness(data) {
        var parts = data.trim().split(",");
        if (parts.length < 5)
            return;
        var percent = Number(parts[3].replace("%", ""));
        if (isNaN(percent))
            return;
        currentBrightness = percent / 100;
        syncControlCenterBrightness();
        if (!suppressBrightnessOsd)
            showOsd("brightness", currentBrightness);
        suppressBrightnessOsd = false;
    }

    function readBrightness(silent) {
        if (silent)
            suppressBrightnessOsd = true;
        brightnessRead.exec(["brightnessctl", "-m"]);
    }

    function adjustBrightness(up) {
        var target = Math.max(minLevel, Math.min(1, currentBrightness + (up ? 0.05 : -0.05)));
        brightnessSet.exec(["brightnessctl", "set", Math.round(target * 100) + "%"]);
    }

    function readBattery() {
        batteryRead.exec(["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo ''"]);
    }

    function readBatteryStatus() {
        batteryStatusRead.exec(["sh", "-c", "cat /sys/class/power_supply/BAT*/status 2>/dev/null || echo 'None'"]);
    }

    function getControlCenter(create) {
        if (create && typeof ensureControlCenter === "function")
            return ensureControlCenter();
        return controlCenter;
    }

    function toggleControlCenter() {
        var panel = getControlCenter(true);
        if (panel)
            panel.toggleControlCenter();
    }

    function closeControlCenter(immediate) {
        var panel = getControlCenter(false);
        if (panel && panel.visible)
            panel.closeControlCenter(immediate);
    }

    function openLauncher() {
        if (launcher)
            launcher.openLauncher();
    }

    function closeLauncher(immediate) {
        if (launcher && launcher.visible)
            launcher.closeLauncher(immediate);
    }

    function toggleLauncher() {
        if (!launcher)
            return;
        if (launcher.visible)
            launcher.closeLauncher();
        else
            launcher.openLauncher();
    }

    IpcHandler {
        target: "osd"

        function volume(value: real): void {
            bar.syncVolumeFromControlCenter(value > 1 ? value / 100 : value, bar.currentVolumeMuted, true);
            bar.syncControlCenterVolume();
        }
        function brightness(value: real): void {
            bar.syncBrightnessFromControlCenter(value > 1 ? value / 100 : value, true);
            bar.syncControlCenterBrightness();
        }
        function lockState(kind: string, enabled: string): void {
            // The Hyprland keybind reports the state before the lock key is
            // applied, so invert it to show the resulting keyboard state.
            bar.showLockOsd(kind, !(enabled === "1" || String(enabled).toLowerCase() === "true"));
        }
        function volumeUp(): void {
            bar.adjustVolume(0.05);
        }
        function volumeDown(): void {
            bar.adjustVolume(-0.05);
        }
        function mute(): void {
            bar.toggleMute();
        }
        function brightnessUp(): void {
            bar.adjustBrightness(true);
        }
        function brightnessDown(): void {
            bar.adjustBrightness(false);
        }
    }

    MediaPlayer {
        id: mediaPopup
        bar: bar
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name !== "activewindow")
                return;
            var idx = event.data.indexOf(",");
            if (idx <= 0) {
                bar.appClass = "";
                bar.appTitle = "Desktop";
            } else {
                bar.appClass = event.data.substring(0, idx);
                bar.appTitle = event.data.substring(idx + 1);
            }
        }
    }

    Process {
        id: brightnessSet
        command: ["brightnessctl", "set", "+5%"]
        onExited: bar.readBrightness()
    }

    Process {
        id: volumeAction
        onExited: bar.readVolume()
    }

    Process {
        id: hyprpickerAction
    }

    Process {
        id: volumeRead
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => bar.parseVolume(data)
        }
    }

    Process {
        id: brightnessRead
        command: ["brightnessctl", "-m"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => bar.parseBrightness(data)
        }
    }

    Process {
        id: batteryRead
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo ''"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                var pct = parseInt(data.trim());
                if (!isNaN(pct)) {
                    bar.batteryAvailable = true;
                    bar.batteryPercent = pct;
                }
            }
        }
        onExited: {
            if (bar.batteryAvailable)
                bar.readBatteryStatus();
        }
    }

    Process {
        id: batteryStatusRead
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/status 2>/dev/null || echo 'None'"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => bar.batteryCharging = data.trim() === "Charging"
        }
    }

    // Fallback poll — instant updates now come from powerSupplyWatcher below,
    // this just guards against missed/coalesced udev events.
    Timer {
        id: batteryTimer
        interval: 10000
        running: true
        repeat: true
        onTriggered: bar.readBattery()
    }

    // Instant refresh: fires the moment AC is plugged/unplugged or the
    // battery status changes, instead of waiting on the poll interval.
    // Requires `udev` / `systemd` (udevadm) — present by default on NixOS.
    Process {
        id: powerSupplyWatcher
        command: ["udevadm", "monitor", "--udev", "--subsystem-match=power_supply"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => bar.readBattery()
        }
    }

    Item {
        id: barRow
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 4
        }
        height: 30

        LauncherIsland {
            id: launcherIsland
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            bar: bar
        }

        BarSection {
            id: workspacesCapsule
            anchors.left: launcherIsland.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: Math.max(workspaces.implicitWidth + 24, 185)

            Workspaces {
                id: workspaces
                anchors.centerIn: parent
            }
        }


        BarSection {
            id: batteryCapsule
            anchors.right: rightCapsule.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: batteryContent.implicitWidth + 24
            visible: bar.batteryAvailable

            Battery {
                id: batteryContent
                anchors.centerIn: parent
                bar: bar
            }
        }

        BarSection {
            id: rightCapsule
            anchors.right: powerCapsule.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: rightRow.implicitWidth + 14

            RowLayout {
                id: rightRow
                anchors.centerIn: parent
                spacing: 8

                Tray {
                    parentWindow: bar
                }

                Divider {
                    vertical: true
                    color: Palette.Theme.textMuted
                    opacity: 0.85
                    Layout.alignment: Qt.AlignVCenter
                }

                IconButton {
                    icon: "\ue3b8"
                    implicitWidth: 26
                    implicitHeight: 34
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: hyprpickerAction.exec(["hyprpicker", "-a"])
                }
            }
        }

        BarSection {
            id: powerCapsule
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: 30
            implicitHeight: 30
            radius: 10

            Text {
                anchors.centerIn: parent
                text: "\ue8ac"
                color: Palette.Theme.textPrimary
                font.family: Palette.Theme.fontIcons
                font.pixelSize: 18
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (bar.powerMenu && typeof bar.powerMenu.togglePowerMenu === "function")
                        bar.powerMenu.togglePowerMenu();
                }
            }
        }
    }

    Notch {
        id: centerCapsule
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        slabWidth: centerContentWidth + 24
        slabRadius: 13
        wingSize: 9
        clipContent: false

        readonly property real centerContentWidth: {
            if (bar.mediaPlaying)
                return cavaContent.implicitWidth;
            return clockContent.implicitWidth;
        }
        opacity: mediaPopup.visible ? 0 : 1

        // Sits flush against the screen edge (no top gap) while the rest of the
        // bar keeps its small top margin — so matching barRow's *height* would
        // leave the notch's bottom edge sitting above barRow's (whose top
        // margin eats into the same window height). Matching the window's
        // height instead lines up both bottom edges flush with each other,
        // giving the notch and barRow an equal (zero) bottom gap even though
        // their top offsets differ. Grows down out of the edge with a gentle
        // overshoot the first time the shell starts; animating the height
        // rather than sliding the whole notch down keeps the wings welded to
        // the edge for the entire drop.
        readonly property real restHeight: bar.height
        slabHeight: 0

        Component.onCompleted: dropInAnim.start()

        NumberAnimation {
            id: dropInAnim
            target: centerCapsule
            property: "slabHeight"
            to: centerCapsule.restHeight
            duration: 480
            easing.type: Easing.OutBack
            // Kept modest so the bounce peak stays inside the window's height.
            easing.overshoot: 1.0
        }

        Behavior on slabWidth {
            NumberAnimation {
                duration: 280
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Cava {
            id: cavaContent
            anchors.centerIn: parent
            active: bar.mediaPlaying && visible
            visible: bar.mediaPlaying
            opacity: bar.centerMode === "normal" && bar.mediaPlaying && !(launcher && launcher.visible) ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }
        }

        RowLayout {
            id: clockContent
            anchors.centerIn: parent
            spacing: 8
            visible: !bar.mediaPlaying
            opacity: bar.centerMode === "normal" && !bar.mediaPlaying && !(launcher && launcher.visible) ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }

            Clock {}
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    bar.closeControlCenter();

                    if (mediaPopup.isOpen)
                        mediaPopup.forceClose();
                    if (bar.mediaPanel)
                        bar.mediaPanel.toggleMediaPanel();
                    else if (Mpris.players.values.length > 0)
                        mediaPopup.open();
                    return;
                }

                if (mediaPopup.isOpen)
                    mediaPopup.forceClose();

                bar.toggleControlCenter();
            }
        }


        Connections {
            target: launcher
            enabled: launcher !== null
            function onAboutToOpen() { bar.centerMode = "launcher"; }
            function onAboutToClose() { bar.centerMode = "normal"; }
        }

        Connections {
            target: bar.controlCenter
            enabled: bar.controlCenter !== null
            function onAboutToOpen() { bar.centerMode = "controlCenter"; }
            function onAboutToClose() { bar.centerMode = "normal"; }
        }

        Connections {
            target: bar.themePicker
            enabled: bar.themePicker !== null
            function onAboutToOpen() { bar.centerMode = "theme"; }
            function onAboutToClose() { bar.centerMode = "normal"; }
        }

        Connections {
            target: bar.clipboard
            enabled: bar.clipboard !== null
            function onAboutToOpen() { bar.centerMode = "clipboard"; }
            function onAboutToClose() { bar.centerMode = "normal"; }
        }

        Connections {
            target: bar.powerMenu
            enabled: bar.powerMenu !== null
            function onAboutToOpen() { bar.centerMode = "powerMenu"; }
            function onAboutToClose() { bar.centerMode = "normal"; }
        }

        Connections {
            target: bar.mediaPanel
            enabled: bar.mediaPanel !== null
            function onAboutToOpen() { bar.centerMode = "mediaPanel"; }
            function onAboutToClose() { bar.centerMode = "normal"; }
        }
    }
}
