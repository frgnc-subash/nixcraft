import QtQuick
import QtQuick.Layouts
import "../theme" as Palette

// Material 3 Expressive desktop weather widget: a pill/stadium chip holding
// the current temperature and condition glyph, sourced from
// services/WeatherService.qml.
Item {
    id: root

    property var service: null
    property var widgetsService: null
    readonly property string widgetId: "weather"
    property real defaultX: 0
    property real defaultY: 0

    readonly property bool available: service ? service.available : false
    readonly property string tempC: service ? service.tempC : ""
    readonly property bool isStale: service ? service.isStale : false
    readonly property string glyph: service ? service.iconGlyph(service.weatherCode) : "cloud"

    implicitWidth: 148
    implicitHeight: 76
    width: implicitWidth
    height: implicitHeight
    visible: available

    // Free-floating on the desktop layer (not laid out by a parent Layout),
    // so position has to be set explicitly — falls back to the caller's
    // default corner spot until the widget has been dragged at least once.
    x: widgetsService && widgetsService.hasPosition(widgetId) ? widgetsService.positionX(widgetId) : defaultX
    y: widgetsService && widgetsService.hasPosition(widgetId) ? widgetsService.positionY(widgetId) : defaultY

    // Idle "breathing" pulse — Material 3 Expressive's continuous, gentle
    // motion rather than a perfectly static shape. Slightly out of phase
    // with the clock widget's own pulse so the pair doesn't beat in unison.
    transformOrigin: Item.Center
    SequentialAnimation on scale {
        loops: Animation.Infinite
        NumberAnimation {
            to: 1.025
            duration: 2800
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            to: 1.0
            duration: 2800
            easing.type: Easing.InOutSine
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Palette.Theme.secondaryContainer
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 10
        opacity: root.isStale ? 0.55 : 1.0

        Rectangle {
            implicitWidth: 40
            implicitHeight: 40
            radius: 20
            color: Palette.Theme.surfaceContainerHighest
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: root.glyph
                color: Palette.Theme.textPrimary
                font.family: Palette.Theme.fontIcons
                font.pixelSize: 22
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: root.tempC + "°"
            color: Palette.Theme.textPrimary
            font.family: Palette.Theme.fontMono
            font.pixelSize: 28
            font.weight: Font.Bold
        }
    }

    // Drag-to-reposition. Position is persisted on release rather than on
    // every move, to avoid hammering the state file.
    MouseArea {
        anchors.fill: parent
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        drag.target: root
        drag.minimumX: 0
        drag.minimumY: 0
        drag.maximumX: root.parent ? root.parent.width - root.width : 0
        drag.maximumY: root.parent ? root.parent.height - root.height : 0

        onPressed: root.z = 1000
        onReleased: {
            root.z = 0;
            if (root.widgetsService)
                root.widgetsService.setPosition(root.widgetId, root.x, root.y);
        }
    }
}
