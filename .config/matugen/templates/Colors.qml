pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "{{colors.surface.default.hex}}"
    readonly property color surfaceVariant: "{{colors.surface_container_high.default.hex}}"
    readonly property color primary: "{{colors.primary.default.hex}}"
    readonly property color primaryText: "{{colors.on_primary.default.hex}}"
    readonly property color text: "{{colors.on_surface.default.hex}}"
    readonly property color subtext: "{{colors.on_surface_variant.default.hex}}"
}
