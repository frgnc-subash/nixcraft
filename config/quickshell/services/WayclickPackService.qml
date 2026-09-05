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
