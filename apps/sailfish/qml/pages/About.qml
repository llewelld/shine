import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: aboutPage
    // The version property is now in the application
    // initialisation code in harbour-scintillon.cpp
    //property string version: "?.?-?"

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: aboutColumn.height
        flickableDirection: Flickable.VerticalFlick

        VerticalScrollDecorator {}

        Column {
            id: aboutColumn
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("About Scintillon")
            }

            Image {
                anchors.topMargin: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                source  : Qt.resolvedUrl("image://scintillon/scintillon-title")
            }

            Label {
                text: qsTr("Control your Philips Hue lighting from your phone")
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
                anchors {
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                    left: parent.left
                    right: parent.right
                }
            }

            InfoRow {
                label: qsTr("Version:")
                value: version
                midlineRatio: 0.3
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                label: qsTr("Author:")
                value: "David Llewellyn-Jones"
                midlineRatio: 0.3
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                label: qsTr("Libhue:")
                value: "Michael Zanetti"
                midlineRatio: 0.3
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                label: qsTr("Licence:")
                value: "GPLv2"
                midlineRatio: 0.3
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            SectionHeader {
                text: qsTr("Links")
            }

            Row {
                spacing: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    id: website
                    text: qsTr("Website")
                    enabled: true
                    onClicked: Qt.openUrlExternally("http://www.flypig.co.uk/?to=scintillon")
                }
                Button {
                    id : email
                    text: qsTr("Email")
                    enabled: true
                    onClicked: Qt.openUrlExternally("mailto:david@flypig.co.uk")
                }
            }
        }
    }
}

