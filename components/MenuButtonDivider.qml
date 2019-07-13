import QtQuick 2.9

import "." as KickAssCoinComponents
import "effects/" as KickAssCoinEffects

Rectangle {
    color: KickAssCoinComponents.Style.appWindowBorderColor
    height: 1

    KickAssCoinEffects.ColorTransition {
        targetObj: parent
        blackColor: KickAssCoinComponents.Style._b_appWindowBorderColor
        whiteColor: KickAssCoinComponents.Style._w_appWindowBorderColor
    }
}
