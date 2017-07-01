import QtQuick 2.0
import QtQuick.Controls 1.4

Rectangle
{
    property alias scaleSliderValue: scaleSlider.value

    color: "lightgrey"
    border.color: "black"

	onScaleSliderValueChanged:
	{
		console.log(scaleSliderValue);
		main_window.updateCauseImageData("canvas");
	}

    Row
    {
        anchors.verticalCenter: parent.verticalCenter
        Text
        {
            anchors.verticalCenter: parent.verticalCenter
			text: "View scale:"
        }

        SpinBox
        {
            anchors.verticalCenter: parent.verticalCenter
            id: scaleSlider

            minimumValue: 0
            maximumValue: 500
            value: 100
            stepSize: 20

            suffix: "%"
        }

        Rectangle
        {
            width: 1
            height: toolbar.height
            color: "black"
        }

        Text
        {
            anchors.verticalCenter: parent.verticalCenter
			text: "Image size: "
        }

        Column
        {
            Text
            {
				text: "Width"
            }

            SpinBox
            {
                id: widthSpinBox
                minimumValue: 0
                maximumValue: Infinity
                value: main_window.imageData["width"]
                stepSize: 10

                onValueChanged:
                {
                    main_window.imageData["width"] = value;
                    main_window.updateCauseImageData("canvas");
                }
            }
        }

        Column
        {
            Text
            {
				text: "Height"
            }

            SpinBox
            {
                id: heightSpinBox
                minimumValue: 0
                maximumValue: Infinity
                value: main_window.imageData["height"]
                stepSize: 10

                onValueChanged:
                {
                    console.log(value);
                    main_window.imageData["height"] = value;
                    main_window.updateCauseImageData("canvas");
                }
            }
        }

        Rectangle
        {
            width: 1
            height: toolbar.height
            color: "black"
        }

        Column
        {
			Text { text: "Grid" }

            CheckBox
            {
				text: "On"
                checked: main_window.configurations["grid_enabled"]

                onCheckedStateChanged:
                {
                    if(checkedState === Qt.Checked)
                    {
                        main_window.configurations["grid_enabled"] = true;
                    }
                    else
                    {
                        main_window.configurations["grid_enabled"] = false;
                    }

                    main_window.updateCauseConfig();
                }
            }
        }

        Column
        {
			Text { text: "Grid step:" }

            SpinBox
            {
                minimumValue: 10
                maximumValue: 500
                stepSize: 10
                value: main_window.configurations["grid_step"]

                onValueChanged:
                {
                    main_window.configurations["grid_step"] = value;
                    main_window.updateCauseConfig();
                }
            }
        }

        Rectangle
        {
            width: 1
            height: toolbar.height
            color: "black"
        }

        Column
        {
			Text { text: "Mark selected shape:" }

            CheckBox
            {
				text: "On"
                checked: main_window.configurations["selection_enabled"]

                onCheckedStateChanged:
                {
                    if(checkedState === Qt.Checked)
                    {
                        main_window.configurations["selection_enabled"] = true;
                    }
                    else
                    {
                        main_window.configurations["selection_enabled"] = false;
                    }

                    main_window.updateCauseConfig();
                }
            }
        }

        spacing: 20
    }
}

