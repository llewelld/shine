.pragma library

.import Hue 0.1 as Hue

// existingRulesFilter
// lightsAndGroupsList
// recipeSelector
// scenesListView
// lightsOrSceneSelector
// sensorLoader
// existingRulesFilter, lightsAndGroupsList, recipeSelector, scenesListView
function loadRules(rulesFilter, lightsAndGroups, recipes, scenes, selector, sensorLoader) {
    // Reset selected scenes
    scenes.selectedScenes = []
    scenes.model = null;

    console.log("Scene list pre length: " + scenes.selectedScenes.length)

    lightsAndGroups.currentIndex = -1;

    // Find all the rules for this button
    rulesFilter.conditionFilter = sensorLoader.item.createFilter();

    // Clear the state if there is no rule
    if (rulesFilter.count == 0) {
        selector.currentIndex = 0
    }

    // Set the view state according to the rules
    for (var i = 0; i < rulesFilter.count; i++) {
        var rule = rulesFilter.get(i);
        console.log("have rule", rule.name)
        if (rule.name.indexOf("Shine-L") === 0) {
            selector.currentIndex = 1
            var lightId = rule.name.substring(8, rule.name.indexOf("-", 8))
            lightsAndGroups.selectLight(lightId)
        } else if (rule.name.indexOf("Shine-G") === 0) {
            selector.currentIndex = 1
            var groupId = rule.name.substring(8, rule.name.indexOf("-", 8))
            lightsAndGroups.selectGroup(groupId)
        } else if (rule.name.indexOf("Shine-S") === 0) {
            selector.currentIndex = 4
            console.log("have scene:", rule.name.substring(7, rule.name.length))
            scenes.selectedScenes.push(rule.name.substring(7, rule.name.length));
        } else if (rule.name.indexOf("Shine-R") === 0) {
            if (rule.name.indexOf("Shine-RG") === 0) {
                lightsAndGroups.selectGroup(rule.name.substring(8, rule.name.indexOf("-", 8)))
            } else {
                lightsAndGroups.selectLight(rule.name.substring(8, rule.name.indexOf("-", 8)))
            }
            var name = rule.name.substring(rule.name.indexOf("-", 9) + 1, rule.name.length);
            if (name == "on") {
                selector.currentIndex = 2
            } else if (name == "off") {
                selector.currentIndex = 3
            }
            console.log("name", name)
        } else if (rule.name.indexOf("Shine-DUL") === 0) {
            selector.currentIndex = 5;
            var lightId = rule.name.substring(10, rule.name.length)
            console.log("lightId", lightId)
            lightsAndGroups.selectLight(lightId)
        } else if (rule.name.indexOf("Shine-DDL") === 0) {
            selector.currentIndex = 6;
            var lightId = rule.name.substring(10, rule.name.length)
            console.log("lightId", lightId)
            lightsAndGroups.selectLight(lightId)
        } else if (rule.name.indexOf("Shine-DUG") === 0) {
            selector.currentIndex = 5;
            var groupId = rule.name.substring(10, rule.name.length)
            lightsAndGroups.selectGroup(groupId)
        } else if (rule.name.indexOf("Shine-DDG") === 0) {
            selector.currentIndex = 6;
            var groupId = rule.name.substring(10, rule.name.length)
            lightsAndGroups.selectGroup(groupId)
        }
    }
    scenes.model = scenes.scenesFilterModel;
    console.log("Scene list post length: " + scenes.selectedScenes.length)
}

// existingRulesFilter
// rules
// sensorLoader
// sensor
// sensors
// lightsOrSceneSelector
// lightsAndGroupsList
// scenesListView
// recipeSelector
// existingRulesFilter, root.rules, sensorLoader, root.sensor, root.sensors, lightsOrSceneSelector, lightsAndGroupsList, scenesListView, recipeSelector
function saveRules(rulesFilter, rules, sensorLoader, sensor, sensors, selector, lightsAndGroups, scenes, recipes) {
    var buttonId = sensorLoader.item.buttonId;

    // Deleting old rules
    rulesFilter.conditionFilter = sensorLoader.item.createFilter();
    for (var i = 0; i < rulesFilter.count; i++) {
        console.log("should delete rule", rulesFilter.get(i).id, rulesFilter.get(i).name)
        rules.deleteRule(rulesFilter.get(i).id)
    }

    var uniqueId = sensor.uniqueId || "000000"
    console.log("uniqueid is", sensor.uniqueId, sensor)
    var helperSensor = sensors.findOrCreateHelperSensor("HueTapHelper" + buttonId, uniqueId);
    if (!helperSensor) {
        console.log("No helper sensor found. bailing out...")
        return;
    }

    var conditions = []
    var actions = []

    console.log("current selection", selector.currentIndex)
    if (selector.currentIndex == 0) {
        console.log("No new rule")
    } else if (selector.currentIndex == 1) {
        console.log("Creating light toggle rules")
        var lightOrGroup = lightsAndGroups.model.get(lightsAndGroups.currentIndex);
        var ruleName = "Shine-"

        conditions = sensorLoader.item.createSensorConditions();
        conditions.push(rules.createHelperCondition(helperSensor.id, "eq", "0"))

        if (lightOrGroup.type === "light") {
            actions.push(rules.createLightAction(lightOrGroup.id, true))
            ruleName += "L"
        } else {
            actions.push(rules.createGroupAction(lightOrGroup.id, true))
            ruleName += "G"
        }
        ruleName += "-" + lightOrGroup.id + "-"

        actions.push(rules.createHelperAction(helperSensor.id, 1))
        rules.createRule(ruleName + "on", conditions, actions);

        conditions = sensorLoader.item.createSensorConditions();
        conditions.push(rules.createHelperCondition(helperSensor.id, "gt", "0"))
        actions = []
        if (lightOrGroup.type === "light") {
            actions.push(rules.createLightAction(lightOrGroup.id, false))
        } else {
            actions.push(rules.createGroupAction(lightOrGroup.id, false))
        }

        actions.push(rules.createHelperAction(helperSensor.id, 0))
        rules.createRule(ruleName + "off", conditions, actions)

    } else if (selector.currentIndex == 4) {
        console.log("Creating activate scenes rules")
        console.log("scenelength", scenes.selectedScenes.length)
        for (var i = 0; i < scenes.selectedScenes.length; i++) {
            console.log("should add scene", scenes.selectedScenes[i])
            var scene = scenes.selectedScenes[i]
            var ruleName = "Shine-S" + scene;
            var conditions = sensorLoader.item.createSensorConditions();
            if (i == 0 && scenes.selectedScenes.length > 1) {
                conditions.push(rules.createHelperCondition(helperSensor.id, "lt", "" + buttonId + "1"))
            } else if (scenes.selectedScenes.length > 1) {
                conditions.push(rules.createHelperCondition(helperSensor.id, "eq", "" + buttonId + i))
            }

            actions = [];
            actions.push(rules.createSceneAction(scenes.selectedScenes[i]));
            if (i == scenes.selectedScenes.length - 1 && scenes.selectedScenes.length > 1) {
                actions.push(rules.createHelperAction(helperSensor.id, "" + buttonId + "0"))
            } else if (scenes.selectedScenes.length > 1) {
                actions.push(rules.createHelperAction(helperSensor.id, "" + buttonId + (i + 1)))
            }

            rules.createRule(ruleName, conditions, actions);
        }
        if (scenes.selectedScenes.length > 1) {
            var conditions = sensorLoader.item.createSensorConditions()
            conditions.push(rules.createHelperCondition(helperSensor.id, "gt", "" + buttonId + (scenes.selectedScenes.length - 1)))

            actions = [];
            actions.push(rules.createSceneAction(scenes.selectedScenes[0]));
            actions.push(rules.createHelperAction(helperSensor.id, "" + buttonId + "1"))
            rules.createRule("Shine-S" + scenes.selectedScenes[0], conditions, actions);
        }
    } else if ((selector.currentIndex == 2) || (selector.currentIndex == 3)) {  // Turn on/off
        console.log("Creating turn on rules")
        var lightOrGroup = lightsAndGroups.model.get(lightsAndGroups.currentIndex);

        console.log("should add recipe", (recipes.lightOn ? "on" : "off"))
        var ruleName = "Shine-R"

        var conditions = sensorLoader.item.createSensorConditions();

        actions = [];

        console.log("***saving rule", lightOrGroup.isGroup, lightOrGroup.name, lightsAndGroups.model)
        if (lightOrGroup.isGroup) {
            ruleName += "G";
            actions.push(rules.createGroupAction(lightOrGroup.id, recipes.lightOn))
        } else {
            ruleName += "L";
            actions.push(rules.createLightAction(lightOrGroup.id, recipes.lightOn))
        }
        ruleName += lightOrGroup.id + "-" + (recipes.lightOn ? "on" : "off");

        rules.createRule(ruleName, conditions, actions);
    } else if (selector.currentIndex == 7) { // Sleep timer
        var lightOrGroup = lightsAndGroups.model.get(lightsAndGroups.currentIndex);
        var ruleName = "Shine-T-"
        conditions = sensorLoader.item.createSensorConditions();
        if (lightOrGroup.type === "light") {
            actions.push(rules.createLightTimerActions(lightOrGroup))
        } else {
            actions.push(rules.createGroupTimerActions(lightOrGroup))
        }
        rules.createRule(ruleName, conditions, actions);

    } else if ((selector.currentIndex == 5) || (selector.currentIndex == 6)) { // Dimmer
        console.log("Creating dimmer rules")
        var lightOrGroup = lightsAndGroups.model.get(lightsAndGroups.currentIndex);

        var ruleName = "Shine-D"

        conditions = sensorLoader.item.createSensorConditions();

        var dimAction;
        if (selector.currentIndex == 5) {
            dimAction = Hue.Rules.DimActionUp;
            ruleName += "U";
        } else if (selector.currentIndex == 6) {
            dimAction = Hue.Rules.DimActionDown;
            ruleName += "D";
        }
        if (lightOrGroup.type === "light") {
            actions.push(rules.createLightDimmerAction(lightOrGroup.id, dimAction))
            ruleName += "L"
        } else {
            actions.push(rules.createGroupDimmerAction(lightOrGroup.id, dimAction))
            ruleName += "G"
        }
        ruleName += "-" + lightOrGroup.id

        actions.push(rules.createHelperAction(helperSensor.id, 1))
        rules.createRule(ruleName, conditions, actions);
    }

    rules.refresh();
}
