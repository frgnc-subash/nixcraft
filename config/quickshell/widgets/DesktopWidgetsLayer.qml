import Quickshell
import Quickshell.Wayland
import QtQuick
import "../services"

// Hosts the desktop widgets (clock, weather) on the wlr background layer —
// below normal windows, above the wallpaper — so they read as part of the
// desktop rather than another panel. Covers the whole screen so each widget
// can be dragged anywhere on it; the input mask is carved down to just the
// widgets' own bounds so every other click/gesture still passes straight
// through to the desktop underneath.
PanelWindow {
    id: root

    property var widgetsService: null

    readonly property bool clockOn: widgetsService ? widgetsService.isEnabled("clock") : true
    readonly property bool weatherOn: widgetsService ? widgetsService.isEnabled("weather") : true

    // Default corner spot (bottom-right, clock stacked above weather,
    // centered on each other) used until a widget has been dragged.
    readonly property real margin: 36
    readonly property real spacing: 16

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    color: "transparent"
    exclusiveZone: -1
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "quickshell:desktop-widgets"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    visible: root.clockOn || root.weatherOn

    mask: Region {
        Region {
            x: clockWidget.x
            y: clockWidget.y
            width: clockWidget.width
            height: clockWidget.height
            intersection: Intersection.Combine
        }
        Region {
            x: weatherWidget.x
            y: weatherWidget.y
            width: weatherWidget.width
            height: weatherWidget.height
            intersection: Intersection.Combine
        }
    }

    WeatherService {
        id: weatherService
    }

    ClockWidget {
        id: clockWidget
        widgetsService: root.widgetsService
        visible: root.clockOn
        defaultX: root.width - root.margin - 140
        defaultY: root.height - root.margin - root.spacing - 132 - 76
    }

    WeatherWidget {
        id: weatherWidget
        service: weatherService
        widgetsService: root.widgetsService
        visible: root.weatherOn
        defaultX: root.width - root.margin - 148
        defaultY: root.height - root.margin - 76
    }
}
