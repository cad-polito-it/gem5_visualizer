// Copyright Samuel Uscidda, Matteo Tucci, Antonio Porsia 2023-2025. Licensed under the EUPL-1.2 or later.

import QtQuick

QtObject {
    property color mainColor: "#191D32"
    property color mainColorAlternative: "#0E101B"
    //property color subMenu: ""
    property color secondaryColor: "#F5FBEF"
    property color tertiaryColor: "#00A9A5"
    property color menuBorderColor: "#627C85"
    property int listViewPixelSize: 16
    property real tvBorderWidth: 2.0
    property real tvColumnSpacing: -tvBorderWidth
    property real tvRowSpacing: tvColumnSpacing
    property string hexTransparencyValue: "#99"
    property real transparencyValue: hexToInt(hexTransparencyValue)
    property string voidColor: "ffffff"
    property string fetchColor: "ff0000"
    property string decodeColor: "ff8400"
    property string executeColor: "ffff00"
    property string memoryColor: "00ff00"
    property string writebackColor: "00ffff"
    property string stallColor: "787878"
    function computeLVOpacity(window, rowIndex) {
        if (window.tableRowIndex === -1 || rowIndex === window.tableRowIndex) {
            return 1.0;
        }
        return 0.2;
    }
    function computeTVOpacity(window, rowIndexTable, display, showGridlines) {
        if (!showGridlines && (display === "" || display === " ")) {
            return 0.0;
        }
        if (window.listRowIndex === -1 || rowIndexTable === window.listRowIndex && !(display === "" || display === " ")) {
            return 1.0;
        }
        else {
            return 0.2;
        }
    }
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
    function computeColumnOpacity(colIndex, matrixModelIndex, display) {
        if (display === "" || display === " ") {
            return 0.0;
        }
        if (matrixModelIndex === colIndex){
            return 1.0
        }
        else
            return 0.2
    }
    function normalize(val, max, min){ return (val - min) / (max - min); }
    function hexToInt(hexVal) {
        hexVal = hexVal.replace("#", "")
        return Math.round(normalize(parseInt(hexVal, 16), 255, 0) * 100);
    }
    function intToHex(intVal) {
        const alpha = intVal / 100
        const alphaInt = Math.round(alpha * 255)
        const alphaHex = alphaInt.toString(16).toUpperCase()
        const paddedAlphaHex = alphaHex.padStart(2, '0')

        return "#" + paddedAlphaHex
    }

}
