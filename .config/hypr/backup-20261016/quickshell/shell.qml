import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
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

            // Estados reactivos de batería y perfil energético
            property string powerProfile: "balanced"
            property string batteryCapacity: "100"

            Process {
                id: getProfileProc
                command: ["powerprofilesctl", "get"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: bar.powerProfile = this.text.trim()
                }
            }

            Process {
                id: getBatProc
                command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1 || echo 100"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: bar.batteryCapacity = this.text.trim()
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
                command: ["sh", "-c", "~/.config/hypr/scripts/wallpaper-selector.sh"]
            }

            Timer {
                interval: 5000
                running: true
                repeat: true
                onTriggered: {
                    getProfileProc.running = true
                    getBatProc.running = true
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 6
                anchors.bottomMargin: 0
                radius: 12
                color: Colors.background
                border.color: Colors.surfaceVariant
                border.width: 1

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

                        Repeater {
                            model: Hyprland.workspaces

                            Rectangle {
                                required property var modelData
                                property bool isFocused: Hyprland.focusedWorkspace?.id === modelData.id

                                Layout.preferredWidth: isFocused ? 28 : 18
                                Layout.preferredHeight: 22
                                radius: 8
                                color: isFocused ? Colors.primary : Colors.surfaceVariant

                                Behavior on Layout.preferredWidth {
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
                                    onClicked: Hyprland.dispatch("workspace " + modelData.id)
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // --- CENTRO: Reloj ---
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

                    Item { Layout.fillWidth: true }

                    // --- DERECHA: Wallpaper y Selector de Batería ---
                    RowLayout {
                        spacing: 10

                        // Botón Selector de Wallpaper
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 26
                            radius: 8
                            color: Colors.surfaceVariant

                            Text {
                                anchors.centerIn: parent
                                text: ""
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

                        // Píldora Interactiva de Batería y Perfil de Consumo
                        Rectangle {
                            Layout.preferredHeight: 26
                            Layout.preferredWidth: batLayout.implicitWidth + 20
                            radius: 8
                            color: Colors.surfaceVariant

                            RowLayout {
                                id: batLayout
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                    color: Colors.primary
                                    text: {
                                        if (bar.powerProfile === "performance") return " Rendimiento"
                                        if (bar.powerProfile === "power-saver") return " Ahorro"
                                        return " Equilibrado"
                                    }
                                }

                                Text {
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: Colors.text
                                    text: "• " + bar.batteryCapacity + "%"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (bar.powerProfile === "balanced") {
                                        cycleProfileProc.targetProfile = "performance"
                                    } else if (bar.powerProfile === "performance") {
                                        cycleProfileProc.targetProfile = "power-saver"
                                    } else {
                                        cycleProfileProc.targetProfile = "balanced"
                                    }
                                    cycleProfileProc.running = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
