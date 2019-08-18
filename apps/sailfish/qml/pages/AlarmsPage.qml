import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1

Page {
    id: root

    property var schedules: null

    allowedOrientations: Orientation.All

    SilicaListView {
        id: listView
        anchors.fill: parent

        VerticalScrollDecorator {}

        ViewPlaceholder {
            enabled: listView.count === 0
            //% "No alarms or timers"
            text: qsTrId("scintillon-alarm_placeholder_title")
            hintText: (HueBridge.status === HueBridge.BridgeStatusConnected)
                      //% "Create an alarm on the Lights or Scenes pages"
                      ? qsTrId("scintillon-alarm_placeholder_summary_create_alarm")
                      //% "Not connected to a Hue Hub"
                      : qsTrId("scintillon-alarm_placeholder_no_hub")
        }

        header: PageHeader {
            id: title
            //% "Alarms and timers"
            title: qsTrId("scintillon-alarm_list_title")
        }

        model: schedules

        delegate: ListItem {
            id: alarmItem
            menu: alarmsMenuComponent
            highlighted: alarmPressable.highlighted

            Row {
                x: Theme.horizontalPageMargin
                height: Theme.itemSizeSmall
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: 0

                IconPressable {
                    id: alarmPressable
                    width: parent.width
                    height: Theme.itemSizeSmall
                    sourceOn: model.type === Schedule.TypeTimer
                              ? Qt.resolvedUrl("image://scintillon/icon-m-countdown")
                              : recurring
                                ? Qt.resolvedUrl("image://scintillon/icon-m-weekday")
                                : Qt.resolvedUrl("image://scintillon/icon-m-alarm")
                    sourceOff: sourceOn
                    icon.color: "white"
                    icon.width: Theme.iconSizeMedium
                    icon.height: icon.width
                    text: model.name

                    onClicked: openSchedule()
                    onPressAndHold: alarmItem.openMenu()
                }
            }

            Component {
                id: alarmsMenuComponent
                ContextMenu {
                    MenuItem {
                        //% "Delete"
                        text: qsTrId("scintillon-alarm_delete")
                        onClicked: schedules.deleteSchedule(model.id)
                    }
                }
            }

            function openSchedule() {
                var schedule = schedules.get(index)
                var dalog
                if (schedule.type === Schedule.TypeTimer) {
                    dalog = pageStack.push(Qt.resolvedUrl("CountdownAdd.qml"), {schedule: schedule, schedules: schedules})
                }
                else {
                    dalog = pageStack.push(Qt.resolvedUrl("AlarmAdd.qml"), {schedule: schedule, schedules: schedules})
                }
            }
        }
    }
}
