import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../imports"

ColumnLayout {
    id: chatColumn
    spacing: 0
    anchors.left: contactsColumn.right
    anchors.leftMargin: 0
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 0
    anchors.top: parent.top
    anchors.topMargin: 0

    RowLayout {
        id: chatContainer
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop

        Component {
            id: chatLogViewDelegate
            Rectangle {
                id: chatBox
                height: 60 + chatText.height
                color: "#00000000"
                border.color: "#00000000"
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.fillWidth: true
                width: chatLogView.width

                Image {
                    id: chatImage
                    width: 30
                    height: 30
                    anchors.left: !isCurrentUser ? parent.left : undefined
                    anchors.leftMargin: !isCurrentUser ? Theme.padding : 0
                    anchors.right: !isCurrentUser ? undefined : parent.right
                    anchors.rightMargin: !isCurrentUser ? 0 : Theme.padding
                    anchors.top: parent.top
                    anchors.topMargin: Theme.padding
                    fillMode: Image.PreserveAspectFit
                    source: identicon
                }

                TextEdit {
                    id: chatName
                    text: userName
                    anchors.top: parent.top
                    anchors.topMargin: 22
                    anchors.left: !isCurrentUser ? chatImage.right : undefined
                    anchors.leftMargin: Theme.padding
                    anchors.right: !isCurrentUser ? undefined : chatImage.left
                    anchors.rightMargin: !isCurrentUser ? 0 : Theme.padding
                    font.bold: true
                    font.pixelSize: 14
                    readOnly: true
                    wrapMode: Text.WordWrap
                    selectByMouse: true
                }

                TextEdit {
                    id: chatText
                    text: message
                    horizontalAlignment: !isCurrentUser ? Text.AlignLeft : Text.AlignRight
                    font.family: "Inter"
                    wrapMode: Text.WordWrap
                    anchors.right: !isCurrentUser ? parent.right : chatName.right
                    anchors.rightMargin: !isCurrentUser ? 60 : 0
                    anchors.left: !isCurrentUser ? chatName.left : parent.left
                    anchors.leftMargin: !isCurrentUser ? 0 : 60
                    anchors.top: chatName.bottom
                    anchors.topMargin: Theme.padding
                    font.pixelSize: 14
                    readOnly: true
                    selectByMouse: true
                    Layout.fillWidth: true
                }

                TextEdit {
                    id: chatTime
                    color: Theme.darkGrey
                    font.family: "Inter"
                    text: timestamp
                    anchors.top: chatText.bottom
                    anchors.bottomMargin: Theme.padding
                    anchors.right: !isCurrentUser ? parent.right : undefined
                    anchors.rightMargin: !isCurrentUser ? Theme.padding : 0
                    anchors.left: !isCurrentUser ? undefined : parent.left
                    anchors.leftMargin: !isCurrentUser ? 0 : Theme.padding
                    font.pixelSize: 10
                    readOnly: true
                    selectByMouse: true
                }
            }
        }

        ListView {
            id: chatLogView
            anchors.fill: parent
            model: chatsModel.messageList
            Layout.fillWidth: true
            Layout.fillHeight: true
            delegate: chatLogViewDelegate
            highlightFollowsCurrentItem: true
            onCountChanged: {
                if (!this.atYEnd) {
                    // User has scrolled up, we don't want to scroll back
                    return;
                }

                // positionViewAtEnd doesn't work well. Instead, we use highlightFollowsCurrentItem
                // and set the current Item/Index to the latest item
                while (this.currentIndex < this.count - 1) {
                    this.incrementCurrentIndex()
                }

            }
        }
    }

    RowLayout {
        id: chatInputContainer
        height: 70
        Layout.fillWidth: true
        Layout.bottomMargin: 0
        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
        transformOrigin: Item.Bottom

        Rectangle {
            id: element2
            width: 200
            height: 70
            Layout.fillWidth: true
            color: "white"
            border.width: 0

            Rectangle {
                id: rectangle
                color: "#00000000"
                border.color: Theme.grey
                anchors.fill: parent

                Button {
                    id: chatSendBtn
                    x: 100
                    width: 30
                    height: 30
                    text: "\u2191"
                    font.bold: true
                    font.pointSize: 12
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    onClicked: {
                        chatsModel.onSend(txtData.text)
                        txtData.text = ""
                    }
                    enabled: txtData.text !== ""
                    background: Rectangle {
                        color: parent.enabled ? Theme.blue : Theme.grey
                        radius: 50
                    }
                }

                TextField {
                    id: txtData
                    text: ""
                    leftPadding: 0
                    padding: 0
                    font.pixelSize: 14
                    placeholderText: qsTr("Type a message...")
                    anchors.right: chatSendBtn.left
                    anchors.rightMargin: 16
                    anchors.top: parent.top
                    anchors.topMargin: 24
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    Keys.onEnterPressed: {
                        chatsModel.onSend(txtData.text)
                        txtData.text = ""
                    }
                    Keys.onReturnPressed: {
                        chatsModel.onSend(txtData.text)
                        txtData.text = ""
                    }
                    background: Rectangle {
                        color: "#00000000"
                    }
                }

                MouseArea {
                    id: mouseArea1
                    anchors.rightMargin: 50
                    anchors.fill: parent
                    onClicked : {
                        txtData.forceActiveFocus(Qt.MouseFocusReason)
                    }
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;height:770;width:800}
}
##^##*/