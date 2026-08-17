import QtQuick
import "../material"
import "../../theme" as Palette
import "../../config/Ui.js" as Ui

Surface {
    id: root

    property bool presented: false
    property real topOffset: Ui.overlayTop

    anchors.horizontalCenter: parent.horizontalCenter
    y: root.presented ? root.topOffset : 8
    opacity: root.presented ? 1 : 0
    scale: root.presented ? 1 : 0.84
    transformOrigin: Item.Top
    radius: Ui.overlayRadius
    color: Palette.Theme.surfaceContainer
    outlineWidth: 1
    outlineColor: Palette.Theme.border

    Behavior on y {
        NumberAnimation {
            duration: 240
            easing.type: Easing.OutCubic
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutBack
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }
}
