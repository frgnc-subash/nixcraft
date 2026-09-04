import Quickshell
import Quickshell.Io
import QtQuick

// Persists which edge the bar lives on (top horizontal strip vs. left
// vertical dock) so it survives shell reloads/restarts. Plain data + a
// setter — the actual picker UI (modules/barlayout/BarLayoutPicker.qml,
// opened via IPC target "barlayout") is what decides when to call setVertical.
Item {
    id: root
    visible: false

    readonly property bool vertical: state.vertical

    function setVertical(value) {
        state.vertical = value;
        // Keeps Hyprland's workspace-slide direction (vertAni.lua vs
        // horizAni.lua) in sync with the bar's edge.
        applyOrientation.exec([Quickshell.env("HOME") + "/.config/quickshell/scripts/apply-bar-orientation.sh", value ? "vertical" : "horizontal"]);
    }

    Process {
        id: applyOrientation
    }

    FileView {
        id: stateFile
        path: Quickshell.cachePath("bar-layout.json")
        watchChanges: false
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: state
            // Matches the value you had set directly in config/Ui.js before
            // this became a live-toggleable, persisted setting.
            property bool vertical: true
        }
    }
}
