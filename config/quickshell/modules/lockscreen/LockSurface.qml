import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../../theme" as Palette
import "../../components/material"

WlSessionLockSurface {
    id: root

    required property var lockScreen

    // Opaque fallback so nothing behind the compositor's lock surface can
    // ever show through before the wallpaper image finishes loading.
    color: "#000000"

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

            Item {
                id: pwFieldWrapper
                Layout.preferredWidth: 240
                Layout.preferredHeight: 38
                Layout.alignment: Qt.AlignHCenter

                transform: Translate {
                    id: shakeTranslate
                }

                Surface {
                    id: pwField
                    anchors.fill: parent
                    radius: height / 2
                    color: Palette.Theme.surfaceContainer
                    outlineWidth: 0

                    scale: passwordInput.activeFocus ? 1.015 : 1
                    Behavior on scale {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
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
                        id: placeholder
                        anchors.centerIn: parent
                        text: root.lockScreen.authBusy ? "Verifying…" : "Enter password"
                        color: Palette.Theme.textMuted
                        font.family: Palette.Theme.fontMono
                        font.pixelSize: 12
                        opacity: passwordInput.text.length === 0 ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 140
                            }
                        }

                        SequentialAnimation on opacity {
                            running: root.lockScreen.authBusy
                            loops: Animation.Infinite
                            NumberAnimation {
                                to: 0.45
                                duration: 550
                                easing.type: Easing.InOutSine
                            }
                            NumberAnimation {
                                to: 1
                                duration: 550
                                easing.type: Easing.InOutSine
                            }
                        }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 7
                        opacity: passwordInput.text.length > 0 ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 140
                            }
                        }

                        Repeater {
                            model: Math.min(passwordInput.text.length, 16)
                            delegate: Rectangle {
                                id: dot
                                width: 7
                                height: 7
                                radius: 3.5
                                scale: 0
                                color: root.lockScreen.authFailed ? Palette.Theme.errorColor : Palette.Theme.accent

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                    }
                                }

                                Component.onCompleted: dotPop.start()

                                NumberAnimation {
                                    id: dotPop
                                    target: dot
                                    property: "scale"
                                    to: 1
                                    duration: 220
                                    easing.type: Easing.OutBack
                                }
                            }
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
