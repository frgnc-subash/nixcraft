import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../../theme" as Palette

RowLayout {
    spacing: 3

    Repeater {
        model: 10

        Rectangle {
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

            implicitHeight: 10
            implicitWidth: isActive ? 45 : 10
            radius: height / 2
            // Text-muted is opaque in every palette, unlike transparent
            // surface outlines used by AMOLED themes such as Ryo.
            color: isActive ? Palette.Theme.accent : Palette.Theme.textMuted
            border.width: 0
            scale: isActive ? 1.0 : 0.9

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 600
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: 300
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + (index + 1))
            }
        }
    }
}
