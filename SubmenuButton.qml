// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

import QtQuick
import QtQuick.Controls

Button {
    id: nextButton
    required property string iconPath
    required property color iconColor
    required property color hoveredColor
    required property color normalColor

    icon.source: nextButton.iconPath
    width: 30
    height: 30
    icon.width: 30
    icon.height: 30
    padding: 0
    icon.color: nextButton.iconColor


    background: Rectangle {
        implicitWidth: 30
        implicitHeight: 30
        color: nextButton.pressed? Qt.darker(nextButton.hoveredColor, 1.1) : (nextButton.hovered? nextButton.hoveredColor : nextButton.normalColor)
        border.width: 0
        radius: implicitWidth / 2.63
        anchors.centerIn: parent
    }
}

