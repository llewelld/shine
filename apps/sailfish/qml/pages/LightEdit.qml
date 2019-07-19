import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1
import harbour.scintillon.settings 1.0

Dialog {
    id: root

    property var light
    property alias name: lightName.text

    allowedOrientations: Orientation.All

    canAccept: (name.length > 0)

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
                id: pageHeader
                title: qsTr("Edit light")
            }

            TextField {
                id: lightName
                label: qsTr("Light name")
                text: light ? light.name : ""
                placeholderText: label
                width: parent.width - 2 * Theme.horizontalPageMargin
                inputMethodHints: Qt.ImhNone
                //EnterKey.iconSource: "image://theme/icon-m-enter-next"
                //EnterKey.onClicked: passwordField.focus = true
            }
        }
    }

    onCanceled: {
        light.alert = "none"
    }

    onAccepted: {
        light.alert = "none"
        apply()
    }

    function apply() {
        lightName.focus = false;
        light.name = name
    }
}
