import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../../theme" as Palette
import "../../components/material"
import "../controlcenter"

WlSessionLockSurface {
    id: root

    required property var lockScreen

    // Opaque fallback so nothing behind the compositor's lock surface can
    // ever show through before the wallpaper image finishes loading.
    color: "#000000"

    property var player: {
        var list = Mpris.players.values;
        for (var i = 0; i < list.length; i++) {
            if (list[i].isPlaying)
                return list[i];
        }
        return list.length > 0 ? list[0] : null;
    }
    readonly property bool hasPlayer: player !== null
    readonly property real progress: (hasPlayer && player.length > 0) ? Math.min(1, Math.max(0, player.position / player.length)) : 0

    Timer {
        interval: 500
        running: root.hasPlayer && root.player.isPlaying
        repeat: true
        onTriggered: if (root.player)
            root.player.positionChanged()
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Image {
        id: bg
        anchors.fill: parent
        source: root.lockScreen.wallpaperPath ? "file://" + root.lockScreen.wallpaperPath : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        cache: false
        visible: false
    }

    MultiEffect {
        anchors.fill: bg
        source: bg
        blurEnabled: true
        blur: 0.5
        blurMax: 48
        brightness: -0.15
        saturation: -0.15
    }

    Rectangle {
        anchors.fill: parent
        color: Palette.Theme.bg
        opacity: 0.32
    }

    MouseArea {
        anchors.fill: parent
        onClicked: passwordInput.forceActiveFocus()
    }

    Component.onCompleted: {
        passwordInput.forceActiveFocus();
        fadeIn.start();
    }

    ColumnLayout {
        id: content
        anchors.centerIn: parent
        spacing: 16
        width: 340
        opacity: 0

        NumberAnimation {
            id: fadeIn
            target: content
            property: "opacity"
            to: 1
            duration: 320
            easing.type: Easing.OutCubic
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 96
            height: 96
            radius: 48
            color: Palette.Theme.surfaceContainer
            border.width: 2
            border.color: Palette.Theme.border
            clip: true

            Image {
                anchors.fill: parent
                source: "file://" + Quickshell.env("HOME") + "/Pictures/misc/pfp.png"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "hi, " + Quickshell.env("USER")
            color: Palette.Theme.textPrimary
            font.family: Palette.Theme.fontMono
            font.pixelSize: 14
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDateTime(clock.date, "hh:mm")
            color: Palette.Theme.textPrimary
            font.family: Palette.Theme.fontMono
            font.pixelSize: 64
            font.weight: Font.Bold
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDateTime(clock.date, "ddd, MMM d")
            color: Palette.Theme.textSecondary
            font.family: Palette.Theme.fontMono
            font.pixelSize: 13
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 6
            spacing: 8

            Surface {
                id: pwField
                Layout.preferredWidth: 220
                Layout.preferredHeight: 44
                Layout.alignment: Qt.AlignHCenter
                radius: 22
                color: Palette.Theme.surfaceContainer
                outlineColor: root.lockScreen.authFailed ? Palette.Theme.errorColor : Palette.Theme.border
                outlineWidth: root.lockScreen.authFailed ? 1.5 : 1

                transform: Translate {
                    id: shakeTranslate
                }

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.margins: 4
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    echoMode: TextInput.NoEcho
                    focus: true
                    selectByMouse: false
                    enabled: !root.lockScreen.authBusy

                    Keys.onEscapePressed: text = ""

                    onAccepted: {
                        var pw = text;
                        text = "";
                        root.lockScreen.submit(pw);
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: passwordInput.text.length === 0
                    text: root.lockScreen.authBusy ? "Verifying…" : "Enter password"
                    color: Palette.Theme.textMuted
                    font.family: Palette.Theme.fontMono
                    font.pixelSize: 12
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 7
                    visible: passwordInput.text.length > 0

                    Repeater {
                        model: Math.min(passwordInput.text.length, 16)
                        delegate: Rectangle {
                            width: 7
                            height: 7
                            radius: 3.5
                            color: root.lockScreen.authFailed ? Palette.Theme.errorColor : Palette.Theme.accent
                        }
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                visible: root.lockScreen.failedAttempts > 0
                text: root.lockScreen.failedAttempts + (root.lockScreen.failedAttempts === 1 ? " attempt failed" : " attempts failed")
                color: Palette.Theme.errorColor
                font.family: Palette.Theme.fontMono
                font.pixelSize: 11
            }
        }

        Surface {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 4
            Layout.preferredWidth: 320
            Layout.preferredHeight: 84
            visible: root.hasPlayer
            radius: 18
            color: Palette.Theme.surfaceContainerLow
            tintOpacity: 0.03

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    Layout.alignment: Qt.AlignVCenter
                    radius: 10
                    color: Palette.Theme.surfaceContainerHigh
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: root.player ? root.player.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: root.player ? (root.player.trackTitle || "Unknown title") : ""
                        color: Palette.Theme.textTitle
                        font.family: Palette.Theme.fontMono
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.player ? (root.player.trackArtist || "") : ""
                        color: Palette.Theme.textSecondary
                        font.family: Palette.Theme.fontMono
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "\ue045"
                            color: Palette.Theme.textPrimary
                            font.family: Palette.Theme.fontIcons
                            font.pixelSize: 16
                            opacity: root.player && root.player.canGoPrevious ? 1 : 0.35

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (root.player && root.player.canGoPrevious)
                                    root.player.previous()
                            }
                        }

                        ControlSlider {
                            Layout.fillWidth: true
                            iconGlyph: root.hasPlayer && root.player.isPlaying ? "\ue034" : "\ue037"
                            accentColor: Palette.Theme.accent
                            value: root.progress
                            onIconClicked: if (root.player && root.player.canTogglePlaying)
                                root.player.togglePlaying()
                            onValueRequested: v => {
                                if (root.player && root.player.length > 0)
                                    root.player.position = v * root.player.length;
                            }
                        }

                        Text {
                            text: "\ue044"
                            color: Palette.Theme.textPrimary
                            font.family: Palette.Theme.fontIcons
                            font.pixelSize: 16
                            opacity: root.player && root.player.canGoNext ? 1 : 0.35

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (root.player && root.player.canGoNext)
                                    root.player.next()
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: root.lockScreen
        function onAuthFailedChanged() {
            if (root.lockScreen.authFailed)
                shakeAnim.restart();
        }
    }

    SequentialAnimation {
        id: shakeAnim
        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: -10
            duration: 45
        }
        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: 8
            duration: 90
        }
        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: -6
            duration: 90
        }
        NumberAnimation {
            target: shakeTranslate
            property: "x"
            to: 0
            duration: 70
        }
    }
}
