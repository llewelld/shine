import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1

Page {
    id: root

    property var lights: null
    property bool searching
    property var searchTime: new Date(0)
    property int searchRemaining

    allowedOrientations: Orientation.All

    Timer {
        running: searching
        interval: 1000
        repeat: true
        onTriggered: {
            var now = new Date()
            searchRemaining = (searchTime - now) / 1000
            if (searchTime < now) {
                searching = false
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: bridgeColumn.height
        flickableDirection: Flickable.VerticalFlick

        VerticalScrollDecorator {}

        Column {
            id: bridgeColumn
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Bridge control")
            }

            InfoRow {
                label: qsTr("Bridge name")
                value: bridgeConfig.name
                midlineRatio: 0.5
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                label: qsTr("Bridge SW Version")
                value: bridgeConfig.swVersion
                midlineRatio: 0.5
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                label: qsTr("Portal services")
                value: bridgeConfig.connectedToPortal ? "Connected" : "Not connected"
                midlineRatio: 0.5
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                label: qsTr("Timezone")
                value: bridgeConfig.timezone
                midlineRatio: 0.5
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                label: qsTr("Update Status")
                value: {
                    switch (bridgeConfig.updateState) {
                    case Configuration.UpdateStateUpToDate:
                        return "Up to date"
                    case Configuration.UpdateStateDownloading:
                        return "Downloading update..."
                    case Configuration.UpdateStateUpdating:
                        return "Updating..."
                    case Configuration.UpdateStateReadyToUpdate:
                        return "Update available"
                    }
                    return ""
                }
                midlineRatio: 0.5
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                label: qsTr("Device search")
                value: searching ? "Searching " + searchRemaining + " secs" : "Not searching"
                midlineRatio: 0.5
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            Row {
                spacing: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    id : deviceSearchButton
                    text: qsTr("Search for devices")
                    enabled: !searching
                    onClicked: {
                        lights.searchForNewLights();
                        var now = new Date()
                        searchTime = new Date(new Date().getTime() + 30000);
                        searchRemaining = (searchTime - now) / 1000
                        searching = true
                    }
                }
                Button {
                    id: updateButton
                    text: qsTr("Update now")
                    enabled: bridgeConfig.connectedToPortal && (bridgeConfig.updateState === Configuration.UpdateStateReadyToUpdate)
                    onClicked: bridgeConfig.performUpdate()
                }
            }
        }
    }
}
