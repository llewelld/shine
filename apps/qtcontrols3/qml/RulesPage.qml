import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

ShinePage {
    id: root
    property var rules: null

    ListView {
        spacing: 2 * (8)
        model: root.rules
        anchors.fill: parent
        delegate: Label {
            text: model.name
        }
    }

    Label {
        width: parent.width - 8 * (8)
        anchors.centerIn: parent
        text: "No Hue rules have been set. You can add new rules in the \"Sensors\" section."
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        visible: rules.count === 0 && !root.busy
    }
}
