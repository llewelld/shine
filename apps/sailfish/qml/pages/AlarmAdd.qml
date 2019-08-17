import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1
import harbour.scintillon.settings 1.0

Dialog {
    id: root

    property var light: null
    property var scene: null
    property var schedules: null
    property var schedule: null
    property var date: new Date()
    property alias name: alarmName.text
    property alias recurring: recurringSwitch.checked
    property string weekdays: "0000000"

    allowedOrientations: Orientation.All

    canAccept: (name.length > 0)

    SilicaFlickable {
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
                title: qsTr("Alarm")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: schedule ? "Edit alarm" : root.light ? "Create alarm for %1. Current power, brightness and color values will be restored at the given time.".arg(root.light.name)
                                 : "Create an alarm for %1. The scene will be activated at the given time.".arg(root.scene.name)
                wrapMode: Text.WordWrap
            }

            TextField {
                id: alarmName
                label: qsTr("Alarm name")
                text: "Alarm on %1".arg(light ? light.name : scene.name)
                placeholderText: label
                width: parent.width - 2 * Theme.horizontalPageMargin
                inputMethodHints: Qt.ImhNone
                //EnterKey.iconSource: "image://theme/icon-m-enter-next"
                //EnterKey.onClicked: passwordField.focus = true
            }

            Row {
                visible: light
                width: parent.width
                TextSwitch {
                    id: turnOnSwitch
                    width: parent.width / 2
                    enabled: light && light.on
                    text: light ? "Turn on" : ""
                    checked: light && light.on
                    automaticCheck: false
                    onClicked: {
                        checked = true
                        turnOffSwitch.checked = !checked
                    }
                }
                TextSwitch {
                    id: turnOffSwitch
                    width: parent.width / 2
                    enabled: light && light.on
                    text: light ? "Turn off" : ""
                    checked: light && !light.on
                    automaticCheck: false
                    onClicked: {
                        checked = true
                        turnOnSwitch.checked = !checked
                    }
                }
            }

            TextSwitch {
                id: recurringSwitch
                text: "Recurring alarm"
                automaticCheck: true
            }

            WeekDaySelector {
                id: weekDaySelector
                enabled: recurringSwitch.checked
                width: parent.width - 2 * Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
            }

            ValueButton {
                id: alarmDate
                label: qsTr("Alarm date")
                value: Qt.formatDate(date, 'd MMM yyyy')
                enabled: !recurringSwitch.checked
                onClicked: {
                    var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", { date: date })
                    dialog.accepted.connect(function() {
                        date = new Date(dialog.year, dialog.month - 1, dialog.day, date.getHours(), date.getMinutes())
                    })
                }
            }

            ValueButton {
                id: alarmTime
                label: qsTr("Alarm time")
                value: Qt.formatTime(date, 'hh:mm')
                width: parent.width
                onClicked: {
                    var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", { hour: date.getHours(), minute: date.getMinutes()})
                    dialog.accepted.connect(function() {
                        date = new Date(date.getFullYear(), date.getMonth(), date.getDate(), dialog.hour, dialog.minute)
                    })
                }
            }

            Label {
                visible: false
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: "Remaining: " + remaining()
            }
        }
    }

    function remaining() {
        var result = ""
        if (schedule) {
            var remaining = schedule.remaining()
            console.log("Remaining: " + remaining)
            result = Qt.formatDateTime(remaining, "hh:mm:ss")
            if (remaining.getYear() > 1970) {
                result = "Over a year"
            }
            else {
                if (remaining.getDate() > 1) {
                    result = (remaining.getDate() - 1) + " days, " + result
                }
                if (remaining.getMonth() > 1) {
                    result = (remaining.getMonth() - 1) + " months, " + result
                }
            }
        }
        return result
    }

    onCanceled: {
        if (light) {
            light.alert = "none"
        }
    }

    onAccepted: {
        if (light) {
            light.alert = "none"
        }
        apply()
    }

    Component.onCompleted: {
        if (schedule) {
            date = schedule.dateTime
            name = schedule.name
            recurring = schedule.recurring
            weekdays = schedule.weekdays
            console.log("Time: " + date.getTime())
            if (date.getTime() < 24 * 60 * 60 * 1000) {
                console.log("Setting date to today")
                // Set the date to today
                var setDate = new Date()
                setDate.setHours(date.getHours())
                setDate.setMinutes(date.getMinutes())
                setDate.setSeconds(date.getSeconds())
                setDate.setMilliseconds(date.getMilliseconds())
                date = setDate
            }

            console.log("Alarm name: " + name)
            console.log("Alarm dateTime: " + date)
            console.log("Alarm weekdays: " + weekdays)
            console.log("Alarm recurring: " + recurring)
        }

        var days = "mtwTfsS"
        var dayList = ""
        for (var i = 0; i < 7; i++) {
            if (weekdays[i + 1] == 1) {
                dayList += days[i]
            }
        }
        weekDaySelector.weekDays = dayList
    }

    function apply() {
        alarmName.focus = false;

        weekdays = "0";
        var days = "mtwTfsS"
        for (var i = 0; i < 7; i++) {
            if (weekDaySelector.weekDays.indexOf(days[i]) >= 0) {
                weekdays = weekdays + "1"
            }
            else {
                weekdays = weekdays + "0"
            }
        }
        console.log("Weekdays: " + days + " = " + weekdays)

        if (schedule) {
            console.log("Setting alarm name: " + name)
            console.log("Setting alarm dateTime: " + date)
            console.log("Setting alarm weekdays: " + weekdays)
            console.log("Setting alarm recurring: " + recurring)
            schedule.name = name
            schedule.setDateTimeRecurring(Schedule.TypeAlarm, date, weekdays, recurring)
        }
        else {
            if (recurring) {
                if (scene) {
                    schedules.createRecurringAlarmForScene(name, scene.id, date, weekdays)
                } else if (light.isGroup) {
                    schedules.createRecurringAlarmForGroup(name, light.id, turnOnSwitch.checked, light.bri, light.color, date, weekdays)
                } else {
                    schedules.createRecurringAlarmForLight(name, light.id, turnOnSwitch.checked, light.bri, light.color, date, weekdays)
                }
            } else {
                if (scene) {
                    schedules.createSingleAlarmForScene(name, scene.id, date);
                } else if (light.isGroup) {
                    schedules.createSingleAlarmForGroup(name, light.id, turnOnSwitch.checked, light.bri, light.color, date)
                } else {
                    schedules.createSingleAlarmForLight(name, light.id, turnOnSwitch.checked, light.bri, light.color, date)
                }
            }
        }
    }
}
