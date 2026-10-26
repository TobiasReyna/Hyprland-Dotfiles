//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import "."

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 42
            color: "transparent"

            // Estado reactivo compartido
            property bool caffeineActive: false
            property string powerProfile: "balanced"
            property string batteryCapacity: "100"
            property string batteryStatus: "Unknown"
            property int cpuUsage: 0
            property real cpuTemp: 0
            property int ramPercent: 0
            property int diskPercent: 0
            property var prevCpu: null

            function runProc(p) { p.running = true }

            Process {
                id: getProfileProc
                command: ["powerprofilesctl", "get"]
                running: true
                stdout: StdioCollector { onStreamFinished: bar.powerProfile = this.text.trim() }
            }

            Process {
                id: batProc
                command: ["sh", "-c", "for b in /sys/class/power_supply/BAT*; do [ -r \"$b/capacity\" ] && echo \"$(cat \"$b/capacity\") $(cat \"$b/status\")\" && break; done"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: {
                        const p = this.text.trim().split(" ")
                        if (p.length >= 2) { bar.batteryCapacity = p[0]; bar.batteryStatus = p[1] }
                    }
                }
            }

            Process {
                id: cpuProc
                command: ["sh", "-c", "head -n1 /proc/stat"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        const f = this.text.trim().split(/\s+/).slice(1).map(Number)
                        const idle = f[3] + (f[4] || 0)
                        const total = f.reduce((a, b) => a + b, 0)
                        if (bar.prevCpu) {
                            const dt = total - bar.prevCpu.total
                            const di = idle - bar.prevCpu.idle
                            if (dt > 0) bar.cpuUsage = Math.round(100 * (dt - di) / dt)
                        }
                        bar.prevCpu = { total: total, idle: idle }
                    }
                }
            }

            Process {
                id: tempProc
                command: ["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do n=$(cat \"$h/name\" 2>/dev/null); case \"$n\" in coretemp|k10temp|zenpower) cat \"$h/temp1_input\"; exit;; esac; done; cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null"]
                stdout: StdioCollector {
                    onStreamFinished: { const v = parseInt(this.text.trim()); if (!isNaN(v)) bar.cpuTemp = Math.round(v / 1000) }
                }
            }

            Process {
                id: ramProc
                command: ["sh", "-c", "free -m | awk '/Mem:/ {printf \"%d\", $3/$2 * 100}'"]
                stdout: StdioCollector {
                    onStreamFinished: { const v = parseInt(this.text.trim()); if (!isNaN(v)) bar.ramPercent = v }
                }
            }

            Process {
                id: diskProc
                command: ["sh", "-c", "df -h / | awk 'NR==2{gsub(/%/,\"\",$5); print $5}'"]
                stdout: StdioCollector {
                    onStreamFinished: { const v = parseInt(this.text.trim()); if (!isNaN(v)) bar.diskPercent = v }
                }
            }

            Process {
                id: cycleProfileProc
                property string targetProfile: "balanced"
                command: ["powerprofilesctl", "set", targetProfile]
                onExited: getProfileProc.running = true
            }

            Process {
                id: wallLauncherProc
                command: ["sh", "-c", "\"$HOME/.config/hypr/scripts/wallpaper-selector.sh\""]
            }

            // Caffeine: matar hypridle evita bloqueo/apagado; relanzarlo restaura los timeouts
            Process {
                id: caffeineProc
                property bool enableCaffeine: false
                command: enableCaffeine
                    ? ["sh", "-c", "pkill -x hypridle"]
                    : ["sh", "-c", "pkill -x hypridle; setsid -f hypridle >/dev/null 2>&1"]
            }

            // Estado inicial: caffeine activo si hypridle no está corriendo
            Process {
                id: caffeineStateProc
                command: ["sh", "-c", "pgrep -x hypridle >/dev/null && echo off || echo on"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: {
                        bar.caffeineActive = this.text.trim() === "on"
                        caffeineProc.enableCaffeine = bar.caffeineActive
                    }
                }
            }

            Process {
                id: wifiProc
                command: ["nm-connection-editor"]
            }

            Process {
                id: btProc
                command: ["blueman-manager"]
            }

            Timer {
                interval: 2000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    cpuProc.running = true
                    tempProc.running = true
                    ramProc.running = true
                    diskProc.running = true
                    getProfileProc.running = true
                    batProc.running = true
                }
            }


            Rectangle {
                anchors.fill: parent
                anchors.margins: 6
                anchors.bottomMargin: 0
                radius: 12
                color: Qt.rgba(Colors.background.r, Colors.background.g, Colors.background.b, 0.65)
                border.color: Qt.rgba(1.0, 1.0, 1.0, 0.25)
                border.width: 1

                // --- CENTRO: Caffeine + Reloj (centrados juntos) ---
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    // Caffeine toggle
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 26
                        radius: 8
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "\uf0f4"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 15
                            color: bar.caffeineActive ? Colors.primary : Colors.subtext
                            opacity: bar.caffeineActive ? 1.0 : 0.6

                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                bar.caffeineActive = !bar.caffeineActive
                                caffeineProc.enableCaffeine = bar.caffeineActive
                                caffeineProc.running = true
                            }
                        }
                    }

                    // Reloj
                    Text {
                        id: clockText
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        font.bold: true
                        color: Colors.text

                        SystemClock {
                            id: sysClock
                            precision: SystemClock.Seconds
                        }
                        text: Qt.formatDateTime(sysClock.date, "ddd dd MMM  •  HH:mm")
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14

                    // --- IZQUIERDA: Logo Arch + Workspaces ---
                    RowLayout {
                        spacing: 8

                        Text {
                            text: ""
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18
                            color: Colors.primary
                            rightPadding: 6
                        }

                        // Contenedor de Workspaces con soporte de click y scroll
                        RowLayout {
                            id: wsLayout
                            spacing: 8

                            Repeater {
                                model: Hyprland.workspaces

                                Rectangle {
                                    required property var modelData
                                    property bool isSpecial: !modelData || modelData.id <= 0 || (modelData.name && modelData.name.startsWith("special:"))
                                    property bool isFocused: Hyprland.focusedWorkspace?.id === modelData.id

                                    visible: !isSpecial
                                    Layout.preferredWidth: isSpecial ? 0 : (isFocused ? 28 : 18)
                                    Layout.preferredHeight: isSpecial ? 0 : 22
                                    radius: 8
                                    color: isFocused ? Colors.primary : Colors.surfaceVariant

                                    Behavior on Layout.preferredWidth {
                                        enabled: !parent.isSpecial
                                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                                    }
                                    Behavior on color {
                                        ColorAnimation { duration: 180 }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.id
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: parent.isFocused ? Colors.primaryText : Colors.text
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = '${modelData.id}' })`)
                                        onWheel: (wheel) => {
                                            if (wheel.angleDelta.y > 0) {
                                                Hyprland.dispatch("hl.dsp.focus({ workspace = 'e-1' })")
                                            } else if (wheel.angleDelta.y < 0) {
                                                Hyprland.dispatch("hl.dsp.focus({ workspace = 'e+1' })")
                                            }
                                        }
                                    }
                                }
                            }

                            WheelHandler {
                                onWheel: (event) => {
                                    if (event.angleDelta.y > 0) {
                                        Hyprland.dispatch("hl.dsp.focus({ workspace = 'e-1' })")
                                    } else if (event.angleDelta.y < 0) {
                                        Hyprland.dispatch("hl.dsp.focus({ workspace = 'e+1' })")
                                    }
                                }
                            }
                        }

                        // MPRIS Media Module
                        Rectangle {
                            id: mprisContainer
                            Layout.preferredHeight: 26
                            Layout.maximumWidth: 250
                            Layout.preferredWidth: mprisLayout.implicitWidth + 16
                            Layout.leftMargin: 4

                            // Solo visible si hay al menos un reproductor
                            visible: Mpris.players.values.length > 0
                            radius: 8
                            color: Colors.surfaceVariant

                            // Prefiere el reproductor que está sonando; si no, el primero
                            property var player: {
                                const ps = Mpris.players.values
                                for (let i = 0; i < ps.length; i++) if (ps[i].isPlaying) return ps[i]
                                return ps.length > 0 ? ps[0] : null
                            }

                            RowLayout {
                                id: mprisLayout
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "\uf001"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 14
                                    color: Colors.primary
                                }

                                Text {
                                    text: {
                                        const p = mprisContainer.player
                                        if (!p) return ""
                                        return p.trackArtist ? (p.trackTitle + " - " + p.trackArtist) : p.trackTitle
                                    }
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                    color: Colors.text
                                    Layout.maximumWidth: 150
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: mprisContainer.player && mprisContainer.player.isPlaying ? "\uf04c" : "\uf04b"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 14
                                    color: Colors.primary

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (mprisContainer.player) mprisContainer.player.togglePlaying()
                                    }
                                }

                                Text {
                                    text: "\uf051"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 14
                                    color: Colors.primary

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (mprisContainer.player) mprisContainer.player.next()
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // --- DERECHA: Métricas, perfil, batería, wallpaper ---
                    RowLayout {
                        spacing: 8

                        // System Tray
                        Rectangle {
                            id: trayContainer
                            Layout.preferredHeight: 26

                            // Contar items activos (excluyendo applets dedicados)
                            readonly property int activeCount: {
                                const _ = trayRepeater.count
                                let count = 0
                                const items = SystemTray.items.values
                                for (let i = 0; i < items.length; i++) {
                                    const it = items[i]
                                    const k = ((it.id || "") + "|" + (it.title || "")).toLowerCase()
                                    if (k.indexOf("nm-applet") < 0 && k.indexOf("blueman") < 0) {
                                        count++
                                    }
                                }
                                return count
                            }

                            visible: activeCount > 0
                            Layout.preferredWidth: activeCount > 0 ? (activeCount * 18 + (activeCount - 1) * 6 + 12) : 0
                            radius: 8
                            color: Colors.surfaceVariant

                            RowLayout {
                                id: trayLayout
                                anchors.centerIn: parent
                                spacing: 6

                                Repeater {
                                    id: trayRepeater
                                    model: SystemTray.items

                                    Item {
                                        id: trayItem
                                        required property var modelData
                                        // Filtro por id y título (applets con botón dedicado)
                                        property bool isHiddenApplet: {
                                            const k = ((modelData.id || "") + "|" + (modelData.title || "")).toLowerCase()
                                            return k.indexOf("nm-applet") >= 0 || k.indexOf("blueman") >= 0
                                        }

                                        visible: !isHiddenApplet
                                        implicitWidth: visible ? 18 : 0
                                        implicitHeight: visible ? 18 : 0
                                        Layout.preferredWidth: visible ? 18 : 0
                                        Layout.preferredHeight: visible ? 18 : 0

                                        Image {
                                            anchors.fill: parent
                                            source: trayItem.modelData.icon
                                            sourceSize: Qt.size(18, 18)
                                            fillMode: Image.PreserveAspectFit
                                            visible: parent.visible
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: (mouse) => {
                                                const it = trayItem.modelData
                                                if (mouse.button === Qt.LeftButton && !it.onlyMenu) it.activate()
                                                else if (mouse.button === Qt.MiddleButton) it.secondaryActivate()
                                                else if (it.hasMenu) {
                                                    const p = trayItem.mapToItem(null, 0, trayItem.height + 6)
                                                    it.display(bar, p.x, p.y)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Píldora de hardware (CPU / Temp / RAM / Disco)
                        Rectangle {
                            Layout.preferredHeight: 26
                            Layout.preferredWidth: hwLayout.implicitWidth + 20
                            radius: 13
                            color: Colors.surfaceVariant

                            RowLayout {
                                id: hwLayout
                                anchors.centerIn: parent
                                spacing: 12

                                Repeater {
                                    model: [
                                        { icon: "\uf2db", label: bar.cpuUsage + "%" },
                                        { icon: "\uf2c9", label: bar.cpuTemp + "°C" },
                                        { icon: "\udb80\udf5b", label: bar.ramPercent + "%" },
                                        { icon: "\uf0a0", label: bar.diskPercent + "%" }
                                    ]
                                    RowLayout {
                                        required property var modelData
                                        spacing: 5
                                        Text {
                                            text: modelData.icon
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 13
                                            color: Colors.primary
                                        }
                                        Text {
                                            text: modelData.label
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: Colors.text
                                        }
                                    }
                                }
                            }
                        }

                        // Perfil de energía (clic para rotar)
                        Rectangle {
                            Layout.preferredHeight: 26
                            Layout.preferredWidth: profLayout.implicitWidth + 20
                            radius: 13
                            color: Colors.surfaceVariant

                            RowLayout {
                                id: profLayout
                                anchors.centerIn: parent
                                Text {
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: Colors.primary
                                    text: {
                                        if (bar.powerProfile === "performance") return "\uf0e7"
                                        if (bar.powerProfile === "power-saver") return "\uf06c"
                                        return "\uf24e"
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (bar.powerProfile === "balanced") cycleProfileProc.targetProfile = "performance"
                                    else if (bar.powerProfile === "performance") cycleProfileProc.targetProfile = "power-saver"
                                    else cycleProfileProc.targetProfile = "balanced"
                                    cycleProfileProc.running = true
                                }
                            }
                        }

                        // Wi-Fi
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 26
                            radius: 13
                            color: Colors.surfaceVariant

                            Text {
                                anchors.centerIn: parent
                                text: "\uf1eb"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                color: Colors.primary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: wifiProc.running = true
                            }
                        }

                        // Bluetooth
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 26
                            radius: 13
                            color: Colors.surfaceVariant

                            Text {
                                anchors.centerIn: parent
                                text: "\uf293"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                color: Colors.primary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: btProc.running = true
                            }
                        }

                        // Batería
                        Rectangle {
                            Layout.preferredHeight: 26
                            Layout.preferredWidth: batLayout.implicitWidth + 20
                            radius: 13
                            color: Colors.surfaceVariant

                            RowLayout {
                                id: batLayout
                                anchors.centerIn: parent
                                spacing: 5
                                Text {
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                    color: Colors.primary
                                    text: {
                                        if (bar.batteryStatus === "Charging") return "\uf0e7"
                                        const c = parseInt(bar.batteryCapacity)
                                        if (c > 80) return "\uf240"
                                        if (c > 60) return "\uf241"
                                        if (c > 40) return "\uf242"
                                        if (c > 20) return "\uf243"
                                        return "\uf244"
                                    }
                                }
                                Text {
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: Colors.text
                                    text: bar.batteryCapacity + "%"
                                }
                            }
                        }

                        // Selector de wallpaper
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 26
                            radius: 13
                            color: Colors.surfaceVariant

                            Text {
                                anchors.centerIn: parent
                                text: "\uf03e"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                color: Colors.primary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: wallLauncherProc.running = true
                            }
                        }
                    }
                }
            }
        }
    }
}
