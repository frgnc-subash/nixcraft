import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme" as Palette
import "../../components/material"

Item {
    id: root

    anchors.fill: parent
    visible: false

    required property var service
    property real maxWidth: 4000
    property var launcher: null
    property var controlCenter: null
    property var powerMenu: null

    readonly property int itemH: 40
    readonly property int maxVisible: 5

    implicitWidth: Math.max(360, Math.min(maxWidth - 32, 430))
    implicitHeight: searchRow.height + divider.height + visibleCount * itemH + 8

    signal aboutToOpen
    signal aboutToClose

    IpcHandler {
        target: "wayclickpack"
        function toggle(): void {
            if (root.visible)
                root.close();
            else
                root.open();
        }
        function open(): void {
            root.open();
        }
        function close(): void {
            root.close();
        }
    }

    // ── pack data ────────────────────────────────────────────────
    property string query: ""
    property int selected: 0
    readonly property var allPacks: service ? service.packs : []
    property var displayPacks: []

    readonly property int visibleCount: Math.min(root.displayPacks.length, root.maxVisible)

    // Folder names are the stable pack IDs (used by apply-pack.sh and
    // .active_pack), so these are display-only overrides — anything not
    // listed falls back to a generic title-cased version.
    readonly property var displayNames: ({
            "default": "Default",
            "animal_crossing_nl": "Animal Crossing: New Leaf",
            "animalese_gamecube": "Animalese (GameCube)",
            "audio_pack_1": "Audio Pack 1",
            "cherry_mx_black_abs": "Cherry MX Black (ABS)",
            "cherry_mx_black_pbt": "Cherry MX Black (PBT)",
            "cherry_mx_brown_abs": "Cherry MX Brown (ABS)",
            "cherry_mx_brown_pbt": "Cherry MX Brown (PBT)",
            "cherry_mx_red_abs": "Cherry MX Red (ABS)",
            "cherry_mx_red_pbt": "Cherry MX Red (PBT)",
            "cry_of_fear": "Cry of Fear",
            "eg_crystal_purple": "EG Crystal Purple",
            "glorious_panda": "Glorious Panda",
            "kailh_box_white": "Kailh Box White",
            "minimal_tick": "Minimal Tick",
            "nk_cream": "NK Cream",
            "osu": "osu!",
            "rosenclick": "Rosenclick",
            "sine_bumps": "Sine Bumps",
            "steelseries_apex_pro_v2": "SteelSeries Apex Pro V2",
            "tealios_v2": "Tealios V2",
            "trails_in_the_sky": "Trails in the Sky",
            "unicomp_classic": "Unicomp Classic",
            "voice_demo": "Voice Demo"
        })

    function displayName(packName) {
        if (displayNames[packName])
            return displayNames[packName];
        return packName.split("_").map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(" ");
    }

    function filterPacks() {
        var q = query.trim().toLowerCase();
        if (q === "") {
            displayPacks = allPacks;
        } else {
            displayPacks = allPacks.filter(p => root.displayName(p).toLowerCase().indexOf(q) !== -1);
        }
        selected = 0;
    }

    onQueryChanged: filterPacks()
    onAllPacksChanged: filterPacks()

    // ── apply helper ─────────────────────────────────────────────
    function applyPack(packName) {
        close();
        service.apply(packName);
    }

    function applySelected() {
        if (displayPacks.length > 0)
            applyPack(displayPacks[selected]);
    }

    function moveSelectionTo(index) {
        if (displayPacks.length === 0)
            return;
        selected = Math.max(0, Math.min(displayPacks.length - 1, index));
        packList.positionViewAtIndex(selected, ListView.Contain);
    }

    function moveSelection(delta) {
        moveSelectionTo(selected + delta);
    }

    function handleKey(event) {
        switch (event.key) {
        case Qt.Key_Up:
            event.accepted = true;
            moveSelection(-1);
            return true;
        case Qt.Key_Down:
            event.accepted = true;
            moveSelection(1);
            return true;
        case Qt.Key_Home:
            event.accepted = true;
            moveSelectionTo(0);
            return true;
        case Qt.Key_End:
            event.accepted = true;
            moveSelectionTo(displayPacks.length - 1);
            return true;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            event.accepted = true;
            applySelected();
            return true;
        case Qt.Key_Escape:
            event.accepted = true;
            close();
            return true;
        default:
            return false;
        }
    }

    // ── open / close ─────────────────────────────────────────────
    function open() {
        if (launcher && launcher.visible)
            launcher.closeLauncher(true);
        if (controlCenter && controlCenter.visible)
            controlCenter.closeControlCenter(true);
        if (powerMenu && powerMenu.visible)
            powerMenu.closePowerMenu(true);
        aboutToOpen();
        searchInput.text = "";
        query = "";
        service.refresh();
        filterPacks();
        selected = Math.max(0, displayPacks.indexOf(service.activePack));
        visible = true;
        searchInput.forceActiveFocus();
    }

    function close(immediate) {
        if (!visible)
            return;
        aboutToClose();
        if (immediate) {
            closeTimer.stop();
            visible = false;
            return;
        }
        closeTimer.restart();
    }

    Timer {
        id: closeTimer
        interval: 180
        onTriggered: root.visible = false
    }

    Component {
        id: packDelegate

        Item {
            required property string modelData
            required property int index

            readonly property bool isActive: modelData === service.activePack

            width: ListView.view.width
            height: root.itemH

            Rectangle {
                anchors {
                    fill: parent
                    leftMargin: 6
                    rightMargin: 6
                    topMargin: 1
                    bottomMargin: 1
                }
                radius: 12
                color: {
                    if (index === root.selected || rowHover.containsMouse)
                        return Palette.Theme.accentLight;
                    return "transparent";
                }
                border.width: 0
                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }
            }

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 12
                    rightMargin: 12
                }
                spacing: 12

                Rectangle {
                    implicitWidth: 24
                    implicitHeight: 24
                    radius: 8
                    color: Palette.Theme.surfaceContainerHighest
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: Palette.Theme.fontIcons
                        font.pixelSize: 13
                        color: Palette.Theme.textSecondary
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        Layout.fillWidth: true
                        text: root.displayName(modelData)
                        color: Palette.Theme.textPrimary
                        font.family: Palette.Theme.fontMono
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                }

                Text {
                    visible: isActive
                    text: ""
                    font.family: Palette.Theme.fontIcons
                    font.pixelSize: 14
                    color: Palette.Theme.accent
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            MouseArea {
                id: rowHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    root.selected = index;
                    packList.positionViewAtIndex(root.selected, ListView.Contain);
                }
                onClicked: {
                    root.selected = index;
                    root.applyPack(modelData);
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── search bar ───────────────────────────────────────────
        Item {
            id: searchRow
            Layout.fillWidth: true
            height: 62

            Rectangle {
                anchors {
                    fill: parent
                    leftMargin: 10
                    rightMargin: 10
                    topMargin: 10
                    bottomMargin: 8
                }
                radius: 18
                color: Palette.Theme.surfaceContainerHigh
                border.width: 0
            }

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 22
                    rightMargin: 18
                    topMargin: 10
                    bottomMargin: 8
                }
                spacing: 10

                Text {
                    text: ""
                    font.family: Palette.Theme.fontIcons
                    font.pixelSize: 18
                    color: Palette.Theme.textSecondary
                    Layout.alignment: Qt.AlignVCenter
                }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    Keys.priority: Keys.BeforeItem
                    font.family: Palette.Theme.fontMono
                    font.pixelSize: 13
                    color: Palette.Theme.textPrimary
                    selectionColor: Palette.Theme.accent + "44"
                    clip: true
                    verticalAlignment: TextInput.AlignVCenter

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "Search sound packs…"
                        font: parent.font
                        color: Palette.Theme.textMuted
                        visible: parent.text === ""
                    }

                    onTextChanged: root.query = text

                    Keys.onPressed: event => root.handleKey(event)
                }

                IconButton {
                    icon: ""
                    opacity: searchInput.text !== "" ? 1 : 0
                    visible: opacity > 0
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: {
                        searchInput.text = "";
                        searchInput.forceActiveFocus();
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                        }
                    }
                }
            }
        }

        // ── divider ──────────────────────────────────────────────
        Divider {
            id: divider
            Layout.fillWidth: true
        }

        Item {
            id: listPanel
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                anchors.fill: parent
                visible: root.displayPacks.length === 0

                Text {
                    anchors.centerIn: parent
                    text: root.allPacks.length === 0 ? "No sound packs found" : "No results for '" + root.query + "'"
                    color: Palette.Theme.textMuted
                    font.family: Palette.Theme.fontMono
                    font.pixelSize: 12
                }
            }

            ListView {
                id: packList
                anchors.fill: parent
                clip: true
                model: root.displayPacks
                currentIndex: root.selected
                Keys.priority: Keys.BeforeItem
                highlightFollowsCurrentItem: true
                preferredHighlightBegin: 0
                preferredHighlightEnd: height
                interactive: root.displayPacks.length > root.maxVisible
                boundsBehavior: Flickable.StopAtBounds
                spacing: 0
                focus: true
                keyNavigationEnabled: true
                reuseItems: true
                cacheBuffer: 240

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 4
                    interactive: false

                    contentItem: Rectangle {
                        implicitWidth: 4
                        radius: 2
                        color: Palette.Theme.accent
                        opacity: parent.active ? 0.6 : 0.25
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 120
                            }
                        }
                    }
                    background: Item {}
                }

                Keys.onPressed: event => root.handleKey(event)

                delegate: packDelegate
            }
        }
    }
}
