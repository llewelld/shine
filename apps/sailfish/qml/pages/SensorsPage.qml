import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1

Page {
    id: root

    property alias sensors: sensorsFilterModel.sensors
    property var rules: null
    property var lights: null
    property var groups: null
    property var scenes: null

    allowedOrientations: Orientation.All

    SilicaListView {
        id: listView
        anchors.fill: parent

        VerticalScrollDecorator {}

        ViewPlaceholder {
            enabled: listView.count === 0
            //% "No sensors or switches"
            text: qsTrId("scintillon-sensors_placeholder_text")
            hintText: (HueBridge.status === HueBridge.BridgeStatusConnected)
                      //% "Connect a switch to your Hue Hub to get started"
                      ? qsTrId("scintillon-sensors_placeholder_hint_no_switches")
                      //% "Not connected to a Hue Hub"
                      : qsTrId("scintillon-sensors_placeholder_hint_no_hub")
        }

        header: PageHeader {
            id: title
            //% "Sensors and switches"
            title: qsTrId("scintillon-sensors_page_title")
        }

        model: SensorsFilterModel {
            id: sensorsFilterModel
            shownTypes: Sensor.TypeZGPSwitch
                        | Sensor.TypeDaylight
                        | Sensor.TypeZLLSwitch
                       // | Sensor.TypeAll
        }

        delegate: ListItem {
            id: sensorItem
            menu: sensorsMenuComponent
            highlighted: sensorPressable.highlighted

            Row {
                x : Theme.horizontalPageMargin
                height: Theme.itemSizeSmall
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: 0

                IconPressable {
                    id: sensorPressable
                    width: parent.width
                    height: Theme.itemSizeSmall
                    sourceOn: {
                        switch(model.type) {
                        case Sensor.TypeZGPSwitch:
                            return Qt.resolvedUrl("image://scintillon/sensors/tap")
                        case Sensor.TypeZLLSwitch:
                            return Qt.resolvedUrl("image://scintillon/sensors/dimmer")
                        case Sensor.TypeDaylight:
                            return Qt.resolvedUrl("image://scintillon/sensors/daylight")
                        case Sensor.TypeClipGenericStatus:
                            return Qt.resolvedUrl("image://scintillon/sensors/generic")
                        }
                        return Qt.resolvedUrl("image://scintillon/sensors/generic");
                    }
                    sourceOff: sourceOn
                    icon.color: "white"
                    icon.width: Theme.iconSizeMedium
                    icon.height: icon.width
                    text: model.name

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("SensorPage.qml"), {sensors: root.sensors, sensor: sensorsFilterModel.get(index), rules: root.rules, lights: root.lights, groups: root.groups, scenes: root.scenes })
                    }
                }
            }

            Component {
                id: sensorsMenuComponent
                ContextMenu {
                    MenuItem {
                        //% "Edit"
                        text: qsTrId("scintillon-sensors_menu_sensor_edit")
                        onClicked: {
                            var scene = scenesFilterModel.get(index)
                            var checkedLights = [];
                            for (var i = 0; i < scene.lightsCount; i++) {
                                console.log("Adding light " + i)
                                checkedLights.push(scene.light(i))
                            }
                            pageStack.push(Qt.resolvedUrl("ScenesAdd.qml"), {sceneid: model.id, lights: lights, name: model.name, scenes: scenes, checkedLights: checkedLights})
                        }
                    }
                }
            }
        }
    }
}
