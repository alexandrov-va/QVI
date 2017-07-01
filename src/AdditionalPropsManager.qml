import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import './Helpers.js' as Helpers

Item
{
    property variant propertiesArray
	property int listElementHeight: 40
    property int headerHeight: 20
    property int addButtonHeight: 20
    property int untitledPropsCounter: 0
    property int maxUntitledCount: 100

    property int prevIndex: 0

    function updatePropertiesModel()
    {
        propertiesArray = [];
        var props = main_window.imageData["properties"];

        console.log("Begin of image props");

        for(var propname in props)
        {
            propertiesArray.push({"name": propname, "type": props[propname]["type"], "value": props[propname]["value"]});
            console.log(propname + ":\t" + JSON.stringify(props[propname]["value"]));
        }

        console.log("End of image props");

        addPropListView.model = propertiesArray;
        addPropListView.currentIndex = prevIndex;
        //addPropListView.update();
    }

    function getColorOf(propname)
    {
        var colors = main_window.imageData["properties"][propname]["value"];
        return Qt.rgba(colors["r"], colors["g"], colors["b"], 1);
    }

    function parseNumberProp(prop, type)
    {
        var res;

        switch(type)
        {
        case "int":
            res = parseInt(prop);
            break;
        case "float":
            res = parseFloat(prop);
            break;
        }

        if(isNaN(res))
        {
            return 0;
        }

        return res;
    }

    Rectangle
    {
        anchors.fill: parent
        color: "white"
    }

    Component
    {
        id: numProp

        Item
        {
            width: dynpropsbar.width - listElementHeight / 2
            height: listElementHeight / 2

            TextField
            {
                width: dynpropsbar.width - listElementHeight
                height: listElementHeight / 2
                text: JSON.stringify(propData["value"])
                horizontalAlignment: TextInput.AlignLeft
                verticalAlignment: TextInput.AlignBottom

                onAccepted:
                {
                    prevIndex = propIndex;
                    main_window.imageData["properties"][propData["name"]]["value"] = JSON.parse(text);
                    main_window.updateCauseImageData("canvas");
                    main_window.updateCauseImageData("addPropMan");
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
                    main_window.imageData["properties"][propData["name"]]["value"] = main_window.imageData["properties"][propData["name"]]["value"] +
                            (propData["type"] === "int"? 1: 0.1);
                    main_window.updateCauseImageData("canvas");
                    main_window.updateCauseImageData("addPropMan");
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
                    main_window.imageData["properties"][propData["name"]]["value"] = main_window.imageData["properties"][propData["name"]]["value"] -
                            (propData["type"] === "int"? 1: 0.1);
                    main_window.updateCauseImageData("canvas");
                    main_window.updateCauseImageData("addPropMan");
                }
            }
        }
    }

    Component
    {
        id: variantProp

        TextField
        {
            width: dynpropsbar.width - listElementHeight / 2
            height: listElementHeight / 2
            text: JSON.stringify(propData["value"])
            horizontalAlignment: TextInput.AlignLeft
            verticalAlignment: TextInput.AlignBottom

            onAccepted:
            {
                prevIndex = propIndex;
                main_window.imageData["properties"][propData["name"]]["value"] = JSON.parse(text);
                main_window.updateCauseImageData("canvas");
                main_window.updateCauseImageData("addPropMan");
            }
        }
    }

    Component
    {
        id: colorProp

        Rectangle
        {
            id: colorBox
            width: dynpropsbar.width - listElementHeight / 2
            height: listElementHeight / 2
            color: "lightgrey"
            border.color: "black"
            border.width: 1

            Rectangle
            {
                id: colorCell
                anchors.fill: parent
                anchors.margins: 2
                color: getColorOf(propData["name"])
            }

            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true

                onEntered:
                {
                    colorBox.color = "white"
                }

                onExited:
                {
                    colorBox.color = "lightgrey"
                }

                onClicked:
                {
                    prevIndex = propIndex;
                    colorDialog.propname = propData["name"];
                    colorDialog.color = getColorOf(propData["name"]);
                    colorDialog.open();
                }
            }
        }
    }

    Component
    {
        id: prop

        Item
        {
            width: dynpropsbar.width
            height: listElementHeight

            Column
            {
                Row
                {
                    TextField
                    {
                        text: modelData["name"]
                        width: dynpropsbar.width * 2 / 3
                        height: listElementHeight / 2
                        font.bold: true
                        verticalAlignment: TextInput.AlignTop

                        onAccepted:
                        {
                            prevIndex = index;
                            if(text === modelData["name"])
                                return;

							main_window.imageData["properties"][Helpers.lowerFirstLetter(text)] = main_window.imageData["properties"][modelData["name"]];
                            delete main_window.imageData["properties"][modelData["name"]];
                            main_window.updateCauseImageData("canvas");
                            main_window.updateCauseImageData("addPropMan");
                        }
                    }

                    ComboBox
                    {
                        width: dynpropsbar.width / 3
                        height: listElementHeight / 2
                        model: Helpers.prop_types
                        currentIndex: Helpers.prop_types.indexOf(modelData["type"])

                        onCurrentTextChanged:
                        {
                            var old = modelData["type"];
                            var nu = currentText;

                            if(old === nu)
                                return;

                            switch(nu)
                            {
                            case "string":
                                main_window.imageData["properties"][modelData["name"]]["value"] = JSON.stringify(main_window.imageData["properties"][modelData["name"]]["value"]);
                                break;
                            case "int":
                                main_window.imageData["properties"][modelData["name"]]["value"] =
                                        parseNumberProp(JSON.stringify(main_window.imageData["properties"][modelData["name"]]["value"]), "int");
                                break;
                            case "real":
                                main_window.imageData["properties"][modelData["name"]]["value"] =
                                        parseNumberProp(JSON.stringify(main_window.imageData["properties"][modelData["name"]]["value"]), "float");
                                break;
                            case "color":
                                main_window.imageData["properties"][modelData["name"]]["value"] = {"r": 0, "g": 0, "b": 0};
                            }

                            main_window.imageData["properties"][modelData["name"]]["type"] = currentText;
                            main_window.updateCauseImageData("canvas");
                            main_window.updateCauseImageData("addPropMan");
                        }
                    }
                }

                Row
                {
                    Loader
                    {
                        property variant propData: modelData
                        property int propIndex: index

                        sourceComponent:
                        {
                            switch(propData["type"])
                            {
                            case "int":
                            case "real":
                                return numProp;
                            /*case "string":
                                return stringProp;*/
                            case "color":
                                return colorProp;
                            default:
                                return variantProp;
                            }
                        }
                    }

                    Button
                    {
                        width: listElementHeight / 2
                        height: listElementHeight / 2
                        text: "X"

                        onClicked:
                        {
                            delete main_window.imageData["properties"][modelData["name"]];
                            main_window.updateCauseImageData("canvas");
                            main_window.updateCauseImageData("addPropMan");
                        }
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
				text: "<b>Image properties:</b>"
                clip: true
                anchors.fill: parent
            }
        }

        ListView
        {
            id: addPropListView
            width: parent.width
            height: additionalPropsManager.height - (headerHeight + addButtonHeight)

            model: propertiesArray
            delegate: prop

            clip: true

            preferredHighlightBegin: 0
            preferredHighlightEnd: listElementHeight
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightFollowsCurrentItem: true
        }


        Button
        {
            width: parent.width
            height: addButtonHeight
			text: "Add new property"

            onClicked:
            {
                prevIndex = 0;
				var nameForProp = "untitled" + untitledPropsCounter;

                while(main_window.imageData["properties"].hasOwnProperty(nameForProp))
                {
                    untitledPropsCounter = (untitledPropsCounter + 1) % maxUntitledCount;
					nameForProp = "untitled" + untitledPropsCounter;
                }

				main_window.imageData["properties"][nameForProp] = {"type": "variant", "value": 0};
                main_window.updateCauseImageData("canvas");
                main_window.updateCauseImageData("addPropMan");
                untitledPropsCounter = (untitledPropsCounter + 1) % maxUntitledCount;
            }
        }
    }

    ColorDialog
    {
        id: colorDialog
        property string propname

        onAccepted:
        {
            main_window.imageData["properties"][propname]["value"] =  {"r": currentColor.r, "g": currentColor.g, "b": currentColor.b};
            //colorCell.color = currentColor;
            main_window.updateCauseImageData("canvas");
            main_window.updateCauseImageData("addPropMan");
        }
    }
}

