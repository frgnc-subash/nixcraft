import QtQuick

Meter {
    iconGlyph: label === "Muted" || value <= 0.01 ? "\ue04f" : value < 0.5 ? "\ue04d" : "\ue050"
}
