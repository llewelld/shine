import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import harbour.scintillon.settings 1.0
import Hue 0.1

ApplicationWindow
{
    id: app

    property alias lights: lights
    property alias groups: groups
    property alias consistency: consistency
    property bool updateLights
    property bool coverActive

    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    function showMainPage(operationType) {
        var first = pageStack.currentPage
        var temp = pageStack.previousPage(pageStack.currentPage)
        while (temp) {
            first = temp
            temp = pageStack.previousPage(temp)
        }

        pageStack.pop(first, operationType)
    }

    Lights {
        id: lights
        autoRefresh: updateLights || coverActive
        consistency: consistency
    }

    Groups {
        id: groups
        autoRefresh: updateLights || coverActive
        consistency: consistency
    }

    Consistency {
        id: consistency
        lights: lights
        groups: groups
    }
}
