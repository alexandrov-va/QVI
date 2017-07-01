import QtQuick 2.0

Item
{
    function updateCauseImageData(element)
    {
        switch(element)
        {
        case "shapesList":
            shapesList.updateShapesList();
            break;
        case "propList":
            propertiesList.updatePropertiesModel();
            break;
        }
    }

    Column
    {
        anchors.fill: parent


        ShapesList
        {
            id: shapesList
            width: sidebar.width
            height: sidebar.height / 2
        }

        PropertiesList
        {
            id: propertiesList
            width: sidebar.width
            height: sidebar.height / 2
        }
    }

    MouseArea
    {
        id: sidebarMouse
        property int prevX

        anchors.left: parent.left
        anchors.top: parent.top
        width: 5
        height: parent.height

        hoverEnabled: true
        cursorShape: Qt.SplitHCursor

        onPressed:
        {
            sidebarDragLine.visible = true;
        }

        onReleased:
        {
            sidebarDragLine.visible = false;
            main_window.updateCauseConfig();
        }

        onPositionChanged:
        {
            if(pressed)
            {
                main_window.configurations["rightbar_width"] = main_window.configurations["rightbar_width"] - mouse.x + prevX;
            }

            prevX = mouse.x;
        }
    }

    Rectangle
    {
        id: sidebarDragLine
        x: sidebarMouse.mouseX
        anchors.top: parent.top
        width: 1
        height: parent.height
        color: "black"
        visible: false
    }
}

