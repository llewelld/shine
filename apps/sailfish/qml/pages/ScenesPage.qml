import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import harbour.scintillon.settings 1.0
import Hue 0.1

Page {
    id: root

    property alias scenes: scenesFilterModel.scenes
    property var lights: null

    allowedOrientations: Orientation.All

    SilicaListView {
        id: listView
        anchors.fill: parent

        VerticalScrollDecorator {}

        ViewPlaceholder {
            enabled: listView.count === 0
            //% "No scenes"
            text: qsTrId("scintillon-scenes_placeholder_text")
            hintText: (HueBridge.status !== HueBridge.BridgeStatusConnected)
                      //% "Not connected to a Hue Hub"
                      ? qsTrId("scintillon-scenes_placeholder_hint_no_hub")
                      : (lights.count > 0)
                        //% "Pull down to create a new scene"
                        ? qsTrId("scintillon-scenes_placeholder_hint_no_scenes")
                        //% "Connect a light to your Hue Hub to get started"
                        : qsTrId("scintillon-scenes_placeholder_text_no_lights")
        }

        PullDownMenu {
            MenuItem {
                //% "Scene settings"
                text: qsTrId("scintillon-scenes_menu_settings")
                onClicked: pageStack.push(Qt.resolvedUrl("ScenesSettings.qml"))
            }

            MenuItem {
                //% "Create scene"
                text: qsTrId("scintillon-scenes_menu_create_scene")
                enabled: lights.count > 0
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ScenesAdd.qml"), {sceneid: null, lights: lights, scenes: scenes})
                }
            }
        }

        header: PageHeader {
            id: title
            //% "Scenes"
            title: qsTrId("scintillon-scenes_page_title")
        }

        model: ScenesFilterModel {
            id: scenesFilterModel
            hideOtherApps: Settings.hideScenesByOtherApps
        }

        delegate: ListItem {
            id: sceneItem
            menu: scenesMenuComponent
            highlighted: scenePressable.highlighted

            Row {
                x: Theme.horizontalPageMargin
                height: Theme.itemSizeSmall
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: 0

                IconPressable {
                    id: scenePressable
                    width: parent.width - 2 * Theme.itemSizeSmall
                    height: Theme.itemSizeSmall
                    sourceOn: Qt.resolvedUrl("image://scintillon/icon-m-scene")
                    sourceOff: Qt.resolvedUrl("image://scintillon/icon-m-scene-outline")
                    icon.color: "white"
                    icon.width: Theme.iconSizeMedium
                    icon.height: icon.width
                    text: model.name

                    onClicked: scenes.recallScene(model.id)
                    onPressAndHold: sceneItem.openMenu()
                }

                IconButton {
                    id: sceneCountdownButton
                    height: Theme.itemSizeSmall
                    width: height
                    icon.source: "image://scintillon/icon-s-countdown"
                    icon.width: Theme.iconSizeSmall
                    icon.height: icon.width
                    onClicked: {
                        var scene = scenesFilterModel.get(index)
                        var dalog = pageStack.push(Qt.resolvedUrl("CountdownAdd.qml"), {scene: scene, schedules: schedules})
                    }
                    onPressAndHold: sceneItem.openMenu()
                }

                IconButton {
                    id: sceneAlarmButton
                    height: Theme.itemSizeSmall
                    width: height
                    icon.source: "image://scintillon/icon-s-alarm"
                    icon.width: Theme.iconSizeSmall
                    icon.height: icon.width
                    onClicked: {
                        var scene = scenesFilterModel.get(index)
                        var dalog = pageStack.push(Qt.resolvedUrl("AlarmAdd.qml"), {scene: scene, schedules: schedules})
                    }
                    onPressAndHold: sceneItem.openMenu()
                }
            }

            Component {
                id: scenesMenuComponent
                ContextMenu {
                    MenuItem {
                        //% "Edit"
                        text: qsTrId("scintillon-scenes_menu_scene_edit")
                        onClicked: {
                            var scene = scenesFilterModel.get(index)
                            var checkedLights = [];
                            for (var i = 0; i < scene.lightsCount; i++) {
                                console.log("Adding light " + i)
                                checkedLights.push(scene.light(i))
                            }
                            pageStack.push(Qt.resolvedUrl("ScenesAdd.qml"), {sceneid: model.id, lights: lights, name: model.name, scenes: scenes, checkedLights: checkedLights})
                        }
                    }
                    MenuItem {
                        //% "Alarm"
                        text: qsTrId("scintillon-scenes_menu_scene_alarm")
                        onClicked: {
                            var scene = scenesFilterModel.get(index)
                            var dalog = pageStack.push(Qt.resolvedUrl("AlarmAdd.qml"), {scene: scene, schedules: schedules})
                        }
                    }
                    MenuItem {
                        //% "Timer"
                        text: qsTrId("scintillon-scenes_menu_scene_timer")
                        onClicked: {
                            var scene = scenesFilterModel.get(index)
                            var dalog = pageStack.push(Qt.resolvedUrl("CountdownAdd.qml"), {scene: scene, schedules: schedules})
                        }
                    }
                    MenuItem {
                        //% "Delete"
                        text: qsTrId("scintillon-scenes_menu_scene_delete")
                        onClicked: scenes.deleteScene(model.id)
                    }
                }
            }
        }
    }
}