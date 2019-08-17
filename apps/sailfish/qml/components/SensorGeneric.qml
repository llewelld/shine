import QtQuick 2.5
import Sailfish.Silica 1.0
import Hue 0.1
import harbour.scintillon.settings 1.0

Item {
    id: hueGeneric
    height: hueGenericRow.height

    Row {
        id: hueGenericRow
        width: parent.width - 2.0 * Theme.horizontalPageMargin
        x: Theme.horizontalPageMargin
        spacing: Theme.paddingMedium

        Column {
            id: hueGenericColumn
            width: parent.width - hueGenericIcon.width - Theme.paddingMedium
        }

        Item {
            width: Theme.iconSizeExtraLarge
            height: width
            Icon {
                id: hueGenericIcon
                width: Theme.iconSizeLarge
                height: Theme.iconSizeLarge
                anchors.centerIn: parent
                source: Qt.resolvedUrl("image://scintillon/sensors/generic-0")
                color: "white"
                fillMode: Image.PreserveAspectFit
            }
        }
    }
}
