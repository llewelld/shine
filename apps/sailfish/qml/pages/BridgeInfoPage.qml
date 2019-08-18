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

        PullDownMenu {
            MenuItem {
                //% "Search for devices"
                text: qsTrId("scintillon-bridge_search_devices")
                enabled: !searching
                onClicked: {
                    lights.searchForNewLights();
                    var now = new Date()
                    searchTime = new Date(new Date().getTime() + 30000);
                    searchRemaining = (searchTime - now) / 1000
                    searching = true
                }
            }
            MenuItem {
                //% "Update now"
                text: qsTrId("scintillon-bridge_update_now")
                enabled: bridgeConfig.connectedToPortal && (bridgeConfig.updateState === Configuration.UpdateStateReadyToUpdate)
                onClicked: bridgeConfig.performUpdate()
            }
        }

        Column {
            id: bridgeColumn
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                //% "Bridge control"
                title: qsTrId("scintillon-bridge_placeholder_title")
            }

            InfoRow {
                //% "Bridge name"
                label: qsTrId("scintillon-bridge_name")
                value: bridgeConfig.name
                midlineRatio: 0.5
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                //% "Bridge SW version"
                label: qsTrId("scintillon-bridge_sw_version")
                value: bridgeConfig.swVersion
                midlineRatio: 0.5
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                //% "Portal services"
                label: qsTrId("scintillon-bridge_portal_services")
                value: bridgeConfig.connectedToPortal
                       //% "Connected"
                       ? qsTrId("scintillon-bridge_connected")
                       //% "Not connected"
                       : qsTrId("scintillon-bridge_not_connected")
                midlineRatio: 0.5
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                //% "Timezone"
                label: qsTrId("scintillon-bridge_timezone")
                value: bridgeConfig.timezone
                midlineRatio: 0.5
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                //% "Update status"
                label: qsTrId("scintillon-bridge_update_status")
                value: {
                    switch (bridgeConfig.updateState) {
                    case Configuration.UpdateStateUpToDate:
                        //% "Up to date"
                        return qsTrId("scintillon-bridge_update_up_to_date")
                    case Configuration.UpdateStateDownloading:
                        //% "Downloading update..."
                        return qsTrId("scintillon-bridge_update_downloading")
                    case Configuration.UpdateStateUpdating:
                        //% "Updating..."
                        return qsTrId("scintillon-bridge_update_updating")
                    case Configuration.UpdateStateReadyToUpdate:
                        //% "Update available"
                        return qsTrId("scintillon-bridge_update_available")
                    }
                    return ""
                }
                midlineRatio: 0.5
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                //% "Device search"
                label: qsTrId("scintillon-bridge_device_search")
                value: searching
                       //% "Searching %1 secs"
                       ? qsTrId("scintillon-bridge_device_searching").arg(searchRemaining)
                       //% "Not searching"
                       : qsTrId("scintillon-bridge_device_not_searching")
                midlineRatio: 0.5
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }
        }
    }
}
