function open(page, parent, parameters) {
    var comp = Qt.createComponent(page);
    var popup = comp.createObject(parent, parameters)
    popup.open()
    return popup
}

function openComponent(comp, parent, parameters) {
    var popup = comp.createObject(parent, parameters)
    popup.open()
    return popup
}

function close(comp) {
    comp.close()
}
