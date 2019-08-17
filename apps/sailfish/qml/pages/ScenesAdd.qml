import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1
import harbour.scintillon.settings 1.0

Dialog {
    id: root

    property var lights: null
    property var checkedLights: null
    property int lightsSelected
    property string sceneid: ""
    property alias name: sceneName.text
    property var scenes

    allowedOrientations: Orientation.All

    canAccept: (name.length > 0) && (lightsSelected > 0)

    Component.onCompleted: {
        console.log("completed", root.checkedLights)
        if (root.checkedLights) {
            lightsSelected = 0
            for (var i = 0; i < root.checkedLights.length; i++) {
                console.log("checked light:", root.checkedLights[i])
                lightsCheckboxes.itemAt(root.checkedLights[i] - 1).checked = true
                lightsSelected++
            }
        }
    }

    SilicaFlickable {
        width: parent.width
        height: parent.height
        interactive: true

        anchors.fill: parent
        contentHeight: settingsColumn.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Column {
            id: settingsColumn
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                id: pageHeader
                title: sceneid.length > 0 ? qsTr("Edit scene") : qsTr("Create scene")
            }

            TextField {
                id: sceneName
                label: qsTr("Scene name")
                placeholderText: label
                width: parent.width - 2 * Theme.horizontalPageMargin
                inputMethodHints: Qt.ImhNone
                //EnterKey.iconSource: "image://theme/icon-m-enter-next"
                //EnterKey.onClicked: passwordField.focus = true
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: "Seect lights to be controlled by this scene. Current brightness and color values will be used."
                wrapMode: Text.WordWrap
            }

            Column {
                width: parent.width
                spacing: 0

                Repeater {
                    id: lightsCheckboxes
                    model: root.lights
                    delegate: ListItem {
                        height: Theme.itemSizeSmall
                        property alias checked: lightSwitch.checked
                        TextSwitch {
                            id: lightSwitch
                            width: parent.width
                            text: name
                            checked: false
                            automaticCheck: true
                            onCheckedChanged: {
                                if (checked) {
                                    lightsSelected++;
                                }
                                else {
                                    lightsSelected--
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    onAccepted: {
        apply()
    }

    function apply() {
        sceneName.focus = false;
        var lightsList = new Array;
        for (var i = 0; i < lightsCheckboxes.count; ++i) {
            if (lightsCheckboxes.itemAt(i).checked) {
                lightsList.push(lights.get(i).id);
            }
        }
        if (sceneid.length > 0) {
            scenes.updateScene(sceneid, name, lightsList);
        }
        else {
            scenes.createScene(name, lightsList)
        }
    }
}
