import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1
import harbour.scintillon.settings 1.0

Dialog {
    id: root
    canAccept: false
    forwardNavigation: false

    property string errorMessage

    SilicaFlickable {
        interactive: true
        anchors.fill: parent
        contentHeight: errorColumn.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Column {
            id: errorColumn
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: qsTr("Hue Hub error")
                acceptText: ""
            }

            Label {
                id: errorLabel
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: errorMessage
                wrapMode: Text.WordWrap
                visible: errorMessage && errorMessage != ""
            }
        }
    }
}
