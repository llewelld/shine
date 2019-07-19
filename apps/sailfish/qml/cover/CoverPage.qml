import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.scintillon.settings 1.0

CoverBackground {
    id: root

    allowResize: true

    Item {
        id: contents

        width: Theme.coverSizeLarge.width
        height: Theme.coverSizeLarge.height

        Column {
            id: stopwatchView

            anchors {
                top: parent.top
                topMargin: Theme.paddingMedium
                leftMargin: Theme.paddingLarge
                rightMargin: Theme.paddingLarge
            }

            Label {
                id: titleLabel

                anchors.horizontalCenter: parent.horizontalCenter
                text: "Scintillon"
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeLarge
                truncationMode: TruncationMode.Fade
            }

        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: Settings.getImageUrl("icon-cover-journey-start")
            onTriggered: console.log("Clicked")
        }
    }
}
