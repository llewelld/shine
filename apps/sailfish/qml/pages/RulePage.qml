import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1
import harbour.scintillon.settings 1.0

Page {
    id: root

    property string ruleid: ""
    property alias name: ruleName.text
    property var rules

    allowedOrientations: Orientation.All

    //canAccept: (name.length > 0)

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

            /*
            DialogHeader {
                id: pageHeader
                //% "Rule"
                title: qsTrId("scintillon-rule_title")
            }
            */

            PageHeader {
                id: pageHeader
                title: ruleName.text
            }

            TextField {
                id: ruleName
                //% "Rule name"
                label: qsTrId("scintillon-rule_name")
                placeholderText: label
                width: parent.width - 2 * Theme.horizontalPageMargin
                inputMethodHints: Qt.ImhNone
                //EnterKey.iconSource: "image://theme/icon-m-enter-next"
                //EnterKey.onClicked: passwordField.focus = true
                visible: false
                enabled: false
            }

            SectionHeader {
                //% "Conditions"
                text: qsTrId("scintillon-rule_section_conditions")
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
                //% "Actions"
                text: qsTrId("scintillon-rule_section_actions")
            }

            Repeater {
                width: parent.width
                model: rules.findRule(ruleid).actions

                delegate: Column {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin

                    Label {
                        text: model.modelData["address"]
                        color: Theme.highlightColor
                    }
                    Label {
                        text: JSON.stringify(model.modelData["body"], null, 4)
                        wrapMode: Text.Wrap
                        font.family: "Monospace"
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }
        }
    }

    /*
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
    */
}
