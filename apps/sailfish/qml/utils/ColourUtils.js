.pragma library

.import Hue 0.1 as Hue;

function interpolateColour(from, to, x) {
    return Qt.rgba((from.r + (x * (to.r - from.r))), (from.g + (x * (to.g - from.g))), (from.b + (x * (to.b - from.b))), (from.a + (x * (to.a - from.a))))
}

function calculateLightColor(item) {
    var rgb
    if (!item) {
        return Qt.rbga(0.0, 0.0, 0.0, 0.0)
    }
    if (item.colormode === Hue.LightInterface.ColorModeCT) {
        var x = (item.ct - 153) / (500.0 - 153.0)
        if (x < 0.5) {
            // Interpolate between #efffff and #ffffea
            rgb = interpolateColour(Qt.rgba(0.937, 1.0, 1.0, 1.0), Qt.rgba(1.0, 1.0, 0.918, 1.0), x * 2.0)
        } else {
            // Interpolate between #ffffea and #ffd649
            rgb = interpolateColour(Qt.rgba(1.0, 1.0, 0.918, 1.0), Qt.rgba(1.0, 0.839, 0.286, 1.0), (x - 0.5) * 2.0)
        }
    } else {
        rgb = item.color
    }
    return interpolateColour(rgb, Qt.rgba(1.0, 1.0, 1.0, 1.0), 0.5)
}
