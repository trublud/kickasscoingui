import QtQuick 2.9

import "../components" as KickAssCoinComponents

TextEdit {
    color: KickAssCoinComponents.Style.defaultFontColor
    font.family: KickAssCoinComponents.Style.fontRegular.name
    selectionColor: KickAssCoinComponents.Style.textSelectionColor
    wrapMode: Text.Wrap
    readOnly: true
    selectByMouse: true
    // Workaround for https://bugreports.qt.io/browse/QTBUG-50587
    onFocusChanged: {
        if(focus === false)
            deselect()
    }
}
