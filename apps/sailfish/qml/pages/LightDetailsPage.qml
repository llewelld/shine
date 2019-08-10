import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1

Page {
    id: root

    property var light: null
    property var schedules: null

    Binding {
        target: root.light
        property: "autoRefresh"
        value: true
    }

    Connections {
        target: root.light
        onStateChanged: {
            brightnessSlider.value = root.light.bri;
            effectSelector.currentIndex = effectSelector.findIndex();
            if (!colorPicker.pressed || !colorPicker.active) {
                colorPicker.color = root.light.color;
            }
            colorPicker.active = light ? (light.colormode == LightInterface.ColorModeHS || light.colormode == LightInterface.ColorModeXY) : false
            if (!colorPickerCt.pressed) {
                colorPickerCt.ct = root.light.ct;
            }
            colorPickerCt.active = !colorPicker.active
        }
        onNameChanged: {
            nameLabel.text = root.light.name;
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 8 * (2)
        spacing: 8 * (2)

        Row {
            width: parent.width
            spacing: Theme.paddingSmall
            IconButton {
                id: dimButton
                width: Theme.itemSizeSmall
                height: Theme.itemSizeSmall
                onClicked: light.on = false;
                icon.source: "image://theme/icon-s-installed"
            }
            Slider {
                id: brightnessSlider
                width: parent.width - 2 * Theme.itemSizeSmall
                minimumValue: 0
                maximumValue: 255
                value: light ? light.bri : 0
                onValueChanged: {
                    light.bri = value
                }
            }
            IconButton {
                id: brightButton
                width: Theme.itemSizeSmall
                height: Theme.itemSizeSmall
                onClicked: light.on = true;
                icon.source: "image://theme/icon-s-installed"
            }

        }

        ColorPicker {
            id: colorPicker
            width: parent.width
            height: 4 * Theme.itemSizeExtraLarge

            color: light ? light.color : "black"
            active: light ? (light.colormode == LightInterface.ColorModeHS || light.colormode == LightInterface.ColorModeXY) : false

            touchDelegate: Rectangle {
                height: 8 * (3)
                width: 8 * (3)
                color: "black"
            }

            onColorChanged: {
                if (pressed) {
                    console.log("light", light, "light.color", light.color, colorPicker.color)
                    light.color = colorPicker.color;
                }
            }
        }
        ColorPickerCt {
            id: colorPickerCt
            width: parent.width
            height: width / 6

            ct: light ? light.ct : minCt
            active: light && light.colormode == LightInterface.ColorModeCT

            onCtChanged: {
                if (pressed) {
                    light.ct = colorPickerCt.ct;
                }
            }

            touchDelegate: Rectangle {
                height: colorPickerCt.height
                width: 8 * (.5)
                color: "transparent"
                border.color: "black"
                border.width: 8 * (2)
            }
        }

        ComboBox {
            id: effectSelector
            width: parent.width
            menu: ContextMenu {
                id: effectModel
                MenuItem {
                    text: "No effect"
                    property string value: "none"
                    onClicked: light.effect = "none"
                }
                MenuItem {
                    text: "Color loop"
                    property string value: "colorloop"
                    onClicked: light.effect = "colorloop"
                }
            }
            currentIndex: findIndex()

            function findIndex() {
                console.log("Light effect: " + light.effect)
                if (!light) {
                    return 0;
                }

                for (var i = 0; i < effectModel.count; i++) {
                    if (effectModel.get(i).value == light.effect) {
                        return i;
                    }
                }
                return 0;
            }
        }
    }

//    LightDelegate {
//        id: lightDelegate
//        width: parent.width
//        __isExpanded: true
//    }
}
