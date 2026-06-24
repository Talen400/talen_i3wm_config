import QtQuick 2.11
import QtQuick.Controls 2.11
import QtQuick.Layouts 1.11
import SddmComponents 2.0

Rectangle {
    id: root
    width: sddm.primaryScreen.width
    height: sddm.primaryScreen.height
    color: "#0F0E17"

    property string fontFamily: "JetBrainsMono Nerd Font"

    // ── Background: wallpaper + dark overlay (no GPU blur) ──
    Image {
        id: background
        source: "/usr/share/sddm/themes/simple-frieren/frieren.jpg"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Rectangle {
        anchors.fill: parent
        color: "#0F0E17"
        opacity: 0.55
    }

    // ── Clock ──
    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.12
        spacing: 4

        Text {
            id: timeDisplay
            Layout.alignment: Qt.AlignHCenter
            font.family: fontFamily
            font.pointSize: 56
            font.weight: Font.Light
            color: "#FFFFFF"
            text: new Date().toLocaleTimeString(Qt.locale(), "HH:mm")

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: parent.text = new Date().toLocaleTimeString(Qt.locale(), "HH:mm")
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            font.family: fontFamily
            font.pointSize: 14
            color: "#E0E0E0"
            text: new Date().toLocaleDateString(Qt.locale(), "dddd, d MMMM")

            Timer {
                interval: 60000
                running: true
                repeat: true
                onTriggered: parent.text = new Date().toLocaleDateString(Qt.locale(), "dddd, d MMMM")
            }
        }
    }

    // ── Login Box ──
    Rectangle {
        id: loginBox
        width: 380
        height: 360
        anchors.centerIn: parent
        color: "#1A1630"
        radius: 16
        border.color: "#A77BFF"
        border.width: 2

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalInset
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 48
            spacing: 14

            Item { Layout.preferredHeight: 4 }

            // ── Avatar ──
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 72
                height: 72
                radius: 36
                color: "#A77BFF"

                Text {
                    anchors.centerIn: parent
                    text: "\uD83E\uDDD9"
                    font.pointSize: 32
                }
            }

            Item { Layout.preferredHeight: 4 }

            // ── Username field ──
            TextField {
                id: userInput
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                placeholderText: "Username"
                font.family: fontFamily
                font.pointSize: 12
                color: "#E0E0E0"
                focus: true
                leftPadding: 14
                KeyNavigation.tab: passwordInput
                Keys.onReturnPressed: login()

                background: Rectangle {
                    radius: 10
                    color: "#0F0E17"
                    border.color: userInput.activeFocus ? "#7DC4E4" : "#444466"
                    border.width: userInput.activeFocus ? 2 : 1
                }

                placeholderTextColor: "#888888"
            }

            // ── Password field ──
            TextField {
                id: passwordInput
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                placeholderText: "Password"
                echoMode: TextInput.Password
                font.family: fontFamily
                font.pointSize: 14
                color: "#E0E0E0"
                leftPadding: 14
                KeyNavigation.tab: loginBtn
                Keys.onReturnPressed: login()

                background: Rectangle {
                    radius: 10
                    color: "#0F0E17"
                    border.color: passwordInput.activeFocus ? "#7DC4E4" : "#444466"
                    border.width: passwordInput.activeFocus ? 2 : 1
                }

                placeholderTextColor: "#888888"
            }

            // ── Sign In button ──
            Rectangle {
                id: loginBtn
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                Layout.topMargin: 4
                radius: 10
                color: loginBtnMouse.containsMouse ? "#C0A0FF" : "#A77BFF"
                focus: true
                Keys.onReturnPressed: login()

                Text {
                    anchors.centerIn: parent
                    text: "Sign In"
                    font.family: fontFamily
                    font.pointSize: 13
                    font.bold: true
                    color: "#0F0E17"
                }

                MouseArea {
                    id: loginBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: login()
                    cursorShape: Qt.PointingHandCursor
                }
            }

            // ── Session selector ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                radius: 8
                color: "#0F0E17"
                border.color: "#444466"
                border.width: 1

                Text {
                    id: sessionText
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Session: i3"
                    font.family: fontFamily
                    font.pointSize: 10
                    color: "#E0E0E0"
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\u25BC"
                    color: "#A77BFF"
                    font.pointSize: 8
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var sessions = sddm.sessions
                        var current = -1
                        for (var i = 0; i < sessions.length; i++) {
                            parent.forceActiveFocus()
                            if (sessions[i].name === sessionText.text.replace("Session: ", "")) {
                                current = i
                                break
                            }
                        }
                        var next = (current + 1) % sessions.length
                        sessionText.text = "Session: " + sessions[next].name
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }

            // ── Error message ──
            Text {
                id: errorMessage
                Layout.fillWidth: true
                color: "#FF6B9D"
                font.family: fontFamily
                font.pointSize: 10
                horizontalAlignment: Text.AlignHCenter
                visible: false
                wrapMode: Text.WordWrap
            }

            Item { Layout.preferredHeight: 2 }
        }
    }

    // ── Power buttons ──
    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        spacing: 24

        Rectangle {
            width: 100
            height: 64
            radius: 14
            color: shutdownMouse.containsMouse ? "#A77BFF" : "#1A1630"
            border.color: "#A77BFF"
            border.width: 1
            opacity: shutdownMouse.containsMouse ? 1 : 0.8

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "\u23F1"
                    color: "#E0E0E0"
                    font.pointSize: 20
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Shut Down"
                    color: "#E0E0E0"
                    font.family: fontFamily
                    font.pointSize: 10
                }
            }

            MouseArea {
                id: shutdownMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: sddm.powerOff()
                cursorShape: Qt.PointingHandCursor
            }
        }

        Rectangle {
            width: 100
            height: 64
            radius: 14
            color: rebootMouse.containsMouse ? "#A77BFF" : "#1A1630"
            border.color: "#A77BFF"
            border.width: 1
            opacity: rebootMouse.containsMouse ? 1 : 0.8

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "\u21BB"
                    color: "#E0E0E0"
                    font.pointSize: 20
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Reboot"
                    color: "#E0E0E0"
                    font.family: fontFamily
                    font.pointSize: 10
                }
            }

            MouseArea {
                id: rebootMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: sddm.reboot()
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    // ── Login function ──
    function login() {
        errorMessage.visible = false
        errorMessage.text = ""
        var sessionName = sessionText.text.replace("Session: ", "")
        for (var i = 0; i < sddm.sessions.length; i++) {
            if (sddm.sessions[i].name === sessionName) {
                sddm.login(userInput.text, passwordInput.text, i)
                return
            }
        }
        sddm.login(userInput.text, passwordInput.text, 0)
    }

    Connections {
        target: sddm
        onLoginSucceeded: {}
        onLoginFailed: {
            errorMessage.text = "Invalid username or password"
            errorMessage.visible = true
            passwordInput.text = ""
            passwordInput.focus = true
        }
    }
}
