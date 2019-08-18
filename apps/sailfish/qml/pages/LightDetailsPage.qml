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
            //% "Light control"
            title: qsTrId("scintillon-light_detail_page_title")
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
                icon.source: "image://scintillon/icon-m-dim"
                icon.color: "white"
                icon.fillMode: Image.PreserveAspectFit
                icon.verticalAlignment: Image.AlignVCenter
                icon.width: width - 2 * Theme.paddingMedium
                icon.height: height
            }
            Slider {
                id: brightnessSlider
                width: parent.width - 2 * Theme.iconSizeMedium
                height: Theme.itemSizeSmall
                leftMargin: Theme.paddingSmall
                rightMargin: Theme.paddingSmall
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
                icon.source: "image://scintillon/icon-m-bright"
                icon.color: "white"
                icon.fillMode: Image.PreserveAspectFit
                icon.verticalAlignment: Image.AlignVCenter
                icon.width: width - 2 * Theme.paddingMedium
                icon.height: height

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

                touchDelegate: GlassItem {
                    width: Theme.itemSizeSmall / 2.0
                    height: Theme.itemSizeSmall / 2.0
                    radius: 0.17
                    falloffRadius: 0.17
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

                touchDelegate: GlassItem {
                    height: colorPickerCt.height
                    width: Theme.itemSizeSmall / 3.0
                    dimmed: false
                    radius: 0.17
                    falloffRadius: 0.14
                    ratio: 0.0
                    color: "black"
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
                    //% "No effect"
                    text: qsTrId("scintillon-light_detail_effect_none")
                    property string value: "none"
                    onClicked: light.effect = "none"
                }
                MenuItem {
                    //% "Color loop"
                    text: qsTrId("scintillon-light_detail_effect_colour_loop")
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
