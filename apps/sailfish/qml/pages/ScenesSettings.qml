import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1
import harbour.scintillon.settings 1.0

Page {
    id: root

    allowedOrientations: Orientation.All

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

            PageHeader {
                title: qsTr("Scene settings")
            }

            TextSwitch {
                text: qsTr("Show scenes created by other apps")
                checked: Settings.hideScenesByOtherApps
                automaticCheck: false
                onClicked: Settings.hideScenesByOtherApps = !Settings.hideScenesByOtherApps
            }
        }
    }
}
