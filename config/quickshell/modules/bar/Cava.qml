import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import "../../theme" as Palette

Item {
    id: root

    property bool active: true
    property bool cavaEnabled: true
    property int barCount: 14
    property var levels: []
    property string configPath: String(Qt.resolvedUrl("cava.conf")).replace("file://", "")
    implicitWidth: 110
    implicitHeight: 18

    // True if ANY mpris player is currently playing — not just whichever
    // single "selected" player a parent might bind `active` to. This way
    // cava keeps running as long as something, anything, is making sound.
    readonly property bool anyPlaying: {
        var list = Mpris.players.values;
        for (var i = 0; i < list.length; i++) {
            if (list[i].isPlaying)
                return true;
        }
        return false;
    }

    // Actual "should cava be running" condition combines the external
    // active flag (e.g. widget visibility) with real playback state.
    readonly property bool shouldRun: root.active && root.anyPlaying

    function parseLine(line) {
        var values = line.trim().split(/[^0-9]+/).filter(function (part) {
            return part.length > 0;
        }).map(function (part) {
            return Math.max(0, Math.min(1, Number(part) / 8));
        });
        if (values.length > 0) {
            levels = values.slice(0, barCount);
            canvas.requestPaint();
        }
    }

    onShouldRunChanged: {
        cavaEnabled = shouldRun;
        if (!shouldRun)
            levels = [];
        canvas.requestPaint();
    }

    Process {
        id: cava
        command: ["cava", "-p", root.configPath]
        running: root.shouldRun && root.cavaEnabled
        onExited: {
            if (root.shouldRun) {
                root.cavaEnabled = false;
                retryCava.restart();
            }
        }
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.parseLine(data)
        }
    }

    Timer {
        id: retryCava
        interval: 2000
        onTriggered: if (root.shouldRun)
            root.cavaEnabled = true
    }

    Timer {
        id: fallbackPulse
        interval: 120
        repeat: true
        running: root.shouldRun && root.levels.length === 0
        onTriggered: canvas.requestPaint()
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var count = root.barCount;
            var gap = 3;
            var barWidth = Math.max(2, (width - gap * (count - 1)) / count);
            var now = Date.now() / 140;
            ctx.fillStyle = Palette.Theme.accent;
            for (var i = 0; i < count; i++) {
                var level = root.levels.length > i ? root.levels[i] : (0.25 + Math.sin(now + i * 0.55) * 0.25);
                var h = Math.max(3, level * height);
                var x = i * (barWidth + gap);
                var y = (height - h) / 2;
                var r = barWidth / 2;
                ctx.globalAlpha = 0.45 + level * 0.55;
                ctx.beginPath();
                ctx.moveTo(x + r, y);
                ctx.lineTo(x + barWidth - r, y);
                ctx.quadraticCurveTo(x + barWidth, y, x + barWidth, y + r);
                ctx.lineTo(x + barWidth, y + h - r);
                ctx.quadraticCurveTo(x + barWidth, y + h, x + barWidth - r, y + h);
                ctx.lineTo(x + r, y + h);
                ctx.quadraticCurveTo(x, y + h, x, y + h - r);
                ctx.lineTo(x, y + r);
                ctx.quadraticCurveTo(x, y, x + r, y);
                ctx.closePath();
                ctx.fill();
            }
            ctx.globalAlpha = 1;
        }
    }
}
