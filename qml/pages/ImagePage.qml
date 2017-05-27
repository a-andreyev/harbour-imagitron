import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    property alias imgSource: img.source
    Image {
        anchors.fill: parent
        id: img
        fillMode: Image.PreserveAspectFit
    }
}





