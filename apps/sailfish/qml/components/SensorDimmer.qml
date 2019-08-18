import QtQuick 2.5
import Sailfish.Silica 1.0
import Hue 0.1
import harbour.scintillon.settings 1.0

Item {
    id: hueDimmer
    property int buttonId: buttonNumber + "00" + buttonMode

    property int buttonNumber: 1
    property int buttonMode: pressCheckBox.checked ? 2 : 1
    property var rules
    property var sensor

    height: hueDimmerRow.height

    function createSensorConditions() {
        return rules.createHueDimmerConditions(sensor.id, hueDimmer.buttonId);
    }

    function createFilter() {
        var filter = new Object();
        filter["address"] = "/sensors/" + sensor.id + "/state/buttonevent"
        filter["operator"] = "eq"
        filter["value"] = hueDimmer.buttonId
        return filter
    }

    Row {
        id: hueDimmerRow
        width: parent.width
        spacing: Theme.paddingMedium

        Column {
            width: (parent.width) * 0.5
            spacing: Theme.paddingSmall

            TextSwitch {
                id: onButton
                width: parent.width
                //% "On"
                text: qsTrId("scintillon-sensor_dimmer_on")
                checked: hueDimmer.buttonNumber == 1
                automaticCheck: false
                onClicked: hueDimmer.buttonNumber = 1
            }

            TextSwitch {
                id: brighterButton
                width: parent.width
                //% "Brighter"
                text: qsTrId("scintillon-sensor_dimmer_brigher")
                checked: hueDimmer.buttonNumber == 2
                automaticCheck: false
                onClicked: hueDimmer.buttonNumber = 2
            }

            TextSwitch {
                id: dimmerButton
                width: parent.width
                //% "Dimmer"
                text: qsTrId("scintillon-sensor_dimmer_dimmer")
                checked: hueDimmer.buttonNumber == 3
                automaticCheck: false
                onClicked: hueDimmer.buttonNumber = 3
            }

            TextSwitch {
                id: offButton
                width: parent.width
                //% "Off"
                text: qsTrId("scintillon-sensor_dimmer_off")
                checked: hueDimmer.buttonNumber == 4
                automaticCheck: false
                onClicked: hueDimmer.buttonNumber = 4
            }
        }

        Column {
            width: (parent.width) * 0.5
            spacing: Theme.paddingSmall

            Item {
                width: Theme.iconSizeExtraLarge
                height: (Theme.itemSizeSmall * 2) + Theme.paddingSmall
                Icon {
                    id: hueDimmerIcon
                    width: Theme.iconSizeLarge
                    height: Theme.iconSizeLarge
                    anchors.centerIn: parent
                    source: {
                        switch (hueDimmer.buttonNumber) {
                        case 1:
                            return Qt.resolvedUrl("image://scintillon/sensors/dimmer-1")
                            break;
                        case 2:
                            return Qt.resolvedUrl("image://scintillon/sensors/dimmer-2")
                            break;
                        case 3:
                            return Qt.resolvedUrl("image://scintillon/sensors/dimmer-3")
                            break;
                        case 4:
                            return Qt.resolvedUrl("image://scintillon/sensors/dimmer-4")
                            break;
                        }
                        return Qt.resolvedUrl("image://scintillon/sensors/dimmer")
                    }
                    color: "white"
                    fillMode: Image.PreserveAspectFit
                }
            }

            TextSwitch {
                id: pressCheckBox
                checked: true
                automaticCheck: false
                onClicked: {
                    pressCheckBox.checked = true;
                    holdCheckBox.checked = false;
                }
                //% "Press"
                text: qsTrId("scintillon-sensor_dimmer_press")
            }

            TextSwitch {
                id: holdCheckBox
                automaticCheck: false
                onClicked: {
                    holdCheckBox.checked = true;
                    pressCheckBox.checked = false;
                }
                //% "Hold"
                text: qsTrId("scintillon-sensor_dimmer_hold")
            }
        }
    }
}
