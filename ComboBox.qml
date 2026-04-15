import QtQuick 2.0

FocusScope {
    id: container

    property color color: "white"
    property color borderColor: "#ababab"
    property color focusColor: "#266294"
    property color hoverColor: "#5692c4"
    property color menuColor: "white"
    property color textColor: "black"
    property int borderWidth: 1
    property font font
    property alias model: listView.model
    property int index: 0
    property Component rowDelegate: defaultRowDelegate

    signal valueChanged(int id)

    function toggle() {
        if (dropDown.state === "visible")
            close(false);
        else
            open();
    }

    function open() {
        dropDown.state = "visible";
        listView.currentIndex = container.index;
    }

    function close(update) {
        dropDown.state = "";
        if (update) {
            container.index = listView.currentIndex;
            topRow.modelItem = listView.currentItem.modelItem;
            valueChanged(listView.currentIndex);
        }
    }

    width: 80
    height: 30
    onFocusChanged: {
        if (!container.activeFocus)
            close(false);

    }
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Up) {
            listView.decrementCurrentIndex();
        } else if (event.key === Qt.Key_Down) {
            if (event.modifiers !== Qt.AltModifier)
                listView.incrementCurrentIndex();
            else
                toggle();
        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
            close(true);
        else if (event.key === Qt.Key_Escape)
            close(false);
    }
    Component.onCompleted: {
        listView.currentIndex = container.index;
        if (listView.currentItem)
            topRow.modelItem = listView.currentItem.modelItem;

    }
    onIndexChanged: {
        listView.currentIndex = container.index;
        if (listView.currentItem)
            topRow.modelItem = listView.currentItem.modelItem;

    }
    onModelChanged: {
        listView.currentIndex = container.index;
        if (listView.currentItem)
            topRow.modelItem = listView.currentItem.modelItem;

    }

    Component {
        id: defaultRowDelegate

        Text {
            anchors.fill: parent
            anchors.margins: 3 + container.borderWidth
            verticalAlignment: Text.AlignVCenter
            color: container.textColor
            font: container.font
            text: parent.modelItem.name
        }

    }

    Rectangle {
        id: main

        anchors.fill: parent
        color: container.color
        border.color: container.borderColor
        border.width: container.borderWidth
        states: [
            State {
                name: "hover"
                when: mouseArea.containsMouse

                PropertyChanges {
                    target: main
                    border.width: container.borderWidth
                    border.color: container.hoverColor
                }

            },
            State {
                name: "focus"
                when: container.activeFocus && !mouseArea.containsMouse

                PropertyChanges {
                    target: main
                    border.width: container.borderWidth
                    border.color: container.focusColor
                }

            }
        ]

        transitions: Transition {
            ColorAnimation {
                property: "border.color"
                duration: 100
            }

        }

    }

    Loader {
        id: topRow

        property variant modelItem

        anchors.fill: parent
        focus: true
        clip: true
        sourceComponent: rowDelegate
    }

    MouseArea {
        id: mouseArea

        anchors.fill: container
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: {
            if (main.state == "")
                main.state = "hover";

        }
        onExited: {
            if (main.state == "hover")
                main.state = "";

        }
        onClicked: {
            container.focus = true;
            toggle();
        }
        onWheel: {
            if (wheel.angleDelta.y > 0)
                listView.decrementCurrentIndex();
            else
                listView.incrementCurrentIndex();
        }
    }

    Rectangle {
        id: dropDown

        width: container.width
        height: 0
        anchors.top: container.bottom
        anchors.topMargin: 0
        color: container.menuColor
        clip: true
        states: [
            State {
                name: "visible"

                PropertyChanges {
                    target: dropDown
                    height: (container.height - 2 * container.borderWidth) * listView.count + container.borderWidth
                }

            }
        ]

        Component {
            id: myDelegate

            Rectangle {
                property variant modelItem: model

                width: dropDown.width
                height: container.height - 2 * container.borderWidth
                color: "transparent"

                Loader {
                    id: loader

                    property variant modelItem: model

                    anchors.fill: parent
                    sourceComponent: rowDelegate
                }

                MouseArea {
                    id: delegateMouseArea

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: listView.currentIndex = index
                    onClicked: close(true)
                }

            }

        }

        ListView {
            id: listView

            width: container.width
            height: (container.height - 2 * container.borderWidth) * count + container.borderWidth
            delegate: myDelegate

            highlight: Rectangle {
                anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                color: container.hoverColor
            }

        }

        Rectangle {
            anchors.fill: listView
            anchors.topMargin: -container.borderWidth
            color: "transparent"
            clip: false
            border.color: main.border.color
            border.width: main.border.width
        }

        transitions: Transition {
            NumberAnimation {
                property: "height"
                duration: 100
            }

        }

    }

}
