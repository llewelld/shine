import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1
import harbour.scintillon.settings 1.0

Dialog {
    id: root

    property string ruleid: ""
    property alias name: ruleName.text
    property var rules

    allowedOrientations: Orientation.All

    canAccept: (name.length > 0)

    Component.onCompleted: {
        var conditions = rules.findRule(ruleid).conditions
        console.log("Rule conditions: " + conditions)
        console.log("Rule condition size: " + conditions.length)
        for (var index = 0; index < conditions.length; index++) {
            var map = conditions[index]

            for (var prop in map) {
                console.log("condition:", prop, "=", map[prop])
            }
        }
    }

    SilicaFlickable {
        width: parent.width
        height: parent.height
        interactive: true

        anchors.fill: parent
        contentHeight: settingsColumn.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Column {
            id: settingsColumn
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                id: pageHeader
                title: qsTr("Rule")
            }

            TextField {
                id: ruleName
                label: qsTr("Rule name")
                placeholderText: label
                width: parent.width - 2 * Theme.horizontalPageMargin
                inputMethodHints: Qt.ImhNone
                //EnterKey.iconSource: "image://theme/icon-m-enter-next"
                //EnterKey.onClicked: passwordField.focus = true
            }

            SectionHeader {
                text: qsTr("Conditions")
            }

            ColumnView {
                width: parent.width
                itemHeight: Theme.itemSizeMedium
                model: rules.findRule(ruleid).conditions

                delegate: Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    property string value: model.modelData["value"] ? model.modelData["value"] : ""
                    text: model.modelData["address"] + " " + model.modelData["operator"] + " " + value
                }
            }

            SectionHeader {
                text: qsTr("Actions")
            }

            ColumnView {
                width: parent.width
                itemHeight: Theme.itemSizeMedium
                model: rules.findRule(ruleid).actions

                delegate: Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    text: model.modelData["address"]
                }
            }
        }
    }

    onAccepted: {
        apply()
    }

    function apply() {
        ruleName.focus = false;
        var rule = rules.findRule(ruleid)
        if (rule) {
            rule.name = root.name
        }
    }
}
