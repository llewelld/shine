import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Hue 0.1
import "PopupUtils.js" as PopupUtils

ShinePage {
    id: root
    title: "Switches"
    busy: sensors && sensors.count === 0 && sensors.busy

    property var sensors: null
    property var rules: null
    property var lights: null
    property var groups: null
    property var scenes: null

    SensorsFilterModel {
        id: filterModel
        sensors: root.sensors
        shownTypes: Sensor.TypeZGPSwitch
//                    | Sensor.TypeDaylight
                    | Sensor.TypeZLLSwitch
//                    | Sensor.TypeAll
    }

    ListView {
        model: filterModel
        anchors.fill: parent
        delegate: ItemDelegate {
            width: parent.width
            height: 8 * (10)
            Row {
                anchors { fill: parent; leftMargin: 8 * (2); rightMargin: 8 * (2); topMargin: 8 * (1); bottomMargin: 8 * (1) }
                spacing: 8 * (1)
                Image {
                    height: parent.height - 8 * (2)
                    anchors.verticalCenter: parent.verticalCenter
                    width: height
                    source: {
                        switch(model.type) {
                        case Sensor.TypeZGPSwitch:
                            return "images/tap_outline.svg"
                        case Sensor.TypeDaylight:
                            return "images/bridge_outline.svg"
                        case Sensor.TypeZLLSwitch:
                            return "images/dimmer_outline.svg"
                        }
                        return "";
                    }
                    sourceSize.width: width
                    sourceSize.height: height
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: model.name
                }
            }
            onClicked: pageStack.push(Qt.resolvedUrl("SensorPage.qml"), {sensors: root.sensors, sensor: filterModel.get(index), rules: root.rules, lights: root.lights, groups: root.groups, scenes: root.scenes });
        }
    }

    Label {
        width: parent.width - 8 * (8)
        anchors.centerIn: parent
        text: "No Hue Tap or Hue Dimmer device connected to the bridge. You can add new remotes in the \"Bridge Control\" section."
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        visible: filterModel.count === 0 && !root.busy
    }
}
