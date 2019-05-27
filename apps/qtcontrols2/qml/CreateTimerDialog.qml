import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Hue 0.1
import "PopupUtils.js" as PopupUtils

Dialog {
    id: root
    title: "Set timer"

    property var schedules: null
    property var light: null

    Column {
        width: parent.width

        Label {
            text: "%1 will be switched off in".arg(root.light.name)
        }

        DatePicker {
            id: dateTime
            showDate: false
            Component.onCompleted: {
                var newDate = new Date(30 * 60 * 1000);
                newDate.setHours(0); // For some reason the above will create 1:30 instead of 0:30
                date = newDate;
            }
        }
    }

    footer: DialogButtonBox {
        Button {
            text: "OK"
            onClicked: {
                if (root.light.isGroup) {
                    root.schedules.createTimerForGroup("%1 off".arg(root.light.name), root.light.id, false, 0, "white", dateTime.date)
                } else {
                    root.schedules.createTimerForLight("%1 off".arg(root.light.name), root.light.id, false, 0, "white", dateTime.date)
                }
                PopupUtils.close(root)
            }
        }
        Button {
            text: "Cancel"
            onClicked: {
                PopupUtils.close(root)
            }
        }
    }
}
