import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.scintillon.settings 1.0
import Hue 0.1
import "../utils/ColourUtils.js" as Utils

CoverBackground {
    id: root

    property Lights lights: app.lights
    property Groups groups: app.groups

    readonly property real itemHeight: (Theme.iconSizeSmall + Theme.paddingSmall)
    readonly property int maxItemCount: Math.floor((coverActionArea.y - listList.y - Theme.paddingMedium) / itemHeight)

    LightsFilterModel {
        id: lightsOn
        lights: root.lights
        filterRoleOn: LightsFilterModel.ShowOn
    }

    Binding {
        target: app
        property: "coverActive"
        value: (status === Cover.Active)
    }

    Image {
        id: background
        visible: true
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: sourceSize.height * width / sourceSize.width
        source: Qt.resolvedUrl("image://scintillon/cover-background")
        opacity: 0.1
    }

    Item {
        id: contents

        anchors.fill: parent

        Label {
            id: lightsOnCount
            text: "" + lightsOn.count
            width: text.length * Theme.fontSizeMedium
            anchors {
                left: parent.left
                leftMargin: Theme.paddingLarge
            }
            y: Theme.paddingMedium
            font.pixelSize: Theme.fontSizeHuge
            horizontalAlignment: Text.AlignRight
        }

        Icon {
            source: Qt.resolvedUrl("image://scintillon/cover-lights-on")
            height: 76
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignLeft
            anchors {
                left: lightsOnCount.right
                leftMargin: Theme.paddingSmall
                right: parent.horizontalCenter
                rightMargin: Theme.paddingSmall / 2
                verticalCenter: lightsOnCount.verticalCenter
            }
        }

        Label {
            id: lightsOffCount
            text: "" + (lights.count - lightsOn.count)
            anchors {
                right: parent.right
                rightMargin: Theme.paddingLarge
            }
            y: Theme.paddingMedium
            width: text.length * Theme.fontSizeMedium
            font.pixelSize: Theme.fontSizeHuge
            horizontalAlignment: Text.AlignLeft
        }

        Icon {
            source: Qt.resolvedUrl("image://scintillon/cover-lights-off")
            height: 80
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignRight
            anchors {
                right: lightsOffCount.left
                rightMargin: Theme.paddingSmall
                left: parent.horizontalCenter
                leftMargin: Theme.paddingSmall / 2
                verticalCenter: lightsOffCount.verticalCenter
            }
        }

        Label {
            visible: lightsOn.count === 0
            anchors {
                top: lightsOffCount.bottom
                topMargin: Theme.paddingMedium
                left: parent.left
                leftMargin: Theme.paddingLarge
                right: parent.right
                rightMargin: Theme.paddingLarge
            }
            color: Theme.highlightColor
            text: (HueBridge.status === HueBridge.BridgeStatusConnected)
                  ? qsTr("All lights off")
                  : qsTr("No hub found")
            font.pixelSize: Theme.fontSizeLarge
            wrapMode: Text.Wrap
            elide: Text.ElideNone
            maximumLineCount: 3
        }

        ListView {
            id: listList
            x: Theme.paddingLarge
            width: parent.width - 2 * Theme.paddingLarge
            height: maxItemCount * itemHeight
            anchors {
                top: lightsOffCount.bottom;
                topMargin: Theme.paddingMedium
            }
            spacing: Theme.paddingMedium
            interactive: false

            model: lightsOn

            delegate: Row {
                width: parent.width
                spacing: Theme.paddingMedium
                Icon {
                    id: lightIcon
                    source: Qt.resolvedUrl("image://scintillon/cover-lights-on")
                    color: Utils.calculateLightColor(lightsOn.get(index))
                    height: Theme.iconSizeSmall
                    width: height
                }

                Label {
                    width: parent.width - lightIcon.width - Theme.paddingMedium
                    height: lightIcon.height
                    verticalAlignment: Text.AlignVCenter
                    text: model.name
                    truncationMode: TruncationMode.Fade
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.highlightColor
                }
            }
        }
    }

    CoverActionList {
        id: coverAction
        enabled: (groups.count > 0) && (lights.count > 0)

        CoverAction {
            iconSource: Settings.getImageUrl("icon-cover-action-on")
            onTriggered: {
                groups.findGroup(0).setOn(true)
            }
        }

        CoverAction {
            iconSource: Settings.getImageUrl("icon-cover-action-off")
            onTriggered: {
                groups.findGroup(0).setOn(false)
            }
        }
    }
}
