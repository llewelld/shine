import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1

Page {
    id: root

    property var rules: null

    allowedOrientations: Orientation.All

    SilicaListView {
        id: listView
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick

        VerticalScrollDecorator {}

        header: PageHeader {
            id: title
            title: qsTr("Rules")
        }

        model: rules

        delegate: ListItem {
            Label {
                text: model.name
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
