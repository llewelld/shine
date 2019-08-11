import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import harbour.scintillon.settings 1.0
import Hue 0.1

Page {
    id: page

    property Lights lights: app.lights
    property Groups groups: app.groups
    property Consistency consistency: app.consistency

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    Component.onCompleted: {
        HueBridge.apiKey = Settings.apiKey;

        if (HueBridge.discoveryError) {
            console.log("Discovery error")
            pageStack.push("ErrorPage.qml", {errorMessage: HueBridge.errorMessage})
        } else if (HueBridge.bridgeFound && !HueBridge.connectedBridge){
            console.log("Login")
            pageStack.push("LoginPage.qml", {startAPage: page})
        }
    }

    Binding {
        target: app
        property: "updateLights"
        value: (pageStack.currentPage == scenesPage
                || pageStack.currentPage == lightsPage
                || pageStack.currentPage == sensorsPage)
    }

    Connections {
        target: HueBridge
        onBridgeFoundChanged: {
            if (!HueBridge.connectedBridge) {
                console.log("Login")
                pageStack.push("LoginPage.qml", {startAPage: page})
            }
        }
        onDiscoveryErrorChanged: {
            if (HueBridge.discoveryError) {
                console.log("Discovery error")
                pageStack.push("ErrorPage.qml", {errorMessage: HueBridge.errorMessage})
            }
        }
        onApiKeyChanged: {
            Settings.apiKey = HueBridge.apiKey;
        }
        onStatusChanged: {
            if (HueBridge.status === HueBridge.BridgeStatusAuthenticationFailure) {
                console.log("Authentication failure")
                pageStack.push("LoginPage.qml", {startAPage: page})
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
        lights: page.lights
    }

    ScenesPage {
        id: scenesPage
        scenes: scenes
        lights: page.lights
    }

    LightsPage {
        id: lightsPage
        lights: page.lights
        groups: page.groups
        schedules: schedules
    }

    GroupsPage {
        id: groupsPage
        groups: page.groups
        lights: page.lights
    }

    SensorsPage {
        id: sensorsPage
        sensors: sensors
        rules: rules
        lights: page.lights
        groups: page.groups
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
        autoRefresh: (pageStack.currentPage == bridgeInfoPage)
    }

    Scenes {
        id: scenes
        autoRefresh: (pageStack.currentPage == scenesPage || pageStack.currentPage == sensorsPage)
        consistency: page.consistency
    }

    Schedules {
        id: schedules
        autoRefresh: (pageStack.currentPage == alarmsPage)
    }

    Sensors {
        id: sensors
        autoRefresh: (pageStack.currentPage == sensorsPage)
    }

    Rules {
        id: rules
        autoRefresh: (pageStack.currentPage == rulesPage || pageStack.currentPage == sensorsPage)
    }
}
