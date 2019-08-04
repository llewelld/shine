import QtQuick 2.5
import Sailfish.Silica 1.0
import Hue 0.1
import harbour.scintillon.settings 1.0

Item {
    id: hueTap

    property int buttonId: 34
    property var rules
    property var sensor

    height: hueTapRow.height

    function createSensorConditions() {
        return rules.createHueTapConditions(sensor.id, hueTap.buttonId);
    }

    function createFilter() {
        var filter = new Object();
        filter["address"] = "/sensors/" + sensor.id + "/state/buttonevent"
        filter["operator"] = "eq"
        filter["value"] = hueTap.buttonId
        return filter
    }

    Row {
        id: hueTapRow
        width: parent.width
        spacing: Theme.paddingMedium

        Column {
            width: (parent.width) * 0.5
            spacing: Theme.paddingSmall

            TextSwitch {
                width: parent.width
                text: "Button 1"
                checked: hueTap.buttonId == 34
                automaticCheck: false
                onClicked: hueTap.buttonId = 34
            }

            TextSwitch {
                width: parent.width
                text: "Button 2"
                checked: hueTap.buttonId == 16
                automaticCheck: false
                onClicked: hueTap.buttonId = 16
            }

            TextSwitch {
                width: parent.width
                text: "Button 3"
                checked: hueTap.buttonId == 17
                automaticCheck: false
                onClicked: hueTap.buttonId = 17
            }

            TextSwitch {
                width: parent.width
                text: "Button 4"
                checked: hueTap.buttonId == 18
                automaticCheck: false
                onClicked: hueTap.buttonId = 18
            }
        }

        Column {
            width: (parent.width) * 0.5
            spacing: Theme.paddingSmall

            IconButton {
                id: hueTapIcon
                width: Theme.iconSizeExtraLarge
                height: width
                icon.source: {
                    switch (hueTap.buttonId) {
                    case 16:
                        return Qt.resolvedUrl("image://scintillon/sensors/tap-2")
                        break;
                    case 17:
                        return Qt.resolvedUrl("image://scintillon/sensors/tap-3")
                        break;
                    case 18:
                        return Qt.resolvedUrl("image://scintillon/sensors/tap-4")
                        break;
                    case 34:
                        return Qt.resolvedUrl("image://scintillon/sensors/tap-1")
                        break;
                    }
                    return Qt.resolvedUrl("image://scintillon/sensors/tap")
                }
                icon.color: "white"
            }
        }
    }
}
