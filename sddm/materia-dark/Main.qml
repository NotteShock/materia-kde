import QtQuick 2.8
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import SddmComponents 2.0 as SddmComponents
import QtQuick.Controls.Material 2.1
import "components"

Rectangle {
    width: 640
    height: 480

    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true
    
//     hack QtQuick.VirtualKeyboard
    Loader {
        id: inputPanel
        property bool keyboardActive: false
        source: "components/VirtualKeyboard.qml"
    }

    SddmComponents.TextConstants {
        id: textConstants
    }

    Connections {
        target: sddm
        onLoginSucceeded: {}
        onLoginFailed: {
            password.placeholderText = qsTr("Login failed")
            password.placeholderTextColor = "#f44336"
            password.text = ""
            password.focus = true
            errorMsgContainer.visible = true
        }
    }

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop

        Binding on source {
            when: config.backgroundImage !== undefined
            value: config.backgroundImage
        }
    }

    Rectangle {
        id: panel
        color: "#282828"
        height: 32
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
    }

    DropShadow {
        anchors.fill: panel
        horizontalOffset: 0
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#70000000"
        source: panel
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.topMargin: 5

        Item {

            ImgButton {
                id: shutdownButton
                width: 22
                height: 22
                normalImg: "images/system-shutdown.svg"
                hoverImg: "images/system-shutdown-hover.svg"
                pressImg: "images/system-shutdown-pressed.svg"
                onClicked: sddm.powerOff()
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 60
        anchors.topMargin: 5
        Item {

            ImgButton {
                id: rebootButton
                width: 22
                height: 22
                normalImg: "images/system-reboot.svg"
                hoverImg: "images/system-reboot-hover.svg"
                pressImg: "images/system-reboot-pressed.svg"
                onClicked: sddm.reboot()
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 90
        anchors.topMargin: 5
        Item {

            ImgButton {
                id: suspendButton
                width: 22
                height: 22
                normalImg: "images/system-suspend.svg"
                hoverImg: "images/system-suspend-hover.svg"
                pressImg: "images/system-suspend-pressed.svg"
                onClicked: sddm.suspend()
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 100
        anchors.topMargin: 5
        Text {
            id: timelb
            text: Qt.formatDateTime(new Date(), "HH:mm")
            color: "#dfdfdf"
            font.pointSize: 11
        }
    }

    Timer {
        id: timetr
        interval: 500
        repeat: true
        onTriggered: {
            timelb.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }
    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 150
        anchors.topMargin: 5
        Text {
            id: kb
            color: "#dfdfdf"
            text: keyboard.layouts[keyboard.currentLayout].shortName
            font.pointSize: 11
        }
    }

    Row {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.topMargin: 5
        Text {
            text: textConstants.welcomeText.arg(sddm.hostName)
            color: "#dfdfdf"
            font.pointSize: 11
        }
    }

    Dialog {
        id: dialog
        anchors.centerIn: parent
        closePolicy: Popup.NoAutoClose
        focus: true
        visible: true
        Material.theme: Material.Dark
        Material.accent: "#8ab4f8"

        Grid {
            columns: 1
            spacing: 10
            verticalItemAlignment: Grid.AlignVCenter
            horizontalItemAlignment: Grid.AlignHCenter

            ComboBox {
                id: user
                width: height * 8
                model: userModel
                textRole: "name"
                currentIndex: userModel.lastIndex

                delegate: MenuItem {
                    Material.theme: Material.Dark
                    Material.accent: "#8ab4f8"
                    width: ListView.view.width
                    text: user.textRole ? (Array.isArray(
                                               user.model) ? modelData[user.textRole] : model[user.textRole]) : modelData
                    Material.foreground: user.currentIndex === index ? ListView.view.contentItem.Material.accent : ListView.view.contentItem.Material.foreground
                    highlighted: user.highlightedIndex === index
                    hoverEnabled: user.hoverEnabled
                    onClicked: {
                        user.currentIndex = index
                        ulistview.currentIndex = index
                        user.popup.close()
                    }
                }
                popup: Popup {
                    Material.theme: Material.Dark
                    Material.accent: "#8ab4f8"
                    width: parent.width
                    height: parent.height * parent.count
                    implicitHeight: ulistview.contentHeight
                    margins: 0
                    contentItem: ListView {
                        id: ulistview
                        clip: true
                        anchors.fill: parent
                        model: user.model
                        spacing: 0
                        highlightFollowsCurrentItem: true
                        currentIndex: user.highlightedIndex
                        delegate: user.delegate
                    }
                }
            }

            TextField {
                id: password
                width: height * 8
                echoMode: TextInput.Password
                focus: true
                placeholderText: qsTr("Enter your password")
                onAccepted: sddm.login(user.currentText, password.text,
                                       session.index)
            }

            Keys.onPressed: {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    sddm.login(user.currentText, password.text, session.index)
                    event.accepted = true
                }
            }

            ComboBox {
                id: session
                width: height * 8
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex

                delegate: MenuItem {
                    Material.theme: Material.Dark
                    Material.accent: "#8ab4f8"
                    width: ListView.view.width
                    text: session.textRole ? (Array.isArray(
                                                  session.model) ? modelData[session.textRole] : model[session.textRole]) : modelData
                    Material.foreground: session.currentIndex === index ? ListView.view.contentItem.Material.accent : ListView.view.contentItem.Material.foreground
                    highlighted: session.highlightedIndex === index
                    hoverEnabled: session.hoverEnabled
                    onClicked: {
                        session.currentIndex = index
                        slistview.currentIndex = index
                        session.popup.close()
                    }
                }
                popup: Popup {
                    Material.theme: Material.Dark
                    Material.accent: "#8ab4f8"
                    width: parent.width
                    height: parent.height * parent.count
                    implicitHeight: slistview.contentHeight
                    margins: 0
                    contentItem: ListView {
                        id: slistview
                        clip: true
                        anchors.fill: parent
                        model: session.model
                        spacing: 0
                        highlightFollowsCurrentItem: true
                        currentIndex: session.highlightedIndex
                        delegate: session.delegate
                    }
                }
            }

            Button {
                id: login
                width: height * 8
                text: textConstants.login
                onClicked: sddm.login(user.currentText, password.text,
                                      session.index)
                highlighted: true
            }
        }
    }
}