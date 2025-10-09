// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

import QtQuick
import QtQuick.Controls

MenuItem {
    id: menuItem

    property color mainColor: "black"
    property color secondaryColor: "white"
    property color tertiaryColor: "#21be2b"

    contentItem: Text {
        text: menuItem.formatMenuText(menuItem.text)
        font: menuItem.font
        color: menuItem.highlighted ? menuItem.mainColor : menuItem.secondaryColor
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 20
        color: menuItem.highlighted ? menuItem.tertiaryColor : "transparent"
    }

    function formatMenuText(input) {
        return input.replace(/&(.)/g, "<u>$1</u>");
    }
}
