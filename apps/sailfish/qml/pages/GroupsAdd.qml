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
    property string id: ""
    property alias name: groupName.text
    property var groups

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
                title: id.length > 0 ? qsTr("Edit group") : qsTr("Create group")
            }

            TextField {
                id: groupName
                label: qsTr("Group name")
                placeholderText: label
                width: parent.width - 2 * Theme.horizontalPageMargin
                inputMethodHints: Qt.ImhNone
                //EnterKey.iconSource: "image://theme/icon-m-enter-next"
                //EnterKey.onClicked: passwordField.focus = true
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: "Check all the lights that should be controlled by this group."
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
        groupName.focus = false;
        var lightsList = new Array;
        for (var i = 0; i < lightsCheckboxes.count; ++i) {
            if (lightsCheckboxes.itemAt(i).checked) {
                console.log("adding light", i)
                lightsList.push(lights.get(i).id);
                console.log("list is now", lightsList.length)
            }
        }
        if (id.length > 0) {
            groups.updateGroup(id, name, lightsList);
        }
        else {
            groups.createGroup(name, lightsList);
        }
    }
}
