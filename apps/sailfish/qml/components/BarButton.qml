import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: root
    property alias source: image.source
    property alias text: label.text
    highlighted: pressed
    property bool _showPress: highlighted || pressTimer.running

    width: parent.width
    height: parent.height / 2

    onPressedChanged: {
        if (pressed) {
            pressTimer.start()
        }
    }
    onCanceled: pressTimer.stop()

    /*
    Rectangle {
        id: verticalback
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        color: root.pressed ? Theme.highlightColor : Theme.secondaryHighlightColor
    }

    Rectangle {
        id: horizontalback
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        color: root.pressed ? Theme.highlightColor : Theme.secondaryHighlightColor
    }
    */

    Label {
        id: label
        text: ""
        color: _showPress ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font.pixelSize: Theme.fontSizeLarge
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: Theme.horizontalPageMargin
        anchors.left: image.right
        anchors.leftMargin: 2 * Theme.paddingLarge
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    HighlightImage {
        id: image
        source: ""
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin + Theme.paddingLarge
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        width: Theme.iconSizeMedium
        height: width
        color: "white"
        highlighted: _showPress
    }

    /*
    OpacityRampEffect {
        id: verticalBackgroundEffect
        slope: 0.5
        offset: -1.5
        direction: OpacityRamp.TopToBottom
        sourceItem: verticalback
    }

    OpacityRampEffect {
        id: horizontalBackgroundEffect
        slope: 1.2
        offset: -0.7
        direction: OpacityRamp.LeftToRight
        sourceItem: horizontalback
    }

    OpacityRampEffect {
        id: imageeffect
        slope: 0.5
        offset: -0.8
        direction: OpacityRamp.TopToBottom
        sourceItem: image
    }
    */

    Timer {
        id: pressTimer
        interval: Theme.minimumPressHighlightTime
    }
}
