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
        contentHeight: aboutColumn.height + Theme.paddingLarge
        flickableDirection: Flickable.VerticalFlick

        VerticalScrollDecorator {}

        Column {
            id: aboutColumn
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                //% "About Scintillon"
                title: qsTrId("scintillon-about_title")
            }

            Image {
                anchors.topMargin: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                source  : Qt.resolvedUrl("image://scintillon/scintillon-title")
            }

            Label {
                //% "Control your Philips Hue lighting from your phone"
                text: qsTrId("scintillon-about_description")
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
                //% "Version"
                label: qsTrId("scintillon-about_verion")
                value: version
                midlineRatio: 0.4
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                //% "App author"
                label: qsTrId("scintillon-about_app_author")
                //% "David Llewellyn-Jones"
                value: qsTrId("scintillon-about_app_author_name")
                midlineRatio: 0.4
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                //% "Libhue author"
                label: qsTrId("scintillon-about_libhue_author")
                //% "Michael Zanetti"
                value: qsTrId("scintillon-about_libhue_author_name")
                midlineRatio: 0.4
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            InfoRow {
                //% "Licence"
                label: qsTrId("scintillon-about_licence")
                //% "GPLv2"
                value: qsTrId("scintillon-about_gpl_v2")
                midlineRatio: 0.4
                midlineMin: Theme.fontSizeSmall * 5
                midlineMax: Theme.fontSizeSmall * 10
            }

            SectionHeader {
                //% "Links"
                text: qsTrId("scintillon-about_header_links")
            }

            Row {
                spacing: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    id: website
                    //% "Website"
                    text: qsTrId("scintillon-about_website")
                    enabled: true
                    onClicked: Qt.openUrlExternally("http://www.flypig.co.uk/?to=scintillon")
                }
                Button {
                    id : email
                    //% "Email"
                    text: qsTrId("scintillon-about_email")
                    enabled: true
                    onClicked: Qt.openUrlExternally("mailto:david@flypig.co.uk")
                }
            }
        }
    }
}
