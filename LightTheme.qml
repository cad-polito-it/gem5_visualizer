// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

import QtQuick

BaseStyle {
    property color mainColor: "#F5FBEF"
    property color mainColorAlternative: Qt.darker("#F5FBEF", 1.05)
    //property color subMenu: ""
    property color secondaryColor: "black"
    property color tertiaryColor: "#056af7"
    property string voidColor: "ffffff"
    property string fetchColor: "ff0000"
    property string decodeColor: "ff8400"
    property string executeColor: "ffff00"
    property string memoryColor: "00ff00"
    property string writebackColor: "00ffff"
    property string stallColor: "787878"
    property string hexTransparencyValue: "#B3"
    function computeTVColor(display) {
        switch(display) {
        case "":
        case " ":
            return hexTransparencyValue + voidColor;
            break;
        case "F":
            return hexTransparencyValue + fetchColor;
            break;
        case "D":
            return hexTransparencyValue + decodeColor;
            break;
        case "E":
        case "A":
        case "X":
        case "d":
            return hexTransparencyValue + executeColor;
            break;
        case "M":
            return hexTransparencyValue + memoryColor;
            break;
        case "W":
            return hexTransparencyValue + writebackColor;
            break;
        default:
            return hexTransparencyValue + stallColor;
        }
    }
}
