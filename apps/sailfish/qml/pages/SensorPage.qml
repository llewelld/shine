import QtQuick 2.5
import Sailfish.Silica 1.0
import Hue 0.1
import harbour.scintillon.settings 1.0
import "../components"
import "../utils/SensorUtils.js" as Utils

Dialog {
    id: root

    property var sensors: null
    property var sensor: null
    property var rules: null
    property var lights: null
    property var groups: null
    property var scenes: null
    property int update

    allowedOrientations: Orientation.All

    canAccept: {
        switch (lightsOrSceneSelector.currentIndex) {
        case 0: // None
            return true
        case 1: // Toggle lights
        case 2: // Switch lights on
        case 3: // Switch lights off
        case 5: // Dim up
        case 6: // Dim down
        case 7: // Sleep timer
            return (lightsAndGroupsList.currentIndex >= 0)
        case 4: // Activate scene
            // Changes to scenesListView.selectedScenes.length don't
            // trigger an update, so we use update instead
            return update, (scenesListView.selectedScenes.length > 0)
        default:
            return false
        }
    }
    onAccepted: Utils.saveRules(existingRulesFilter, root.rules, sensorLoader, root.sensor, root.sensors, lightsOrSceneSelector, lightsAndGroupsList, scenesListView, recipeSelector)

    SilicaFlickable {
        interactive: true
        anchors.fill: parent
        contentHeight: sensorColumn.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Column {
            id: sensorColumn
            width: parent.width
            spacing: Theme.paddingSmall

            DialogHeader {
                id: pageHeader
                title: sensor.name
            }

            Loader {
                id: sensorLoader
                width: parent.width
                sourceComponent: {
                    switch(root.sensor.type) {
                    case Sensor.TypeDaylight:
                        return hueBridgeComponent;
                    case Sensor.TypeZGPSwitch:
                        return hueTapComponent;
                    case Sensor.TypeZLLSwitch:
                        return hueDimmerComponent;
                    }
                    return hueGenericComponent;
                }
            }

            ComboBox {
                id: lightsOrSceneSelector
                //% "Action"
                label: qsTrId("scintillon-sensor_action")
                menu: ContextMenu {
                    //% "None"
                    MenuItem { text: qsTrId("scintillon-sensor_action_none")}
                    //% "Toggle lights"
                    MenuItem { text: qsTrId("scintillon-sensor_action_toggle_lights")}
                    //% "Switch lights on"
                    MenuItem { text: qsTrId("scintillon-sensor_action_lights_on")}
                    //% "Switch lights off"
                    MenuItem { text: qsTrId("scintillon-sensor_action_lights_off")}
                    //% "Activate scenes"
                    MenuItem { text: qsTrId("scintillon-sensor_action_activate_scenes")}
                    //% "Dim up"
                    MenuItem { text: qsTrId("scintillon-sensor_action_dim_up")}
                    //% "Dim down"
                    MenuItem { text: qsTrId("scintillon-sensor_action_dim_down")}
                    //% "Set sleep timer"
                    //MenuItem { text: qsTrId("scintillon-sensor_action_set_sleep_timer")}
                }
            }

            SwitchOnOffList {
                id: recipeSelector
                width: parent.width
                lightOn: (lightsOrSceneSelector.currentIndex == 2)
                visible: (lightsOrSceneSelector.currentIndex == 2) || (lightsOrSceneSelector.currentIndex == 3)
            }

            LightsAndGroupsList {
                id: lightsAndGroupsList
                lights: root.lights
                groups: root.groups
                width: parent.width
                visible: (lightsOrSceneSelector.currentIndex !== 4) && (lightsOrSceneSelector.currentIndex !== 0)
            }

            ScenesList {
                id: scenesListView
                scenes: root.scenes
                width: parent.width
                visible: lightsOrSceneSelector.currentIndex === 4
            }
        }
    }

    SensorsFilterModel {
        sensors: root.sensors
    }

    RulesFilterModel {
        id: existingRulesFilter
        rules: root.rules
    }

    Connections {
        target: sensorLoader.item
        onButtonIdChanged: {
            console.log("button id changed", sensorLoader.item.buttonId)
            Utils.loadRules(existingRulesFilter, lightsAndGroupsList, recipeSelector, scenesListView, lightsOrSceneSelector, sensorLoader);
            update = update + 1
        }
    }

    Component.onCompleted: {
        Utils.loadRules(existingRulesFilter, lightsAndGroupsList, recipeSelector, scenesListView, lightsOrSceneSelector, sensorLoader);
        update = update + 1
    }

    Component {
        id: hueBridgeComponent
        SensorBridge {
            width: parent.width
            rules: root.rules
            sensor: root.sensor
        }
    }

    Component {
        id: hueTapComponent
        SensorTap {
            width: parent.width
            rules: root.rules
            sensor: root.sensor
        }
    }

    Component {
        id: hueDimmerComponent
        SensorDimmer {
            width: parent.width
            rules: root.rules
            sensor: root.sensor
        }
    }

    Component {
        id: hueGenericComponent
        SensorGeneric {
            width: parent.width
        }
    }
}
