// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtCore
import QtQml
import SpecialProjectQML

pragma ComponentBehavior: Bound

ApplicationWindow {
    id: window
    width: 1080
    height: 720
    minimumWidth: 800
    minimumHeight: 600
    visible: true
    title: qsTr("Gem5 Visualizer")
    color: currentStyle.mainColor

    property BaseStyle currentStyle
    DarkTheme {
        id: darkTheme
    }
    LightTheme {
        id: lightTheme
    }
    BaseStyle {
        id: customTheme
        mainColor: settings.mainColor
        mainColorAlternative: settings.mainColorAlternative
        secondaryColor: settings.secondaryColor
        tertiaryColor: settings.tertiaryColor
        menuBorderColor: settings.menuBorderColor
        fetchColor: settings.fetchColor
        decodeColor: settings.decodeColor
        executeColor: settings.executeColor
        memoryColor: settings.memoryColor
        writebackColor: settings.writebackColor
        stallColor: settings.stallColor
        hexTransparencyValue: intToHex(settings.transparencyValue)
        transparencyValue: settings.transparencyValue
    }
    currentStyle: (  settings.theme === "darkTheme"
                   ? darkTheme
                   : settings.theme === "lightTheme"
                   ? lightTheme
                   : customTheme)

    Settings {
        id: settings
        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height

        property string theme: "darkTheme"
        property color mainColor: darkTheme.mainColor
        property color mainColorAlternative: darkTheme.mainColorAlternative
        property color secondaryColor: darkTheme.secondaryColor
        property color tertiaryColor: darkTheme.tertiaryColor
        property color menuBorderColor: darkTheme.menuBorderColor
        property string fetchColor: darkTheme.fetchColor
        property string decodeColor: darkTheme.decodeColor
        property string executeColor: darkTheme.executeColor
        property string memoryColor: darkTheme.memoryColor
        property string writebackColor: darkTheme.writebackColor
        property string stallColor: darkTheme.stallColor
        property real transparencyValue: darkTheme.transparencyValue
    }

    menuBar: MenuBar {
        id: menuBar
        Menu {
            title: qsTr("&File")
            Action {
                text: qsTr("&Open")
                onTriggered: {
                    parser.clearData();
                    fileSelector.open();
                }
            }
            Action {
                text: qsTr("&Close")
                onTriggered: {
                    mainContainer.visible = false;
                    parser.clearData();
                    matrixModel.setCC(0);
                    listModelRegister.setCC(0);
                    listModelStats.setCC(0);
                    rightGL.cc = 0;
                    textInput.text = 0;
                }
            }
            MenuSeparator {
                contentItem: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 1
                    color: window.currentStyle.menuBorderColor
                }
            }
            Action {
                text: qsTr("&Quit")
                onTriggered: Qt.quit();
            }

            delegate: CustomMenuItem {
                mainColor: window.currentStyle.mainColor
                secondaryColor: window.currentStyle.secondaryColor
                tertiaryColor: window.currentStyle.tertiaryColor
            }

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 20
                color: currentStyle.mainColor
                border.color: window.currentStyle.menuBorderColor
            }

        }
        Menu {
            title: qsTr("&Settings")
            delegate: CustomMenuItem {
                mainColor: window.currentStyle.mainColor
                secondaryColor: window.currentStyle.secondaryColor
                tertiaryColor: window.currentStyle.tertiaryColor
            }

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 20
                color: currentStyle.mainColor
                border.color: window.currentStyle.menuBorderColor
            }
            Action {
                text: "Themes"
                onTriggered: winld.active = true
            }
            MenuSeparator {}
            Action {
                    id: showGridAction
                    text: qsTr("Toggle grid lines")
                    onTriggered: {
                        rightGL.showGridlines = !rightGL.showGridlines
                    }
                }
        }
        Menu {
            title: qsTr("&Help")
            Action {
                text: qsTr("&About")
                onTriggered: aboutWin.active = true
            }
            Action {
                text: qsTr("Co&ntrols")
                onTriggered: controlsWin.active = true
            }

            delegate: CustomMenuItem {
                mainColor: window.currentStyle.mainColor
                secondaryColor: window.currentStyle.secondaryColor
                tertiaryColor: window.currentStyle.tertiaryColor
            }

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 20
                color: window.currentStyle.mainColor
                border.color: window.currentStyle.menuBorderColor
            }
        }

            delegate: MenuBarItem {
                id: menuBarItem

                contentItem: Text {
                    text: menuBar.formatMenuText(menuBarItem.text)
                    font: menuBarItem.font
                    textFormat: Text.RichText
                    color: menuBarItem.highlighted ? window.currentStyle.mainColor : window.currentStyle.secondaryColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    color: menuBarItem.highlighted ? window.currentStyle.tertiaryColor : "transparent"
                }
            }

        background: Rectangle {
            color: window.currentStyle.mainColorAlternative

            Rectangle {
                color: window.currentStyle.menuBorderColor
                width: parent.width
                height: mainContainer.visible ? 0 : 2
                anchors.bottom: parent.bottom
            }
        }

        function formatMenuText(input) {
            return input.replace(/&(.)/g, "<u>$1</u>");
        }
    }

    Loader {
            id: winld
            active: false
            sourceComponent: Window {
                title: qsTr("Themes")
                width: 900
                height: 600
                minimumWidth: 900
                minimumHeight: 600

                modality: Qt.WindowModal
                color: window.currentStyle.mainColor
                visible: true
                onClosing: winld.active = false

                ColumnLayout {
                    property int w: parent.width
                    property int h: parent.height

                    id: themeMainColLay
                    width: parent.width

                    Text {
                        text: "Select a theme or make your own"
                        font.bold: true
                        Layout.alignment: Qt.AlignCenter
                        font.pixelSize: 25
                        color: window.currentStyle.secondaryColor
                    }
                    CustomRadioButton {
                        id: radioButton1
                        textRB: "Light"
                        textColor: window.currentStyle.secondaryColor
                        checked: settings.theme === "lightTheme" ? true : false

                        onClicked: {
                            window.currentStyle = lightTheme
                            settings.theme = "lightTheme"
                        }
                    }
                    CustomRadioButton {
                        id: radioButton2
                        textRB: "Dark"
                        textColor: window.currentStyle.secondaryColor
                        checked: settings.theme === "darkTheme" ? true : false

                        onClicked: {
                            window.currentStyle = darkTheme
                            settings.theme = "darkTheme"
                        }
                    }
                    CustomRadioButton {
                        id: radioButton3
                        textRB: "Custom"
                        textColor: window.currentStyle.secondaryColor
                        checked: settings.theme === "customTheme" ? true : false

                        onClicked: {
                            window.currentStyle = customTheme
                            settings.theme = "customTheme"
                        }
                    }
                    Grid {
                        id: colorColumn
                        rowSpacing: 20
                        rows: themeMainColLay.w > 1620 ? 1 : 2

                        ColumnLayout {
                            id: colorColumn1
                            spacing: 10

                            ColorDialog {
                                id: colorPicker1
                                selectedColor: customTheme.mainColor
                                onAccepted: {
                                    settings.mainColor = selectedColor
                                }
                            }

                            Text {
                                text: "Main Color"
                                color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                            }
                            Rectangle {
                                color: customTheme.mainColor
                                border.width: 1.0
                                border.color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                Layout.preferredHeight: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        colorPicker1.open()
                                    }
                                }
                            }
                            Rectangle {
                                color: "transparent"
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 1
                            }
                        }
                        ColumnLayout {
                            id: colorColumn2
                            spacing: 10

                            ColorDialog {
                                id: colorPicker2
                                selectedColor: customTheme.secondaryColor
                                onAccepted: settings.secondaryColor = selectedColor
                            }

                            Text {
                                text: "Secondary Color"
                                color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                            }
                            Rectangle {
                                color: customTheme.secondaryColor
                                border.width: 1.0
                                border.color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                Layout.preferredHeight: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        colorPicker2.open()
                                    }
                                }
                            }
                            Rectangle {
                                color: "transparent"
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 1
                            }
                        }
                        ColumnLayout {
                            id: colorColumn3
                            spacing: 10

                            ColorDialog {
                                id: colorPicker3
                                selectedColor: customTheme.tertiaryColor
                                onAccepted: settings.tertiaryColor = selectedColor
                            }

                            Text {
                                text: "Tertiary Color"
                                color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                            }
                            Rectangle {
                                color: customTheme.tertiaryColor
                                border.width: 1.0
                                border.color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                Layout.preferredHeight: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        colorPicker3.open()
                                    }
                                }
                            }
                            Rectangle {
                                color: "transparent"
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 1
                            }
                        }
                        ColumnLayout {
                            id: colorColumn4
                            spacing: 10

                            ColorDialog {
                                id: colorPicker4
                                selectedColor: customTheme.mainColorAlternative
                                onAccepted: settings.mainColorAlternative = selectedColor
                            }

                            Text {
                                text: "Main Color Alternative"
                                color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                            }
                            Rectangle {
                                color: customTheme.mainColorAlternative
                                border.width: 1.0
                                border.color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                Layout.preferredHeight: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        colorPicker4.open()
                                    }
                                }
                            }
                            Rectangle {
                                color: "transparent"
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 1
                            }
                        }
                        ColumnLayout {
                            id: colorColumn5
                            spacing: 10

                            ColorDialog {
                                id: colorPicker5
                                selectedColor: customTheme.menuBorderColor
                                onAccepted: settings.menuBorderColor = selectedColor
                            }

                            Text {
                                text: "Menu Border Color"
                                color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                            }
                            Rectangle {
                                color: customTheme.menuBorderColor
                                border.width: 1.0
                                border.color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                Layout.preferredHeight: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        colorPicker5.open()
                                    }
                                }
                            }
                            Rectangle {
                                color: "transparent"
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 1
                            }
                        }
                        ColumnLayout {
                            id: colorColumn6
                            spacing: 10

                            ColorDialog {
                                id: colorPicker6
                                selectedColor: customTheme.computeTVColor("F")
                                onAccepted: settings.fetchColor = parser.colorToString(selectedColor)
                            }

                            Text {
                                text: "Fetch Color"
                                color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                            }
                            Rectangle {
                                color: customTheme.computeTVColor("F")
                                border.width: 1.0
                                border.color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                Layout.preferredHeight: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        colorPicker6.open()
                                    }
                                }
                            }
                            Rectangle {
                                color: "transparent"
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 1
                            }
                        }
                        ColumnLayout {
                            id: colorColumn7
                            spacing: 10

                            ColorDialog {
                                id: colorPicker7
                                selectedColor: customTheme.computeTVColor("D")
                                onAccepted: settings.decodeColor = parser.colorToString(selectedColor)
                            }

                            Text {
                                text: "Decode Color"
                                color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                            }
                            Rectangle {
                                color: customTheme.computeTVColor("D")
                                border.width: 1.0
                                border.color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                Layout.preferredHeight: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        colorPicker7.open()
                                    }
                                }
                            }
                            Rectangle {
                                color: "transparent"
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 1
                            }
                        }
                        ColumnLayout {
                            id: colorColumn8
                            spacing: 10

                            ColorDialog {
                                id: colorPicker8
                                selectedColor: customTheme.computeTVColor("E")
                                onAccepted: settings.executeColor = parser.colorToString(selectedColor)
                            }

                            Text {
                                text: "Execute Color"
                                color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                            }
                            Rectangle {
                                color: customTheme.computeTVColor("E")
                                border.width: 1.0
                                border.color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                Layout.preferredHeight: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        colorPicker8.open()
                                    }
                                }
                            }
                            Rectangle {
                                color: "transparent"
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 1
                            }
                        }
                        ColumnLayout {
                            id: colorColumn9
                            spacing: 10

                            ColorDialog {
                                id: colorPicker9
                                selectedColor: customTheme.computeTVColor("M")
                                onAccepted: settings.memoryColor = parser.colorToString(selectedColor)
                            }

                            Text {
                                text: "Memory Color"
                                color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                            }
                            Rectangle {
                                color: customTheme.computeTVColor("M")
                                border.width: 1.0
                                border.color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                Layout.preferredHeight: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        colorPicker9.open()
                                    }
                                }
                            }
                            Rectangle {
                                color: "transparent"
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 1
                            }
                        }
                        ColumnLayout {
                            id: colorColumn10
                            spacing: 10

                            ColorDialog {
                                id: colorPicker10
                                selectedColor: customTheme.computeTVColor("W")
                                onAccepted: settings.writebackColor = parser.colorToString(selectedColor)
                            }

                            Text {
                                text: "Writeback Color"
                                color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                            }
                            Rectangle {
                                color: customTheme.computeTVColor("W")
                                border.width: 1.0
                                border.color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                Layout.preferredHeight: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        colorPicker10.open()
                                    }
                                }
                            }
                            Rectangle {
                                color: "transparent"
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 1
                            }
                        }
                        ColumnLayout {
                            id: colorColumn11
                            spacing: 10

                            ColorDialog {
                                id: colorPicker11
                                selectedColor: customTheme.computeTVColor("s")
                                onAccepted: settings.stallColor = parser.colorToString(selectedColor)
                            }

                            Text {
                                text: "Stall Color"
                                color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                            }
                            Rectangle {
                                color: customTheme.computeTVColor("s")
                                border.width: 1.0
                                border.color: window.currentStyle.secondaryColor
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                Layout.preferredHeight: themeMainColLay.w/27 > 40 ? 40 : themeMainColLay.w/27
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        colorPicker11.open()
                                    }
                                }
                            }
                            Rectangle {
                                color: "transparent"
                                Layout.alignment: Qt.AlignCenter
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 1
                            }
                        }
                    }
                    Text {
                        text: "Blocks opacity"
                        color: window.currentStyle.secondaryColor
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Slider {
                        id: slider
                        from: 0.0
                        value: settings.transparencyValue
                        to: 100
                        stepSize: 5
                        leftPadding: 50
                        topPadding: 5
                        bottomPadding: 50
                        implicitWidth: themeMainColLay.w - 50
                        snapMode: Slider.SnapOnRelease

                        background: Rectangle {
                            x: slider.leftPadding
                            y: slider.topPadding + slider.availableHeight / 2 - height / 2
                            implicitWidth: 200
                            implicitHeight: 4
                            width: slider.availableWidth
                            height: implicitHeight
                            radius: 2
                            color: window.currentStyle.secondaryColor

                            Rectangle {
                                width: slider.visualPosition * parent.width
                                height: parent.height
                                color: window.currentStyle.tertiaryColor
                                radius: 2
                            }

                            Repeater {
                                id: sliderRepeater
                                model: (slider.to - slider.from) / slider.stepSize + 1
                                delegate: Column {
                                    required property int index
                                    x: (index * parent.width / (slider.to - slider.from) * slider.stepSize - width / 2)
                                    y: 0
                                    spacing: 2
                                    Rectangle {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 1
                                        height: 10
                                        color: window.currentStyle.secondaryColor
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        color: window.currentStyle.secondaryColor
                                        text: parent.index * slider.stepSize + slider.from
                                    }
                                }
                            }
                        }

                        handle: Rectangle {
                            x: slider.leftPadding - ((50 - slider.value)*(13/50)) + slider.visualPosition * (slider.availableWidth - width)
                            y: slider.topPadding + slider.availableHeight / 2 - height / 2
                            implicitWidth: 26
                            implicitHeight: 26
                            radius: 13
                            color: slider.pressed ? window.currentStyle.tertiaryColor : window.currentStyle.secondaryColor
                            border.color: window.currentStyle.mainColorAlternative
                        }
                        onPressedChanged: {
                            if(!slider.pressed) {
                                settings.transparencyValue = slider.value
                            }
                        }
                    }
                    Button {
                        id: button1
                        Layout.leftMargin: 10
                        Text {
                            text: "Reset"
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: button1.down ? window.currentStyle.mainColorAlternative : window.currentStyle.mainColor
                        }
                        background: Rectangle {
                            implicitWidth: 70
                            implicitHeight: 35
                            color: button1.pressed? Qt.darker(window.currentStyle.tertiaryColor, 1.1) : (button1.hovered? window.currentStyle.tertiaryColor : window.currentStyle.secondaryColor)
                            border.color: button1.down ? "#474747" : "#575757"
                            border.width: 1
                            radius: 2
                        }
                        onClicked: {
                            settings.mainColor = darkTheme.mainColor
                            settings.mainColorAlternative = darkTheme.mainColorAlternative
                            settings.secondaryColor = darkTheme.secondaryColor
                            settings.tertiaryColor = darkTheme.tertiaryColor
                            settings.menuBorderColor = darkTheme.menuBorderColor
                            settings.fetchColor = darkTheme.fetchColor
                            settings.decodeColor = darkTheme.decodeColor
                            settings.executeColor = darkTheme.executeColor
                            settings.memoryColor = darkTheme.memoryColor
                            settings.writebackColor = darkTheme.writebackColor
                            settings.stallColor = darkTheme.stallColor
                            settings.transparencyValue = darkTheme.transparencyValue
                        }
                    }
                }
            }
        }
    Loader {
        id: controlsWin
        active: false
        sourceComponent: Window {
            title: qsTr("Controls")
            width: 900
            height: 600
            minimumWidth: 900
            minimumHeight: 600
            maximumWidth: 900
            maximumHeight: 600

            modality: Qt.WindowModal
            color: window.currentStyle.mainColor
            visible: true
            onClosing: controlsWin.active = false

            Text {
                topPadding: 20
                leftPadding: 10
                text: "<b>Mouse drag</b>: lets you move around the grid in the central section and go up and down on the left <br>and on the right.<br><br><b>Mouse wheel</b>: lets you increase or decrease zoom level in the central section and go up and down<br> on the left and on the right.<br><br><b>Mouse hover</b>: gives additional information about the hovered instruction."
                color: window.currentStyle.secondaryColor
                font.pixelSize: 20
            }
        }
    }
    Loader {
        id: aboutWin
        active: false
        sourceComponent: Window {
            title: qsTr("About")
            width: 900
            height: 600
            minimumWidth: 900
            minimumHeight: 600
            maximumWidth: 900
            maximumHeight: 600

            modality: Qt.WindowModal
            color: window.currentStyle.mainColor
            visible: true
            onClosing: aboutWin.active = false
            Text {
                topPadding: 20
                leftPadding: 10
                text: 
"Developed by Samuel Uscidda, Matteo Tucci, Antonio Porsia
Politecnico di Torino 2023-2025
This software is licensed under the European Union Public License (EUPL) version 1.2.
You may use, modify, and redistribute this software under the terms of the EUPL v1.2. The full license text 
is available at https://eupl.eu/1.2/en/.
This software is provided 'as is' without any warranties. 
For more details, please refer to the license documentation included with this program."
                color: window.currentStyle.secondaryColor
                font.pixelSize: 16
            }
        }
    }

    FileDialog {
        id: fileSelector
        title: "Choose a gem5 trace file"
        nameFilters: ["Text files (*.*)"]
        onAccepted: {
            parser.parseFile(fileSelector.selectedFile);
            mainContainer.visible = true;
            fileSelector.close();
            matrixModel.setCC(0);
            listModelRegister.setCC(0);
            listModelStats.setCC(0);
            rightGL.cc = 0;
            textInput.text = 0;
        }
        onRejected: {
            fileSelector.close();
        }
    }

    FileParser {
        id: parser
		objectName: "FileParserDiPeppa"
        onReadEnded: {
            listModel.setData(parser.getListData());
            listModelRegister.setData(parser.getRegisters());
            listModelStats.setData(parser.getStats());
            matrixModel.setData(parser.getTableData(), parser.getMaxRowLen());
            totalInstrText.maxRowLen = parser.getMaxRowLen();
        }
    }

    ListModelCustom {
        id: listModel
    }

    MatrixModel {
        id: matrixModel
		objectName: "NEO"
    }

    ListModelRegister {
        id: listModelRegister
		objectName: "LINDA"
    }

    ListModelStats {
        id: listModelStats
		objectName: "RUST"
    }

    required property int listRowIndex
    required property int tableRowIndex
    required property int tableColumnIndex
    required property real scale

    listRowIndex: -1
    tableRowIndex: -1
    tableColumnIndex: -1
    scale: 1.0

    ColumnLayout {
        id: mainContainer
        anchors.fill: parent
        spacing: 0
        visible: false
		objectName: "ContainerDiAntonio"
        RowLayout {
            Layout.preferredHeight: 50
            Layout.fillWidth: true
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height
                color: window.currentStyle.mainColorAlternative
                RowLayout {
                    id: submenuBar
                    anchors.centerIn: parent
                    spacing: 20
                    SubmenuButton {
                        id: fastBackButton
                        iconPath: "icons/fastBack.svg"
                        iconColor: window.currentStyle.mainColorAlternative
                        hoveredColor: window.currentStyle.tertiaryColor
                        normalColor: window.currentStyle.secondaryColor
                        onClicked: {
                            matrixModel.setCC(0);
                            textInput.text = matrixModel.getCC();
                            rightGL.cc = matrixModel.getCC();
                            listModelRegister.setCC(rightGL.cc);
                            listModelStats.setCC(rightGL.cc);
                        }
                    }
                    SubmenuButton {
                        id: backButton
                        iconPath: "icons/back.svg"
                        iconColor: window.currentStyle.mainColorAlternative
                        hoveredColor: window.currentStyle.tertiaryColor
                        normalColor: window.currentStyle.secondaryColor
                        onClicked: {
                            matrixModel.decreaseCC();
                            textInput.text = matrixModel.getCC();
                            rightGL.cc = matrixModel.getCC();
                            listModelRegister.setCC(rightGL.cc);
                            listModelStats.setCC(rightGL.cc);
                        }
                    }
                    Text {
                        id: submenuBarCCText
                        text: "CC: "
                        color: window.currentStyle.secondaryColor
                    }
                    Rectangle {
                        TextInput {
                            id: textInput
							objectName: "FABRIZIO"
                            //Layout.alignment: Qt.AlignRight
                            //rightPadding: -100
                            text: matrixModel.getCC();
                            validator: IntValidator{bottom: 0;}
                            color: window.currentStyle.secondaryColor
                            anchors.centerIn: parent
                            selectionColor: window.currentStyle.tertiaryColor
                            onAccepted: {
                                matrixModel.setCC(text);
                                text = matrixModel.getCC();
                                rightGL.cc = matrixModel.getCC();
                                listModelRegister.setCC(rightGL.cc);
                                listModelStats.setCC(rightGL.cc);
                            }
                        }
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 30
                        color: Qt.rgba(window.currentStyle.mainColor.r, window.currentStyle.mainColor.g, window.currentStyle.mainColor.b, 0.8)
                        border.color: Qt.rgba(window.currentStyle.secondaryColor.r, window.currentStyle.secondaryColor.g, window.currentStyle.secondaryColor.b, 0.5)
                        border.width: 1
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: 0
                    }
                    Text {
                        id: totalInstrText
                        property string maxRowLen
                        text: "/" + maxRowLen
                        color: window.currentStyle.secondaryColor
                    }
                    SubmenuButton {
                        id: nextButton
                        iconPath: "icons/next.svg"
                        iconColor: window.currentStyle.mainColorAlternative
                        hoveredColor: window.currentStyle.tertiaryColor
                        normalColor: window.currentStyle.secondaryColor
                        onClicked: {
                            matrixModel.increaseCC();
                            textInput.text = matrixModel.getCC();
                            rightGL.cc = matrixModel.getCC();
                            listModelRegister.setCC(rightGL.cc);
                            listModelStats.setCC(rightGL.cc);
                        }
                    }
                    SubmenuButton {
                        id: fastNextButton
                        iconPath: "icons/fastNext.svg"
                        iconColor: window.currentStyle.mainColorAlternative
                        hoveredColor: window.currentStyle.tertiaryColor
                        normalColor: window.currentStyle.secondaryColor
                        onClicked: {
                            matrixModel.setCC(parser.getMaxRowLen())
                            textInput.text = matrixModel.getCC();
                            rightGL.cc = matrixModel.getCC();
                            listModelRegister.setCC(rightGL.cc);
                            listModelStats.setCC(rightGL.cc);
                        }
                    }
                    /*
                    Text {
                        id: submenuBarStartFromCCText
                        text: "Start from CC: "
                        color: window.currentStyle.secondaryColor
                    }
                    Rectangle {
                        TextInput {
                            id: textInputCC
                            //Layout.alignment: Qt.AlignRight
                            //rightPadding: -100
                            text: "0";
                            validator: IntValidator{bottom: 0;}
                            color: window.currentStyle.secondaryColor
                            anchors.centerIn: parent
                            selectionColor: window.currentStyle.tertiaryColor
                            onAccepted: {
                                matrixModel.startFromCC(text);
                                rightGL.cc = matrixModel.getCC();
                                listModelCustom.setCC(rightGL.cc);
                                listModelCustom.setStartFromCC(rightGL.cc);
                                listModelRegister.setCC(rightGL.cc);
                                listModelStats.setCC(rightGL.cc);
                            }
                        }
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 30
                        color: Qt.rgba(window.currentStyle.mainColor.r, window.currentStyle.mainColor.g, window.currentStyle.mainColor.b, 0.8)
                        border.color: Qt.rgba(window.currentStyle.secondaryColor.r, window.currentStyle.secondaryColor.g, window.currentStyle.secondaryColor.b, 0.5)
                        border.width: 1
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: 0
                    } */
                }
            }
        }
        Rectangle {
            Layout.preferredHeight: 2
            Layout.fillWidth: true
            color: window.currentStyle.menuBorderColor
        }
        SplitView {
            id: mainLayout
            Layout.fillHeight: true
            Layout.fillWidth: true
            handle: Rectangle {
                id: handleDelegate
                implicitWidth: 4
                implicitHeight: 4
                color: SplitHandle.pressed ? window.currentStyle.secondaryColor
                    : (SplitHandle.hovered ? Qt.lighter(window.currentStyle.menuBorderColor, 1.1) : window.currentStyle.menuBorderColor)

                containmentMask: Item {
                    x: (handleDelegate.width - width) / 2
                    width: 8
                    height: mainLayout.height
                }
            }
            ScrollView {
                id: scrollViewInsts
                clip: true
                SplitView.minimumWidth: window.width * (1/10)
                SplitView.maximumWidth: window.width * (0.25)
                SplitView.preferredWidth: 200

                spacing: window.currentStyle.tvRowSpacing
                ListView {
                    id: listView
                    model: listModel
                    clip: true
                    width: contentWidth
                    spacing: window.currentStyle.tvRowSpacing

                    property int currentRow: 0

                    delegate: Rectangle {
                        required property string display
                        required property int rowIndex

                        width: window.width * (3/5)
                        height: 40 * window.scale
                        border.color: "transparent"
                        border.width: window.currentStyle.tvBorderWidth
                        color: window.currentStyle.mainColor
                        Text {
                            text: parent.display
                            font.pixelSize: 16 * window.scale
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: window.currentStyle.computeLVOpacity(window, rowIndex)
                            color: (rightGL.cc >= parser.getMaxRowLen()) ? window.currentStyle.secondaryColor : (rowIndex == parser.getHighlightedRowByCC(rightGL.cc) ? window.currentStyle.tertiaryColor : window.currentStyle.secondaryColor)
                            font.bold: (rightGL.cc >= parser.getMaxRowLen()) ? false : (rowIndex == parser.getHighlightedRowByCC(rightGL.cc) ? true : false)
                        }

                        MouseArea {
                            id: listMouseArea
                            anchors.fill: parent
                            width: parent.width
                            height: parent.height
                            hoverEnabled: true

                            onEntered: {
                                if (matrixModel.getCC() === parser.getMaxRowLen()){
                                    hoverTimerList.restart()
                                }
                            }
                            onExited: {
                                window.setListRowIndex(-1);
                                hoverTimerList.stop()
                            }

                            function listHover(){
                                window.setListRowIndex(parent.rowIndex);
                            }
                        }

                        Timer {
                            id: hoverTimerList
                            interval: 80
                            running: false
                            repeat: false
                            onTriggered: {
                                listMouseArea.listHover();
                            }
                        }
                    }
                    property real lastY: 0

                    onContentYChanged: {
                        if (rightGL.contentY !== contentY) {
                            if (!rightGL.moving) {
                                rightGL.contentY = contentY;
                            }
                            else {
                                contentY = rightGL.contentY
                            }
                        }
                    }
                }
            }

                TableView {
                    property bool showGridlines: false

                    id: rightGL
					objectName: "HTML"
                    model: matrixModel
                    ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        // Horizontal ScrollBar
                        ScrollBar.horizontal: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }
                    SplitView.fillWidth: true
                    clip: true
                    columnSpacing: window.currentStyle.tvColumnSpacing
                    rowSpacing: window.currentStyle.tvRowSpacing

                    property int cc: 0
                    WheelHandler {
                        id: wheelHandler
                        onWheel: (wheel) => {
                            let factor = (wheel.angleDelta.y > 0) ? 1.1 : 0.9;
                            window.scale = Math.max(0.5, Math.min(2.0, window.scale * factor));
                            zoomTimer.restart()
                        }
                    }

                    Timer {
                        id: zoomTimer
                        interval: 150
                        running: false
                        repeat: false
                        onTriggered: rightGL.forceLayout()
                    }

                    delegate: Rectangle {
                        required property string display
                        required property int rowIndexTable
                        required property int columnIndexTable

                        width: 40 * window.scale
                        height: 40 * window.scale
                        border.color: window.currentStyle.secondaryColor
                        border.width: window.currentStyle.tvBorderWidth
                        color: window.currentStyle.computeTVColor(display)
                        opacity: (rightGL.cc >= parser.getMaxRowLen()) ? window.currentStyle.computeTVOpacity(window, rowIndexTable, display, rightGL.showGridlines) : window.currentStyle.computeColumnOpacity(columnIndexTable, rightGL.cc, display)

                        Text {
                            id: rectText
                            font.pixelSize: 16 * window.scale
                            anchors.centerIn: parent
                            text: parent.display
                            opacity: 1.0
                            color: window.currentStyle.secondaryColor
                        }

                        MouseArea {
                            id: tableMouseArea
                            anchors.fill: parent
                            width: parent.width
                            height: parent.width
                            hoverEnabled: true

                            onEntered: {
                                hoverTimer.restart()
                            }

                            onExited: {
                                tooltip.visible = false
                                hoveredRow = -1
                                hoveredCol = -1
                                hoverTooltipText = ""
                                window.setTableRowIndex(-1);
                                window.setTableColumnIndex(-1);
                                hoverTimer.stop()
                            }

                            function tableHover(){
                                if (parent.display !== "" && parent.display !== " ") {
                                    hoveredRow = rowIndexTable
                                    hoveredCol = columnIndexTable
                                    tooltip.visible = true
                                    hoverTooltipText =                                 ( (rectText.text  === "F"
                                                                                        ? "Fetch"
                                                                                        : rectText.text  === "D"
                                                                                        ? "Decode"
                                                                                        : rectText.text  ===  "E"
                                                                                        ? "Execute"
                                                                                        : rectText.text  ===  "M"
                                                                                        ? "Memory"
                                                                                        : rectText.text  ===  "W"
                                                                                        ? "Write back"
                                                                                        : rectText.text  ===  "X"
                                                                                        ? "Multiplication"
                                                                                        : rectText.text  ===  "A"
                                                                                        ? "Floating-point addition"
                                                                                        : rectText.text  ===  "d"
                                                                                        ? "Division"
                                                                                        : "Stall") + "\n" + "CC: " + columnIndexTable)
                                    if (hoveredRow >= 0 && hoveredCol >= 0) {
                                        window.setTableRowIndex(hoveredRow)
                                        window.setTableColumnIndex(hoveredCol)
                                    } else {
                                        window.setTableRowIndex(-1)
                                        window.setTableColumnIndex(-1)
                                    }
                                }
                            }
                        }
                        property int hoveredRow: -1
                        property int hoveredCol: -1
                        property string hoverTooltipText: ""
                        Timer {
                            id: hoverTimer
                            interval: 80
                            running: false
                            repeat: false
                            onTriggered: tableMouseArea.tableHover()
                        }

                        ToolTip {
                            id: tooltip
                            visible: false
                            Text {
                                text: hoverTooltipText
                                color: window.currentStyle.secondaryColor
                                anchors.centerIn: parent
                            }
                            background: Rectangle {
                                implicitWidth: 160
                                implicitHeight: 40
                                color: window.currentStyle.mainColor
                                border.color: window.currentStyle.secondaryColor
                            }
                        }
                    }

                    onContentYChanged: {
                                if (listView && listView.contentY !== contentY) {
                                    listView.contentY = contentY
                                }
                            }
                    rowHeightProvider: function(row) { return 40 * window.scale; }
                    columnWidthProvider: function(column) { return 40 * window.scale; }
            }

            ColumnLayout {
                id: regCol
                clip: true
                SplitView.minimumWidth: window.width * (1/10)
                SplitView.maximumWidth: window.width * (0.45)
                SplitView.preferredWidth: 500
                Text {
                    text: "Global stats:"
                    color: window.currentStyle.secondaryColor
                    font.bold: true
                    font.pixelSize: 20
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 20
                }
                ListView {
                    model: listModelStats
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    Layout.leftMargin: 10

                    delegate: Text {
                        required property string display
                        text: display
                        color: window.currentStyle.secondaryColor
                        font.pixelSize: 20
                        Layout.leftMargin: 10
                        font.family: "Monospace"
                    }
                }
                Text {
                    id: baseText
                    property int base: listModelRegister.getVisualFormat()
                    text: "Register values:"
                    color: window.currentStyle.secondaryColor
                    font.bold: true
                    font.pixelSize: 20
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    Layout.bottomMargin: 20
                }
                RowLayout {
                    Layout.preferredHeight: 50
                    Layout.fillWidth: true
                    Text {
                        id: numBaseTextbox
                        text: "Format: "
                        color: window.currentStyle.secondaryColor
                        font.pixelSize: 20
                        Layout.leftMargin: 10
                    }
                    ComboBox {
                        id: numBaseDropdown
                        font.pixelSize: 20
                        Layout.rightMargin: 10
                        Layout.fillWidth: true
                        implicitHeight: background.implicitHeight
                        background: Rectangle {
                            color: window.currentStyle.mainColorAlternative
                            border.width: parent && parent.activeFocus ? 2 : 1
                            border.color: parent && parent.activeFocus ? window.currentStyle.menuBorderColor : window.currentStyle.secondaryColor
                            implicitHeight: numBaseDropdown.contentItem.implicitHeight + 8
                        }

                        contentItem: Text {
                            text: numBaseDropdown.currentText
                            padding: 4
                            font.pixelSize: 16
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            color: window.currentStyle.secondaryColor
                        }
                        popup: Popup {
                            y: numBaseDropdown.height - 1
                            width: numBaseDropdown.width
                            height: Math.min(contentItem.implicitHeight, numBaseDropdown.Window.height - topMargin - bottomMargin)
                            padding: 1
                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: numBaseDropdown.popup.visible ? numBaseDropdown.delegateModel : null
                                currentIndex: numBaseDropdown.highlightedIndex

                                ScrollIndicator.vertical: ScrollIndicator { }
                            }

                            background: Rectangle {
                                border.width: 10
                                border.color: window.currentStyle.menuBorderColor
                            }
                        }

                        delegate: ItemDelegate {
                            required property string texto
                            required property int value
                            id: itemDlgt
                            width: numBaseDropdown.width
                            height: numBaseDropdown.height
                            padding: 0
                            icon.color: window.currentStyle.secondaryColor
                            contentItem: Rectangle {
                                id: rectDlgt
                                width: parent.implicitWidth
                                height: itemDlgt.height
                                color: itemDlgt.hovered ? window.currentStyle.secondaryColor : (value % 2 === 0 ? window.currentStyle.mainColor : window.currentStyle.mainColorAlternative);

                                Text {
                                    id: textItemss
                                    text: texto
                                    width: parent.width
                                    height: parent.height
                                    color: hovered ? window.currentStyle.mainColor : window.currentStyle.secondaryColor
                                    font.pixelSize: 16
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignLeft
                                }
                            }
                        }

                        model: ListModel {
                            ListElement { texto: "Hexadecimal"; value: 0 }
                            ListElement { texto: "Binary"; value: 1 }
                            ListElement { texto: "Floating-point"; value: 2 }
                            ListElement { texto: "Signed integer"; value: 3 }
                            ListElement { texto: "Unsigned integer"; value: 4 }
                        }
                        textRole: "texto"
                        valueRole: "value"
                        onCurrentIndexChanged: {
                            listModelRegister.setVisualFormat(currentIndex)
                            baseText.base = listModelRegister.getVisualFormat()
                        }
                    }
                }
                ListView {
                    id: regView
                    model: listModelRegister
                    clip: true
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 10
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                    delegate: Text {
                        required property string display
                        text: display
                        color: window.currentStyle.secondaryColor
                        font.pixelSize: 20
                        font.family: "Monospace"
                    }

                }
            }
        }
    }
    Component.onCompleted: {
        if(Qt.application.arguments[1] !== undefined) {
            if(parser.parseFile(parser.stringConversion(Qt.application.arguments[1])) === true) {
                mainLayout.visible = true;
            }
        }
    }

    function setListRowIndex(index){
        window.listRowIndex = index;
    }
    function setTableRowIndex(index){
        window.tableRowIndex = index;
    }
    function setTableColumnIndex(index){
        window.tableColumnIndex = index;
    }

}
