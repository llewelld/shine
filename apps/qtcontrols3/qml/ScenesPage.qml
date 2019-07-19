/*
 * Copyright 2013-2015 Michael Zanetti
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 2.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Michael Zanetti <michael_zanetti@gmx.net>
 */

import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import Hue 0.1
import "PopupUtils.js" as PopupUtils

ShinePage {
    id: root
    title: "Scenes"
    busy: scenes && scenes.count === 0 && scenes.busy

    property var lights: null
    property var scenes: null
    property var schedules: null

    toolButtons: ListModel {
        ListElement { text: "settings"; image: "add" }
        ListElement { text: "add"; image: "add" }
    }
    onToolButtonClicked: {
        switch (index) {
        case 0:
            PopupUtils.openComponent(sceneSettingsComponent, root, {})
            break
        case 1:
            var popup = PopupUtils.open(Qt.resolvedUrl("EditSceneDialog.qml"), root, {title: "Create Scene", lights: root.lights})
            popup.accepted.connect(function(name, lightsList) {
                scenes.createScene(name, lightsList);
            })
            break
        }
    }

    Label {
        anchors { left: parent.left; right: parent.right; margins: 8 * (2); verticalCenter: parent.verticalCenter }
        wrapMode: Text.WordWrap
        text: "No scenes created. You can create scenes by using the + button in the header."
        horizontalAlignment: Text.AlignHCenter
        visible: scenes.count === 0 && !root.busy
        z: 2
    }

    Column {
        anchors.fill: parent
        ScenesFilterModel {
            id: scenesFilterModel
            scenes: root.scenes
            hideOtherApps: settings.hideScenesByOtherApps
        }

        ListView {
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.height
            model: scenesFilterModel

            delegate: ItemDelegate {
                property var scene: scenesFilterModel.get(index)
                width: parent.width
                height: 60

                Row {
                    anchors { fill: parent; leftMargin: 8 * (2); rightMargin: 8 * (2) }
                    spacing: 8 * (1)
                    Image {
                        id: icon
                        height: parent.height - 8 * (2)
                        anchors.verticalCenter: parent.verticalCenter
                        width: height
                        source: "images/scene_outline.svg"

                        sourceSize.width: width
                        sourceSize.height: height
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Label {
                            width: parent.width
                            text: model.name
                        }

                        Row {
                            Repeater {
                                model: root.lights.count > 0 && scene ? scene.lightsCount : 0
                                Label {
                                    text: scene ? lights.findLight(scene.light(index)).name : ""
                                }
                            }
                        }
                    }
                }

                onClicked: {
                    scenes.recallScene(scene.id)
                }
                onPressAndHold: actionMenu.open()

                Menu {
                    id: actionMenu
                    MenuItem {
                        text: "Edit"
                        onTriggered: {
                            var checkedLights = [];
                            for (var i = 0; i < scene.lightsCount; i++) {
                                checkedLights.push(scene.light(i))
                            }
                            var popup = PopupUtils.open(Qt.resolvedUrl("EditSceneDialog.qml"), root, {title: "Edit scene", lights: root.lights, checkedLights: checkedLights, name: scene.name})
                            popup.accepted.connect(function(name, lightsList) {
                                scenes.updateScene(scene.id, name, lightsList);
                            })
                        }
                    }
                    MenuItem {
                        text: "Alarm clock"
                        onTriggered: {
                            PopupUtils.open(Qt.resolvedUrl("CreateAlarmDialog.qml"), root, {scene: scenesFilterModel.get(index), schedules: root.schedules } )
                        }
                    }
                    MenuItem {
                        id: deleteAction
                        text: "Delete"
                        onTriggered: scenes.deleteScene(scene.id)
                    }
                }



            }
        }

    }

    Component {
        id: sceneSettingsComponent
        Dialog {
            id: sceneSettingsDialog
            title: "Scene settings"
            Column {
                RowLayout {
                    CheckBox {
                        id: showOtherApps
                        checked: !settings.hideScenesByOtherApps
                    }
                    Label {
                        color: "black"
                        text: "Show scenes created by other apps"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
            footer: DialogButtonBox {
                Button {
                    text: "OK"
                    onClicked: {
                        settings.hideScenesByOtherApps = !showOtherApps.checked
                        PopupUtils.close(sceneSettingsDialog)
                    }
                }
            }
        }
    }
}
