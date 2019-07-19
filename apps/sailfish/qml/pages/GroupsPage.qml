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
                text: qsTr("Create group")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GroupsAdd.qml"), {lights: lights, groups: groups})
                }
            }
        }

        header: PageHeader {
            id: title
            title: qsTr("Groups")
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
                            text: qsTr("Countdown")
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
}
