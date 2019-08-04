import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import harbour.scintillon.settings 1.0
import Hue 0.1

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    Component.onCompleted: {
        HueBridge.apiKey = Settings.apiKey;

        if (HueBridge.discoveryError) {
            console.log("Discovery error")
            //PopupUtils.open(errorComponent, root)
        } else if (HueBridge.bridgeFound && !HueBridge.connectedBridge){
            console.log("Login")
            //PopupUtils.open(loginComponent, root)
        }
    }

    Connections {
        target: HueBridge
        onBridgeFoundChanged: {
            if (!HueBridge.connectedBridge) {
                console.log("Login")
                //PopupUtils.open(loginComponent, root)
            }
        }
        onDiscoveryErrorChanged: {
            if (HueBridge.discoveryError) {
                console.log("Discovery error")
                //PopupUtils.open(errorComponent, root)
            }
        }
        onApiKeyChanged: {
            Settings.apiKey = HueBridge.apiKey;
        }
        onStatusChanged: {
            if (HueBridge.status === HueBridge.BridgeStatusAuthenticationFailure) {
                console.log("Authentication failure")
                //PopupUtils.open(loginComponent, root)
            }
        }
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        VerticalScrollDecorator {}

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.implicitHeight

        Column {
            id: column

            width: isPortrait ? parent.width : parent.width / 3.0
            height: isPortrait ? page.height / 3.0 : page.height
            spacing: 0

            BarButton {
                source: "image://scintillon/icon-m-lights"
                text: qsTr("Lights and groups")
                onClicked: pageStack.push(lightsPage)
            }

            BarButton {
                source: "image://scintillon/icon-m-scenes"
                text: qsTr("Scenes")
                onClicked: pageStack.push(scenesPage)
            }
        }

        Column {
            id: column2

            width: isPortrait ? parent.width : parent.width / 3.0
            height: isPortrait ? page.height / 3.0 : page.height
            spacing: 0
            y: isPortrait ? page.height / 3.0 : 0
            x: isPortrait ? 0 : page.width / 3.0

            BarButton {
                source: "image://scintillon/icon-m-switches"
                text: qsTr("Sensors and switches")
                onClicked: pageStack.push(sensorsPage)
            }

            BarButton {
                source: "image://scintillon/icon-m-alarms"
                text: qsTr("Alarms and timers")
                onClicked: pageStack.push(alarmsPage)
            }
        }

        Column {
            id: column3

            width: isPortrait ? parent.width : parent.width / 3.0
            height: isPortrait ? page.height / 3.0 : page.height
            spacing: 0
            y: isPortrait ? 2.0 * page.height / 3.0 : 0
            x: isPortrait ? 0 : 2.0 * page.width / 3.0

            BarButton {
                source: "image://scintillon/icon-m-rules"
                text: qsTr("Rules")
                onClicked: pageStack.push(rulesPage)
            }

            BarButton {
                source: "image://scintillon/icon-m-bridge"
                text: qsTr("Bridge Control")
                onClicked: pageStack.push(bridgeInfoPage)
            }
        }
    }

    BridgeInfoPage {
        id: bridgeInfoPage
        lights: lights
    }

    ScenesPage {
        id: scenesPage
        scenes: scenes
        lights: lights
    }

    LightsPage {
        id: lightsPage
        lights: lights
        groups: groups
        schedules: schedules
    }

    GroupsPage {
        id: groupsPage
        groups: groups
        lights: lights
    }

    SensorsPage {
        id: sensorsPage
        sensors: sensors
        rules: rules
        lights: lights
        groups: groups
        scenes: scenes
    }

    AlarmsPage {
        id: alarmsPage
        schedules: schedules
    }

    RulesPage {
        id: rulesPage
        rules: rules
    }

    Configuration {
        id: bridgeConfig
        autoRefresh: (pageStack.currentPage == bridgeInfoPage)// && !bigColorPicker.visible
    }

    Scenes {
        id: scenes
        autoRefresh: (pageStack.currentPage == scenesPage || pageStack.currentPage == sensorsPage)// && !bigColorPicker.visible
        consistency: consistency
    }

    Lights {
        id: lights
        autoRefresh: (pageStack.currentPage == lightsPage || pageStack.currentPage == sensorsPage)// || bigColorPicker.visible
        consistency: consistency
    }

    Groups {
        id: groups
        autoRefresh: (pageStack.currentPage == lightsPage || pageStack.currentPage == sensorsPage)// || bigColorPicker.visible
        consistency: consistency
    }

    Schedules {
        id: schedules
        autoRefresh: (pageStack.currentPage == alarmsPage)// && !bigColorPicker.visible
    }

    Sensors {
        id: sensors
        autoRefresh: (pageStack.currentPage == sensorsPage)// && !bigColorPicker.visible
    }

    Rules {
        id: rules
        autoRefresh: (pageStack.currentPage == rulesPage || pageStack.currentPage == sensorsPage)// && !bigColorPicker.visible
    }

    Consistency {
        id: consistency
        lights: lights
        groups: groups
    }
}
