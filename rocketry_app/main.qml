import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.6
import QtCharts 2.1
import Backend 1.0

// Usefull resources
// Layouts: https://www.dmcinfo.com/latest-thinking/blog/id/10393/resizing-uis-with-qml-layouts

Window {
    id: mainWindow
    visible: true
    visibility: "Maximized"
    color: "Black"
    title: qsTr("Ground control software")

    // Connected slots to Backend signals
    Connections {
        target: Sinstance
        onSendSerialPortsInfo: {
            // console.log(portsInfo[0].portName);
        }
    }

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

    function createChargeBar() {
        var component = Qt.createComponent("CustomBatteryBar.qml")

        for (var i = 0; i < voltage_cell.barsNum; i++) {

            voltage_cell.bar_list.push(component.createObject(voltage_cell))
            // TODO: REFACTORING
            if (i > 20 && i < 24){
                voltage_cell.bar_list[i].color = "orange"
            }
            else if (i > 23 && i < 27){
                voltage_cell.bar_list[i].color = "yellow"
            }
            else if(i > 26 && i < 30){
                voltage_cell.bar_list[i].color = "green"
            }


            // We use Qt.binding, in order to bind properties in JS. Primarly it doesn't bind properties dynamically.
            // Make the initial indent from the left edge of the parent object
            if (i == 0) {
                voltage_cell.bar_list[i].anchors.left = voltage_cell.left
                voltage_cell.bar_list[i].anchors.leftMargin =  Qt.binding(function() { return voltage_cell.barInitialIndent })
            }
            // Place other bars right after each other with the specified gap
            else {
                voltage_cell.bar_list[i].anchors.left = voltage_cell.bar_list[i - 1].right
                voltage_cell.bar_list[i].anchors.leftMargin = Qt.binding(function() { return voltage_cell.barBetweenGap })
            }
        }
    }

    function createChargeBarIfInitialized() {
        if (voltage_cell.width !== 0 && voltage_cell.height !== 0) {
            createChargeBar()
        } else {
            // Retry function call after a short delay if width or height is zero
            // Adjust the delay (e.g., 100) based on your application's needs
            Qt.callLater(createChargeBarIfInitialized, 100)
        }
    }

    function findListModelElementIndex(model, element){

        for (var i = 0; i < model.count; i++){

            if (model.get(i).text === element){
                return i;
            }

        }
        return -1;
    }

    function findListModelNextIndex(model, element){
        for (var i = 0; i < model.count; i++){

            if (model.get(i).text.localeCompare(element) === 1){
                return i;
            }
        }
        return model.count;
    }

    function printall(model){
        console.log("before")
        for (var i = 0; i < model.count; i++){
            console.log(model.get(i).text)

        }
        console.log("after")
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

                        anchors.top: time_cell.top
                        anchors.topMargin: time_cell.height * 0.05
                        anchors.horizontalCenter: time_cell.horizontalCenter
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
                    radius: voltage_cell.width * 0.01

                    property int barsNum: 30
                    property real barInitialIndent: voltage_cell.width * 0.02
                    property real barBetweenGap: voltage_cell.width * 0.005
                    property list<Item> bar_list

                    Text {
                        text: "Voltage"

                        font.family: "Helvetica"
                        font.pointSize: adjustFontSizeToRectangle(12, voltage_cell.width * 0.2, voltage_cell.height * 0.2, "Time");

                        color: "White"

                        anchors.top: voltage_cell.top
                        anchors.topMargin: voltage_cell.height * 0.1
                        anchors.horizontalCenter: voltage_cell.horizontalCenter
                    }

                    Text {
                        id: voltage_string
                        anchors.right: voltage_cell.right
                        anchors.verticalCenter: voltage_cell.verticalCenter
                        anchors.verticalCenterOffset: voltage_cell.height / 6
                        text: "4.98V"
                        font.family: "Helvetica"
                        font.pointSize: adjustFontSizeToRectangle(10, voltage_cell.width * 0.15, voltage_cell.height / 2, voltage_string.text);
                        color: "green"
                        anchors.rightMargin: voltage_cell.height / 12
                    }

                    Component.onCompleted: createChargeBarIfInitialized()

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

            color: "#181b1f"

            border.width: 1
            border.color: "steelblue"
            radius: altitude_plot_cell.width * 0.01


            ChartView {
                id: altitude_plot
                anchors.fill: parent
                margins { top: 0; bottom: 0; left: 0; right: 0 }

                title: "Altitude plot"
                titleColor: "white"
                titleFont.family: "Helvetica"
                titleFont.pointSize: 15


                antialiasing: true
                legend.visible:false // Remove legend of the line

                backgroundColor: "#181b1f"
                ValueAxis {
                    id: x_axis_altitude
                    min: 0;
                    max: 100;
                    color : "white"
                    gridLineColor: "white"
                    labelsColor : "white"
                    lineVisible: false
                    labelFormat: "%.2f"
                    titleText: "<font color='white'>Time [s]</font>"
                }
                ValueAxis {
                    id: y_axis_altitude
                    min: 0;
                    max: 100;
                    color : "white"
                    gridLineColor: "white"
                    labelsColor : "white"
                    lineVisible: false
                    labelFormat: "%.2f"
                    titleText: "<font color='white'>Altitude [m]</font>"

                }

                LineSeries {
                    axisX: x_axis_altitude
                    axisY: y_axis_altitude
                    XYPoint { x: 0; y: 0 }
                    XYPoint { x: 1.1; y: 2.1 }
                    XYPoint { x: 5.9; y: 43.3 }
                    XYPoint { x: 26.1; y: 45.1 }
                    XYPoint { x: 55.9; y: 77.9 }
                    XYPoint { x: 68.4; y: 88.0 }
                    XYPoint { x: 92.1; y: 32.3 }
                }
            }
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

            color: "#181b1f"

            border.width: 1
            border.color: "steelblue"
            radius: acceleration_plot_cell.width * 0.01

            ChartView {
                id: acceleration_plot
                anchors.fill: parent
                margins { top: 0; bottom: 0; left: 0; right: 0 }

                title: "Acceleration plot"
                titleColor: "white"
                titleFont.family: "Helvetica"
                titleFont.pointSize: 15


                antialiasing: true
                legend.visible:false // Remove legend of the line

                backgroundColor: "#181b1f"
                ValueAxis {
                    id: x_axis_acceleration
                    min: 0;
                    max: 100;
                    color : "white"
                    gridLineColor: "white"
                    labelsColor : "white"
                    lineVisible: false
                    labelFormat: "%.2f"
                    titleText: "<font color='white'>Time [s]</font>"
                }
                ValueAxis {
                    id: y_axis_acceleration
                    min: 0;
                    max: 100;
                    color : "white"
                    gridLineColor: "white"
                    labelsColor : "white"
                    lineVisible: false
                    labelFormat: "%.2f"
                    titleText: "<font color='white'>Acceleration [m/s2]</font>"

                }

                LineSeries {
                    axisX: x_axis_acceleration
                    axisY: y_axis_acceleration
                    XYPoint { x: 0; y: 0 }
                    XYPoint { x: 1.1; y: 2.1 }
                    XYPoint { x: 1.9; y: 3.3 }
                    XYPoint { x: 2.1; y: 2.1 }
                    XYPoint { x: 2.9; y: 4.9 }
                    XYPoint { x: 3.4; y: 3.0 }
                    XYPoint { x: 4.1; y: 3.3 }
                }
            }


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
            id: connection_settings_cell
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

            color: "#181b1f"

            border.width: 1
            border.color: "steelblue"
            radius: acceleration_plot_cell.width * 0.01

            TabBar {
                id: tab_bar
                width: parent.width
                anchors.fill: parent
                property int stack_index: 0
                background:
                    Rectangle{
                    color: 'black'
                    border.color: "steelblue"
                    radius: 5
                }

                TabButton {
                    id: connectionSettingsButton

                    property color checkedColor: connectionSettingsButton.checked ? "white" : "#353637"
                    property color pressedColor: connectionSettingsButton.checked ? "#dedede" : "#797a7a"

                    contentItem: Text {
                        text: qsTr("Connection settings")
                        color: parent.checked ? "black" : "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background:
                        // Now it has the following shape
                        Rectangle {

                        implicitWidth: 100
                        implicitHeight: 40

                        color: connectionSettingsButton.pressed ? connectionSettingsButton.pressedColor : connectionSettingsButton.checkedColor

                        border.color: "steelblue"
                        border.width: 1
                        radius: acceleration_plot_cell.width * 0.01

                        Rectangle{
                            implicitWidth: acceleration_plot_cell.width * 0.01
                            implicitHeight: acceleration_plot_cell.width * 0.01
                            x: parent.x
                            y: parent.y + parent.height - parent.radius
                            color: connectionSettingsButton.pressed ? connectionSettingsButton.pressedColor : connectionSettingsButton.checkedColor
                        }
                        Rectangle{
                            implicitWidth: parent.border.width
                            implicitHeight: acceleration_plot_cell.width * 0.01
                            x: parent.x
                            y: parent.y + parent.height - acceleration_plot_cell.width * 0.01

                            color: "transparent"
                            border.color: "steelblue"
                            border.width: 1
                        }
                        Rectangle{
                            implicitWidth: acceleration_plot_cell.width * 0.01
                            implicitHeight: parent.border.width
                            x: parent.x
                            y: parent.y + parent.height - parent.border.width

                            color: "transparent"
                            border.color: "steelblue"
                            border.width: 1
                        }
                        Rectangle{
                            implicitWidth: acceleration_plot_cell.width * 0.01
                            implicitHeight: acceleration_plot_cell.width * 0.01
                            x: parent.x + parent.width - parent.radius
                            y: parent.y
                            color: connectionSettingsButton.pressed ? connectionSettingsButton.pressedColor : connectionSettingsButton.checkedColor
                        }

                        Rectangle{
                            implicitWidth: acceleration_plot_cell.width * 0.01
                            implicitHeight: parent.border.width
                            x: parent.x + parent.width - parent.radius
                            y: parent.y

                            color: "transparent"
                            border.color: "steelblue"
                            border.width: 1
                        }

                        Rectangle{
                            implicitWidth: parent.border.width
                            implicitHeight: acceleration_plot_cell.width * 0.01
                            x: parent.x + parent.width - parent.radius + acceleration_plot_cell.width * 0.01 - parent.border.width
                            y: parent.y

                            color: "transparent"
                            border.color: "steelblue"
                            border.width: 1
                        }

                        Rectangle{
                            implicitWidth: acceleration_plot_cell.width * 0.01
                            implicitHeight: acceleration_plot_cell.width * 0.01
                            x: parent.x + parent.width - parent.radius
                            y: parent.y + parent.height - parent.radius
                            color: connectionSettingsButton.pressed ? connectionSettingsButton.pressedColor : connectionSettingsButton.checkedColor
                        }

                        Rectangle{
                            implicitWidth: acceleration_plot_cell.width * 0.01
                            implicitHeight: parent.border.width
                            x: parent.x + parent.width - parent.radius
                            y: parent.y + parent.height - parent.radius + acceleration_plot_cell.width * 0.01 - parent.border.width

                            color: "transparent"
                            border.color: "steelblue"
                            border.width: 1
                        }
                        Rectangle{
                            implicitWidth: parent.border.width
                            implicitHeight: acceleration_plot_cell.width * 0.01
                            x: parent.x + parent.width - parent.radius + acceleration_plot_cell.width * 0.01 - parent.border.width
                            y: parent.y + parent.height - parent.radius

                            color: "transparent"
                            border.color: "steelblue"
                            border.width: 1
                        }
                    }
                    onClicked: tab_bar.stack_index = 0;
                }
                TabButton {
                    id: fileSettingsButton

                    property color checkedColor: fileSettingsButton.checked ? "white" : "#353637"
                    property color pressedColor: fileSettingsButton.checked ? "#dedede" : "#797a7a"

                    contentItem: Text {
                        text: qsTr("File settings")
                        color: parent.checked ? "black" : "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {

                        implicitWidth: 100
                        implicitHeight: 40

                        color: fileSettingsButton.pressed ? fileSettingsButton.pressedColor : fileSettingsButton.checkedColor

                        border.color: "steelblue"
                        border.width: 1

                    }
                    onClicked: tab_bar.stack_index = 1;
                }
                TabButton {
                    id: inFutureButton

                    property color checkedColor: inFutureButton.checked ? "white" : "#353637"
                    property color pressedColor: inFutureButton.checked ? "#dedede" : "#797a7a"

                    contentItem: Text {
                        text: qsTr("In future")
                        color: parent.checked ? "black" : "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {

                        implicitWidth: 100
                        implicitHeight: 40

                        color: inFutureButton.pressed ? inFutureButton.pressedColor : inFutureButton.checkedColor

                        border.color: "steelblue"
                        border.width: 1
                        radius: acceleration_plot_cell.width * 0.01


                        Rectangle{
                            implicitWidth: acceleration_plot_cell.width * 0.01
                            implicitHeight: acceleration_plot_cell.width * 0.01
                            x: parent.x
                            y: parent.y
                            color: inFutureButton.pressed ? inFutureButton.pressedColor : inFutureButton.checkedColor
                        }

                        Rectangle{
                            implicitWidth: parent.border.width
                            implicitHeight: acceleration_plot_cell.width * 0.01
                            x: parent.x
                            y: parent.y
                            color: "transparent"
                            border.color: "steelblue"
                            border.width: 1
                        }
                        Rectangle{
                            implicitWidth: acceleration_plot_cell.width * 0.01
                            implicitHeight: parent.border.width
                            x: parent.x
                            y: parent.y
                            color: "transparent"
                            border.color: "steelblue"
                            border.width: 1
                        }
                        Rectangle{
                            implicitWidth: acceleration_plot_cell.width * 0.01
                            implicitHeight: acceleration_plot_cell.width * 0.01
                            x: parent.x
                            y: parent.y + parent.height - parent.radius
                            color: inFutureButton.pressed ? inFutureButton.pressedColor : inFutureButton.checkedColor
                        }

                        Rectangle{
                            implicitWidth: parent.border.width
                            implicitHeight: acceleration_plot_cell.width * 0.01
                            x: parent.x
                            y: parent.y + parent.height - acceleration_plot_cell.width * 0.01

                            color: "transparent"
                            border.color: "steelblue"
                            border.width: 1
                        }
                        Rectangle{
                            implicitWidth: acceleration_plot_cell.width * 0.01
                            implicitHeight: parent.border.width
                            x: parent.x
                            y: parent.y + parent.height - parent.border.width

                            color: "transparent"
                            border.color: "steelblue"
                            border.width: 1
                        }
                        Rectangle{
                            implicitWidth: acceleration_plot_cell.width * 0.01
                            implicitHeight: acceleration_plot_cell.width * 0.01
                            x: parent.x + parent.width - parent.radius
                            y: parent.y + parent.height - parent.radius
                            color: inFutureButton.pressed ? inFutureButton.pressedColor : inFutureButton.checkedColor
                        }

                        Rectangle{
                            implicitWidth: acceleration_plot_cell.width * 0.01
                            implicitHeight: parent.border.width
                            x: parent.x + parent.width - parent.radius
                            y: parent.y + parent.height - parent.radius + acceleration_plot_cell.width * 0.01 - parent.border.width

                            color: "transparent"
                            border.color: "steelblue"
                            border.width: 1
                        }
                        Rectangle{
                            implicitWidth: parent.border.width
                            implicitHeight: acceleration_plot_cell.width * 0.01
                            x: parent.x + parent.width - parent.radius + acceleration_plot_cell.width * 0.01 - parent.border.width
                            y: parent.y + parent.height - parent.radius

                            color: "transparent"
                            border.color: "steelblue"
                            border.width: 1
                        }
                    }
                    onClicked: tab_bar.stack_index = 2;
                }
            }

            StackLayout {
                x: parent.border.width
                y: connectionSettingsButton.y + connectionSettingsButton.height
                width: parent.width - parent.border.width * 2 - parent.border.width
                height: parent.height - parent.border.width * 2  - connectionSettingsButton.height
                currentIndex: tab_bar.stack_index

                Rectangle{
                    id : first_page
                    color: "Black"
                    anchors.fill: parent
                    RowLayout{
                        anchors.top : parent.top
                        anchors.topMargin: (parent.height - 2 * (ports_combobox.height)  - spacing) / 2
                        anchors.left: parent.left
                        anchors.leftMargin: (parent.width - width) / 2
                        ColumnLayout{
                            Text {
                                text: qsTr("Port:")
                                color: "white"
                                font.family: "Helvetica"
                                font.pointSize: 14
                            }
                            Text {
                                text: qsTr("Parity:")
                                color: "white"
                                font.family: "Helvetica"
                                font.pointSize: 14
                            }
                        }
                        ColumnLayout{
                            CustomComboBox {
                                id: ports_combobox
                                model: ListModel {
                                    id: model
                                }

                                Connections {
                                    target: Sinstance

                                    onSendSerialPortsInfo: {

                                        // In order to visualize only relevant ports
                                        // It's required to add new ports
                                        // and also delete old ports

                                        // To reach the following functionality
                                        // We can use Set substraction
                                        // newPorts = SetA - SetB
                                        // toDeletePorts = SetB - SetA

                                        var addSet = []
                                        var deleteSet = []

                                        // Filling sets
                                        for (var i = 0; i < portsInfo.length; i++){
                                            addSet.push(portsInfo[i].portName)
                                        }

                                        for (i = 0; i < ports_combobox.model.count; i++){
                                            deleteSet.push(ports_combobox.model.get(i).text)
                                        }

                                        // Getting new ports
                                        for (i = 0; i < ports_combobox.model.count; i++){

                                            let indexOfRemovableElement = addSet.indexOf(ports_combobox.model.get(i).text);

                                            if (indexOfRemovableElement > -1){
                                                addSet.splice(indexOfRemovableElement, 1);
                                            }
                                        }

                                        // Getting ports to delete
                                        for (i = 0; i < portsInfo.length; i++){
                                            let indexOfRemovableElement = deleteSet.indexOf(portsInfo[i].portName);

                                            if (indexOfRemovableElement > -1){
                                                deleteSet.splice(indexOfRemovableElement, 1);
                                            }
                                        }

                                        // Adding new ports in descending order to ComboBox
                                        for (i = 0; i < addSet.length; i++){
                                            let indextToInsert = findListModelNextIndex(ports_combobox.model, addSet[i]);

                                            ports_combobox.model.insert(indextToInsert, {text: addSet[i]});

                                        }

                                        // Deletion old ports from ComboBox
                                        for (i = 0; i < deleteSet.length; i++){
                                            let indexOfRemovableElement = findListModelElementIndex(ports_combobox.model, deleteSet[i]);

                                            if (indexOfRemovableElement > -1){
                                                ports_combobox.model.remove(indexOfRemovableElement);
                                            }
                                        }

                                    }
                                }


                            }
                            CustomComboBox {
                                model: ["None", "EvenParity", "OddParity", "SpaceParity", "MarkParity"]
                            }
                        }
                        ColumnLayout{
                            Layout.leftMargin: 40
                            Text {
                                text: qsTr("Baudrate:")
                                color: "white"
                                font.family: "Helvetica"
                                font.pointSize: 14
                            }
                            Text {
                                text: qsTr("Stop bits:")
                                color: "white"
                                font.family: "Helvetica"
                                font.pointSize: 14
                            }
                        }
                        ColumnLayout{
                            CustomComboBox {
                                id: baudrate_combobox
                                objectName: "baudrate_combobox"

                                Connections {
                                    target: Sinstance
                                    onSendBaudRates: {
                                        baudrate_combobox.model = baudrates;
                                        for (var i = 0; i < baudrate_combobox.model.length; i++){
                                            if (baudrate_combobox.model[i] === 115200){
                                                baudrate_combobox.currentIndex = i;
                                            }
                                        }
                                    }
                                }
                            }
                            CustomComboBox {
                                model: ["1", "1.5", "2"]
                            }
                        }
                        ColumnLayout{
                            Layout.leftMargin: 40
                            Text {
                                text: qsTr("Data bits:")
                                color: "white"
                                font.family: "Helvetica"
                                font.pointSize: 14
                            }
                            Text {
                                text: qsTr("Flow control:")
                                color: "white"
                                font.family: "Helvetica"
                                font.pointSize: 14
                            }
                        }
                        ColumnLayout{
                            CustomComboBox {
                                model: ["5", "6", "7", "8"]
                                currentIndex: 3
                            }
                            CustomComboBox {
                                model: ["None", "Hardware", "Software"]
                            }
                        }
                    }

                    Button{
                        id: open_serial_port_button
                        objectName: "open_serial_port_button"
                        y: parent.height * 0.8
                        x : 100
                        text: "Open"

                        signal openSerialPort()
                        onPressed: openSerialPort()
                    }
                    Button{
                        objectName: "close_serial_port_button"
                        y: parent.height * 0.8
                        x : 300
                        text: "Close"

                        signal closeSerialPort()
                        onPressed: closeSerialPort()
                    }
                }
                Rectangle{
                    color: "Black"
                    implicitWidth: 20
                    implicitHeight: 200
                }
                Rectangle{
                    color: "green"
                    implicitWidth: 20
                    implicitHeight: 200
                }

            }
        }
    }
}
