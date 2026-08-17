pragma Singleton

import QtQuick

QtObject {
    id: root

    // Palette values are properties, not JavaScript constants. Any assignment
    // here notifies every bound component and updates the UI immediately.
    property var bg: "rgba(7, 10, 14, 0.62)"
    property var surface: "rgba(7, 10, 14, 0.62)"
    property var surfaceContainerLow: "rgba(12, 15, 20, 0.72)"
    property var surfaceContainer: "rgba(16, 20, 27, 0.82)"
    property var surfaceContainerHigh: "rgba(26, 32, 42, 0.88)"
    property var surfaceContainerHighest: "rgba(38, 47, 61, 0.92)"
    property var surfaceTint: "#eef5ff"
    property var outlineVariant: "rgba(132, 151, 170, 0.42)"
    property var border: "rgba(132, 151, 170, 0.42)"
    property var accent: "#8bd5ff"
    property var accentText: "#071017"
    property var info: "#8bd5ff"
    property var warning: "#f0b080"
    property var success: "#8ff0c7"
    property var errorColor: "#ff6b6b"
    property var accentLight: "#141e26"
    property var primaryContainer: "rgba(29, 45, 59, 0.86)"
    property var primaryText: "#b9e6ff"
    property var secondaryContainer: "rgba(48, 36, 65, 0.84)"
    property var secondaryContainerHover: "#2e3c4d"
    // Names beginning with `on` and an uppercase letter are reserved for QML
    // signal handlers, so keep the semantic color under a safe property name.
    property var secondaryText: "#decaff"
    property var wsInactive: "#8092a1"
    property var textPrimary: "#eef5ff"
    property var textTitle: "#eef5ff"
    property var textSecondary: "#9aa8ba"
    property var textMuted: "#899cac"
    property var textDisabled: "rgba(132, 151, 170, 0.42)"

    readonly property real surfaceTintOpacity: 0.015
    readonly property string fontMono: "SF Mono "
    readonly property string fontIcons: "Material Symbols Rounded "
    readonly property int radiusSmall: 10
    readonly property int radiusMedium: 16
    readonly property int radiusLarge: 22
    readonly property int radiusExtraLarge: 28
    readonly property int iconButtonSize: 32

    function apply(values) {
        var paletteKeys = ["bg", "surface", "surfaceContainerLow", "surfaceContainer", "surfaceContainerHigh", "surfaceContainerHighest", "surfaceTint", "outlineVariant", "border", "accent", "accentText", "info", "warning", "success", "errorColor", "accentLight", "primaryContainer", "primaryText", "secondaryContainer", "secondaryContainerHover", "secondaryText", "wsInactive", "textPrimary", "textTitle", "textSecondary", "textMuted", "textDisabled"];
        for (var key in values) {
            if (paletteKeys.indexOf(key) !== -1)
                root[key] = values[key];
        }
    }
}
