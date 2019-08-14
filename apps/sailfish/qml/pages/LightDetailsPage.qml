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
        width: parent.width
        spacing: Theme.paddingLarge

        PageHeader {
            title: qsTr("Light control")
        }

        Row {
            x: Theme.horizontalPageMargin
            width: parent.width - 2 * Theme.horizontalPageMargin
            spacing: 0
            IconButton {
                id: dimButton
                width: Theme.iconSizeMedium
                height: Theme.itemSizeSmall
                onClicked: light.bri = 0;
                icon.source: "image://scintillon/icon-s-dim"
                icon.color: "white"
                icon.fillMode: Image.PreserveAspectFit
                icon.verticalAlignment: Image.AlignVCenter
            }
            Slider {
                id: brightnessSlider
                width: parent.width - 2 * Theme.iconSizeMedium
                height: Theme.itemSizeSmall
                minimumValue: 0
                maximumValue: 255
                //value: light ? light.bri : 0
                onValueChanged: {
                    light.setBriImmediate(value)
                }
            }
            IconButton {
                id: brightButton
                width: Theme.iconSizeMedium
                height: Theme.itemSizeSmall
                onClicked: light.bri = 255;
                icon.source: "image://scintillon/icon-s-bright"
                icon.color: "white"
                icon.fillMode: Image.PreserveAspectFit
                icon.verticalAlignment: Image.AlignVCenter
            }
        }

        Column {
            x: Theme.horizontalPageMargin
            width: parent.width - 2 * Theme.horizontalPageMargin
            spacing: Theme.paddingLarge

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
                        light.setColorImmediate(colorPicker.color)
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
                        light.setCtImmediate(colorPickerCt.ct)
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
        }

        ComboBox {
            id: effectSelector
            visible: false
            enabled: false
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
