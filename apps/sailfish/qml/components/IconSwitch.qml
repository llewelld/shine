import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: root
    property alias icon: image
    property string sourceOn
    property string sourceOff: sourceOn
    property bool down: pressed && containsMouse
    property bool highlighted: down
    property bool _showPress: highlighted || pressTimer.running
    property alias text: label.text
    property bool checked
    height: Theme.itemSizeSmall

    onPressedChanged: {
        if (pressed) {
            pressTimer.start()
        }
    }
    onCanceled: pressTimer.stop()

    HighlightImage {
        id: image
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.itemSizeSmall
        height: Theme.itemSizeSmall
        source: checked ? sourceOn : sourceOff

        highlighted: _showPress
        opacity: parent.enabled ? 1.0 : 0.4
    }

    Label {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - image.width - Theme.paddingLarge
        x: Theme.itemSizeSmall + Theme.paddingLarge
        color: _showPress ? Theme.secondaryHighlightColor : Theme.secondaryColor
    }

    Timer {
        id: pressTimer
        interval: Theme.minimumPressHighlightTime
    }
}
