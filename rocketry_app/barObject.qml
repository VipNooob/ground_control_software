import QtQuick 2.0

Rectangle{
    // A free space for the bars is 80% of the rectangle width
    // On this 80% of width, we have to place 30 bars with according gaps
    // [indent_(bar)_(gap)_(bar)_(gap)_.....
    width: ((parent.width * 0.8) - parent.barBetweenGap * (parent.barsNum - 2) - parent.barInitialIndent) / parent.barsNum
    height: parent.height * 0.5
    radius: parent.height * 0.02
    // set anchors
    anchors.bottom: parent.bottom
    anchors.bottomMargin: parent.height * 0.075

    color: "red"

}
