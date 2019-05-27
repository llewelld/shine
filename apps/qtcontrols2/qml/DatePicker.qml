import QtQuick 2.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.1

Rectangle {
    id: root
    height: frame.implicitHeight
    width: frame.implicitWidth

    property string mode: "Hours|Minutes"
    property var date: new Date()
    property bool showDate

    property int visibleItemCount: 5

    function formatText(count, modelData) {
        var data = count === 12 ? modelData + 1 : modelData;
        return data.toString().length < 2 ? "0" + data : data;
    }

    Component {
        id: delegateComponent

        Label {
            text: formatText(Tumbler.tumbler.count, modelData)
            opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    Frame {
        id: frame
        padding: 0
        anchors.centerIn: parent
        Row {
            id: row
            height: 12 * (8)
            Tumbler {
                model: 24
                currentIndex: date.getHours()
                height: parent.height
                visibleItemCount: visibleItemCount
                delegate: delegateComponent
                onCurrentIndexChanged: date.setHours(currentIndex)
            }
            Label {
                text: ":"
                anchors.verticalCenter: parent.verticalCenter
            }
            Tumbler {
                model: 60
                currentIndex: date.getMinutes()
                height: parent.height
                visibleItemCount: visibleItemCount
                delegate: delegateComponent
                onCurrentIndexChanged: date.setMinutes(currentIndex)
            }
            Label {
                text: ".  "
                anchors.verticalCenter: parent.verticalCenter
                visible: showDate
            }
            Tumbler {
                model: 31
                currentIndex: date.getDate()
                height: parent.height
                visibleItemCount: visibleItemCount
                delegate: delegateComponent
                visible: showDate
                onCurrentIndexChanged: date.setDate(currentIndex)
            }
            Tumbler {
                id: monthTumbler
                currentIndex: date.getMonth()
                height: parent.height
                visibleItemCount: visibleItemCount
                model: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
                delegate: Label {
                    text: modelData
                    opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                visible: showDate
                onCurrentIndexChanged: date.setMonth(currentIndex)
            }
            Tumbler {
                model: 2100
                currentIndex: date.getFullYear()
                height: parent.height
                visibleItemCount: visibleItemCount
                delegate: delegateComponent
                visible: showDate
                onCurrentIndexChanged: date.setYear(currentIndex)
            }
        }
    }
}
