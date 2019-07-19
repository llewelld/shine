import QtQuick 2.5
import Sailfish.Silica 1.0
import "../components"
import Hue 0.1
import harbour.scintillon.settings 1.0

Dialog {
    id: root

    property var sensors: null
    property var sensor: null
    property var rules: null
    property var lights: null
    property var groups: null
    property var scenes: null

    allowedOrientations: Orientation.All

    canAccept: false

    SilicaFlickable {
        interactive: true
        anchors.fill: parent
        contentHeight: sensorColumn.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Column {
            id: sensorColumn
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                id: pageHeader
                title: sensor.name
            }

            Loader {
                id: sensorLoader
                width: parent.width
                sourceComponent: {
                    switch(root.sensor.type) {
                    case Sensor.TypeDaylight:
                        return hueBridgeComponent;
                    case Sensor.TypeZGPSwitch:
                        return hueTapComponent;
                    case Sensor.TypeZLLSwitch:
                        return hueDimmerComponent;
                    }
                    return null;
                }
            }

            Button {
                text: qsTr("Save")
                onClicked: {
                    root.saveRules()
                }
            }

            ComboBox {
                id: lightsOrSceneSelector
                label: qsTr("Action")
                menu: ContextMenu {
                    MenuItem { text: "Toggle lights"}
                    MenuItem { text: "Switch lights"}
                    MenuItem { text: "Activate scenes"}
                    MenuItem { text: "Dim Up"}
                    MenuItem { text: "Dim Down"}
                    //MenuItem { text: "Set sleep timer"}
                }
            }

            Item {
                id: recipeSelector
                width: parent.width
                height: lightRecipeColumn.height
                visible: lightsOrSceneSelector.currentIndex == 1
                opacity: lightsOrSceneSelector.menu.active ? 0 : 1

                property var recipes: []
                function toggleRecipe(name) {
                    print("toggling", name)
                    var removed = false;
                    var list = [];
                    for (var i = 0; i < recipeSelector.recipes.length; i++) {
                        if (recipeSelector.recipes[i] === name) {
                            print("removing", name)
                            removed = true;
                        } else {
                            print("adding", recipeSelector.recipes[i])
                            list.push(recipeSelector.recipes[i]);
                        }
                    }
                    if (!removed) {
                        list.push(name)
                    }
                    recipeSelector.recipes = list;
                }

                Column {
                    id: lightRecipeColumn
                    width: parent.width
                    spacing: Theme.paddingSmall
                    Repeater {
                        model: LightRecipeModel {
                            id: lightRecipeModel
                        }
                        delegate: TextSwitch {
                            //TODO: Set up tick model images
                            //source: "images/" + model.name + ".svg"
                            width: parent.width
                            height: Theme.itemSizeSmall
                            text: model.name
                            checked: {
                                for (var i = 0; i < recipeSelector.recipes.length; i++) {
                                    if (recipeSelector.recipes[i] === model.name) {
                                        return true;
                                    }
                                }
                                return false;
                            }
                            onClicked: recipeSelector.toggleRecipe(model.name)
                            automaticCheck: false
                        }
                    }
                    TextSwitch {
                        width: parent.width
                        //TODO: Set up torch image
                        //source: "image://theme/torch-off"
                        text: "Torch"
                        onClicked: recipeSelector.toggleRecipe("off")
                        checked: {
                            for (var i = 0; i < recipeSelector.recipes.length; i++) {
                                if (recipeSelector.recipes[i] === "off") {
                                    return true;
                                }
                            }
                            return false;
                        }
                        automaticCheck: false
                    }
                }
            }

            LightsAndGroupsList {
                id: lightsAndGroupsList
                lights: root.lights
                groups: root.groups
                width: parent.width
                height: Theme.itemSizeSmall * 6
                visible: lightsOrSceneSelector.currentIndex !== 2
                opacity: lightsOrSceneSelector.menu.active ? 0 : 1
            }

            ListView {
                id: scenesListView
                width: parent.width
                height: Theme.itemSizeSmall * 6
                currentIndex: 0
                visible: lightsOrSceneSelector.currentIndex === 2
                opacity: lightsOrSceneSelector.menu.active ? 0 : 1

                property var selectedScenes: []
                model: scenesFilterModel
                ScenesFilterModel {
                    id: scenesFilterModel
                    scenes: root.scenes
                    hideOtherApps: true
                }
                delegate: TextSwitch {
                    width: parent.width
                    height: Theme.itemSizeSmall
                    text: model.name
                    checked: {
                        print("evaluating visible for", model.name, scenesListView.selectedScenes.length)
                        for (var i = 0; i < scenesListView.selectedScenes.length; i++) {
                            if (scenesListView.selectedScenes[i] == model.id) {
                                print("scene is checked", model.name)
                                return true;
                            }
                        }
                        return false;
                    }
                    automaticCheck: false
                    onClicked: {
                        var removed = false;
                        var list = [];
                        for (var i = 0; i < scenesListView.selectedScenes.length; i++) {
                            if (scenesListView.selectedScenes[i] === model.id) {
                                removed = true;
                            } else {
                                list.push(scenesListView.selectedScenes[i])
                            }
                        }
                        if (!removed){
                            list.push(model.id)
                        }
                        scenesListView.selectedScenes = list;
                    }
                }
            }
        }

        /*
        MouseArea {
            anchors.fill: parent
            visible: busyRect.opacity > 0
            Timer {
                id: busyTimer
                interval: 5000
                repeat: false
            }
            Rectangle {
                id: busyRect
                anchors.fill: parent
                color: "black"
                opacity: busyTimer.running ? 0.7 : 0
            }
            Column {
                width: parent.width
                anchors.centerIn: parent
                spacing: 8 * (5)
                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: parent.visible
                }
                Label {
                    width: parent.width - 8 * (8)
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"
                    text: "Please wait while the configuration is saved to the bridge..."
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

            }
        }
        */
    }



    SensorsFilterModel {
        sensors: root.sensors

    }

    RulesFilterModel {
        id: existingRulesFilter
        rules: root.rules
    }

    Connections {
        target: sensorLoader.item
        onButtonIdChanged: {
            print("button id changed", sensorLoader.item.buttonId)
            loadRules();
        }
    }

    Component.onCompleted: loadRules();

    function loadRules() {
        // Reset selected scenes
        scenesListView.selectedScenes = []
        scenesListView.model = null;
        var recipes = [];

        lightsAndGroupsList.currentIndex = -1;

        // Find all the rules for this button
        existingRulesFilter.conditionFilter = sensorLoader.item.createFilter();

        // Set the view state according to the rules
        for (var i = 0; i < existingRulesFilter.count; i++) {
            var rule = existingRulesFilter.get(i);
            print("have rule", rule.name)
            if (rule.name.indexOf("Shine-L") === 0) {
                lightsOrSceneSelector.currentIndex = 0
                var lightId = rule.name.substring(8, rule.name.indexOf("-", 8))
                lightsAndGroupsList.selectLight(lightId)
            } else if (rule.name.indexOf("Shine-G") === 0) {
                lightsOrSceneSelector.currentIndex = 0
                var groupId = rule.name.substring(8, rule.name.indexOf("-", 8))
                lightsAndGroupsList.selectGroup(groupId)
            } else if (rule.name.indexOf("Shine-S") === 0) {
                lightsOrSceneSelector.currentIndex = 2
                print("have scene:", rule.name.substring(7, rule.name.length))
                scenesListView.selectedScenes.push(rule.name.substring(7, rule.name.length));
            } else if (rule.name.indexOf("Shine-R") === 0) {
                lightsOrSceneSelector.currentIndex = 1
                if (rule.name.indexOf("Shine-RG") === 0) {
                    lightsAndGroupsList.selectGroup(rule.name.substring(8, rule.name.indexOf("-", 8)))
                } else {
                    lightsAndGroupsList.selectLight(rule.name.substring(8, rule.name.indexOf("-", 8)))
                }
                var name = rule.name.substring(rule.name.indexOf("-", 9) + 1, rule.name.length);
                print("name", name, recipes.indexOf(name))
                if (recipes.indexOf(name) === -1) {
                    recipes.push(name)
                }
            } else if (rule.name.indexOf("Shine-DUL") === 0) {
                lightsOrSceneSelector.currentIndex = 3;
                var lightId = rule.name.substring(10, rule.name.length)
                print("lightId", lightId)
                lightsAndGroupsList.selectLight(lightId)
            } else if (rule.name.indexOf("Shine-DDL") === 0) {
                lightsOrSceneSelector.currentIndex = 4;
                var lightId = rule.name.substring(10, rule.name.length)
                print("lightId", lightId)
                lightsAndGroupsList.selectLight(lightId)
            } else if (rule.name.indexOf("Shine-DUG")) {
                lightsOrSceneSelector.currentIndex = 3;
                var groupId = rule.name.substring(10, rule.name.length)
                lightsAndGroupsList.selectGroup(groupId)
            } else if (rule.name.indexOf("Shine-DDG")) {
                lightsOrSceneSelector.currentIndex = 4;
                var groupId = rule.name.substring(10, rule.name.length)
                lightsAndGroupsList.selectGroup(groupId)
            }
        }
        scenesListView.model = scenesFilterModel;
        recipeSelector.recipes = recipes;
    }

    function saveRules() {
        busyTimer.start();
        var buttonId = sensorLoader.item.buttonId;

        // Deleting old rules
        existingRulesFilter.conditionFilter = sensorLoader.item.createFilter();
        for (var i = 0; i < existingRulesFilter.count; i++) {
            print("should delete rule", existingRulesFilter.get(i).id, existingRulesFilter.get(i).name)
            root.rules.deleteRule(existingRulesFilter.get(i).id)
        }

        var uniqueId = root.sensor.uniqueId || "000000"
        print("uniqueid is", root.sensor.uniqueId, root.sensor)
        var helperSensor = root.sensors.findOrCreateHelperSensor("HueTapHelper" + buttonId, uniqueId);
        if (!helperSensor) {
            print("No helper sensor found. bailing out...")
            return;
        }
        

        var conditions = []
        var actions = []

        print("current selection", lightsOrSceneSelector.currentIndex)
        if (lightsOrSceneSelector.currentIndex == 0) {
            print("Creating light toggle rules")
            var lightOrGroup = lightsAndGroupsList.model.get(lightsAndGroupsList.currentIndex);
            var ruleName = "Shine-"

            conditions = sensorLoader.item.createSensorConditions();
            conditions.push(rules.createHelperCondition(helperSensor.id, "eq", "0"))

            if (lightOrGroup.type === "light") {
                actions.push(root.rules.createLightAction(lightOrGroup.id, true))
                ruleName += "L"
            } else {
                actions.push(root.rules.createGroupAction(lightOrGroup.id, true))
                ruleName += "G"
            }
            ruleName += "-" + lightOrGroup.id + "-"

            actions.push(root.rules.createHelperAction(helperSensor.id, 1))
            rules.createRule(ruleName + "on", conditions, actions);

            conditions = sensorLoader.item.createSensorConditions();
            conditions.push(root.rules.createHelperCondition(helperSensor.id, "gt", "0"))
            actions = []
            if (lightOrGroup.type === "light") {
                actions.push(root.rules.createLightAction(lightOrGroup.id, false))
            } else {
                actions.push(root.rules.createGroupAction(lightOrGroup.id, false))
            }

            actions.push(root.rules.createHelperAction(helperSensor.id, 0))
            rules.createRule(ruleName + "off", conditions, actions)

        } else if (lightsOrSceneSelector.currentIndex == 2) {
            print("Creating activate scenes rules")
            print("scenelength", scenesListView.selectedScenes.length)
            for (var i = 0; i < scenesListView.selectedScenes.length; i++) {
                print("should add scene", scenesListView.selectedScenes[i])
                var scene = scenesListView.selectedScenes[i]
                var ruleName = "Shine-S" + scene;
                var conditions = sensorLoader.item.createSensorConditions();
                if (i == 0 && scenesListView.selectedScenes.length > 1) {
                    conditions.push(rules.createHelperCondition(helperSensor.id, "lt", "" + buttonId + "1"))
                } else if (scenesListView.selectedScenes.length > 1) {
                    conditions.push(rules.createHelperCondition(helperSensor.id, "eq", "" + buttonId + i))
                }

                actions = [];
                actions.push(root.rules.createSceneAction(scenesListView.selectedScenes[i]));
                if (i == scenesListView.selectedScenes.length - 1 && scenesListView.selectedScenes.length > 1) {
                    actions.push(rules.createHelperAction(helperSensor.id, "" + buttonId + "0"))
                } else if (scenesListView.selectedScenes.length > 1) {
                    actions.push(rules.createHelperAction(helperSensor.id, "" + buttonId + (i + 1)))
                }

                rules.createRule(ruleName, conditions, actions);
            }
            if (scenesListView.selectedScenes.length > 1) {
                var conditions = sensorLoader.item.createSensorConditions()
                conditions.push(rules.createHelperCondition(helperSensor.id, "gt", "" + buttonId + (scenesListView.selectedScenes.length - 1)))

                actions = [];
                actions.push(root.rules.createSceneAction(scenesListView.selectedScenes[0]));
                actions.push(rules.createHelperAction(helperSensor.id, "" + buttonId + "1"))
                rules.createRule("Shine-S" + scenesListView.selectedScenes[0], conditions, actions);
            }
        } else if (lightsOrSceneSelector.currentIndex == 1) {  // recipies
            print("Creating recipe rules")
            var lightOrGroup = lightsAndGroupsList.model.get(lightsAndGroupsList.currentIndex);

            for (var i = 0; i < recipeSelector.recipes.length; i++) {
                var recipe = { name: "off"};
                if (recipeSelector.recipes[i] !== "off") {
                    recipe = lightRecipeModel.getByName(recipeSelector.recipes[i]);
                }
                print("should add recipe", recipeSelector.recipes[i], recipe.name)
                var ruleName = "Shine-R"

                var conditions = sensorLoader.item.createSensorConditions();
                if (i == 0 && recipeSelector.recipes.length > 1) {
                    conditions.push(rules.createHelperCondition(helperSensor.id, "lt", "" + buttonId + "1"))
                } else if (recipeSelector.recipes.length > 1) {
                    conditions.push(rules.createHelperCondition(helperSensor.id, "eq", "" + buttonId + i))
                }

                actions = [];

                print("***saving rule", lightOrGroup.isGroup, lightOrGroup.name, lightsAndGroupsList.model)
                if (lightOrGroup.isGroup) {
                    ruleName += "G";
                    if (recipe.name === "off") {
                        actions.push(root.rules.createGroupAction(lightOrGroup.id, false))
                    } else {
                        actions.push(root.rules.createGroupColorAction(lightOrGroup.id, recipe.color, recipe.bri));
                    }
                } else {
                    ruleName += "L";
                    if (recipe.name === "off") {
                        actions.push(root.rules.createLightAction(lightOrGroup.id, false))
                    } else {
                        actions.push(root.rules.createLightColorAction(lightOrGroup.id, recipe.color, recipe.bri));
                    }
                }
                ruleName += lightOrGroup.id + "-" + recipe.name;

                if (i == recipeSelector.recipes.length - 1 && recipeSelector.recipes.length > 1) {
                    actions.push(rules.createHelperAction(helperSensor.id, "" + buttonId + "0"))
                } else if (recipeSelector.recipes.length > 1) {
                    actions.push(rules.createHelperAction(helperSensor.id, "" + buttonId + (i + 1)))
                }

                rules.createRule(ruleName, conditions, actions);
            }
            if (recipeSelector.recipes.length > 1) {
                var recipe = { name: "off" };
                if (recipeSelector.recipes[0] !== "off") {
                    recipe = lightRecipeModel.getByName(recipeSelector.recipes[0])
                }
                var conditions = sensorLoader.item.createSensorConditions()
                conditions.push(rules.createHelperCondition(helperSensor.id, "gt", "" + buttonId + (recipeSelector.recipes.length - 1)))
                var ruleName = "Shine-R"
                actions = [];
                if (lightOrGroup.isGroup) {
                    ruleName += "G";
                    if (recipe.name === "off") {
                        actions.push(root.rules.createGroupAction(lightOrGroup.id, false));
                    } else {
                        actions.push(root.rules.createGroupColorAction(lightOrGroup.id, recipe.color, recipe.bri));
                    }
                } else {
                    ruleName += "L";
                    if (recipe.name === "off") {
                        actions.push(root.rules.createLightAction(lightOrGroupId, false));
                    } else {
                        actions.push(root.rules.createLightColorAction(lightOrGroup.id, recipe.color, recipe.bri));
                    }
                }
                ruleName += lightOrGroup.id + "-" + recipe.name;
                actions.push(rules.createHelperAction(helperSensor.id, "" + buttonId + "1"))
                rules.createRule(ruleName, conditions, actions);
            }
        } else if (lightsOrSceneSelector.currentIndex == 5) { // Sleep timer
            var lightOrGroup = lightsAndGroupsList.model.get(lightsAndGroupsList.currentIndex);
            var ruleName = "Shine-T-"
            conditions = sensorLoader.item.createSensorConditions();
            if (lightOrGroup.type === "light") {
                actions.push(root.rules.createLightTimerActions(lightOrGroup))
            } else {
                actions.push(root.rules.createGroupTimerActions(lightOrGroup))
            }
            rules.createRule(ruleName, conditions, actions);

        }else { // Dimmer
            print("Creating dimmer rules")
            var lightOrGroup = lightsAndGroupsList.model.get(lightsAndGroupsList.currentIndex);

            var ruleName = "Shine-D"

            conditions = sensorLoader.item.createSensorConditions();

            var dimAction;
            if (lightsOrSceneSelector.currentIndex == 3) {
                dimAction = Rules.DimActionUp;
                ruleName += "U";
            } else {
                dimAction = Rules.DimActionDown;
                ruleName += "D";
            }
            if (lightOrGroup.type === "light") {
                actions.push(root.rules.createLightDimmerAction(lightOrGroup.id, dimAction))
                ruleName += "L"
            } else {
                actions.push(root.rules.createGroupDimmerAction(lightOrGroup.id, dimAction))
                ruleName += "G"
            }
            ruleName += "-" + lightOrGroup.id

            actions.push(root.rules.createHelperAction(helperSensor.id, 1))
            rules.createRule(ruleName, conditions, actions);
        }

        rules.refresh();
    }

    Component {
        id: hueBridgeComponent

        Item {
            id: hueBridge

            property int buttonId: 0
            property bool day: true

            height: hueBridgeRow.height
            width: parent.width

            function createSensorConditions() {
                return root.rules.createDaylightConditions(root.sensor.id, hueBridge.day);
            }

            function createFilter() {
                var filter = new Object();
                filter["address"] = "/sensors/" + root.sensor.id + "/state/daylight"
                filter["operator"] = "eq"
                filter["value"] = hueBridge.day
                return filter
            }

            Row {
                id: hueBridgeRow
                width: parent.width - 2.0 * Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium

                Column {
                    width: parent.width - hueBridgeIcon.width - Theme.paddingMedium

                    TextSwitch {
                        width: parent.width
                        text: "Sunrise"
                        checked: hueBridge.day
                        automaticCheck: false
                        onClicked: hueBridge.day = true
                    }

                    TextSwitch {
                        width: parent.width
                        text: "Sunset"
                        checked: !hueBridge.day
                        automaticCheck: false
                        onClicked: hueBridge.day = false
                    }
                }

                IconButton {
                    id: hueBridgeIcon
                    width: Theme.iconSizeExtraLarge
                    height: width
                    icon.source: hueBridge.day ? Qt.resolvedUrl("image://scintillon/sensors/daylight-sunrise") : Qt.resolvedUrl("image://scintillon/sensors/daylight-sunset")
                    icon.color: "white"
                }
            }
        }
    }

    Component {
        id: hueTapComponent
        Column {
            id: hueTap

            property int buttonId: 34

            width: parent.width

            function createSensorConditions() {
                return root.rules.createHueTapConditions(root.sensor.id, hueTap.buttonId);
            }

            function createFilter() {
                var filter = new Object();
                filter["address"] = "/sensors/" + root.sensor.id + "/state/buttonevent"
                filter["operator"] = "eq"
                filter["value"] = hueTap.buttonId
                return filter
            }

            TextSwitch {
                width: parent.width
                text: "Button 1"
                checked: hueTap.buttonId == 34
                automaticCheck: false
                onClicked: hueTap.buttonId = 34
            }

            TextSwitch {
                width: parent.width
                text: "Button 2"
                checked: hueTap.buttonId == 16
                automaticCheck: false
                onClicked: hueTap.buttonId = 16
            }

            TextSwitch {
                width: parent.width
                text: "Button 3"
                checked: hueTap.buttonId == 17
                automaticCheck: false
                onClicked: hueTap.buttonId = 17
            }

            TextSwitch {
                width: parent.width
                text: "Button 4"
                checked: hueTap.buttonId == 18
                automaticCheck: false
                onClicked: hueTap.buttonId = 18
            }

            Image {
                //TODO: Icon changes based on hueTap.buttonId
                //source: "images/tap_outline_" +  hueTap.buttonId + ".svg"
                source: Qt.resolvedUrl("image://scintillon/icon-s-bright")
                height: Theme.itemSizeLarge
                width: height
                sourceSize.height: height
                sourceSize.width: width
                anchors.horizontalCenter: parent.horizontalCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: hueTap.buttonId = 34
                }

                MouseArea {
                    height: parent.height / 4
                    width: height
                    anchors { left: parent.left; leftMargin: width / 2; verticalCenter: parent.verticalCenter }
                    onClicked: hueTap.buttonId = 16
                }
                MouseArea {
                    height: parent.height / 4
                    width: height
                    anchors { bottom: parent.bottom; bottomMargin: width / 2; horizontalCenter: parent.horizontalCenter }
                    onClicked: hueTap.buttonId = 17
                }
                MouseArea {
                    height: parent.height / 4
                    width: height
                    anchors { right: parent.right; rightMargin: width / 2; verticalCenter: parent.verticalCenter }
                    onClicked: hueTap.buttonId = 18
                }
            }
        }
    }

    Component {
        id: hueDimmerComponent
        Item {
            id: hueDimmer
            property int buttonId: buttonNumber + "00" + buttonMode

            property int buttonNumber: 1
            property int buttonMode: pressCheckBox.checked ? 2 : 1

            width: parent.width
            height: hueDimmerColumn.height

            function createSensorConditions() {
                return root.rules.createHueDimmerConditions(root.sensor.id, hueDimmer.buttonId);
            }

            function createFilter() {
                var filter = new Object();
                filter["address"] = "/sensors/" + root.sensor.id + "/state/buttonevent"
                filter["operator"] = "eq"
                filter["value"] = hueDimmer.buttonId
                return filter
            }

            Column {
                id: hueDimmerColumn
                width: parent.width

                TextSwitch {
                    width: parent.width
                    text: "On button"
                    checked: hueDimmer.buttonNumber == 1
                    automaticCheck: false
                    onClicked: hueDimmer.buttonNumber = 1
                }

                TextSwitch {
                    width: parent.width
                    text: "Brighter button"
                    checked: hueDimmer.buttonNumber == 2
                    automaticCheck: false
                    onClicked: hueDimmer.buttonNumber = 2
                }

                TextSwitch {
                    width: parent.width
                    text: "Dimmer button"
                    checked: hueDimmer.buttonNumber == 3
                    automaticCheck: false
                    onClicked: hueDimmer.buttonNumber = 3
                }

                TextSwitch {
                    width: parent.width
                    text: "Off button"
                    checked: hueDimmer.buttonNumber == 4
                    automaticCheck: false
                    onClicked: hueDimmer.buttonNumber = 4
                }

                /*
                Image {
                    //TODO: Icon changes based on hueDimmer.buttonNumber
                    //source: "images/dimmer_outline_" + hueDimmer.buttonNumber + ".svg"
                    source: Qt.resolvedUrl("image://scintillon/icon-s-bright")
                    height: parent.height
                    width: height
                    sourceSize.height: height
                    sourceSize.width: width
//                    anchors.horizontalCenter: parent.horizontalCenter

                    MouseArea {
                        height: parent.height / 3
                        width: parent.width / 3
                        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                        onClicked: hueDimmer.buttonNumber = 1
                    }
                    MouseArea {
                        height: parent.height / 6
                        width: parent.width / 3
                        anchors { centerIn: parent; verticalCenterOffset: -height / 2 }
                        onClicked: hueDimmer.buttonNumber = 2
                    }
                    MouseArea {
                        height: parent.height / 6
                        width: parent.width / 3
                        anchors { centerIn: parent; verticalCenterOffset: height / 2 }
                        onClicked: hueDimmer.buttonNumber = 3
                    }
                    MouseArea {
                        height: parent.height / 3
                        width: parent.width / 3
                        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                        onClicked: hueDimmer.buttonNumber = 4
                    }
                }
                */
                TextSwitch {
                    id: pressCheckBox
                    checked: true
                    automaticCheck: false
                    onClicked: {
                        pressCheckBox.checked = true;
                        holdCheckBox.checked = false;
                    }
                    text: "Press"
                }

                TextSwitch {
                    id: holdCheckBox
                    automaticCheck: false
                    onClicked: {
                        holdCheckBox.checked = true;
                        pressCheckBox.checked = false;
                    }
                    text: "Hold"
                }
            }
        }
    }
}
