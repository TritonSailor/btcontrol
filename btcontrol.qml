/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Copyright (C) 2013 BlackBerry Limited. All rights reserved.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the examples of the QtBluetooth module.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.5
import QtBluetooth 5.2
import QtQuick.Controls 1.4
//import QtQuick.Controls.Styles 1.4

Item {
    id: top

    property BluetoothService currentService
    property bool serviceFound: false
    property string remoteDeviceName: ""

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
    }

    BluetoothDiscoveryModel {
        id: btModel
        running: true
        uuidFilter: "00001101-0000-1000-8000-00805f9b34fb"
        remoteAddress: "98:D3:31:20:4A:5C"
        //discoveryMode: BluetoothDiscoveryModel.DeviceDiscovery
        discoveryMode: BluetoothDiscoveryModel.MinimalServiceDiscovery
        onDiscoveryModeChanged: console.log("Discovery mode: " + discoveryMode)
        //onServiceDiscovered: console.log("Found new service " + service.deviceAddress + " " + service.deviceName + " " + service.serviceName);

        onServiceDiscovered: {
            if (serviceFound)
                return
            serviceFound = true
            //console.log(service)
            console.log("Found new service " + service.deviceAddress + " " + service.deviceName + " " + service.serviceName);
            //searchBox.appendText("\nConnecting to server...")
            console.log("\nConnecting to server...")
            remoteDeviceName = service.deviceName
            socket.setService(service)
        }

        onDeviceDiscovered: console.log("New device: " + device)
        onErrorChanged: {
                switch (btModel.error) {
                case BluetoothDiscoveryModel.PoweredOffError:
                    console.log("Error: Bluetooth device not turned on"); break;
                case BluetoothDiscoveryModel.InputOutputError:
                    console.log("Error: Bluetooth I/O Error"); break;
                case BluetoothDiscoveryModel.InvalidBluetoothAdapterError:
                    console.log("Error: Invalid Bluetooth Adapter Error"); break;
                case BluetoothDiscoveryModel.NoError:
                    break;
                default:
                    console.log("Error: Unknown Error"); break;
                }
        }
   }

  /*  BluetoothService {
        //id: defaultAdapter
        deviceAddress: "98:D3:31:20:4A:5C"
        serviceName: "Dev A"
        serviceUuid: "00001101-0000-1000-8000-00805f9b34fb"
        serviceProtocol: BluetoothService.RfcommProtocol

    }*/

    BluetoothSocket {
        id: socket
        connected: true
        onConnectedChanged: {
            if(connected) console.log("Connected")
            else console.log("Disconnected")
        }
        //onSocketStateChanged: {
            //console.log("Connected to server")
            //top.state = "chatActive"
        //}
    }
    /*BluetoothSocket {
        id: serialModel
        connected: false
        service: service
        onConnectedChanged: console.log("Connected")
    }*/

    function sendMessage(data)
    {
        // toogle focus to force end of input method composer
        //var hasFocus = input.focus;
        //input.focus = false;

        //var data = input.text
        //var data = "1"

        //input.clear()
        //chatContent.append({content: "Me: " + data})
        //! [BluetoothSocket-5]
        socket.stringData = data
        //! [BluetoothSocket-5]
        //chatView.positionViewAtEnd()

        //input.focus = hasFocus;
    }
    Rectangle {
        id: busy
        width: top.width * 0.7;
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: top.top;
        height: text.height*1.2;
        radius: 5
        color: "#1c56f3"
        visible: btModel.running

        Text {
            id: text
            text: "Scanning"
            font.bold: true
            font.pointSize: 20
            anchors.centerIn: parent
        }

        SequentialAnimation on color {
            id: busyThrobber
            ColorAnimation { easing.type: Easing.InOutSine; from: "#1c56f3"; to: "white"; duration: 1000; }
            ColorAnimation { easing.type: Easing.InOutSine; to: "#1c56f3"; from: "white"; duration: 1000 }
            loops: Animation.Infinite
        }
    }

    ListView {
        id: mainList
        width: top.width
        anchors.top: busy.bottom
        anchors.bottom: conButton.bottom
        anchors.bottomMargin: 10
        anchors.topMargin: 10
        clip: true

        model: btModel
        delegate: Rectangle {
            id: btDelegate
            width: parent.width
            height: column.height + 10

            property bool expended: false;
            clip: true
            Image {
                id: bticon
                source: "qrc:/default.png";
                width: bttext.height;
                height: bttext.height;
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 5
            }

            Column {
                id: column
                anchors.left: bticon.right
                anchors.leftMargin: 5
                Text {
                    id: bttext
                    text: deviceName ? deviceName : name
                    font.family: "FreeSerif"
                    font.pointSize: 16
                }

                Text {
                    id: details
                    function get_details(s) {
                        if (btModel.discoveryMode == BluetoothDiscoveryModel.DeviceDiscovery) {
                            //We are doing a device discovery
                            var str = "Address: " + remoteAddress;
                            return str;
                        } else {
                            //var str = "Address: " + s.deviceAddress;
                            if (s.deviceAddress) var str = "Address: " + s.deviceAddress;
                            if (s.serviceName) { str += "<br>Service: " + s.serviceName; }
                            if (s.serviceDescription) { str += "<br>Description: " + s.serviceDescription; }
                            if (s.serviceProtocol) { str += "<br>Protocol: " + s.serviceProtocol; }
                            return str;
                        }
                    }
                    visible: opacity !== 0
                    opacity: btDelegate.expended ? 1 : 0.0
                    text: get_details(service)
                    font.family: "FreeSerif"
                    font.pointSize: 14
                    Behavior on opacity {
                        NumberAnimation { duration: 200}
                    }
                }
            }
            Behavior on height { NumberAnimation { duration: 200} }

            MouseArea {
                anchors.fill: parent
                onClicked: btDelegate.expended = !btDelegate.expended
            }
        }
        focus: true
    }

    Button2 {
        id: conButton
        width: top.width*0.9
        //mdButton has longest text
        height: mdButton.height
        anchors.bottom: buttonGroup3.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        //spacing: 15
        text: (socket.connected) ? "Disconnect" : "Connect"
        //onClicked: socket.connected = true
        onClicked: {
        if (socket.connected) socket.connected = false
        else socket.connected = true
        }
    }

    Row {
        id: buttonGroup
        property var activeButton: devButton

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        spacing: 15

        ButtonOrange {
            id: fdButton
            width: top.width/3*0.9
            height: mdButton.height
            property bool orgLED: false
            //mdButton has longest text
            text: (orgLED) ? "Off": "On"
            onClicked: {
                if (orgLED) {
                    fdButton.spread = 0.1
                    sendMessage("A")
                }
                else {
                    spread = 0.3
                    sendMessage("a")
                }
                orgLED = !orgLED
            }
        }
        Button {
            id: mdButton
            width: top.width/3*0.9
            text: "Minimal Discovery"
            onClicked: {
                btModel.discoveryMode = BluetoothDiscoveryModel.MinimalServiceDiscovery
                btModel.running = false
                btModel.running = true
            }
        }
        Button {
            id: devButton
            width: top.width/3*0.9
            //mdButton has longest text
            height: mdButton.height
            text: "Device Discovery"
            onClicked: {
                btModel.discoveryMode = BluetoothDiscoveryModel.DeviceDiscovery
                btModel.running = false
                btModel.running = true
            }
        }
    }

    Row {
        id: buttonGroup2
        property var activeButton: devButton

        anchors.bottom: buttonGroup.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        spacing: 15

        /*Button2 {
            id: conButton
            width: top.width/3*0.9
            //mdButton has longest text
            height: mdButton.height
            text: (socket.connected) ? "Disconnect" : "Connect"
            //onClicked: socket.connected = true
            onClicked: {
            if (socket.connected) socket.connected = false
            else socket.connected = true
            }
        }*/
        ButtonOrange {
            id: orgButtonCycle
            width: top.width/3*0.9
            height: mdButton.height
            property bool orgLED: false
            //mdButton has longest text
            text: (orgLED) ? "Blink": "Fade"
            onClicked: {
                if (orgLED) {
                    orgButtonCycle.spread = 0.1
                    sendMessage("h")
                }
                else {
                    spread = 0.3
                    sendMessage("H")
                }
                orgLED = !orgLED
            }
        }
        Button2 {
            id: discButton
            width: top.width/3*0.9
            height: mdButton.height
            text: "Blink All"
            onClicked: sendMessage("hjkl;")
        }
        Button2 {
            id: txButton
            width: top.width/3*0.9
            //mdButton has longest text
            height: mdButton.height
            text: "Chase Fade"
            onClicked: sendMessage("1")
        }
    }
    Row {
        id: buttonGroup3
        //property var activeButton: devButton

        anchors.bottom: buttonGroup2.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        spacing: 15

        Button2 {
            id: greenLEDButton
            width: top.width/3*0.9
            //mdButton has longest text
            height: mdButton.height
            color: "green"
            //text: "On"
            //onClicked: sendMessage("s")
            property bool greenLED: false
            text: (greenLED) ? "Off": "On"
            onClicked: {
                if (greenLED) {
                    greenLEDButton.spread = 0.1
                    sendMessage("S")
                }
                else {
                    greenLEDButton.spread = 0.3
                    sendMessage("s")
                }
                greenLED = !greenLED
            }
        }
        Button2 {
            id: allLEDButton
            width: top.width/3*0.9
            height: mdButton.height
            //text: "All On"
            //onClicked: sendMessage("asdf")
            property bool allLED: false
            text: (allLED) ? "All Off": "All On"
            onClicked: {
                if (allLED) {
                    allLEDButton.spread = 0.1
                    sendMessage("ASDFG")
                }
                else {
                    allLEDButton.spread = 0.3
                    sendMessage("asdfg")
                }
                allLED = !allLED
            }
        }
        Button2 {
            id: extOnButton
            width: top.width/3*0.9
            //mdButton has longest text
            height: mdButton.height
            //text: "Ext On"
            //onClicked: sendMessage("g")
            property bool extLED: false
            text: (extLED) ? "Ext Off": "Ext On"
            onClicked: {
                if (extLED) {
                    extOnButton.spread = 0.1
                    sendMessage("G")
                }
                else {
                    extOnButton.spread = 0.3
                    sendMessage("g")
                }
                extLED = !extLED
            }
        }
    }
}
