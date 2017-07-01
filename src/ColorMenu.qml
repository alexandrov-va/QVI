import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

Row
{
    property string propname
    property int colorButtonSize
    property string signText
    property int currentShapeIndex: main_window.currentShapeIndex

    function getColorOf(propname)
    {
        var colors = main_window.imageData["shapes"][currentShapeIndex][propname + "Color"];
        //console.log(colors);
        return Qt.rgba(colors["r"], colors["g"], colors["b"], 1);
    }

    function updateColorCell()
    {
        if(main_window.imageData["shapes"].length === 0)
            return;

        if(main_window.imageData["shapes"][currentShapeIndex][propname + "Type"] === "none")
        {
            fillColorCell.color = "transparent"
        }
        else
        {
            fillColorCell.color = getColorOf(propname);
        }

        fillCheckBox.checked = main_window.imageData["shapes"][currentShapeIndex][propname + "Type"] !== "none";
    }

    onCurrentShapeIndexChanged:
    {
        updateColorCell();
    }

    Column
    {
        Text
        {
            text: signText
            y: (main_window.toolbar_height - font.pixelSize) / 2
        }

        CheckBox
        {
            id: fillCheckBox
            checked: main_window.imageData["shapes"][currentShapeIndex][propname + "Type"] !== "none"
			text: "On"

            onCheckedStateChanged:
            {
                if(checkedState === Qt.Checked)
                {
                    if(!main_window.imageData["shapes"][currentShapeIndex].hasOwnProperty(propname + "Color"))
                    {
                        main_window.imageData["shapes"][currentShapeIndex][propname + "Color"] = {"r": 0, "g": 0, "b": 0};
                    }
                    main_window.imageData["shapes"][currentShapeIndex][propname + "Type"] = "color";
                    fillColorCell.color = getColorOf(propname);
                }
                else
                {
                    main_window.imageData["shapes"][currentShapeIndex][propname + "Type"] = "none";
                }

                main_window.updateCauseImageData("canvas");
                main_window.updateCauseImageData("propList");
            }
        }
    }

    Rectangle
    {
        id: fillColorBox
        width: colorButtonSize
        height: colorButtonSize
        color: "lightgrey"
        border.color: "black"
        border.width: 1

        Rectangle
        {
            id: fillColorCell
            anchors.fill: parent
            anchors.margins: 5
            color: "white"
        }

        MouseArea
        {
            anchors.fill: parent
            hoverEnabled: true

            onEntered:
            {
                fillColorBox.color = "white"
            }

            onExited:
            {
                fillColorBox.color = "lightgrey"
            }

            onClicked:
            {
                fillColorDialog.open();
            }
        }
    }

    ColorDialog
    {
        id: fillColorDialog

        color: getColorOf(propname)

        onAccepted:
        {
            main_window.imageData["shapes"][currentShapeIndex][propname + "Color"]["r"] = currentColor.r;
            main_window.imageData["shapes"][currentShapeIndex][propname + "Color"]["g"] = currentColor.g;
            main_window.imageData["shapes"][currentShapeIndex][propname + "Color"]["b"] = currentColor.b;
            fillColorCell.color = currentColor;
            main_window.updateCauseImageData("canvas");
            main_window.updateCauseImageData("propList");
        }
    }
}

