import Quickshell
import QtQuick
import "../../theme" as Palette

Text {
    text: Qt.formatDateTime(clock.date, "hh:mm")

    color: Palette.Theme.textPrimary
    font.family: Palette.Theme.fontMono
    font.pixelSize: 12
    font.weight: Font.DemiBold

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
