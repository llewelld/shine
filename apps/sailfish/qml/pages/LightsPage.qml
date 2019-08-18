import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1
import "../utils/ColourUtils.js" as Utils

Page {
    id: root

    property alias lights: lightsFilterModel.lights
    property var groups: null
    property var schedules: null

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: mainColumn.height

        VerticalScrollDecorator {}

        ViewPlaceholder {
            enabled: (lightsColumn.count === 0) && (groupsColumn.count === 0)
            //% "No lights or groups"
            text: qsTrId("scintillon-lights_placeholder_text")
            hintText: (HueBridge.status === HueBridge.BridgeStatusConnected)
                      //% "Connect a light to your Hue Hub to get started"
                      ? qsTrId("scintillon-lights_placeholder_hint_no_lights")
                      //% "Not connected to a Hue Hub"
                      : qsTrId("scintillon-lights_placeholder_hint_no_hub")
        }

        PullDownMenu {
            MenuItem {
                //% "Create group"
                text: qsTrId("scintillon-lights_menu_create_group")
                enabled: lightsColumn.count
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GroupsAdd.qml"), {lights: lights, groups: groups})
                }
            }
        }

        Column {
            id: mainColumn
            width: parent.width

            PageHeader {
                id: title
                //% "Lights and groups"
                title: qsTrId("scintillon-lights_page_title")
            }

            SectionHeader {
                //% "Groups"
                text: qsTrId("scintillon-lights_section_groups")
                visible: groupsColumn.count > 0
            }

            ColumnView {
                id: groupsColumn
                width: parent.width
                itemHeight: Theme.itemSizeSmall

                model: groups

                delegate: ListItem {
                    id: groupItem
                    menu: groupsMenuComponent
                    highlighted: groupSwitch.highlighted

                    Row {
                        x: Theme.horizontalPageMargin
                        width: parent.width - 2 * Theme.horizontalPageMargin
                        spacing: 0

                        IconSwitch {
                            id: groupSwitch
                            width: parent.width - Theme.itemSizeSmall
                            height: Theme.itemSizeSmall
                            sourceOn: Qt.resolvedUrl("image://scintillon/bulbGroup")
                            sourceOff: Qt.resolvedUrl("image://scintillon/bulbGroup-outline")
                            icon.color: "white"
                            icon.width: Theme.iconSizeMedium
                            icon.height: icon.width
                            text: model.name
                            checked: model.on

                            onClicked: {
                                var group = groups.get(index)
                                group.on = !model.on
                            }
                            onPressAndHold: groupItem.openMenu()
                        }

                        IconButton {
                            id: groupConfigButton
                            height: Theme.itemSizeSmall
                            width: height
                            icon.source: "image://theme/icon-s-setting"
                            icon.width: Theme.iconSizeSmall
                            icon.height: icon.width
                            onClicked: {
                                var group = groups.get(index)
                                pageStack.push(Qt.resolvedUrl("LightDetailsPage.qml"), {light: group, schedules: schedules})
                            }
                            onPressAndHold: groupItem.openMenu()
                        }

                        Connections {
                            target: groups.get(index)
                            onWriteOperationFinished: {
                                root.groups.refresh()
                            }
                        }
                        Component {
                            id: groupsMenuComponent
                            ContextMenu {
                                MenuItem {
                                    //% "Edit"
                                    text: qsTrId("scintillon-lights_menu_group_edit")
                                    onClicked: {
                                        var group = groups.get(index)
                                        var checkedLights = [];
                                        for (var i = 0; i < group.lightsCount; i++) {
                                            console.log("Adding light " + i)
                                            checkedLights.push(group.light(i))
                                        }
                                        pageStack.push(Qt.resolvedUrl("GroupsAdd.qml"), {id: model.id, lights: lights, name: model.name, groups: groups, checkedLights: checkedLights})
                                    }
                                }
                                MenuItem {
                                    //% "Alarm"
                                    text: qsTrId("scintillon-lights_menu_group_alarm")
                                    onClicked: {
                                        var group = groups.get(index)
                                        group.alert = "lselect"
                                        var dalog = pageStack.push(Qt.resolvedUrl("AlarmAdd.qml"), {light: group, schedules: schedules})
                                    }
                                }
                                MenuItem {
                                    //% "Timer"
                                    text: qsTrId("scintillon-lights_menu_group_timer")
                                    onClicked: {
                                        var group = groups.get(index)
                                        group.alert = "lselect"
                                        var dalog = pageStack.push(Qt.resolvedUrl("CountdownAdd.qml"), {light: group, schedules: schedules})
                                    }
                                }
                                MenuItem {
                                    //% "Delete"
                                    text: qsTrId("scintillon-lights_menuu_group_delete")
                                    onClicked: groups.deleteGroup(model.id)
                                }
                            }
                        }
                    }
                }
            }

            SectionHeader {
                //% "Lights"
                text: qsTrId("scintillon-lights_section_lights")
                visible: lightsColumn.count > 0
            }

            ColumnView {
                id: lightsColumn
                width: parent.width
                itemHeight: Theme.itemSizeSmall

                model: LightsFilterModel {
                    id: lightsFilterModel
                }

                delegate: ListItem {
                    id: lightItem
                    menu: lightsMenuComponent
                    highlighted: lightSwitch.highlighted

                    Row {
                        x: Theme.horizontalPageMargin
                        width: parent.width - 2 * Theme.horizontalPageMargin
                        spacing: 0

                        IconSwitch {
                            id: lightSwitch
                            width: parent.width - Theme.itemSizeSmall
                            height: Theme.itemSizeSmall
                            sourceOn: Qt.resolvedUrl("image://scintillon/archetypes/" + model.archetype)
                            sourceOff: Qt.resolvedUrl("image://scintillon/archetypes/" + model.archetype + "-outline")
                            icon.color: Utils.calculateLightColor(lightsFilterModel.get(index))
                            icon.width: Theme.iconSizeMedium
                            icon.height: icon.width
                            text: model.name
                            checked: model.on

                            onClicked: {
                                var light = lightsFilterModel.get(index)
                                light.on = !checked;
                                console.log("Colour: " + light.color)
                            }
                            onPressAndHold: lightItem.openMenu()
                        }

                        IconButton {
                            id: lightConfigButton
                            height: Theme.itemSizeSmall
                            width: height
                            icon.source: "image://theme/icon-s-setting"
                            icon.width: Theme.iconSizeSmall
                            icon.height: icon.width
                            onClicked: {
                                var light = lightsFilterModel.get(index)
                                pageStack.push(Qt.resolvedUrl("LightDetailsPage.qml"), {light: light, schedules: schedules})
                            }
                            onPressAndHold: lightItem.openMenu()
                        }

                        Connections {
                            target: lightsFilterModel.get(index)
                            onWriteOperationFinished: {
                                root.lights.refresh()
                            }
                        }
                        Component {
                            id: lightsMenuComponent
                            ContextMenu {
                                MenuItem {
                                    //% "Rename"
                                    text: qsTrId("scintillon-lights_menu_light_rename")
                                    onClicked: {
                                        var light = lightsFilterModel.get(index)
                                        light.alert = "lselect"
                                        pageStack.push(Qt.resolvedUrl("LightEdit.qml"), {light: light})
                                    }
                                }
                                MenuItem {
                                    //% "Alarm"
                                    text: qsTrId("scintillon-lights_menu_light_alarm")
                                    onClicked: {
                                        var light = lightsFilterModel.get(index)
                                        light.alert = "lselect"
                                        var dalog = pageStack.push(Qt.resolvedUrl("AlarmAdd.qml"), {light: light, schedules: schedules})
                                    }
                                }
                                MenuItem {
                                    //% "Timer"
                                    text: qsTrId("scintillon-lights_menu_light_timer")
                                    onClicked: {
                                        var light = lightsFilterModel.get(index)
                                        light.alert = "lselect"
                                        var dalog = pageStack.push(Qt.resolvedUrl("CountdownAdd.qml"), {light: light, schedules: schedules})
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
