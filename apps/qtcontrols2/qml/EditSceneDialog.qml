import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Hue 0.1
import "PopupUtils.js" as PopupUtils

Dialog {
    id: root
    width: parent.width

    property var lights: null
    property var checkedLights: null
    property alias name: nameTextField.text

    signal accepted(string name, var ligths);
    signal rejected();

    Component.onCompleted: {
        print("completed", root.checkedLights)
        if (root.checkedLights) {
            for (var i = 0; i < root.checkedLights.length; i++) {
                print("checked light:", root.checkedLights[i])
                lightsCheckboxes.itemAt(root.checkedLights[i] - 1).checked = true
            }
        }
    }

    Column {
        width: parent.width

        Label {
            text: "Scene name"
        }

        TextField {
            id: nameTextField
            width: parent.width
        }
        ThinDivider {}

        Label {
            width: parent.width
            text: "Check all the lights that should be controlled by this scene. The current brightness and color values will be used."
            wrapMode: Text.WordWrap
        }

        Repeater {
            id: lightsCheckboxes
            model: root.lights
            delegate: Row {
                width: parent.width
                spacing: 8 * (1)
                property alias checked: checkBox.checked
                CheckBox {
                    id: checkBox
                    checked: false
                }
                Label {
                    text: name
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    footer: DialogButtonBox {
        Button {
            text: "OK"
            enabled: nameTextField.text.length > 0 || nameTextField.inputMethodComposing
            onClicked: {
                nameTextField.focus = false;
                var lightsList = new Array;
                for (var i = 0; i < lightsCheckboxes.count; ++i) {
                    if (lightsCheckboxes.itemAt(i).checked) {
                        print("adding light", i)
                        lightsList.push(lights.get(i).id);
                        print("list is now", lightsList.length)
                    }
                }

                root.accepted(nameTextField.text, lightsList)
                PopupUtils.close(root)
            }
        }
        Button {
            text: "Cancel"
            onClicked: {
                root.rejected();
                close(root)
            }
        }
    }
}
