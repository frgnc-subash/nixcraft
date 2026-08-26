import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    visible: false

    // "none" (no screen shader) is always first.
    property var shaders: ["none"]
    property string activeShader: "none"

    Component.onCompleted: refresh()

    function refresh() {
        shaderList.running = true;
        activeShaderRead.running = true;
    }

    function apply(shaderName) {
        if (shaders.indexOf(shaderName) === -1)
            return;
        activeShader = shaderName;
        applyShader.exec([Quickshell.env("HOME") + "/.config/quickshell/scripts/apply-shader.sh", shaderName]);
    }

    Process {
        id: shaderList
        command: ["sh", "-c", "printf 'none\\n'; for f in \"$HOME/.config/hypr/shaders\"/*.glsl; do [ -f \"$f\" ] || continue; b=\"${f##*/}\"; printf '%s\\n' \"${b%.glsl}\"; done | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.shaders = text.trim() === "" ? ["none"] : text.trim().split("\n");
            }
        }
    }

    Process {
        id: activeShaderRead
        command: ["sh", "-c", "sed -n 's/.*\"\\(.*\\)\".*/\\1/p' \"$HOME/.config/hypr/shader.lua\" 2>/dev/null | head -n 1 | xargs -r basename | sed 's/\\.glsl$//'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var name = text.trim();
                root.activeShader = name === "" ? "none" : name;
            }
        }
    }

    Process {
        id: applyShader
    }
}
