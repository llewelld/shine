import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1


Page {
    id: root

    property var groups: null
    property var lights: null

    allowedOrientations: Orientation.All

    SilicaListView {
        id: listView
        anchors.fill: parent

        VerticalScrollDecorator {}

        PullDownMenu {
            MenuItem {
                //% "Create group"
                text: qsTrId("scintillon-groups_menu_create")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GroupsAdd.qml"), {lights: lights, groups: groups})
                }
            }
        }

        header: PageHeader {
            id: title
            //% "Groups"
            title: qsTrId("scintillon-groups_page_title")
        }

        model: groups

        delegate: ListItem {
            id: listItem
            menu: groupsMenuComponent
            Row {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingLarge

                TextSwitch {
                    text: model.name
                    checked: model.on
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - configButton.width
                    onClicked: {
                        var group = groups.get(index)
                        group.on = !group.on;
                    }
                    onPressAndHold: listItem.openMenu()
                }

                IconButton {
                    id: configButton
                    height: Theme.itemSizeSmall
                    width: height
                    icon.source: "image://theme/icon-s-setting"
                    onClicked: {
                        var group = groups.get(index)
                        pageStack.push(Qt.resolvedUrl("LightDetailsPage.qml"), {light: group, schedules: schedules})
                    }
                    onPressAndHold: listItem.openMenu()
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
                            text: qsTrId("scintillon-groups_menu_edit")
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
                            text: qsTrId("scintillon-groups_menu_alarm")
                            onClicked: {
                                var group = groups.get(index)
                                group.alert = "lselect"
                                var dalog = pageStack.push(Qt.resolvedUrl("AlarmAdd.qml"), {light: group, schedules: schedules})
                            }
                        }
                        MenuItem {
                            //% "Countdown"
                            text: qsTrId("scintillon-groups_menu_countdown")
                            onClicked: {
                                var group = groups.get(index)
                                group.alert = "lselect"
                                var dalog = pageStack.push(Qt.resolvedUrl("CountdownAdd.qml"), {light: group, schedules: schedules})
                            }
                        }
                        MenuItem {
                            //% "Delete"
                            text: qsTrId("scintillon-groups_menu_delete")
                            onClicked: groups.deleteGroup(model.id)
                        }
                    }
                }
            }
        }
    }
}
