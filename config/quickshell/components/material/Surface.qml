import QtQuick
import "../../theme" as Palette

Rectangle {
    id: root

    property color tint: Palette.Theme.surfaceTint
    property real tintOpacity: Palette.Theme.surfaceTintOpacity
    property color outlineColor: Palette.Theme.outlineVariant
    property real outlineWidth: 0

    radius: Palette.Theme.radiusLarge
    color: Palette.Theme.surfaceContainer
    clip: true
    border.color: root.outlineColor
    border.width: root.outlineWidth

    Rectangle {
        anchors.fill: parent
        anchors.margins: root.outlineWidth
        radius: parent.radius
        color: root.tint
        opacity: root.tintOpacity
    }
}
