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

    allowedOrientations: Orientation.All

    canAccept: (name.length > 0)

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
                //% "Countdown timer"
                title: qsTrId("scintillon-countdown_header")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                //% "Edit countdown timer"
                text: schedule ? qsTrId("scintillon-countdown_edit_timer")
                               : root.light
                                 //% "Create countdown timer for %1. Current power, brightness and color values will be restored after the time has elapsed."
                                 ? qsTrId("scintillon-countdown_create_for_light").arg(root.light.name)
                                 //% "Create a countdown timer for %1. The scene will be activated after the time has elapsed."
                                 : qsTrId("scintillon-countdown_create_for_scene").arg(root.scene.name)
                wrapMode: Text.WordWrap
            }

            TextField {
                id: alarmName
                //% "Timer name"
                label: qsTrId("scintillon-countdown_timer_name")
                //% "Countdown on %1"
                text: qsTrId("scintillon-countdown_default_name").arg(light ? light.name : scene.name)
                placeholderText: label
                width: parent.width - 2 * Theme.horizontalPageMargin
                inputMethodHints: Qt.ImhNone
                //EnterKey.iconSource: "image://theme/icon-m-enter-next"
                //EnterKey.onClicked: passwordField.focus = true
            }

            Row {
                visible: light
                width: parent.width - 2 * Theme.horizontalPageMargin
                TextSwitch {
                    id: turnOnSwitch
                    width: parent.width / 2
                    enabled: light && light.on
                    //% "Turn on"
                    text: light ? qsTrId("scintillon-countdown_turn_on") : ""
                    checked: light.on
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
                    //% "Turn off"
                    text: light ? qsTrId("scintillon-countdown_turn_off") : ""
                    checked: !light.on
                    automaticCheck: false
                    onClicked: {
                        checked = true
                        turnOnSwitch.checked = !checked
                    }
                }
            }

            ValueButton {
                id: alarmTime
                //% "Duration"
                label: qsTrId("scintillon-countdown_duration")
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
        if (schedule) {
            console.log("Remaining: " + schedule.remaining())
            return Qt.formatTime(schedule.remaining(), 'hh:mm:ss')
        }
        else {
            return "Awaiting"
        }
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

            console.log("Setting alarm name: " + name)
            console.log("Setting alarm dateTime: " + date)
        }
        else {
            var setDate = new Date()
            setDate.setHours(0)
            setDate.setMinutes(10)
            setDate.setSeconds(0)
            setDate.setMilliseconds(0)
            date = setDate
        }
    }

    function apply() {
        alarmName.focus = false
        var repeat = -1

        if (schedule) {
            console.log("Setting alarm name: " + name)
            console.log("Setting alarm dateTime: " + date)
            schedule.name = name
            schedule.dateTime = date
        }
        else {
            if (scene) {
                schedules.createTimerForScene(name, scene.id, date, repeat);
            } else if (light.isGroup) {
                schedules.createTimerForGroup(name, light.id, turnOnSwitch.checked, light.bri, light.color, date, repeat)
            } else {
                schedules.createTimerForLight(name, light.id, turnOnSwitch.checked, light.bri, light.color, date, repeat)
            }
        }
    }
}
