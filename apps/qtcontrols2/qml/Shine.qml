/*
 * Copyright 2013 Michael Zanetti
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
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
import QtQuick.Controls 2.1
import Hue 0.1
import Qt.labs.settings 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 480
    height: 640

    property string orientation: "portrait" // width > height ? "landscape" : "portrait"

    Component.onCompleted: {
        HueBridge.apiKey = keystore.apiKey;

        if (HueBridge.discoveryError) {
            PopupUtils.open(errorComponent, root)
        } else if (HueBridge.bridgeFound && !HueBridge.connectedBridge){
            PopupUtils.open(loginComponent, root)
        }
    }

    Connections {
        target: HueBridge
        onBridgeFoundChanged: {
            if (!HueBridge.connectedBridge) {
                PopupUtils.open(loginComponent, root)
            }
        }
        onDiscoveryErrorChanged: {
            if (HueBridge.discoveryError) {
                PopupUtils.open(errorComponent, root)
            }
        }
        onApiKeyChanged: {
            keystore.apiKey = HueBridge.apiKey;
        }
        onStatusChanged: {
            if (HueBridge.status === HueBridge.BridgeStatusAuthenticationFailure) {
                print("Authentication failure!")
                PopupUtils.open(loginComponent, root)
            }
        }
    }

    StackView {
        id: pageStack
        anchors.fill: parent

        Menu {
            id: mainMenu
            y: 50
            MenuItem {
                text: "Lights"
                onClicked: pageStack.replace(lightsPage)
            }
            MenuItem {
                text: "Scenes"
                onClicked: pageStack.replace(scenesPage)
            }
            MenuItem {
                text: "Alarms and Timers"
                onClicked: pageStack.replace(schedulesPage)
            }
            MenuItem {
                text: "Switches"
                onClicked: pageStack.replace(sensorsPage)
            }
            MenuItem {
                text: "Rules"
                onClicked: pageStack.replace(rulesPage)
            }
            MenuItem {
                text: "Bridge control"
                onClicked: pageStack.replace(bridgeInfoPage)
            }
        }

        initialItem: LightsPage {
            id: lightsPage
            lights: lights
            groups: groups
            schedules: schedules
            visible: pageStack.currentItem == lightsPage
        }
        ScenesPage {
            id: scenesPage
            lights: lights
            scenes: scenes
            schedules: schedules
            visible: pageStack.currentItem == scenesPage
        }
        SchedulesPage {
            id: schedulesPage
            lights: lights
            schedules: schedules
            scenes: scenes
            groups: groups
            visible: pageStack.currentItem == schedulesPage
        }
        SensorsPage {
            id: sensorsPage
            sensors: sensors
            rules: rules
            lights: lights
            groups: groups
            scenes: scenes
            visible: pageStack.currentItem == sensorsPage
        }
        RulesPage {
            id: rulesPage
            rules: rules
            visible: pageStack.currentItem == rulesPage
        }
        BridgeInfoPage {
            id: bridgeInfoPage
            lights: lights
            visible: pageStack.currentItem == bridgeInfoPage
        }
        //        }
    //        Tab {
    //            id: schedulesTab
    //            title: "Alarms & Timers"
    //            page: PageStack {
    //                id: pageStack
    //                Component.onCompleted: push(schedulesPage)
    //                SchedulesPage {
    //                    id: schedulesPage
    //                    lights: lights
    //                    schedules: schedules
    //                    scenes: scenes
    //                    groups: groups
    //                    pageActive: tabs.selectedTab == schedulesTab
    //                }
    //            }
    //        }

    //        Tab {
    //            id: sensorsTab
    //            title: "Switches"
    //            page: PageStack {
    //                Component.onCompleted: push(sensorsPage)
    //                SensorsPage {
    //                    id: sensorsPage
    //                    sensors: sensors
    //                    rules: rules
    //                    lights: lights
    //                    groups: groups
    //                    scenes: scenes
    //                }
    //            }
    //        }

    //        //            Tab {
    //        //                id: rulesTab
    //        //                title: "Rules"
    //        //                page: RulesPage {
    //        //                    rules: rules
    //        //                }
    //        //            }

    //        Tab {
    //            id: bridgeInfoTab
    //            title: "Bridge control"
    //            page: BridgeInfoPage {
    //                lights: lights
    //            }
    //        }
//            }
//        }
    }


    Lights {
        id: lights
        autoRefresh: true //(pageStack.currentItem == lightsPage) || bigColorPicker.visible
    }

    Groups {
        id: groups
        autoRefresh: true //(pageStack.currentItem == lightsPage) || bigColorPicker.visible
    }

    Scenes {
        id: scenes
        autoRefresh: true //(pageStack.currentItem == scenesPage || pageStack.currentItem == sensorsPage) && !bigColorPicker.visible
    }

    Schedules {
        id: schedules
        autoRefresh: true //(pageStack.currentItem == schedulesPage) && !bigColorPicker.visible
    }

    Configuration {
        id: bridgeConfig
        autoRefresh: true //(pageStack.currentItem == bridgeInfoPage) && !bigColorPicker.visible
    }

    Sensors {
        id: sensors
        autoRefresh: true //(pageStack.currentItem == sensorsPage) && !bigColorPicker.visible
    }

    Rules {
        id: rules
        autoRefresh: true //(pageStack.currentItem == rulesPage) && !bigColorPicker.visible
    }

    Settings {
        id: settings

        property bool hideScenesByOtherApps: true
    }

    Component {
        id: loginComponent
        Dialog {
            id: connectDialog
            title: "Connect to Hue bridge"
//            text: "Please press the button on the Hue bridge and then \"Connect...\""

            Connections {
                target: HueBridge
                onCreateUserFailed: {
                    connectDialog.text = "Error authenticating to Hue bridge: " + errorMessage;
                    connectButton.text = "Try again!";
                }
                onConnectedBridgeChanged: {
                    if (HueBridge.connectedBridge) {
                        PopupUtils.close(connectDialog)
                    }
                }
            }

            Button {
                id: connectButton
                text: "Connect..."
                onClicked: {
                    HueBridge.createUser("Shine - Ubuntu touch")
                    connectDialog.text = "Waiting for the connection to establish..."
                }
            }
            Button {
                text: "Quit"
                onClicked: {
                    Qt.quit();
                }
            }
        }
    }

    Component {
        id: errorComponent
        Dialog {
            id: errorDialog
            title: "Error discovering bridges"
//            text: "Could not start discovery for bridges. This won't work."
            Button {
                text: "Quit"
                onClicked: Qt.quit();
            }
        }
    }

    Column {
        anchors { left: parent.left; right: parent.right }
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8 * (5)
        visible: searchingSpinner.running
        BusyIndicator {
            id: searchingSpinner
            anchors.horizontalCenter: parent.horizontalCenter
            height: 8 * (5)
            width: height
            running: !HueBridge.discoveryError && !HueBridge.bridgeFound
        }
        Label {
            anchors { left: parent.left; right: parent.right }
            text: "Searching for Hue bridges..."
            horizontalAlignment: Text.AlignHCenter
        }
    }

    BigColorPicker {
        id: bigColorPicker
        anchors.fill: parent
        visible: root.orientation == "landscape"
        lights: lights
    }
}
