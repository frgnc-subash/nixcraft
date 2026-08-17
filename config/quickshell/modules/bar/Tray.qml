import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme" as Palette

RowLayout {
    id: root
    spacing: 5

    // Pass the enclosing PanelWindow so right-click menus can position correctly.
    required property var parentWindow

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayIcon
            required property SystemTrayItem modelData

            implicitWidth: 16
            implicitHeight: 16
            Layout.alignment: Qt.AlignVCenter

            // ── icon ─────────────────────────────────────────────
            IconImage {
                anchors.centerIn: parent
                implicitSize: 16
                source: trayIcon.modelData.icon
                smooth: true
                mipmap: true
            }

            // ── hover state layer ────────────────────────────────
            Rectangle {
                anchors.fill: parent
                anchors.margins: -3
                radius: 4
                color: Palette.Theme.surfaceTint
                opacity: ma.containsMouse ? 0.08 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }

            // ── mouse handling ───────────────────────────────────
            MouseArea {
                id: ma
                anchors.fill: parent
                anchors.margins: -3
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton)
                        trayIcon.modelData.activate();
                    else if (mouse.button === Qt.MiddleButton)
                        trayIcon.modelData.secondaryActivate();
                    else if (mouse.button === Qt.RightButton && trayIcon.modelData.hasMenu)
                        trayIcon.modelData.display(root.parentWindow, trayIcon.x + mouse.x, trayIcon.y + mouse.y);
                }
            }

            // ── tooltip ──────────────────────────────────────────
            ToolTip {
                visible: ma.containsMouse && trayIcon.modelData.tooltipTitle !== ""
                text: {
                    var t = trayIcon.modelData.tooltipTitle;
                    var d = trayIcon.modelData.tooltipDescription;
                    return d !== "" ? t + "\n" + d : t;
                }
                delay: 600
                font.family: Palette.Theme.fontMono
                font.pixelSize: 11
            }
        }
    }
}
