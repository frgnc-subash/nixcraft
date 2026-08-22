import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    visible: false

    // "default" (the root config.json + *.wav set) is always first.
    property var packs: ["default"]
    property string activePack: "default"

    Component.onCompleted: refresh()

    function refresh() {
        packList.running = true;
        activePackRead.running = true;
    }

    function apply(packName) {
        if (packs.indexOf(packName) === -1)
            return;
        activePack = packName;
        applyPack.exec([Quickshell.env("HOME") + "/.config/wayclick/scripts/apply-pack.sh", packName]);
    }

    Process {
        id: packList
        // "default" is just another directory under soundpacks/ like every
        // other pack, but always listed first for a stable, predictable spot
        // in the picker rather than wherever it happens to sort alphabetically.
        command: ["sh", "-c", "printf 'default\\n'; for d in \"$HOME/.config/wayclick/soundpacks\"/*/; do [ -d \"$d\" ] || continue; d=\"${d%/}\"; b=\"${d##*/}\"; [ \"$b\" = default ] && continue; printf '%s\\n' \"$b\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.packs = text.trim() === "" ? ["default"] : text.trim().split("\n");
            }
        }
    }

    Process {
        id: activePackRead
        command: ["sh", "-c", "cat \"$HOME/.config/wayclick/.active_pack\" 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                var name = text.trim();
                root.activePack = name === "" ? "default" : name;
            }
        }
    }

    Process {
        id: applyPack
    }
}
