import QtQuick 2.0

MouseArea {
    id: button

    property alias text: textItem.text
    property alias fontSize: textItem.font.pointSize

    hoverEnabled: true

    Rectangle {
        anchors.fill: parent
        color: button.containsMouse ? "#cccccc" : "#ffffff"
        border.color: "#000000"
        border.width: 1
    }

    Text {
        id: textItem

        anchors.centerIn: parent
    }

}
