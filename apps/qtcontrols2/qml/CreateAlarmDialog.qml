import QtQuick 2.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.1
import Hue 0.1

Dialog {
    id: root
    title: "Create Alarm"
    width: parent.width

    property var light: null
    property var scene: null
    property var schedules: null
    property var date: new Date()

    Column {
        width: parent.width
        Label {
            width: parent.width
            text: root.light ? "Create an alarm for %1. The current power, brightness and color values will be restored at the given time.".arg(root.light.name)
                             : "Create an alarm for %1. The scene will be activated at the given time.".arg(root.scene.name)
            wrapMode: Text.WordWrap
        }

        TextField {
            id: alarmName
            width: parent.width
            placeholderText: "Alarm name"
            text: "Alarm on %1".arg(root.light ? root.light.name : root.scene.name)
        }

        AlarmDatePicker {
            id: alarmDateTime
        }
    }

    footer: DialogButtonBox {
        Button {
            text: "OK"
            enabled: alarmName.text
            onClicked: {
                if (alarmDateTime.recurring) {
                    if (root.scene) {
                        root.schedules.createRecurringAlarmForScene(alarmName.text, root.scene.id, alarmDateTime.date, alarmDateTime.weekdays)
                    } else if (root.light.isGroup) {
                        root.schedules.createRecurringAlarmForGroup(alarmName.text, root.light.id, root.light.on, light.bri, light.color, alarmDateTime.date, alarmDateTime.weekdays)
                    } else {
                        root.schedules.createRecurringAlarmForLight(alarmName.text, root.light.id, root.light.on, light.bri, light.color, alarmDateTime.date, alarmDateTime.weekdays)
                    }
                } else {
                    if (alarmDateTime.date < new Date()) {
                        alarmDateTime.showPastTimeError()
                        return;
                    }
                    if (root.scene) {
                        root.schedules.createSingleAlarmForScene(alarmName.text, root.scene.id, alarmDateTime.date);
                    } else if (root.light.isGroup) {
                        root.schedules.createSingleAlarmForGroup(alarmName.text, root.light.id, root.light.on, light.bri, light.color, alarmDateTime.date)
                    } else {
                        root.schedules.createSingleAlarmForLight(alarmName.text, root.light.id, root.light.on, light.bri, light.color, alarmDateTime.date)
                    }
                }
                close(root)
            }
        }

        Button {
            text: "Cancel"
            onClicked: {
                close(root)
            }
        }
    }
}

