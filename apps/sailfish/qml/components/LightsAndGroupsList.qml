import QtQuick 2.5
import Sailfish.Silica 1.0
import Hue 0.1
import harbour.scintillon.settings 1.0

ListView {
    id: root
    currentIndex: -1

    property var lights: null
    property var groups: null

    function selectLight(id) {
        for (var i = 0; i < lightsAndGroups.count; i++) {
            if (lightsAndGroups.get(i).type == "light" && lightsAndGroups.get(i).id == id) {
                root.currentIndex = i;
            }
        }
    }

    function selectGroup(id) {
        for (var i = 0; i < lightsAndGroups.count; i++) {
            if (lightsAndGroups.get(i).type == "group" && lightsAndGroups.get(i).id == id) {
                root.currentIndex = i;
            }
        }
    }

    model: ListModel {
        id: lightsAndGroups
        Component.onCompleted: refresh()
        function refresh() {
            lightsAndGroups.clear();
            for (var i = 0; i < root.lights.count; i++) {
                lightsAndGroups.append({name: root.lights.get(i).name, id: root.lights.get(i).id, type: "light", isGroup: false})
            }
            for (var i = 0; i < root.groups.count; i++) {
                lightsAndGroups.append({name: root.groups.get(i).name, id: root.groups.get(i).id, type: "group", isGroup: true})
            }
        }
    }
    Connections {
        target: root.lights
        onCountChanged: lightsAndGroups.refresh();
    }
    delegate: TextSwitch {
        width: parent.width
        height: Theme.itemSizeSmall
        text: model.name
        checked: root.currentIndex == index
        automaticCheck: false
        onClicked: {
            console.log("Selecting index " + index)
            root.currentIndex = index
        }
    }
}
