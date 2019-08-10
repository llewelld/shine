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
            text: qsTr("No lights or groups")
            hintText: (HueBridge.status === HueBridge.BridgeStatusConnected)
                      ? qsTr("Connect a light to your Hue Hub to get started")
                      : qsTr("Not connected to a Hue Hub")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Create group")
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
                title: qsTr("Lights and groups")
            }

            SectionHeader {
                text: qsTr("Groups")
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
                                    text: qsTr("Edit")
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
                                    text: qsTr("Alarm")
                                    onClicked: {
                                        var group = groups.get(index)
                                        group.alert = "lselect"
                                        var dalog = pageStack.push(Qt.resolvedUrl("AlarmAdd.qml"), {light: group, schedules: schedules})
                                    }
                                }
                                MenuItem {
                                    text: qsTr("Timer")
                                    onClicked: {
                                        var group = groups.get(index)
                                        group.alert = "lselect"
                                        var dalog = pageStack.push(Qt.resolvedUrl("CountdownAdd.qml"), {light: group, schedules: schedules})
                                    }
                                }
                                MenuItem {
                                    text: qsTr("Delete")
                                    onClicked: groups.deleteGroup(model.id)
                                }
                            }
                        }
                    }
                }
            }

            SectionHeader {
                text: qsTr("Lights")
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
                                    text: qsTr("Rename")
                                    onClicked: {
                                        var light = lightsFilterModel.get(index)
                                        light.alert = "lselect"
                                        pageStack.push(Qt.resolvedUrl("LightEdit.qml"), {light: light})
                                    }
                                }
                                MenuItem {
                                    text: qsTr("Alarm")
                                    onClicked: {
                                        var light = lightsFilterModel.get(index)
                                        light.alert = "lselect"
                                        var dalog = pageStack.push(Qt.resolvedUrl("AlarmAdd.qml"), {light: light, schedules: schedules})
                                    }
                                }
                                MenuItem {
                                    text: qsTr("Timer")
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
