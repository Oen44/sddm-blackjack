import QtQuick 2.0

Item {
    id: card

    readonly property real imageWidth: 500
    readonly property real imageHeight: 726
    readonly property real scale: 0.25
    property string source
    property bool hidden: false

    width: imageWidth * scale
    height: imageHeight * scale

    Image {
        anchors.fill: parent
        source: hidden ? Qt.resolvedUrl("cards/back.png") : card.source
    }

}
