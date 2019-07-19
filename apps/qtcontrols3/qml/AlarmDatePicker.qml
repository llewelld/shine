import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.1
import "PopupUtils.js" as PopupUtils

Column {
    id: root
    spacing: 8 * (1)
    width: parent.width

    property var date: new Date()
    property alias recurring: recurringSwitch.checked
    property string weekdays: "X1111100X"

    property int margins: 0

    function showPastTimeError() {
        PopupUtils.openComponent(pastTimeError, root, {})
    }

    Row {
        anchors { left: parent.left; right: parent.right; leftMargin: root.margins; rightMargin: root.margins }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: "Recurring alarm"
            width: parent.width - recurringSwitch.width
        }
        Switch {
            anchors.verticalCenter: parent.verticalCenter
            id: recurringSwitch
        }
    }

    Button {
        width: parent.width
        Row {
            anchors.fill: parent
            anchors { leftMargin: root.margins; rightMargin: root.margins }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: root.recurring ? "Time" : "Date & Time"
                width: parent.width - timeLabel.width
            }
            Label {
                id: timeLabel
                anchors.verticalCenter: parent.verticalCenter
                text: "" + (root.recurring ? "" : Qt.formatDate(root.date)) + " " + Qt.formatTime(root.date)
            }
        }

        onClicked: {
            var popup = PopupUtils.openComponent(dateTimePicker, root, {date: root.date})
            popup.closed.connect(function(date) {
                root.date = date
            })
        }
        Component {
            id: dateTimePicker
            Dialog {
                id: dtp
                title: root.recurring ? "Time" : "Date & Time"
                width: parent.width
                signal closed(var date)

                property var date: new Date()


                Row {
                    DatePicker {
                        id: datePicker
                        date: dtp.date
                        showDate: !root.recurring
                    }
                }

                footer: DialogButtonBox {
                    Button {
                        text: "OK"
                        onClicked: {
                            var mixedDate = datePicker.date;
                            dtp.closed(mixedDate)
                            PopupUtils.close(dtp)
                        }
                    }
                }
            }
        }
    }

    Button {
        id: recurrenceSelector
        width: parent.width

        states: [
            State {
                name: "invisible"; when: !root.recurring
                PropertyChanges { target: recurrenceSelector; height: 0; opacity: 0 }
            }
        ]
        transitions: [
            Transition {
                from: "*"
                to: "*"
                NumberAnimation { properties: "height,opacity" }
            }
        ]
        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors { left: parent.left; right: parent.right; leftMargin: root.margins; rightMargin: root.margins }
            Label {
                text: "Recurrence"
                width: parent.width - weedayListLabel.width
            }
            Label {
                id: weedayListLabel
                text: {
                    var strings = new Array()
                    if (root.weekdays[1] == "1") strings.push("Mon")
                    if (root.weekdays[2] == "1") strings.push("Tue")
                    if (root.weekdays[3] == "1") strings.push("Wed")
                    if (root.weekdays[4] == "1") strings.push("Thu")
                    if (root.weekdays[5] == "1") strings.push("Fri")
                    if (root.weekdays[6] == "1") strings.push("Sat")
                    if (root.weekdays[7] == "1") strings.push("Sun")
                    return strings.join(", ")
                }

            }
        }

        onClicked: {
            var popup = PopupUtils.openComponent(recurrancePicker, root, {weekdays: root.weekdays})
            popup.closed.connect(function(weekdays) {
                root.weekdays = weekdays;
            })
        }

        Component {
            id: recurrancePicker

            Dialog {
                id: rp
                title: "Days"
                signal closed(string weekdays)
                property string weekdays
                width: parent.width
                height: parent.height

                function toggleDay(day) {
                    weekdays = weekdays.substr(0, day) + (weekdays[day] === "1" ? '0' : '1') + weekdays.substr(day - 8)
                }

                Flow {
                    width: parent.width
                    CheckBox { checked: weekdays[1] === "1"; checkable: false; onClicked: toggleDay(1); text: "Monday" }
                    CheckBox { checked: weekdays[2] === "1"; checkable: false; onClicked: toggleDay(2); text: "Tuesday" }
                    CheckBox { checked: weekdays[3] === "1"; checkable: false; onClicked: toggleDay(3); text: "Wednesday" }
                    CheckBox { checked: weekdays[4] === "1"; checkable: false; onClicked: toggleDay(4); text: "Thursday" }
                    CheckBox { checked: weekdays[5] === "1"; checkable: false; onClicked: toggleDay(5); text: "Friday" }
                    CheckBox { checked: weekdays[6] === "1"; checkable: false; onClicked: toggleDay(6); text: "Saturday" }
                    CheckBox { checked: weekdays[7] === "1"; checkable: false; onClicked: toggleDay(7); text: "Sunday" }
                }

                footer: DialogButtonBox {
                    Button {
                        text: "OK"
                        onClicked: {
                            rp.closed(weekdays)
                            PopupUtils.close(rp);
                        }
                    }
                }
            }
        }
    }

    Component {
        id: pastTimeError
        Dialog {
            id: dialog
            title: "Invalid Time"
            Column {
                Label {
                    text: "The selected time is in the past. Please select a time in the future."
                }
            }
            footer: DialogButtonBox {
                Button {
                    text: "OK"
                    onClicked: PopupUtils.close(dialog)
                }
            }
        }
    }
}

