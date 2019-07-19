import QtQuick 2.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.1

Dialog {
    id: root
    title: mode == "group" ? "Add group" : "Add scene"

    property string mode: "group" // or "scene"
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
        Label {
            text: mode == "group" ? "Please enter a name for the new group:" : "Please enter a name for the scene:"
        }

        TextField {
            id: nameTextField
            width: parent.width - x
        }
        ThinDivider {}

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
            enabled: nameTextField.text || nameTextField.inputMethodComposing
            onClicked: {
                nameTextField.focus = false;
                var lightsList = new Array;
                for (var i = 0; i < lightsCheckboxes.count; ++i) {
                    if (lightsCheckboxes.itemAt(i).checked) {
                        lightsList.push(lights.get(i).id);
                    }
                }

                if (lightsList.length == 0) {
                    PopupUtils.open(errorDialog, root)
                    return;
                }

                root.accepted(nameTextField.text, lightsList)
                accept()
            }
        }
        Button {
            text: "Cancel"
            onClicked: {
                root.rejected();
                reject()
            }
        }
    }

    Component {
        id: errorDialog
        Dialog {
            id: ed
            title: "Error"
            Label {
                text: "Please select at least one light to be part of the group."
            }
            Button {
                text: "OK"
                onClicked: PopupUtils.close(ed)
            }
        }
    }
}
