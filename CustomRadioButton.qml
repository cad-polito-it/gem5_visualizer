// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

import QtQuick.Controls
import QtQuick

RadioButton {
    id: radioButton

    required property string textRB
    required property color textColor

    indicator: Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: 16
        implicitHeight: 16
        x: radioButton.leftPadding
        y: parent.height / 2 - height / 2
        radius: 8
        border.color: radioButton.down ? "#474747" : "#575757"

        Rectangle {
            width: 8
            height: 8
            x: parent.x
            y: parent.y
            anchors.centerIn: parent
            radius: 4
            color: radioButton.down ? "#474747" : "#575757"
            visible: radioButton.checked
        }
    }
    contentItem: Text {
        text: radioButton.textRB
        verticalAlignment: Text.AlignVCenter
        leftPadding: radioButton.indicator.width + radioButton.spacing
        color: radioButton.textColor
    }
}
