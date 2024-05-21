import QtQuick 2.0
import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.6
import QtCharts 2.1



ComboBox {
    id: control
    model: []
    delegate: ItemDelegate {
        id: delegated_item
        width: control.width
        contentItem:

            Rectangle{
            anchors.fill: parent
            color: delegated_item.hovered ? "#0f3555" : "#181b1f"
            Text {
                leftPadding: 20
                text: modelData
                color: "white"
                font: control.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
        }
        highlighted: control.highlightedIndex === index
    }

    indicator: Canvas {
        id: canvas
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: control
            function onPressedChanged() { canvas.requestPaint(); }
        }

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = "steelblue";
            context.fill();
        }
    }

    contentItem: Text {
        leftPadding: 20
        rightPadding: control.indicator.width + control.spacing

        text: control.displayText
        font: control.font
        // from white to tan color
        color: control.pressed ? "white" : "#eeeee4"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        color: "#181b1f"
        border.color: "steelblue"
        border.width: 1
        radius: 2
    }

    popup: Popup {
        y: control.height - 1
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: "#181b1f"
            border.color: "steelblue"
            radius: 2
        }
    }
}


