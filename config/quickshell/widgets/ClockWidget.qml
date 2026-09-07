import Quickshell
import QtQuick
import QtQuick.Layouts
import "../theme" as Palette
import "../components/material"

// Material 3 Expressive desktop clock: a scalloped "cookie" dial with a
// digital hh/mm readout, a decorative sweeping hand, and two perched badges
// (day-of-month, seconds) — an at-a-glance widget rather than a literal
// analog clock.
Item {
    id: root

    property var widgetsService: null
    readonly property string widgetId: "clock"
    property real defaultX: 0
    property real defaultY: 0

    implicitWidth: 132
    implicitHeight: 132
    width: implicitWidth
    height: implicitHeight

    // Free-floating on the desktop layer (not laid out by a parent Layout),
    // so position has to be set explicitly — falls back to the caller's
    // default corner spot until the widget has been dragged at least once.
    x: widgetsService && widgetsService.hasPosition(widgetId) ? widgetsService.positionX(widgetId) : defaultX
    y: widgetsService && widgetsService.hasPosition(widgetId) ? widgetsService.positionY(widgetId) : defaultY

    // Idle "breathing" pulse — Material 3 Expressive's continuous, gentle
    // motion rather than a perfectly static shape. Runs on a slightly
    // different period than the weather widget's pulse so the pair doesn't
    // beat in unison.
    transformOrigin: Item.Center
    SequentialAnimation on scale {
        loops: Animation.Infinite
        NumberAnimation {
            to: 1.02
            duration: 3200
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            to: 1.0
            duration: 3200
            easing.type: Easing.InOutSine
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    readonly property int hours24: clock.date.getHours()
    readonly property int hours12: (hours24 % 12) === 0 ? 12 : (hours24 % 12)
    readonly property int minutes: clock.date.getMinutes()
    readonly property int seconds: clock.date.getSeconds()
    readonly property int dayOfMonth: clock.date.getDate()

    // Sweeps a full turn per hour, nudged by the current second so it
    // isn't dead-still between minute ticks.
    readonly property real handAngle: (minutes + seconds / 60) / 60 * 360

    CookieShape {
        anchors.fill: parent
        color: Palette.Theme.secondaryContainer
        lobes: 12
        amplitude: 0.05
    }

    // Zero-size pivot at the dial's center — rotating it carries the hand
    // rectangle (positioned relative to it) around the same point.
    Item {
        anchors.centerIn: parent
        width: 1
        height: 1
        rotation: root.handAngle

        Behavior on rotation {
            RotationAnimation {
                duration: 400
                direction: RotationAnimation.Shortest
            }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: -height * 0.85
            width: root.width * 0.1
            height: root.height * 0.6
            radius: width / 2
            color: Palette.Theme.accent
            opacity: 0.55
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: -6

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.hours12 < 10 ? "0" + root.hours12 : "" + root.hours12
            color: Palette.Theme.textPrimary
            opacity: 0.9
            font.family: Palette.Theme.fontMono
            font.pixelSize: 34
            font.weight: Font.Bold
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.minutes < 10 ? "0" + root.minutes : "" + root.minutes
            color: Palette.Theme.textPrimary
            opacity: 0.9
            font.family: Palette.Theme.fontMono
            font.pixelSize: 34
            font.weight: Font.Bold
        }
    }

    // Day-of-month badge, perched on the dial's upper-left rim.
    CookieShape {
        width: 30
        height: 30
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: -2
        anchors.leftMargin: -2
        lobes: 6
        amplitude: 0.16
        color: Palette.Theme.success

        Text {
            anchors.centerIn: parent
            text: root.dayOfMonth
            color: Palette.Theme.bg
            font.family: Palette.Theme.fontMono
            font.pixelSize: 11
            font.weight: Font.Bold
        }
    }

    // Seconds badge, perched on the dial's lower-right rim.
    Rectangle {
        width: 30
        height: 30
        radius: 15
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: -2
        anchors.rightMargin: -2
        color: Palette.Theme.surfaceContainerHighest

        Text {
            anchors.centerIn: parent
            text: root.seconds < 10 ? "0" + root.seconds : "" + root.seconds
            color: Palette.Theme.textPrimary
            font.family: Palette.Theme.fontMono
            font.pixelSize: 11
            font.weight: Font.Bold
        }
    }

    // Drag-to-reposition — covers the whole widget rather than just the
    // dial, so grabbing the badges works too. Position is persisted on
    // release rather than on every move, to avoid hammering the state file.
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
