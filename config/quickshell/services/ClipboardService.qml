import Quickshell.Io
import QtQuick

Item {
    id: root
    visible: false

    property var entries: []

    function refresh() {
        history.running = true;
    }

    function copy(entryId) {
        if (!/^[0-9]+$/.test(entryId))
            return;
        decode.exec(["sh", "-c", "cliphist decode \"$1\" | wl-copy", "cliphist-decode", entryId]);
    }

    function clear() {
        entries = [];
        wipe.running = true;
    }

    Process {
        id: history
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                var rows = text.trim() === "" ? [] : text.trim().split("\n");
                var parsed = [];
                // cliphist already emits newest entries first. Keep that order
                // so the top row is always the latest copied item.
                for (var i = 0; i < rows.length && parsed.length < 50; ++i) {
                    var tab = rows[i].indexOf("\t");
                    if (tab > 0)
                        parsed.push({
                            id: rows[i].slice(0, tab),
                            text: rows[i].slice(tab + 1)
                        });
                }
                root.entries = parsed;
            }
        }
    }

    Process {
        id: decode
    }
    Process {
        id: wipe
        command: ["sh", "-c", "cliphist wipe; wl-copy --clear"]
    }
}
