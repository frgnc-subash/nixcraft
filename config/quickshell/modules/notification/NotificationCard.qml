import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../../components/material"
import "../../theme" as Palette

Surface {
    id: card
    required property var notification
    property bool compact: false
    property string iconSource: ""
    property string bodyText: ""
    property var actionTarget: notification
    property bool canDismiss: true
    property bool dismissOnActivate: true
    signal dismissed
    signal activated
    function actionLabel(action) {
        var label = action && action.text ? action.text.trim() : "";
        return /^(activate|default)$/i.test(label) ? "Open" : label;
    }
    function dismissNotification() {
        card.dismissed();
        if (card.canDismiss && card.actionTarget)
            card.actionTarget.dismiss();
    }
    height: implicitHeight
    implicitHeight: content.implicitHeight + 22
    radius: Palette.Theme.radiusMedium
    color: Palette.Theme.surfaceContainerHigh
    tint: notification && notification.urgency === NotificationUrgency.Critical ? Palette.Theme.accent : Palette.Theme.surfaceTint
    tintOpacity: notification && notification.urgency === NotificationUrgency.Critical ? 0.16 : 0.04

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Palette.Theme.surfaceTint
        opacity: cardMouse.containsMouse ? 0.06 : 0.025
        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }
    }
    MouseArea {
        id: cardMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            card.activated();
            if (card.dismissOnActivate)
                card.dismissNotification();
        }
    }
    RowLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 11
            rightMargin: 50
        }
        spacing: 12
        Rectangle {
            implicitWidth: 56
            implicitHeight: 56
            radius: 16
            color: Palette.Theme.surfaceContainerHigh
            clip: true
            Layout.alignment: Qt.AlignVCenter
            Image {
                id: icon
                anchors.fill: parent
                source: card.iconSource
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true
                asynchronous: true
                sourceSize.width: 128
                sourceSize.height: 128
                opacity: status === Image.Ready ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }
            }
            Text {
                anchors.centerIn: parent
                visible: icon.status !== Image.Ready
                text: "\ue7f4"
                color: Palette.Theme.textSecondary
                font.family: Palette.Theme.fontIcons
                font.pixelSize: 26
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                opacity: icon.status === Image.Null || icon.status === Image.Error ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text: card.notification ? (card.notification.appName || "Application") : ""
                    color: Palette.Theme.textMuted
                    font.family: Palette.Theme.fontMono
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
            Text {
                text: card.notification ? (card.notification.summary || "Notification") : ""
                color: Palette.Theme.textPrimary
                font.family: Palette.Theme.fontMono
                font.pixelSize: 14
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: card.bodyText
                color: Palette.Theme.textSecondary
                font.family: Palette.Theme.fontMono
                font.pixelSize: 12
                lineHeight: 1.15
                wrapMode: Text.WordWrap
                maximumLineCount: card.compact ? 2 : 5
                elide: Text.ElideRight
                visible: text !== ""
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: card.actionTarget && card.actionTarget.actions.length > 0
                Item {
                    Layout.fillWidth: true
                }
                Repeater {
                    model: card.actionTarget ? card.actionTarget.actions : []
                    delegate: Item {
                        required property var modelData
                        implicitWidth: actionText.implicitWidth
                        // Keeps roughly 4px of breathing room above and below
                        // the 11px link text without making a separate footer.
                        implicitHeight: 22
                        Text {
                            id: actionText
                            anchors.centerIn: parent
                            text: card.actionLabel(modelData)
                            color: actionMouse.containsMouse ? Palette.Theme.textPrimary : Palette.Theme.info
                            font.family: Palette.Theme.fontMono
                            font.pixelSize: 11
                            font.underline: true

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }
                        }
                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                modelData.invoke();
                                card.activated();
                                if (card.canDismiss && card.actionTarget && !card.actionTarget.resident)
                                    card.dismissNotification();
                            }
                        }
                    }
                }
            }
        }
    }
    Text {
        id: clearText
        text: "Clear"
        color: clearMouse.containsMouse ? Palette.Theme.textPrimary : Palette.Theme.textMuted
        font.family: Palette.Theme.fontMono
        font.pixelSize: 11
        font.underline: true
        anchors {
            right: parent.right
            rightMargin: 11
            verticalCenter: parent.verticalCenter
        }

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        MouseArea {
            id: clearMouse
            anchors.fill: parent
            anchors.margins: -6
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: card.dismissNotification()
        }
    }
}
