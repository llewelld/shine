/*
 * Copyright 2013-2015 Michael Zanetti
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 2.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Michael Zanetti <michael_zanetti@gmx.net>
 */

import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Hue 0.1
import "PopupUtils.js" as PopupUtils

ShinePage {
    id: root
    title: "Alarms and Timers"
    busy: schedules && schedules.count === 0 && schedules.busy

    property var lights: null
    property var groups: null
    property var schedules: null
    property var scenes: null

    property bool pageActive: false

    Label {
        anchors { left: parent.left; right: parent.right; margins: 8 * (2); verticalCenter: parent.verticalCenter }
        wrapMode: Text.WordWrap
        text: "No alarms or timers set up. You can create alarms and timers in the lights and scenes sections."
        horizontalAlignment: Text.AlignHCenter
        visible: schedules.count === 0 && !root.busy
        z: 2
    }


    ListView {
        anchors.fill: parent
        model: schedules

        delegate: Item {
            height: 6 * (8)
            Row {
                height: parent.height
                anchors {
                    fill: parent
                    leftMargin: 8 * (2)
                    rightMargin: 8 * (2)
                }
                spacing: 8 * (1)
                Button {
                    icon.source: "images/cross.svg"
                    height: parent.height
                    width: height
                    onClicked: schedules.deleteSchedule(model.id)
                }

                Image {
                    height: parent.height - (8)
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                    source: model.type == Schedule.TypeAlarm ? "images/alarm-clock.svg" : "images/camera-self-timer.svg"
                    sourceSize.height: height
                    sourceSize.width: width
                }
                Column {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        width: parent.width
                        text: model.name
                    }
                    Label {
                        width: parent.width
                        property string weekdays: model.weekdays
                        property string weekdaysString: {
                            var strings = new Array()
                            if (weekdays[1] == "1") strings.push("Mon")
                            if (weekdays[2] == "1") strings.push("Tue")
                            if (weekdays[3] == "1") strings.push("Wed")
                            if (weekdays[4] == "1") strings.push("Thu")
                            if (weekdays[5] == "1") strings.push("Fri")
                            if (weekdays[6] == "1") strings.push("Sat")
                            if (weekdays[7] == "1") strings.push("Sun")
                            return strings.join(", ")
                        }

                        text: model.type == Schedule.TypeAlarm ?
                                  (model.recurring ?
                                     Qt.formatTime(model.dateTime) + "  " + weekdaysString
                                   : Qt.formatDateTime(model.dateTime))
                                : Qt.formatTime(model.dateTime)


                    }
                }
            }
        }
    }
}
