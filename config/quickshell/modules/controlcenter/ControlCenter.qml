import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../../components/material"
import "../../theme" as Palette
import "../notification"

Item {
    id: root

    anchors.fill: parent
    visible: false

    property real maxWidth: 4000
    property real maxHeight: 4000
    property var notificationCenter
    property var bar
    property var idleService: null
    property bool wifiEnabled: true
    property string powerProfile: "balanced"
    property bool powerProfileLoaded: false
    property bool bluetoothEnabled: false
    property bool bluetoothLoaded: false
    property bool ethernetConnected: false
    property real volumeValue: 0.5
    property bool volumeMuted: false
    property real brightnessValue: 0.5
    property real micValue: 0.5
    property bool micMuted: false
    property string detailMode: "none"
    property string pendingBluetoothAddress: ""
    property bool wifiScanning: false
    property bool bluetoothScanning: false
    property bool showVolumeOsdOnRead: false
    property bool showBrightnessOsdOnRead: false
    property bool showMicOsdOnRead: false
    property bool dndEnabled: false
    property string powerProfilePending: ""
    readonly property bool keepAwake: idleService ? idleService.keepAwake : false

    readonly property real minLevel: 0.05
    readonly property var notifications: notificationCenter ? notificationCenter.notifications : []
    readonly property int notificationCount: notificationCenter ? notificationCenter.count : 0
    readonly property bool showingDetail: detailMode !== "none"

    implicitWidth: Math.max(360, Math.min(maxWidth - 2, 520))
    implicitHeight: showingDetail ? Math.max(320, Math.min(maxHeight - 4, 400)) : notificationCount > 0 ? Math.max(500, Math.min(maxHeight - 4, 600)) : Math.max(420, Math.min(maxHeight - 4, 440))

    signal aboutToOpen
    signal aboutToClose

    function clampLevel(value) {
        return Math.max(minLevel, Math.min(1, value));
    }

    function refreshAll() {
        readNetwork();
        readPowerProfile();
        readBluetooth();
        readVolume();
        readBrightness();
        readMic();
        syncDnd();
    }

    function syncVolumeFromBar(value, muted) {
        volumeValue = clampLevel(value);
        volumeMuted = muted;
    }

    function syncBrightnessFromBar(value) {
        brightnessValue = clampLevel(value);
    }

    function syncFromBar() {
        if (!root.bar)
            return;
        syncVolumeFromBar(root.bar.currentVolume, root.bar.currentVolumeMuted);
        syncBrightnessFromBar(root.bar.currentBrightness);
    }

    function openControlCenter() {
        if (root.bar && typeof root.bar.closeLauncher === "function")
            root.bar.closeLauncher(true);
        if (root.visible)
            return;
        aboutToOpen();
        syncFromBar();
        refreshAll();
        visible = true;
    }

    function closeControlCenter(immediate) {
        if (!root.visible)
            return;
        aboutToClose();
        detailMode = "none";
        if (immediate) {
            closeTimer.stop();
            visible = false;
            return;
        }
        closeTimer.restart();
    }

    function toggleControlCenter() {
        if (visible)
            closeControlCenter();
        else
            openControlCenter();
    }

    function readWifi() {
        wifiRead.exec(["nmcli", "radio", "wifi"]);
    }

    function readNetwork() {
        readWifi();
        readEthernet();
    }

    function parseWifi(data) {
        wifiEnabled = data.trim() === "enabled";
    }

    function toggleWifi() {
        wifiToggle.exec(["nmcli", "radio", "wifi", wifiEnabled ? "off" : "on"]);
    }

    function toggleNetwork() {
        toggleWifi();
    }

    function openWifiList() {
        detailMode = detailMode === "wifi" ? "none" : "wifi";
        if (wifiNetworkModel.count === 0)
            scanWifi(false);
    }

    function scanWifi(rescan) {
        wifiScanning = true;
        wifiNetworkModel.clear();
        var command = ["nmcli", "-t", "-f", "IN-USE,SSID,SECURITY,SIGNAL", "dev", "wifi", "list"];
        if (rescan)
            command = command.concat(["--rescan", "yes"]);
        wifiScan.exec(command);
    }

    function parseWifiNetwork(data) {
        var parts = data.split(":");
        if (parts.length < 4)
            return;
        var ssid = parts[1].replace(/\\:/g, ":");
        if (ssid === "")
            return;
        for (var i = 0; i < wifiNetworkModel.count; i++) {
            if (wifiNetworkModel.get(i).ssid === ssid)
                return;
        }
        wifiNetworkModel.append({
            active: parts[0] === "*",
            ssid: ssid,
            security: parts[2] === "" ? "Open" : parts[2],
            signal: parts[3]
        });
    }

    function connectWifi(ssid) {
        wifiConnect.exec(["nmcli", "dev", "wifi", "connect", ssid]);
    }

    function readPowerProfile() {
        powerProfileRead.exec(["powerprofilesctl", "get"]);
    }

    function parsePowerProfile(data) {
        if (powerProfilePending !== "")
            return;
        powerProfile = data.trim() || powerProfile;
        powerProfileLoaded = true;
    }

    function cyclePowerProfile() {
        var next = "balanced";
        if (powerProfile === "balanced")
            next = "power-saver";
        else if (powerProfile === "power-saver")
            next = "performance";
        setPowerProfile(next);
    }

    function setPowerProfile(profile) {
        if (profile === powerProfile && powerProfilePending === "")
            return;
        powerProfile = profile;
        powerProfileLoaded = true;
        powerProfilePending = profile;
        powerProfileSet.exec(["powerprofilesctl", "set", profile]);
    }

    function readBluetooth() {
        bluetoothRead.exec(["bluetoothctl", "show"]);
    }

    function parseBluetooth(data) {
        var match = data.match(/Powered:\s+(yes|no)/);
        if (!match || match.length < 2)
            return;
        bluetoothEnabled = match[1] === "yes";
        bluetoothLoaded = true;
    }

    function toggleBluetooth() {
        bluetoothToggle.exec(["bluetoothctl", "power", bluetoothEnabled ? "off" : "on"]);
    }

    function openBluetoothList() {
        detailMode = detailMode === "bluetooth" ? "none" : "bluetooth";
        if (bluetoothDeviceModel.count === 0)
            readKnownBluetoothDevices();
    }

    function closeDetailWindow(animated) {
        detailMode = "none";
    }

    function readKnownBluetoothDevices() {
        bluetoothDeviceModel.clear();
        bluetoothKnownRead.exec(["bluetoothctl", "devices"]);
    }

    function scanBluetooth() {
        bluetoothScanning = true;
        readKnownBluetoothDevices();
        bluetoothScan.exec(["bluetoothctl", "--timeout", "4", "scan", "on"]);
    }

    function parseBluetoothDevice(data) {
        var match = data.match(/^Device\s+([0-9A-Fa-f:]+)\s+(.+)$/);
        if (!match || match.length < 3)
            return;
        for (var i = 0; i < bluetoothDeviceModel.count; i++) {
            if (bluetoothDeviceModel.get(i).address === match[1])
                return;
        }
        bluetoothDeviceModel.append({
            address: match[1],
            name: match[2]
        });
    }

    function pairBluetooth(address) {
        pendingBluetoothAddress = address;
        bluetoothPair.exec(["bluetoothctl", "pair", address]);
    }

    function readEthernet() {
        ethernetConnected = false;
        ethernetRead.exec(["nmcli", "-t", "-f", "TYPE,STATE", "dev", "status"]);
    }

    function parseEthernet(data) {
        var parts = data.split(":");
        if (parts.length < 2 || parts[0] !== "ethernet")
            return;
        ethernetConnected = parts[1] === "connected";
    }

    function readVolume() {
        volumeRead.exec(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]);
    }

    function parseVolume(data) {
        var match = data.match(/Volume:\s+([0-9.]+)/);
        if (!match || match.length < 2)
            return;
        var level = Number(match[1]);
        if (isNaN(level))
            return;
        volumeValue = level;
        volumeMuted = /MUTED/.test(data);
        if (root.bar && typeof root.bar.syncVolumeFromControlCenter === "function")
            root.bar.syncVolumeFromControlCenter(volumeValue, volumeMuted, showVolumeOsdOnRead);
        showVolumeOsdOnRead = false;
    }

    function setVolume(value) {
        volumeValue = clampLevel(value);
        showVolumeOsdOnRead = true;
        if (root.bar && typeof root.bar.syncVolumeFromControlCenter === "function")
            root.bar.syncVolumeFromControlCenter(volumeValue, volumeMuted, true);
        volumeSet.exec(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.round(volumeValue * 100) + "%"]);
    }

    function toggleMute() {
        showVolumeOsdOnRead = true;
        volumeMute.exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
    }

    function openWiremix() {
        wiremixLaunch.exec(["kitty", "-e", "wiremix"]);
    }

    function readBrightness() {
        brightnessRead.exec(["brightnessctl", "-m"]);
    }

    function parseBrightness(data) {
        var parts = data.trim().split(",");
        if (parts.length < 5)
            return;
        var percent = Number(parts[3].replace("%", ""));
        if (isNaN(percent))
            return;
        brightnessValue = percent / 100;
        if (root.bar && typeof root.bar.syncBrightnessFromControlCenter === "function")
            root.bar.syncBrightnessFromControlCenter(brightnessValue, showBrightnessOsdOnRead);
        showBrightnessOsdOnRead = false;
    }

    function setBrightness(value) {
        brightnessValue = clampLevel(value);
        showBrightnessOsdOnRead = true;
        if (root.bar && typeof root.bar.syncBrightnessFromControlCenter === "function")
            root.bar.syncBrightnessFromControlCenter(brightnessValue, true);
        brightnessSet.exec(["brightnessctl", "set", Math.round(brightnessValue * 100) + "%"]);
    }

    function readMic() {
        micRead.exec(["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]);
    }

    function parseMic(data) {
        var match = data.match(/Volume:\s+([0-9.]+)/);
        if (!match || match.length < 2)
            return;
        var level = Number(match[1]);
        if (isNaN(level))
            return;
        micValue = level;
        micMuted = /MUTED/.test(data);
        showMicOsdOnRead = false;
    }

    function setMic(value) {
        micValue = clampLevel(value);
        showMicOsdOnRead = true;
        micSet.exec(["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", Math.round(micValue * 100) + "%"]);
    }

    function toggleMicMute() {
        showMicOsdOnRead = true;
        micMute.exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]);
    }

    function micIcon() {
        return root.micMuted ? "\ue02b" : "\ue029";
    }

    function wifiIcon() {
        return root.wifiEnabled ? "\ue63e" : "\ue648";
    }

    function networkIcon() {
        return root.ethernetConnected ? ethernetIcon() : wifiIcon();
    }

    function networkActive() {
        return root.ethernetConnected || root.wifiEnabled;
    }

    function networkSubtitle() {
        if (root.ethernetConnected && root.wifiEnabled)
            return "Wired + Wi-Fi";
        if (root.ethernetConnected)
            return "Wired";
        return root.wifiEnabled ? "Wi-Fi" : "Off";
    }

    function dndIcon() {
        return "\ue51c";
    }

    function powerIcon() {
        if (root.powerProfile === "power-saver")
            return "\ue9e4";
        if (root.powerProfile === "performance")
            return "\uea0b";
        return "\ue8d4";
    }

    function powerProfileColor() {
        if (root.powerProfile === "power-saver")
            return Palette.Theme.success;
        if (root.powerProfile === "performance")
            return "#ef5350";
        return Palette.Theme.surfaceContainer;
    }

    function bluetoothSubtitle() {
        if (!root.bluetoothLoaded)
            return "loading";
        return root.bluetoothEnabled ? "On" : "Off";
    }

    function bluetoothIcon() {
        return "\ue1a7";
    }

    function syncDnd() {
        if (root.notificationCenter)
            dndEnabled = root.notificationCenter.doNotDisturb;
    }

    function toggleDnd() {
        dndEnabled = !dndEnabled;
        if (root.notificationCenter && typeof root.notificationCenter.setDnd === "function")
            root.notificationCenter.setDnd(dndEnabled);
        setExternalDnd(dndEnabled);
    }

    function setExternalDnd(enabled) {
        dndSet.exec(["sh", "-c", enabled ? "command -v makoctl >/dev/null 2>&1 && makoctl mode -a do-not-disturb; command -v swaync-client >/dev/null 2>&1 && swaync-client -dn" : "command -v makoctl >/dev/null 2>&1 && makoctl mode -r do-not-disturb; command -v swaync-client >/dev/null 2>&1 && swaync-client -df"]);
    }

    function clearAllNotifications() {
        if (root.notificationCenter)
            root.notificationCenter.clearAll();
        notificationClear.exec(["sh", "-c", "command -v swaync-client >/dev/null 2>&1 && swaync-client -C"]);
    }

    function toggleKeepAwake() {
        if (root.idleService)
            root.idleService.toggleKeepAwake();
    }

    function keepAwakeIcon() {
        return "\uefef";
    }
    function ethernetIcon() {
        return "\ue8be";
    }

    function volumeIcon() {
        if (root.volumeMuted || root.volumeValue <= 0.01)
            return "\ue04f";
        if (root.volumeValue < 0.5)
            return "\ue04d";
        return "\ue050";
    }

    function brightnessIcon() {
        if (root.brightnessValue < 0.5)
            return "\ue1ab";
        return "\ue1ac";
    }

    ListModel {
        id: wifiNetworkModel
    }

    ListModel {
        id: bluetoothDeviceModel
    }

    Timer {
        id: closeTimer
        interval: 180
        onTriggered: root.visible = false
    }

    Process {
        id: wifiRead
        command: ["nmcli", "radio", "wifi"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.parseWifi(data)
        }
    }

    Process {
        id: wifiToggle
        onExited: root.readWifi()
    }

    Process {
        id: wifiScan

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.parseWifiNetwork(data)
        }

        onExited: root.wifiScanning = false
    }

    Process {
        id: wifiConnect
        onExited: {
            root.readWifi();
            root.scanWifi(false);
        }
    }

    Process {
        id: powerProfileRead
        command: ["powerprofilesctl", "get"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.parsePowerProfile(data)
        }
    }

    Process {
        id: powerProfileSet
        onExited: {
            root.powerProfilePending = "";
            root.readPowerProfile();
        }
    }

    Process {
        id: bluetoothRead
        command: ["bluetoothctl", "show"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.parseBluetooth(data)
        }
    }

    Process {
        id: bluetoothToggle
        onExited: root.readBluetooth()
    }

    Process {
        id: bluetoothScan

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.parseBluetoothDevice(data)
        }

        onExited: root.bluetoothScanning = false
    }

    Process {
        id: bluetoothKnownRead

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.parseBluetoothDevice(data)
        }
    }

    Process {
        id: bluetoothPair
        onExited: {
            if (root.pendingBluetoothAddress !== "")
                bluetoothConnect.exec(["bluetoothctl", "connect", root.pendingBluetoothAddress]);
        }
    }

    Process {
        id: bluetoothConnect
        onExited: {
            root.pendingBluetoothAddress = "";
            root.scanBluetooth();
        }
    }

    Process {
        id: ethernetRead
        command: ["nmcli", "-t", "-f", "TYPE,STATE", "dev", "status"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.parseEthernet(data)
        }
    }

    Process {
        id: volumeRead
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.parseVolume(data)
        }
    }

    Process {
        id: volumeSet
        onExited: root.readVolume()
    }

    Process {
        id: volumeMute
        onExited: root.readVolume()
    }

    Process {
        id: micRead
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.parseMic(data)
        }
    }

    Process {
        id: micSet
        onExited: root.readMic()
    }

    Process {
        id: micMute
        onExited: root.readMic()
    }

    Process {
        id: wiremixLaunch
    }

    Process {
        id: dndSet
    }

    Process {
        id: notificationClear
    }

    Process {
        id: brightnessRead
        command: ["brightnessctl", "-m"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.parseBrightness(data)
        }
    }

    Process {
        id: brightnessSet
        onExited: root.readBrightness()
    }

        Item {
            id: normalView
            anchors.fill: parent
            opacity: root.showingDetail ? 0 : 1
            scale: root.showingDetail ? 0.98 : 1
            transformOrigin: Item.Top
            enabled: !root.showingDetail

            Behavior on opacity {
                NumberAnimation {
                    duration: 190
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.bottomMargin: 16
                anchors.topMargin: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    ColumnLayout {
                        spacing: 0
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                        SystemClock {
                            id: ccClock
                            precision: SystemClock.Minutes
                        }

                        Text {
                            text: Qt.formatDateTime(ccClock.date, "hh:mm")
                            color: Palette.Theme.textPrimary
                            font.family: Palette.Theme.fontMono
                            font.pixelSize: 14
                            font.weight: Font.Normal
                            Layout.alignment: Qt.AlignLeft
                        }

                        Text {
                            text: Qt.formatDateTime(ccClock.date, "ddd, MMM d")
                            color: Palette.Theme.textMuted
                            font.family: Palette.Theme.fontMono
                            font.pixelSize: 10
                            Layout.alignment: Qt.AlignLeft
                        }
                    }
                }

                Divider {
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 244
                    Layout.preferredHeight: 244
                    Layout.maximumHeight: 244
                    spacing: 8

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 8
                            rowSpacing: 8

                            QuickTile {
                                Layout.fillWidth: true
                                Layout.minimumHeight: 76
                                Layout.preferredHeight: 76
                                Layout.maximumHeight: 76
                                compact: true
                                accentColor: Palette.Theme.info
                                iconGlyph: root.networkIcon()
                                title: "Network"
                                subtitle: root.networkSubtitle()
                                active: root.networkActive()
                                onClicked: root.toggleNetwork()
                                onRightClicked: root.openWifiList()
                            }

                            QuickTile {
                                Layout.fillWidth: true
                                Layout.minimumHeight: 76
                                Layout.preferredHeight: 76
                                Layout.maximumHeight: 76
                                compact: true
                                accentColor: Palette.Theme.info
                                iconGlyph: root.bluetoothIcon()
                                title: "Bluetooth"
                                subtitle: root.bluetoothSubtitle()
                                active: root.bluetoothLoaded && root.bluetoothEnabled
                                onClicked: root.toggleBluetooth()
                                onRightClicked: root.openBluetoothList()
                            }
                        }

                        Surface {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 152
                            radius: 14
                            color: Palette.Theme.surfaceContainerLow
                            tintOpacity: 0.025

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 2

                                ControlSlider {
                                    Layout.fillWidth: true
                                    iconGlyph: root.volumeIcon()
                                    accentColor: Palette.Theme.accent
                                    value: root.volumeValue
                                    onIconClicked: root.toggleMute()
                                    onIconRightClicked: root.openWiremix()
                                    onValueRequested: value => root.setVolume(value)
                                }

                                ControlSlider {
                                    Layout.fillWidth: true
                                    iconGlyph: root.brightnessIcon()
                                    accentColor: Palette.Theme.accent
                                    value: root.brightnessValue
                                    onValueRequested: value => root.setBrightness(value)
                                }

                                ControlSlider {
                                    Layout.fillWidth: true
                                    iconGlyph: root.micIcon()
                                    accentColor: Palette.Theme.accent
                                    value: root.micValue
                                    onIconClicked: root.toggleMicMute()
                                    onValueRequested: value => root.setMic(value)
                                }
                            }
                        }
                    }

                    Divider {
                        vertical: true
                        Layout.fillHeight: true
                        Layout.topMargin: 4
                        Layout.bottomMargin: 4
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 154
                        Layout.minimumWidth: 154
                        spacing: 8

                        QuickTile {
                            Layout.fillWidth: true
                            Layout.minimumHeight: 76
                            Layout.preferredHeight: 76
                            Layout.maximumHeight: 76
                            compact: true
                            accentColor: Palette.Theme.warning
                            iconGlyph: root.dndIcon()
                            title: "DND"
                            subtitle: root.dndEnabled ? "On" : "Off"
                            active: root.dndEnabled
                            onClicked: root.toggleDnd()
                        }

                        QuickTile {
                            Layout.fillWidth: true
                            Layout.minimumHeight: 76
                            Layout.preferredHeight: 76
                            Layout.maximumHeight: 76
                            compact: true
                            accentColor: Palette.Theme.success
                            iconGlyph: root.keepAwakeIcon()
                            title: "Keep Awake"
                            subtitle: root.keepAwake ? "On" : "Off"
                            active: root.keepAwake
                            onClicked: root.toggleKeepAwake()
                        }

                        QuickTile {
                            Layout.fillWidth: true
                            Layout.minimumHeight: 76
                            Layout.preferredHeight: 76
                            Layout.maximumHeight: 76
                            compact: true
                            accentColor: root.powerProfileColor()
                            activeIconColor: root.powerProfile === "balanced" ? "#ffffff" : "#000000"
                            iconGlyph: root.powerIcon()
                            title: "Power"
                            subtitle: root.powerProfileLoaded ? root.powerProfile : "loading"
                            active: root.powerProfileLoaded
                            onClicked: root.cyclePowerProfile()
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "Notifications"
                        color: Palette.Theme.textMuted
                        font.family: Palette.Theme.fontMono
                        font.pixelSize: 11
                        Layout.fillWidth: true
                    }

                    Text {
                        text: String(root.notificationCount)
                        color: Palette.Theme.textMuted
                        font.family: Palette.Theme.fontMono
                        font.pixelSize: 11
                        Layout.rightMargin: 2
                    }

                    ActionChip {
                        label: "Clear all"
                        active: false
                        onClicked: root.clearAllNotifications()
                    }
                }

                Divider {
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        anchors.centerIn: parent
                        text: "No notifications"
                        color: Palette.Theme.textMuted
                        font.family: Palette.Theme.fontMono
                        font.pixelSize: 12
                        visible: root.notificationCount === 0
                    }

                    ListView {
                        anchors.fill: parent
                        clip: true
                        spacing: 10
                        model: root.notificationCenter ? root.notificationCenter.groupedNotifications : []
                        visible: root.notificationCount > 0
                        reuseItems: true
                        cacheBuffer: 320

                        delegate: NotificationGroupCard {
                            required property var modelData
                            width: ListView.view.width
                            notificationCenter: root.notificationCenter
                            group: modelData
                        }
                    }
                }
            }
        }

        Item {
            id: detailView
            anchors.fill: parent
            anchors.margins: 12
            opacity: root.showingDetail ? 1 : 0
            scale: root.showingDetail ? 1 : 0.98
            transformOrigin: Item.Top
            enabled: root.showingDetail

            Behavior on opacity {
                NumberAnimation {
                    duration: 210
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 320
                    easing.type: Easing.OutCubic
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        implicitWidth: 28
                        implicitHeight: 28
                        radius: 14
                        color: Palette.Theme.surfaceContainerHigh
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            anchors.centerIn: parent
                            text: root.detailMode === "wifi" ? root.wifiIcon() : root.bluetoothIcon()
                            color: Palette.Theme.info
                            font.family: Palette.Theme.fontIcons
                            font.pixelSize: 17
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Text {
                        text: root.detailMode === "wifi" ? "Wi-Fi networks" : "Bluetooth devices"
                        color: Palette.Theme.textPrimary
                        font.family: Palette.Theme.fontMono
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    IconButton {
                        icon: "\ue5c4"
                        implicitWidth: 28
                        implicitHeight: 28
                        onClicked: root.closeDetailWindow(true)
                    }

                    IconButton {
                        icon: "\ue5d5"
                        implicitWidth: 28
                        implicitHeight: 28
                        onClicked: {
                            if (root.detailMode === "wifi")
                                root.scanWifi(true);
                            else
                                root.scanBluetooth();
                        }
                    }
                }

                Divider {
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        anchors.centerIn: parent
                        text: root.detailMode === "wifi" ? (root.wifiScanning ? "Scanning" : "No networks") : (root.bluetoothScanning ? "Scanning" : "No devices")
                        color: Palette.Theme.textMuted
                        font.family: Palette.Theme.fontMono
                        font.pixelSize: 12
                        visible: detailList.count === 0
                    }

                    ListView {
                        id: detailList

                        anchors.fill: parent
                        clip: true
                        spacing: 0
                        model: root.detailMode === "wifi" ? wifiNetworkModel : bluetoothDeviceModel
                        reuseItems: true
                        cacheBuffer: 240

                        delegate: DeviceRow {
                            required property var modelData

                            width: ListView.view.width
                            iconGlyph: root.detailMode === "wifi" ? root.wifiIcon() : root.bluetoothIcon()
                            title: root.detailMode === "wifi" ? modelData.ssid : modelData.name
                            subtitle: root.detailMode === "wifi" ? (modelData.security + "  " + modelData.signal + "%") : modelData.address
                            active: root.detailMode === "wifi" ? modelData.active : false
                            onClicked: {
                                if (root.detailMode === "wifi")
                                    root.connectWifi(modelData.ssid);
                                else
                                    root.pairBluetooth(modelData.address);
                            }
                        }
                    }
                }
            }
        }
}
