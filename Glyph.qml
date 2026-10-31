import QtQuick
import QtQuick.Shapes

// Stroked line icons from the Figma file, drawn as vector paths so they take
// the theme colors. Paths use a 24x24 design grid, scaled to `size`.
Item {
    id: root

    property string kind: ""
    property color color: Theme.fg
    property real size: Theme.px(20)
    property real level: 1            // battery fill, 0..1

    implicitWidth: size
    implicitHeight: size

    readonly property var defs: ({
        note:     { stroke: "M9 18V6l10-2v12 M4 18a2.5 2.5 0 1 0 5 0a2.5 2.5 0 1 0 -5 0 M14 16a2.5 2.5 0 1 0 5 0a2.5 2.5 0 1 0 -5 0" },
        volume:   { stroke: "M4 9.5h3.5L12 6v12l-4.5-3.5H4v-5Z M15.5 9a4 4 0 0 1 0 6 M18 6.5a8 8 0 0 1 0 11" },
        wifi:     { stroke: "M3 9.5a14 14 0 0 1 18 0 M6 13a9.5 9.5 0 0 1 12 0 M9 16.5a5 5 0 0 1 6 0",
                    fill:   "M10.9 19.6a1.1 1.1 0 1 0 2.2 0a1.1 1.1 0 1 0 -2.2 0Z" },
        battery:  { stroke: "M5 7.5H17A2.5 2.5 0 0 1 19.5 10V14A2.5 2.5 0 0 1 17 16.5H5A2.5 2.5 0 0 1 2.5 14V10A2.5 2.5 0 0 1 5 7.5Z M22 10.5v3" },
        saver:    { stroke: "M5 19C5 10 10 5 19 5c0 9-5 14-14 14Z M5 19c3-5 6-8 10-10" },
        balanced: { stroke: "M4 12a8 8 0 1 0 16 0a8 8 0 1 0 -16 0",
                    fill:   "M12 4a8 8 0 0 1 0 16Z", fillAlpha: 0.55 },
        perf:     { stroke: "M13 3 5 13.5h6L10 21l9-11h-6.5L13 3Z" },
        chevDown: { stroke: "M6 9 12 15 18 9" },
        chevUp:   { stroke: "M6 15 12 9 18 15" },
        therm:    { stroke: "M10 14.5V5a2 2 0 1 1 4 0v9.5a4 4 0 1 1-4 0Z M12 9.5v7" },
        search:   { stroke: "M4.5 11a6.5 6.5 0 1 0 13 0a6.5 6.5 0 1 0 -13 0 M16 16l4.5 4.5" }
    })

    readonly property var def: defs[kind] || ({})
    readonly property string strokePath: def.stroke || ""
    readonly property string fillPath: kind === "battery"
        ? "M4.7 9.7H" + (4.7 + 10.6 * Math.max(0.06, Math.min(1, level))) + "V14.3H4.7Z"
        : (def.fill || "")
    readonly property real fillAlpha: def.fillAlpha !== undefined ? def.fillAlpha : 1

    Shape {
        width: 24
        height: 24
        scale: root.size / 24
        transformOrigin: Item.TopLeft
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.8
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: root.strokePath }
        }

        ShapePath {
            strokeColor: "transparent"
            strokeWidth: 0
            fillColor: Qt.rgba(root.color.r, root.color.g, root.color.b, root.fillAlpha)
            PathSvg { path: root.fillPath }
        }
    }
}
