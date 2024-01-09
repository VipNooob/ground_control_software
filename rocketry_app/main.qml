import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5

// Usefull resources
// Layouts: https://www.dmcinfo.com/latest-thinking/blog/id/10393/resizing-uis-with-qml-layouts

Window {
    id: mainWindow
    visible: true
    visibility: "Maximized"
    color: "Black"
    title: qsTr("Hello World")

    function getCurrentTime() {
        var now = new Date()

        var hours = now.getHours()
        var minutes = now.getMinutes()
        var seconds = now.getSeconds()

        if (hours < 10)
            hours = "0" + hours
        if (minutes < 10)
            minutes = "0" + minutes
        if (seconds < 10)
            seconds = "0" + seconds

        return hours + ':' + minutes + ':' + seconds
    }

    function adjustFontSizeToRectangle(maximumFontSize, rectWidth, rectHeight, text) {

        var font = Qt.font({ family: "Helvetica", pointSize: maximumFontSize });
        var textMetrics = Qt.createQmlObject('import QtQuick 2.6; TextMetrics {}', time_cell);

        textMetrics.text = text;
        textMetrics.font = font;

        var textWidth = textMetrics.boundingRect.width;
        var textHeight = textMetrics.boundingRect.height;

        // Calculate the scale factor based on available space
        // The idea is how many times the required text can be fitted inside the available space
        var scaleFactor = Math.min(rectWidth / textWidth, rectHeight / textHeight);

        // Apply a scale factor to adjust the font size
        var adjustedFontSize = maximumFontSize * scaleFactor;

        textMetrics.destroy();
        return adjustedFontSize;
    }

    // setup a timer to update time string every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: time_string.text = getCurrentTime()
    }

    GridLayout {
        id: grid
        anchors.fill: parent

        columnSpacing : 2
        rowSpacing : 2

        rows: 4
        columns: 4

        // Adding column layout inside a cell of the grid layout
        Item {
            id: time_voltage_cell
            // Position inside the grid
            Layout.row: 0
            Layout.column: 0
            // Indents
            Layout.topMargin: 2
            Layout.leftMargin: 2

            Layout.fillWidth: true
            Layout.fillHeight: true
            // Establish size constraints
            Layout.preferredWidth : mainWindow.width / 4
            Layout.preferredHeight: mainWindow.height / 4


            ColumnLayout{
                id: time_voltage_layout
                // Make a layout size equals to the item's size
                anchors.fill: parent
                spacing: 2

                Rectangle{
                    id: time_cell

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Layout.preferredWidth: time_voltage_cell.width
                    Layout.preferredHeight: time_voltage_cell.height / 2

                    color: "#181b1f"

                    border.width: 1
                    border.color: "steelblue"
                    radius: time_cell.width * 0.01
                    // Think about font.pointSize, cos it depends only on the height
                    Text {
                        text: "Time"

                        font.family: "Helvetica"
                        font.pointSize: adjustFontSizeToRectangle(12, time_cell.width * 0.2, time_cell.height * 0.2, "Time");

                        color: "White"

                        anchors.top: parent.top
                        anchors.topMargin: time_cell.height * 0.05
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        id: time_string
                        text: getCurrentTime()

                        font.family: "Helvetica"
                        font.pointSize: adjustFontSizeToRectangle(50, time_cell.width * 0.8, time_cell.height * 0.7, time_string.text);

                        color: "White"
                        anchors.centerIn: parent
                    }


                }
                Rectangle{
                    id: voltage_cell

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Layout.preferredWidth: time_voltage_cell.width
                    Layout.preferredHeight: time_voltage_cell.height / 2

                    color: "#181b1f"

                    border.width: 1
                    border.color: "steelblue"
                    radius: time_cell.width * 0.01
                }
            }
        }
        Rectangle{
            id: altitude_plot_cell
            // Position in the grid
            Layout.row: 0
            Layout.column: 1
            // Indents
            Layout.topMargin: 2

            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.preferredWidth : mainWindow.width / 4
            Layout.preferredHeight: mainWindow.height / 4

            color: "orange"

        }
        Rectangle{
            id: acceleration_plot_cell
            // Position in the grid
            Layout.row: 0
            Layout.column: 2
            // Indents
            Layout.topMargin: 2

            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.preferredWidth : mainWindow.width / 4
            Layout.preferredHeight: mainWindow.height / 4

            color: "orange"

        }
        Rectangle{
            id: rocket_tasks_cell
            // Position in the grid
            Layout.row: 0
            Layout.column: 3
            // Indents
            Layout.topMargin: 2
            Layout.rightMargin: 2

            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.preferredWidth : mainWindow.width / 4
            Layout.preferredHeight: mainWindow.height / 4

            color: "tan"

        }
        Rectangle{
            id: google_maps_cell
            // Position in the grid
            Layout.row: 1
            Layout.column: 0
            // Indents
            Layout.leftMargin: 2

            Layout.rowSpan: 2
            Layout.columnSpan: 2

            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.preferredWidth : mainWindow.width / 2
            Layout.preferredHeight: mainWindow.height / 2

            color: "pink"
        }
        Rectangle{
            id: spacial_model_cell
            // Position in the grid
            Layout.row: 1
            Layout.column: 2
            // Indents
            Layout.rightMargin: 2

            Layout.rowSpan: 2
            Layout.columnSpan: 2

            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.preferredWidth : mainWindow.width / 2
            Layout.preferredHeight: mainWindow.height / 2

            color: "pink"

        }
        Rectangle{
            id: secondary_info_cell
            // Position in the grid
            Layout.row: 3
            Layout.column: 0
            // Indents
            Layout.bottomMargin: 2
            Layout.leftMargin: 2

            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.preferredWidth : mainWindow.width / 4
            Layout.preferredHeight: mainWindow.height / 4

            color: "purple"
        }
        Rectangle{
            id: raw_telemetry_cell
            // Position in the grid
            Layout.row: 3
            Layout.column: 1
            // Indents
            Layout.bottomMargin: 2

            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.preferredWidth : mainWindow.width / 4
            Layout.preferredHeight: mainWindow.height / 4

            color: "white"
        }
        Rectangle{
            id: control_buttons_cell
            // Position in the grid
            Layout.row: 3
            Layout.column: 2
            // Indents
            Layout.bottomMargin: 2
            Layout.rightMargin: 2

            Layout.columnSpan: 2

            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.preferredWidth : mainWindow.width / 2
            Layout.preferredHeight: mainWindow.height / 4

            color: "white"
        }
    }

}
