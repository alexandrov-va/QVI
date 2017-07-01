import QtQuick 2.0
import QtQuick.Controls 1.4

Item
{
    property int listElementHeight: 40
    property int currentShapeIndex: main_window.imageData["order"][shapesListView.currentIndex]
    property int headerHeight: 20
    property int prevIndex: 0
    property int curIndex: 0

	function swap(array, a, b)
	{
		var temp = array[a];
		array[a] = array[b];
		array[b] = temp;
	}

    function updateShapesList()
    {
        prevIndex = shapesListView.currentIndex;
        shapesListView.model = main_window.imageData["order"];
        shapesListView.currentIndex = (prevIndex > main_window.imageData["shapes"].length - 1 || prevIndex < 0? 0: prevIndex);
        console.log("Prev: " + prevIndex);
        console.log("Cur: " + shapesListView.currentIndex);
    }

    Component
    {
        id: shapeElement

        Item
        {
            width: sidebar.width
            height: listElementHeight

			Row
			{
				Column
				{
					Button
					{
						width: listElementHeight / 2
						height: listElementHeight / 2
                        text: "△"
						onClicked:
						{
							if(index <= 0)
								return;

                            swap(main_window.imageData["order"], index, index - 1);
							shapesListView.decrementCurrentIndex();
                            main_window.updateCauseImageData("canvas");
                            main_window.updateCauseImageData("shapesList");
						}
					}

					Button
					{
						width: listElementHeight / 2
						height: listElementHeight / 2
                        text: "▽"
						onClicked:
						{
                            if(index >= main_window.imageData["shapes"].length - 1)
								return;

                            swap(main_window.imageData["order"], index, index + 1);
							shapesListView.incrementCurrentIndex();
                            main_window.updateCauseImageData("canvas");
                            main_window.updateCauseImageData("shapesList");
						}
					}
				}

				Column
				{
					Text { text: "Name: <b>" + main_window.imageData["shapes"][modelData]["id"] + "</b>" }
					Text { text: "Type: <b>" + main_window.imageData["shapes"][modelData]["type"] + "</b>" }
					Text { text: "Number: <b>" + modelData + "</b>" }
				}

			}


            Button
            {
                text: "..."
                anchors.right: parent.right
                width: listElementHeight / 2
                height: listElementHeight
                onClicked:
                {
                    contextMenu.popup();
                }
            }

            MouseArea
            {
				anchors.fill: parent
                anchors.leftMargin: listElementHeight / 2
                anchors.rightMargin: listElementHeight / 2

                onClicked:
                {
                    shapesListView.currentIndex = index;
                    main_window.currentShapeIndex = main_window.imageData["order"][index];
                }
            }

            Menu
            {
                id: contextMenu

                MenuItem
                {
					text: "Clone"
                    onTriggered:
                    {
                        var copy = JSON.parse(JSON.stringify(main_window.imageData["shapes"][modelData]));
                        main_window.imageData["order"].splice(index + 1, 0, main_window.imageData["shapes"].length);
                        main_window.imageData["shapes"].push(copy);

                        main_window.updateCauseImageData("canvas");
                        main_window.updateCauseImageData("shapesList");
                    }
                }

                MenuSeparator{ }

                MenuItem
                {
					text: "Delete"
                    onTriggered:
                    {
                        main_window.imageData["shapes"].splice(modelData, 1);
                        main_window.imageData["order"].splice(index, 1);

                        for(var i = index; i < main_window.imageData["order"].length; i++)
                        {
                            main_window.imageData["order"][i] -= 1;
                        }

                        main_window.updateCauseImageData("canvas");
                        main_window.updateCauseImageData("shapesList");
                    }
                }
            }
        }

    }

    Column
    {
        anchors.fill: parent

        Rectangle
        {
            width: parent.width
            height: headerHeight
            color: "lightgrey"
            border.color: "black"
            Text
            {
				text: "<b>Image shapes:</b>"
            }
        }

        ListView
        {
            id: shapesListView
            anchors.fill: parent
            anchors.topMargin: headerHeight

            model: main_window.imageData["order"]
            delegate: shapeElement

            highlight: Rectangle { color: "lightsteelblue"; radius: 5; border.color: "black" }
            highlightMoveVelocity: Infinity

            /*onCurrentIndexChanged:
            {
                prevIndex = curIndex;
                curIndex = currentIndex;
            }

            onModelChanged:
            {
                currentIndex = prevIndex;
            }*/

			spacing: 5
        }
    }
}

