import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1
import harbour.scintillon.settings 1.0

Dialog {
    property Page startAPage

    canAccept: false
    acceptDestinationAction: PageStackAction.Pop
    acceptDestination: startAPage
    //backNavigation: false

    onStatusChanged: {
        if (status === PageStatus.Active) {
            console.log("Activated")
            busyIndicator.running = true
            HueBridge.createUser("Sailfish Scintillon")
        }
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: true
        size: BusyIndicatorSize.Large
    }

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
                title: qsTr("Attempting connection")
                acceptText: ""
                cancelText: qsTr("Retry")
            }

            Label {
                id: busyLabel
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Waiting for the connection to establish")
                wrapMode: Text.WordWrap
                visible: false
            }

            Label {
                id: errorLabel
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: qsTr("Error authenticating to Hue bridge\nPlease go back and try connecting again")
                wrapMode: Text.WordWrap
                visible: false
            }

            Label {
                id: errorMessageLabel
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.WordWrap
                visible: false
            }
        }
    }

    Connections {
        target: HueBridge
        onCreateUserFailed: {
            busyLabel.visible = false
            errorLabel.visible = true
            errorMessageLabel.visible = true
            errorMessageLabel.text = errorMessage
            busyIndicator.running = false
            canAccept = false
            backNavigation = true
        }
        onConnectedBridgeChanged: {
            if (HueBridge.connectedBridge) {
                busyLabel.visible = false
                errorLabel.visible = false
                errorMessageLabel.visible = false
                busyIndicator.running = false
                canAccept = true
                accept()
            }
        }
    }
}
