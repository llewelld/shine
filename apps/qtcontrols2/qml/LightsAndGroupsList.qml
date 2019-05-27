import QtQuick 2.3
import QtQuick.Controls 2.1
import Hue 0.1
import "PopupUtils.js" as PopupUtils

ListView {
    id: root
    clip: true
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
    delegate: MouseArea {
        height: 8 * (5)
        Row {
            anchors { fill: parent; leftMargin: 8 * (2); rightMargin: 8 * (2); topMargin: 8 * (1); bottomMargin: 8 * (1) }
            Label {
                text: model.name
            }
            Image {
                source: "images/tick.svg"
                visible: root.currentIndex == index
            }
        }
        onClicked: root.currentIndex = index
    }
}
