import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4

Rectangle
{
    property int currentShapeIndex: main_window.currentShapeIndex
    property int moveElementSize: height * 2 / 3
    property int sliderWidth: 80
    property int elementsSpacing: 10

    color: "white"
    border.color: "black"
    border.width: 1

    function updateCauseImageData()
    {
        fillColorMenu.updateColorCell();
        strokeColorMenu.updateColorCell();
    }

	function moveShape(axis, step)
	{
        switch(main_window.imageData["shapes"][currentShapeIndex]["type"])
		{
		case "path":
		case "polygon":
		case "polyline":
            for (var i = 0; i < main_window.imageData["shapes"][currentShapeIndex][axis + "Points"].length; i++)
			{
                main_window.imageData["shapes"][currentShapeIndex][axis + "Points"][i] += step;
			}

			break;
        case "line":

            main_window.imageData["shapes"][currentShapeIndex][axis + "1"] += step;
            main_window.imageData["shapes"][currentShapeIndex][axis + "2"] += step;

            break;
		default:
            main_window.imageData["shapes"][currentShapeIndex]["c" + axis] += step;
			break;
		}
	}

    Row
    {
        anchors.verticalCenter: parent.verticalCenter

        Rectangle
        {

			width: 110
            height: toolbar.height
            color: "lightgrey"
            border.color: "black"

            Text
            {
                anchors.verticalCenter: parent.verticalCenter
				text: "<i>Shape\noperations:<\i>"
            }
        }


        Row
        {
            anchors.verticalCenter: parent.verticalCenter
            ColorMenu
            {
                id: fillColorMenu
                propname: "fillPaint"
                colorButtonSize: parent.parent.height
				signText: "Fill: "
            }

            ColorMenu
            {
                id: strokeColorMenu
                propname: "strokePaint"
                colorButtonSize: parent.parent.height
				signText: "Stroke: "
            }

            spacing: elementsSpacing / 2
        }

        Rectangle
        {
            width: 1
            height: toolbar.height
            color: "black"
        }

        Row
        {
            anchors.verticalCenter: parent.verticalCenter

            Text
            {
                anchors.verticalCenter: parent.verticalCenter
				text: "Stroke width: "
            }

            SpinBox
            {
                minimumValue: 0
                value: main_window.imageData["shapes"][currentShapeIndex]["strokeWidth"]
                decimals: 1
                stepSize: 0.1

                onValueChanged:
                {
                    main_window.imageData["shapes"][currentShapeIndex]["strokeWidth"] = value;
                    main_window.updateCauseImageData("propList");
                    main_window.updateCauseImageData("canvas");
                    main_window.updateCauseImageData("toolbar");
                }
            }
        }

        Rectangle
        {
            width: 1
            height: toolbar.height
            color: "black"
        }

        Row
        {
            anchors.verticalCenter: parent.verticalCenter
			Text{ text: "Opacity: " }

            Slider
            {
                value: main_window.imageData["shapes"][currentShapeIndex]["opacity"]
                width: sliderWidth
                minimumValue: 0
                maximumValue: 1
                stepSize: 0.1
                tickmarksEnabled: true

                onValueChanged:
                {
                    main_window.imageData["shapes"][currentShapeIndex]["opacity"] = value;
                    main_window.updateCauseImageData("propList");
                    main_window.updateCauseImageData("canvas");
                    main_window.updateCauseImageData("toolbar");
                }
            }
        }

        Rectangle
        {
            width: 1
            height: toolbar.height
            color: "black"
        }

        Row
        {
            Text
            {
				text: "\nShape movement: "
            }

            Column
            {
				Text{ text: "Horizontal: " }

                Rectangle
                {
                    width: moveElementSize * 2
                    height: moveElementSize
                    anchors.horizontalCenter: parent.horizontalCenter
                    border.color: "black"
                    color: "white"

					Button
					{
						width: moveElementSize
						height: moveElementSize
						anchors.left: parent.left
						anchors.top: parent.top
                        text: "◀"

						onClicked:
						{
							moveShape("x", -1);
                            main_window.updateCauseImageData("propList");
                            main_window.updateCauseImageData("canvas");
                            main_window.updateCauseImageData("toolbar");
						}
					}

					Button
					{
						width: moveElementSize
						height: moveElementSize
						anchors.right: parent.right
						anchors.top: parent.top
                        text: "▶"

						onClicked:
						{
                            moveShape("x", 1);
                            main_window.updateCauseImageData("propList");
                            main_window.updateCauseImageData("canvas");
                            main_window.updateCauseImageData("toolbar");
						}
					}
                }
            }

            Column
            {
				Text{ text: "Vertical: " }

                Rectangle
                {
                    width: moveElementSize * 2
                    height: moveElementSize
                    anchors.horizontalCenter: parent.horizontalCenter
                    border.color: "black"
                    color: "white"

					Button
					{
						width: moveElementSize
						height: moveElementSize
						anchors.left: parent.left
						anchors.top: parent.top
                        text: "▲"

						onClicked:
						{
							moveShape("y", -1);
                            main_window.updateCauseImageData("propList");
                            main_window.updateCauseImageData("canvas");
                            main_window.updateCauseImageData("toolbar");
						}
					}

					Button
					{
						width: moveElementSize
						height: moveElementSize
						anchors.right: parent.right
						anchors.top: parent.top
                        text: "▼"

						onClicked:
						{
							moveShape("y", 1);
                            main_window.updateCauseImageData("propList");
                            main_window.updateCauseImageData("canvas");
                            main_window.updateCauseImageData("toolbar");
						}
					}
                }
            }

            spacing: elementsSpacing /  2
        }

        spacing: elementsSpacing
    }


}

