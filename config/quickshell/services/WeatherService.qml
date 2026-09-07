import Quickshell
import Quickshell.Io
import QtQuick

// Standalone weather fetch/cache for the desktop weather widget. Mirrors
// modules/bar/Weather.qml's wttr.in + cache-file approach but is kept
// separate so the desktop widget can be toggled independently of the bar
// (and doesn't need the bar's nmcli reconnect-triggered refresh).
Item {
    id: root
    visible: false

    property string tempC: ""
    property string conditionText: ""
    property int weatherCode: 0
    property bool isStale: false
    readonly property bool available: tempC !== ""

    function iconGlyph(code) {
        if (code === 113)
            return "wb_sunny";
        if (code === 116)
            return "partly_cloudy_day";
        if ([119, 122, 143, 248, 260].includes(code))
            return "cloud";
        if ([176, 179, 182, 185, 200, 263, 266, 293, 296, 299, 302, 305, 308, 311, 314, 317, 320, 353, 356, 359, 386, 389].includes(code))
            return "rainy";
        if ([227, 230, 323, 326, 329, 332, 335, 338, 350, 362, 365, 368, 371, 374, 377, 392, 395].includes(code))
            return "weather_snowy";
        return "cloud";
    }

    function refresh() {
        weatherProcess.running = true;
    }

    // Persistent last-known-good reading, survives quickshell/session restarts.
    FileView {
        id: cacheFile
        path: Quickshell.cachePath("desktop-weather-cache.json")
        watchChanges: false
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: cache
            property string tempC: ""
            property string conditionText: ""
            property int weatherCode: 0

            onTempCChanged: {
                if (root.tempC === "" && cache.tempC !== "") {
                    root.tempC = cache.tempC;
                    root.conditionText = cache.conditionText;
                    root.weatherCode = cache.weatherCode;
                    root.isStale = true;
                }
            }
        }
    }

    Timer {
        interval: 5 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: weatherProcess
        command: ["curl", "-s", "--max-time", "8", "https://wttr.in/?format=j1"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var current = JSON.parse(text).current_condition[0];
                    root.tempC = current.temp_C;
                    root.conditionText = current.weatherDesc[0].value;
                    root.weatherCode = parseInt(current.weatherCode);
                    root.isStale = false;

                    cache.tempC = root.tempC;
                    cache.conditionText = root.conditionText;
                    cache.weatherCode = root.weatherCode;
                } catch (e) {
                    // Transient network/parse failure — keep showing the
                    // last good reading (live or cached) instead of blanking out.
                }
            }
        }
    }
}
