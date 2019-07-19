import QtQuick 2.5
import QtQuick.Controls 2.1

AbstractButton {
    id: root
    property alias source: image.source

    Image {
        id: image
        anchors.fill: parent
    }
}
