import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup
    title: qsTr("Network")

    property string newNetwork: "";
 
    Column {
        id: column
        spacing: Style.current.padding
        width: parent.width

        ButtonGroup { id: networkSettings }

        Item {
            id: addNetwork
            width: parent.width
            height: addButton.height

            StatusRoundButton {
                id: addButton
                icon.name: "plusSign"
                size: "medium"
                anchors.verticalCenter: parent.verticalCenter
            }

            ButtonGroup {
                id: networkChainGroup
            }

            StyledText {
                id: usernameText
                text: qsTr("Add network")
                color: Style.current.blue
                anchors.left: addButton.right
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: addButton.verticalCenter
                font.pixelSize: 15
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: addNetworkPopup.open()
            }

            ModalPopup {
                id: addNetworkPopup
                title: qsTr("Add network")
                height: 600

                property string nameValidationError: ""
                property string rpcValidationError: ""
                property int networkId: 1;
                property string networkType: Constants.networkMainnet

                function validate() {
                    nameValidationError = ""
                    rpcValidationError = ""

                    if (nameInput.text === "") {
                        nameValidationError = qsTr("You need to enter a name")
                    }

                    if (rpcInput.text === "") {
                        rpcValidationError = qsTr("You need to enter the RPC endpoint URL")
                    } else if(!Utils.isURL(rpcInput.text)) {
                        rpcValidationError = qsTr("Invalid URL")
                    }

                    return !nameValidationError && !rpcValidationError
                }

                onOpened: {
                    nameInput.text = "";
                    rpcInput.text = "";
                    mainnetRadioBtn.checked = true;
                    addNetworkPopup.networkId = 1;
                    addNetworkPopup.networkType = Constants.networkMainnet;

                    nameValidationError = "";
                    rpcValidationError = "";
                }

                footer: StyledButton {
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.smallPadding
                    label: qsTr("Save")
                    anchors.bottom: parent.bottom
                    disabled: nameInput.text == "" || rpcInput.text == ""
                    onClicked: {
                        if (!addNetworkPopup.validate()) {
                            return;
                        }
                        profileModel.network.add(nameInput.text, rpcInput.text, addNetworkPopup.networkId, addNetworkPopup.networkType)
                        addNetworkPopup.close()
                    }
                }

                Input {
                    id: nameInput
                    label: qsTr("Name")
                    placeholderText: qsTr("Specify a name")
                    validationError: addNetworkPopup.nameValidationError
                }

                Input {
                    id: rpcInput
                    label: qsTr("RPC URL")
                    placeholderText: qsTr("Specify a RPC URL")
                    validationError: addNetworkPopup.rpcValidationError
                    anchors.top: nameInput.bottom
                    anchors.topMargin: Style.current.bigPadding
                }

                StatusSectionHeadline {
                    id: networkChainHeadline
                    text: qsTr("Network chain")
                    anchors.top: rpcInput.bottom
                    anchors.topMargin: Style.current.bigPadding
                }

                Column {
                    spacing: Style.current.padding
                    anchors.top: networkChainHeadline.bottom
                    anchors.topMargin: Style.current.smallPadding
                    anchors.left: parent.left
                    anchors.right: parent.right

                    RowLayout {
                        width: parent.width
                        StyledText {
                            text: qsTr("Main network")
                            font.pixelSize: 15
                        }

                        StatusRadioButton {
                            id: mainnetRadioBtn
                            Layout.alignment: Qt.AlignRight
                            ButtonGroup.group: networkChainGroup
                            rightPadding: 0
                            checked: true
                            onClicked: {
                                addNetworkPopup.networkId = 1;
                                addNetworkPopup.networkType = Constants.networkMainnet;
                            }
                        }
                    }

                    RowLayout {
                        width: parent.width
                        StyledText {
                            text: qsTr("Ropsten test network")
                            font.pixelSize: 15
                        }
                        StatusRadioButton {
                            id: ropstenRadioBtn
                            Layout.alignment: Qt.AlignRight
                            ButtonGroup.group: networkChainGroup
                            rightPadding: 0
                            onClicked: {
                                addNetworkPopup.networkId = 3;
                                addNetworkPopup.networkType = Constants.networkRopsten;
                            }
                        }
                    }

                    RowLayout {
                        width: parent.width
                        StyledText {
                            text: qsTr("Rinkeby test network")
                            font.pixelSize: 15
                        }
                        StatusRadioButton {
                            id: rinkebyRadioBtn
                            Layout.alignment: Qt.AlignRight
                            ButtonGroup.group: networkChainGroup
                            rightPadding: 0
                            onClicked: {
                                addNetworkPopup.networkId = 4;
                                addNetworkPopup.networkType = Constants.networkRinkeby;
                            }
                        }
                    }

                    RowLayout {
                        width: parent.width
                        StyledText {
                            text: qsTr("Custom")
                            font.pixelSize: 15
                        }
                        StatusRadioButton {
                            id: customRadioBtn
                            Layout.alignment: Qt.AlignRight
                            ButtonGroup.group: networkChainGroup
                            rightPadding: 0
                            onClicked: {
                                addNetworkPopup.networkId = 55; // TODO
                                addNetworkPopup.networkType = "";
                            }
                        }
                    }
                }
            }
        }

        StatusSectionHeadline {
            text: qsTr("Main networks")
        }

        NetworkRadioSelector {
            network: Constants.networkMainnet
        }

        NetworkRadioSelector {
            network: Constants.networkPOA
        }

        NetworkRadioSelector {
            network: Constants.networkXDai
        }

        StatusSectionHeadline {
            text: qsTr("Test networks")
        }

        NetworkRadioSelector {
            network: Constants.networkGoerli
        }

        NetworkRadioSelector {
            network: Constants.networkRinkeby
        }

        NetworkRadioSelector {
            network: Constants.networkRopsten
        }

        StatusSectionHeadline {
            text: qsTr("Custom Networks")
        }

        NetworkRadioSelector {
            network: "SOME NETWORK"
        }
    }

    StyledText {
        anchors.top: column.bottom
        anchors.topMargin: Style.current.padding
        //% "Under development\nNOTE: You will be logged out and all installed\nsticker packs will be removed and will\nneed to be reinstalled. Purchased sticker\npacks will not need to be re-purchased."
        text: qsTrId("under-development-nnote--you-will-be-logged-out-and-all-installed-nsticker-packs-will-be-removed-and-will-nneed-to-be-reinstalled--purchased-sticker-npacks-will-not-need-to-be-re-purchased-")
    }
}
