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

        ViewPlaceholder {
            enabled: listView.count === 0
            //% "No rules"
            text: qsTrId("scintillon-rules_placeholder_text")
            hintText: (HueBridge.status === HueBridge.BridgeStatusConnected)
                      //% "New rules are created on the Sensors and Switchs page"
                      ? qsTrId("scintillon-rules_placeholder_hint_no_sensors")
                      //% "Not connected to a Hue Hub"
                      : qsTrId("scintillon-rules_placeholder_hint_no_hub")
        }

        header: PageHeader {
            id: title
            //% "Rules"
            title: qsTrId("scintillon-rules_page_title")
        }

        model: rules

        delegate: ListItem {
            id: ruleItem
            menu: rulesMenuComponent
            highlighted: rulePressable.highlighted

            Row {
                x: Theme.horizontalPageMargin
                height: Theme.itemSizeSmall
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: 0

                IconPressable {
                    id: rulePressable
                    width: parent.width
                    height: Theme.itemSizeSmall
                    sourceOn: Qt.resolvedUrl("image://scintillon/icon-m-rule")
                    sourceOff: sourceOn
                    icon.color: "white"
                    icon.width: Theme.iconSizeMedium
                    icon.height: icon.width
                    text: model.name

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("RulePage.qml"), {ruleid: model.id, rules: rules, name: model.name})
                    }
                    onPressAndHold: ruleItem.openMenu()
                }
            }

            Component {
                id: rulesMenuComponent
                ContextMenu {
                    MenuItem {
                        //% "Delete"
                        text: qsTrId("scintillon-rules_menu_rule_delete")
                        onClicked: rules.deleteRule(model.id)
                    }
                }
            }
        }
    }
}