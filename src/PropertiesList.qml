import QtQuick 2.0
import QtQuick.Controls 1.4
import "./Helpers.js" as Helpers

Item
{
    property int currentShapeIndex: main_window.currentShapeIndex
    property variant propertiesArray
    property int listElementHeight: 40
    property int headerHeight: 20
    property int prevIndex: 0

    onCurrentShapeIndexChanged:
    {
        updatePropertiesModel();
    }

    function updatePropertiesModel()
    {
        //Save scroll position

        propertiesArray = [];
        var currentShape = main_window.imageData["shapes"][currentShapeIndex];

        for(var propname in currentShape)
        {
            if(Helpers.ignoredProps.indexOf(propname) == -1)
                propertiesArray.push({"name": propname, "value": currentShape[propname]});
        }

        propListView.model = propertiesArray;
        propListView.currentIndex = prevIndex;
    }

    Rectangle
    {
        anchors.fill: parent
        color: "white"
    }


    Component
    {
        id: arrayProp

        Item
        {
            id: arrayInput
            width: sidebar.width
            height: listElementHeight / 2

            SpinBox
            {
                id: arrayId
                height: parent.height
                value: 0
                stepSize: 1
                minimumValue: 0
                maximumValue: main_window.imageData["shapes"][currentShapeIndex][propData["name"]].length - 1
            }

            /*SpinBox
            {
                value: propData["value"][arrayId.value]
                anchors.fill: parent
                anchors.leftMargin: arrayId.width
                horizontalAlignment: Qt.AlignLeft
                minimumValue: -Infinity
                maximumValue: Infinity
                stepSize: 0.1
                decimals: 3

                onValueChanged:
                {
                    main_window.imageData["shapes"][currentShapeIndex][propData["name"]][arrayId.value] = value;
                    main_window.updateCauseImageData("canvas");
                    main_window.updateCauseImageData("toolbar");
                    main_window.updateCauseImageData("propList");
                }
            }*/

            TextField
            {
                anchors.fill: parent
                anchors.leftMargin: arrayId.width
                anchors.rightMargin: listElementHeight / 2
                text: JSON.stringify(propData["value"][arrayId.value])
                horizontalAlignment: TextInput.AlignLeft
                verticalAlignment: TextInput.AlignBottom

                onAccepted:
                {
                    prevIndex = propIndex;
                    main_window.imageData["shapes"][currentShapeIndex][propData["name"]][arrayId.value] = JSON.parse(text);
                    main_window.updateCauseImageData("canvas");
                    main_window.updateCauseImageData("toolbar");
                    main_window.updateCauseImageData("propList");
                }
            }

            Button
            {
                width: listElementHeight / 2
                height: listElementHeight / 4
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: listElementHeight / 4
                text: "▲"

                onClicked:
                {
                    prevIndex = propIndex;
                    main_window.imageData["shapes"][currentShapeIndex][propData["name"]][arrayId.value] = main_window.imageData["shapes"][currentShapeIndex][propData["name"]][arrayId.value] + 0.1;
                    main_window.updateCauseImageData("canvas");
                    main_window.updateCauseImageData("toolbar");
                    main_window.updateCauseImageData("propList");
                }
            }

            Button
            {
                width: listElementHeight / 2
                height: listElementHeight / 4
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                text: "▼"

                onClicked:
                {
                    prevIndex = propIndex;
                    main_window.imageData["shapes"][currentShapeIndex][propData["name"]][arrayId.value] = main_window.imageData["shapes"][currentShapeIndex][propData["name"]][arrayId.value] - 0.1;
                    main_window.updateCauseImageData("canvas");
                    main_window.updateCauseImageData("toolbar");
                    main_window.updateCauseImageData("propList");
                }
            }
        }
    }

    Component
    {
        id: numericProp

        Item
        {
            width: sidebar.width
            height: listElementHeight / 2

            TextField
            {
                width: sidebar.width - listElementHeight / 2
                height: listElementHeight / 2
                text: JSON.stringify(propData["value"])
                horizontalAlignment: TextInput.AlignLeft
                verticalAlignment: TextInput.AlignBottom

                onAccepted:
                {
                    prevIndex = propIndex;
                    main_window.imageData["shapes"][currentShapeIndex][propData["name"]] = JSON.parse(text);
                    main_window.updateCauseImageData("canvas");
                    main_window.updateCauseImageData("toolbar");
                    main_window.updateCauseImageData("propList");
                }
            }

            Button
            {
                width: listElementHeight / 2
                height: listElementHeight / 4
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: listElementHeight / 4
                text: "▲"

                onClicked:
                {
                    prevIndex = propIndex;
                    main_window.imageData["shapes"][currentShapeIndex][propData["name"]] = main_window.imageData["shapes"][currentShapeIndex][propData["name"]] + 0.1;
                    main_window.updateCauseImageData("canvas");
                    main_window.updateCauseImageData("toolbar");
                    main_window.updateCauseImageData("propList");
                }
            }

            Button
            {
                width: listElementHeight / 2
                height: listElementHeight / 4
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                text: "▼"

                onClicked:
                {
                    prevIndex = propIndex;
                    main_window.imageData["shapes"][currentShapeIndex][propData["name"]] = main_window.imageData["shapes"][currentShapeIndex][propData["name"]] - 0.1;
                    main_window.updateCauseImageData("canvas");
                    main_window.updateCauseImageData("toolbar");
                    main_window.updateCauseImageData("propList");
                }
            }
        }
    }

    Component
    {
        id: defaultProp

        TextField
        {
            text: JSON.stringify(propData["value"])
            width: sidebar.width
            height: listElementHeight / 2
            horizontalAlignment: TextInput.AlignLeft
            verticalAlignment: TextInput.AlignBottom

            onAccepted:
            {
                prevIndex = propIndex;
                console.log("OLD PROP:\t" + main_window.imageData["shapes"][currentShapeIndex][propData["name"]]);
                console.log("NU PROP:\t" + JSON.parse(text) + "(" + typeof(JSON.parse(text)) + ")");
                console.log("preparing equation...");
                main_window.imageData["shapes"][currentShapeIndex][propData["name"]] = JSON.parse(text);
                console.log("preparing update...");
                main_window.updateCauseImageData("canvas");
                main_window.updateCauseImageData("toolbar");
                main_window.updateCauseImageData("propList");
            }
        }
    }

    Component
    {
        id: prop

        Item
        {
            width: sidebar.width
            height: listElementHeight

            Column
            {
                Text { text: "<b>" + modelData["name"] + "</b>" }

                Loader
                {
                    property var propData: modelData
                    property var propIndex: index
                    sourceComponent:
                    {
                        var prop = propData["value"];

                        if(Array.isArray(prop))
                            return arrayProp;

                        if(typeof(prop) === "number")
                            return numericProp;

                        return defaultProp;
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
				text: "<b>Shape properties:</b>"
            }
        }

        ListView
        {
            id: propListView
            anchors.fill: parent
            anchors.topMargin: headerHeight

            model: propertiesArray
            delegate: prop

            clip: true

            preferredHighlightBegin: 0
            preferredHighlightEnd: listElementHeight
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightFollowsCurrentItem: true

        }
    }
}

