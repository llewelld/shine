import QtQuick 2.5
import Sailfish.Silica 1.0
import Hue 0.1
import harbour.scintillon.settings 1.0

Item {
    id: hueBridge

    property int buttonId: day ? 1 : 0
    property bool day: true
    property var rules
    property var sensor

    height: hueBridgeRow.height

    function createSensorConditions() {
        return rules.createDaylightConditions(sensor.id, hueBridge.day);
    }

    function createFilter() {
        var filter = new Object();
        filter["address"] = "/sensors/" + root.sensor.id + "/state/daylight"
        filter["operator"] = "eq"
        filter["value"] = hueBridge.day.toString()
        return filter
    }

    Row {
        id: hueBridgeRow
        width: parent.width
        spacing: Theme.paddingMedium

        Column {
            width: (parent.width) * 0.5
            spacing: Theme.paddingSmall

            TextSwitch {
                width: parent.width
                text: "Sunrise"
                checked: hueBridge.day
                automaticCheck: false
                onClicked: hueBridge.day = true
            }

            TextSwitch {
                width: parent.width
                text: "Sunset"
                checked: !hueBridge.day
                automaticCheck: false
                onClicked: hueBridge.day = false
            }
        }

        Column {
            width: (parent.width) * 0.5
            spacing: Theme.paddingSmall

            Item {
                width: Theme.iconSizeExtraLarge
                height: width
                Icon {
                    id: hueBridgeIcon
                    width: Theme.iconSizeLarge
                    height: Theme.iconSizeLarge
                    anchors.centerIn: parent
                    source: hueBridge.day
                                 ? Qt.resolvedUrl("image://scintillon/sensors/daylight-sunrise")
                                 : Qt.resolvedUrl("image://scintillon/sensors/daylight-sunset")
                    color: "white"
                    fillMode: Image.PreserveAspectFit
                }
            }
        }
    }
}
