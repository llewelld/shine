import QtQuick 2.5
import Sailfish.Silica 1.0
import Hue 0.1
import harbour.scintillon.settings 1.0

ColumnView {
    itemHeight: Theme.itemSizeSmall
    currentIndex: 0
    property var selectedScenes: []
    model: scenesFilterModel
    property alias scenes: scenesFilterModel.scenes
    property alias scenesFilterModel: scenesFilterModel

    ScenesFilterModel {
        id: scenesFilterModel
        hideOtherApps: true
    }
    delegate: TextSwitch {
        width: parent.width
        height: Theme.itemSizeSmall
        text: model.name
        checked: {
            console.log("evaluating visible for", model.name, selectedScenes.length)
            for (var i = 0; i < selectedScenes.length; i++) {
                if (selectedScenes[i] == model.id) {
                    console.log("scene is checked", model.name)
                    return true;
                }
            }
            return false;
        }
        automaticCheck: false
        onClicked: {
            var removed = false;
            var list = [];
            for (var i = 0; i < selectedScenes.length; i++) {
                if (selectedScenes[i] === model.id) {
                    removed = true;
                } else {
                    list.push(selectedScenes[i])
                }
            }
            if (!removed){
                list.push(model.id)
            }
            selectedScenes = list;
        }
    }
}
