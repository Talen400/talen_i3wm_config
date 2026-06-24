import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.0
import SddmComponents 2.0

Rectangle {
    id: root
    width: sddm.primaryScreen.width
    height: sddm.primaryScreen.height
    color: "#0F0E17"

    property string fontFamily: "JetBrainsMono Nerd Font"

    // ── Background: wallpaper + blur + overlay ──
    Image {
        id: background
        source: "/usr/share/sddm/themes/simple-frieren/frieren.jpg"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: width
        sourceSize.height: height
    }

    FastBlur {
        anchors.fill: background
        source: background
        radius: 64
    }

    Rectangle {
        anchors.fill: parent
        color: "#0F0E17"
        opacity: 0.35
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
                    text: "🧙"
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
                KeyNavigation.tab: loginButton
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
            Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                Layout.topMargin: 4
                font.family: fontFamily
                font.pointSize: 13
                font.bold: true
                KeyNavigation.tab: sessionSelector
                Keys.onReturnPressed: login()

                background: Rectangle {
                    radius: 10
                    color: loginButton.hovered ? "#C0A0FF" : "#A77BFF"
                }

                contentItem: Text {
                    text: "Sign In"
                    font: loginButton.font
                    color: "#0F0E17"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: login()
            }

            // ── Session selector ──
            ComboBox {
                id: sessionSelector
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                font.family: fontFamily
                font.pointSize: 10
                model: sddm.sessions
                textRole: "name"
                currentIndex: {
                    var idx = 0
                    for (var i = 0; i < sddm.sessions.length; i++) {
                        if (sddm.sessions[i].name.toLowerCase().indexOf("i3") !== -1) {
                            idx = i
                            break
                        }
                    }
                    return idx
                }

                background: Rectangle {
                    radius: 8
                    color: "#0F0E17"
                    border.color: sessionSelector.activeFocus ? "#A77BFF" : "#444466"
                    border.width: sessionSelector.activeFocus ? 2 : 1
                }

                contentItem: Text {
                    text: sessionSelector.displayText
                    font: sessionSelector.font
                    color: "#E0E0E0"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }

                indicator: Canvas {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    width: 10
                    height: 6
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.fillStyle = "#A77BFF"
                        ctx.moveTo(0, 0)
                        ctx.lineTo(width / 2, height)
                        ctx.lineTo(width, 0)
                        ctx.closePath()
                        ctx.fill()
                    }
                }

                delegate: ItemDelegate {
                    width: sessionSelector.width
                    contentItem: Text {
                        text: model.name
                        font: sessionSelector.font
                        color: highlighted ? "#0F0E17" : "#E0E0E0"
                        leftPadding: 10
                    }
                    highlighted: sessionSelector.highlightedIndex === index
                    background: Rectangle {
                        color: highlighted ? "#A77BFF" : "#1A1630"
                    }
                }

                popup: Popup {
                    y: sessionSelector.height + 2
                    width: sessionSelector.width
                    implicitHeight: Math.min(contentItem.implicitHeight, 200)
                    padding: 1

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: sessionSelector.popup.visible ? sessionSelector.delegateModel : null
                        currentIndex: sessionSelector.highlightedIndex
                        ScrollIndicator.vertical: ScrollIndicator {}
                    }

                    background: Rectangle {
                        color: "#1A1630"
                        radius: 8
                        border.color: "#A77BFF"
                        border.width: 1
                    }
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
                    text: "⏻"
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
                    text: "↻"
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
        sddm.login(userInput.text, passwordInput.text, sessionSelector.currentIndex)
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
