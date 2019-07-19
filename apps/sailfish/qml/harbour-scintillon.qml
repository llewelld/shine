import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import harbour.scintillon.settings 1.0

ApplicationWindow
{
    id: app
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
}
