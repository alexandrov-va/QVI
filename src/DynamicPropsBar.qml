import QtQuick 2.0

Item
{

    function updateCauseImageData(element)
    {
        switch(element)
        {
        case "addPropMan":
            additionalPropsManager.updatePropertiesModel();
            break;
        case "funcMan":
            functionsManager.updateManager();
            functionsManager.updateTextEdit();
            break;
        }
    }

    Column
    {
        anchors.fill: parent

        FunctionsManager
        {
            id: functionsManager
            width: dynpropsbar.width
            height: dynpropsbar.height / 2
        }

        AdditionalPropsManager
        {
            id: additionalPropsManager
            width: dynpropsbar.width
            height: dynpropsbar.height / 2
        }
    }

    MouseArea
    {
        id: dynPropBarMouse
        property int prevX

        anchors.right: parent.right
        anchors.top: parent.top
        width: 5
        height: parent.height

        hoverEnabled: true
        cursorShape: Qt.SplitHCursor

        onPressed:
        {
            dynPropBarDragLine.visible = true;
        }

        onReleased:
        {
            dynPropBarDragLine.visible = false;
            main_window.updateCauseConfig();
        }

        onPositionChanged:
        {
            if(pressed)
            {
                main_window.configurations["leftbar_width"] = main_window.configurations["leftbar_width"] + mouse.x - prevX;
            }

            prevX = mouse.x;
        }
    }

    Rectangle
    {
        id: dynPropBarDragLine
        x: dynPropBarMouse.mouseX + parent.width
        anchors.top: parent.top
        width: 1
        height: parent.height
        color: "black"
        visible: false
    }
}

