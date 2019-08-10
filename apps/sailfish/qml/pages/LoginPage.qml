import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1
import harbour.scintillon.settings 1.0

Dialog {
    property Page startAPage

    acceptDestinationProperties: {"startAPage": startAPage}
    acceptDestination: Qt.resolvedUrl("BusyPage.qml")
    backNavigation: false

    SilicaFlickable {
        interactive: true
        anchors.fill: parent
        contentHeight: connectColumn.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Column {
            id: connectColumn
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: qsTr("Connect to Hue bridge")
                acceptText: qsTr("Connect")
                cancelText: ""
            }

            Label {
                id: pressButtonLabel
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Please press the button on the Hue bridge and then Connect")
                wrapMode: Text.WordWrap
                visible: true
            }
        }
    }
}
