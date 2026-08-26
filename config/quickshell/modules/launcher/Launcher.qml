import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../theme" as Palette
import "../../components/material"

// Note: DesktopEntries / DesktopEntry are part of the base "Quickshell"
// module, already imported above — no extra import line is needed.

Item {
    id: root

    anchors.fill: parent
    visible: false

    property real maxWidth: 4000
    property var controlCenter: null
    property var serviceManager: null

    readonly property int itemH: 56

    implicitWidth: Math.max(360, Math.min(maxWidth - 32, 430))
    // Fixed height (always room for maxVisible rows) rather than sizing to the
    // current result count — a count that changes on every keystroke would
    // otherwise retrigger the shared stage's grow/shrink animation constantly
    // while typing.
    implicitHeight: searchRow.height + divider.height + maxVisible * itemH + 8

    // ── IPC ───────────────────────────────────────────────────────
    signal aboutToOpen
    signal aboutToClose

    IpcHandler {
        target: "launcher"
        function toggle(): void {
            if (root.visible)
                root.closeLauncher();
            else
                root.openLauncher();
        }
        function open(): void {
            root.openLauncher();
        }
        function close(): void {
            root.closeLauncher();
        }
    }

    // ── app data ──────────────────────────────────────────────────
    property string query: ""
    property int selected: 0
    property var allApps: []
    property var displayApps: []

    readonly property int maxVisible: 5
    readonly property int visibleCount: Math.min(root.displayApps.length, root.maxVisible)

    function rebuildApps() {
        var entries = [...DesktopEntries.applications.values].filter(d => d && d.name && !d.noDisplay).sort((a, b) => a.name.localeCompare(b.name));

        allApps = entries;
        filterApps();
    }

    function filterApps() {
        var q = query.trim().toLowerCase();
        if (q === "") {
            displayApps = allApps;
        } else {
            displayApps = allApps.filter(d => {
                var name = (d.name || "").toLowerCase();
                var comment = (d.comment || "").toLowerCase();
                var keywords = (d.keywords || []).join(" ").toLowerCase();
                return name.indexOf(q) !== -1 || comment.indexOf(q) !== -1 || keywords.indexOf(q) !== -1;
            });
        }

        selected = 0;
    }

    onQueryChanged: filterApps()

    Connections {
        target: DesktopEntries
        function onApplicationsChanged(): void {
            root.rebuildApps();
        }
    }

    // ── launch helper ─────────────────────────────────────────────
    function launchApp(entry) {
        var commandText = entry.command ? entry.command.join(" ").toLowerCase() : "";
        var entryName = (entry.name || "").toLowerCase();
        if (entryName === "uuctl" || commandText.indexOf("uuctl") !== -1) {
            closeLauncher(true);
            if (serviceManager)
                serviceManager.open();
            return;
        }
        closeLauncher();
        if (entry.runInTerminal && entry.command && entry.command.length > 0)
            terminalLaunch.exec(["kitty", "-e"].concat(entry.command));
        else
            entry.execute();
    }

    function launchSelected() {
        if (displayApps.length > 0)
            launchApp(displayApps[selected]);
    }

    function moveSelectionTo(index) {
        if (displayApps.length === 0)
            return;
        selected = Math.max(0, Math.min(displayApps.length - 1, index));
        appList.positionViewAtIndex(selected, ListView.Contain);
    }

    function moveSelection(delta) {
        moveSelectionTo(selected + delta);
    }

    // Single source of truth for launcher keyboard shortcuts — shared by
    // both the search field and the list so behavior can't drift between them.
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
            moveSelectionTo(displayApps.length - 1);
            return true;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            event.accepted = true;
            launchSelected();
            return true;
        case Qt.Key_Escape:
            event.accepted = true;
            closeLauncher();
            return true;
        default:
            return false;
        }
    }

    Component {
        id: appDelegate

        Item {
            required property var modelData
            required property int index

            readonly property int absoluteIndex: index

            width: ListView.view.width
            height: 56

            Rectangle {
                anchors {
                    fill: parent
                    leftMargin: 6
                    rightMargin: 6
                    topMargin: 2
                    bottomMargin: 2
                }
                radius: 16
                color: {
                    if (absoluteIndex === root.selected || rowHover.containsMouse)
                        return Palette.Theme.surfaceContainerHigh;
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
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: 10
                    color: Palette.Theme.surfaceContainerHighest
                    Layout.alignment: Qt.AlignVCenter

                    IconImage {
                        id: appIcon
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        source: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""
                        smooth: true
                        mipmap: true
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: appIcon.status !== Image.Ready
                        text: "\ue3af"
                        font.family: Palette.Theme.fontIcons
                        font.pixelSize: 18
                        color: Palette.Theme.textSecondary
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        Layout.fillWidth: true
                        text: modelData.name || ""
                        color: Palette.Theme.textPrimary
                        font.family: Palette.Theme.fontMono
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.comment || ""
                        visible: text !== ""
                        color: Palette.Theme.textMuted
                        font.family: Palette.Theme.fontMono
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }
            }

            MouseArea {
                id: rowHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    root.selected = absoluteIndex;
                    appList.positionViewAtIndex(root.selected, ListView.Contain);
                }
                onClicked: {
                    root.selected = absoluteIndex;
                    root.launchApp(modelData);
                }
            }
        }
    }

    Process {
        id: terminalLaunch
    }

    // ── open / close ──────────────────────────────────────────────
    Component.onCompleted: rebuildApps()

    function openLauncher() {
        if (root.controlCenter && root.controlCenter.visible && typeof root.controlCenter.closeControlCenter === "function")
            root.controlCenter.closeControlCenter(true);
        if (root.visible)
            return;
        aboutToOpen();
        searchInput.text = "";
        query = "";
        selected = 0;
        visible = true;
        searchInput.forceActiveFocus();
    }

    function closeLauncher(immediate) {
        if (!root.visible)
            return;
        aboutToClose();
        if (immediate) {
            closeTimer.stop();
            root.visible = false;
            return;
        }
        closeTimer.restart();
    }

    Timer {
        id: closeTimer
        interval: 180
        onTriggered: root.visible = false
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

            // ── search bar ────────────────────────────────────────
            Item {
                id: searchRow
                Layout.fillWidth: true
                height: 62

                Rectangle {
                    id: searchField
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 10
                        bottomMargin: 8
                    }
                    radius: height / 2
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
                    spacing: 12

                    // leading search icon
                    Text {
                        text: "\ue8b6"
                        font.family: Palette.Theme.fontIcons
                        font.pixelSize: 18
                        color: Palette.Theme.textMuted
                        Layout.alignment: Qt.AlignVCenter
                    }

                    // text input
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
                            text: "Search, calculate or run"
                            font: parent.font
                            color: Palette.Theme.textMuted
                            visible: parent.text === ""
                        }

                        onTextChanged: root.query = text

                        Keys.onPressed: event => root.handleKey(event)
                    }

                    // clear button — fades in/out instead of popping
                    IconButton {
                        icon: "\ue5cd"
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

            // ── divider ───────────────────────────────────────────
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
                    visible: root.displayApps.length === 0

                    Text {
                        anchors.centerIn: parent
                        text: root.allApps.length === 0 ? "No applications found" : "No results for '" + root.query + "'"
                        color: Palette.Theme.textMuted
                        font.family: Palette.Theme.fontMono
                        font.pixelSize: 12
                    }
                }

                ListView {
                    id: appList
                    anchors.fill: parent
                    clip: true
                    model: root.displayApps
                    currentIndex: root.selected
                    Keys.priority: Keys.BeforeItem
                    highlightFollowsCurrentItem: true
                    preferredHighlightBegin: 0
                    preferredHighlightEnd: height
                    interactive: root.displayApps.length > root.maxVisible
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

                    delegate: appDelegate
                }
            }
        }
}
