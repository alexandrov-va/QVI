import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import './Helpers.js' as Helpers

ApplicationWindow {
    id: main_window
    visible: true
    width: configurations["window_width"]
    height: configurations["window_height"]
	title: "QVI"
	property variant imageData
    property int currentShapeIndex
    property alias scaleSliderValue: settingsBar.scaleSliderValue
    property variant configurations: init_config

    function updateCauseImageData(element)
    {
        switch(element)
        {
        case "addPropMan":
            dynpropsbar.updateCauseImageData("addPropMan");
            break;
        case "funcMan":
            dynpropsbar.updateCauseImageData("funcMan");
            break;
        case "canvas":
            canvasContainer.updateCauseImageData();
            break;
        case "toolbar":
            toolbar.updateCauseImageData();
            break;
        case "shapesList":
            sidebar.updateCauseImageData("shapesList");
            break;
        case "propList":
            sidebar.updateCauseImageData("propList");
            break;
        case "all":
            dynpropsbar.updateCauseImageData("addPropMan");
            dynpropsbar.updateCauseImageData("funcMan");
            canvasContainer.updateCauseImageData();
            toolbar.updateCauseImageData();
            sidebar.updateCauseImageData("shapesList");
            sidebar.updateCauseImageData("propList");
            break;
        }
    }

    function updateCauseConfig()
    {
        canvasContainer.updateCauseConfig();
        sidebar.width = configurations["rightbar_width"];
        dynpropsbar.width = configurations["leftbar_width"];
        boundingRectForCanvas.anchors.leftMargin = configurations["leftbar_width"];
        boundingRectForCanvas.anchors.rightMargin = configurations["rightbar_width"];
    }

    Component.onCompleted:
    {
        console.log(init_config);
        console.log(configurations["leftbar_width"]);
    }

    onWidthChanged:
    {
        configurations["window_width"] = width;
    }

    onHeightChanged:
    {
        configurations["window_height"] = height;
    }


    onConfigurationsChanged:
    {
        updateCauseConfig();
    }

    onImageDataChanged:
    {
        addOrders();
        addFunctionalityForShapes();
        addPropertyKeyForImage();
        updateCauseImageData("all");
    }

    onClosing:
    {
        jsonTools.toFile(configurations, "current_config.json");
    }

    function addOrders()
    {
        if(imageData.hasOwnProperty("order"))
            return;

        imageData["order"] = [];

        for(var i = 0; i < imageData["shapes"].length; i++)
            imageData["order"].push(i);

        updateCauseImageData();
    }

    function addFunctionalityForShapes()
    {
        imageData["shapes"].forEach(function(cur_shape, i)
        {
            if(cur_shape.hasOwnProperty("functions"))
                return;

            cur_shape["functions"] = {};
            Helpers.shape_params[cur_shape["type"]].forEach(function(funcname)
            {
                cur_shape["functions"][funcname] = "empty";
            });

            updateCauseImageData();
        });
    }

    function addPropertyKeyForImage()
    {
        if(imageData.hasOwnProperty("properties"))
            return;

        imageData["properties"] = {};
        updateCauseImageData();
    }

    Item
    {
        anchors.fill: parent
        anchors.topMargin: configurations["toolbar_height"]
        anchors.bottomMargin: configurations["settingsbar_height"]

        Rectangle
        {
            id: boundingRectForCanvas
            color: "dimgrey"
            anchors.fill: parent
            anchors.rightMargin: configurations["rightbar_width"]
            anchors.leftMargin: configurations["leftbar_width"]

            MainCanvas
            {
                id: canvasContainer
                anchors.fill: parent
                anchors.margins: 1
            }
        }

        DynamicPropsBar
        {
            id: dynpropsbar
			width: configurations["leftbar_width"]
            height: parent.height
            anchors.left: parent.left
            anchors.top: parent.top
        }

        Sidebar
        {
            id: sidebar
            width: configurations["rightbar_width"]
            height: parent.height
            anchors.right: parent.right
            anchors.top: parent.top
        }
    }

    menuBar: MenuBar
    {
        Menu
        {
			title: "File"

            MenuItem
            {
				text: "Open SVG image..."
                shortcut: "Ctrl+O"
                onTriggered:
                {
                    openSvgFileDialog.open();
                }
            }

            MenuItem
            {
				text: "Open JSON file..."
                shortcut: "Ctrl+J"
                onTriggered:
                {
                    openJsonFileDialog.open();
                }
            }

            MenuItem
            {
				text: "Save as JSON file..."
                shortcut: "Ctrl+S"
                onTriggered:
                {
                    saveJsonFileDialog.open();
                }
            }

            MenuItem
            {
				text: "Generate QML file"
                shortcut: "Ctrl+Q"
                onTriggered:
                {
                    generateQmlDialog.open();
                }
            }
        }

        Menu
        {
			title: "Window configurations"

            MenuItem
            {
				text: "Load configurations..."
                onTriggered:
                {
                    openConfigDialog.open();
                }
            }

            MenuItem
            {
				text: "Save configurations..."
                onTriggered:
                {
                    saveConfigDialog.open();
                }
            }

            MenuItem
            {
				text: "Return to default configurations..."
                onTriggered:
                {
                    defaultConfigMessage.open();
                }
            }
        }
    }

	Toolbar
    {
        id: toolbar
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: configurations["toolbar_height"]
	}

    SettingsBar
    {
        id: settingsBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: parent.width
        height: configurations["settingsbar_height"]
    }

    FileDialog
    {
        id: openSvgFileDialog
		title: "Choose SVG file"
        folder: shortcuts.documents
		nameFilters: ["Scalable Vector Image (*.svg)"]

        onAccepted:
        {
			var filePath = openSvgFileDialog.fileUrl.toString().replace("file://", "");

            postProcessedSvgData.process(filePath);
            var readedData = JSON.parse(postProcessedSvgData.writeToJsonFile("blabla").toString());

            if(readedData["shapes"].length <= 0 || readedData["width"] <= 0 || readedData["height"] <= 0)
            {
				fileError.title = "Error while opening SVG file";
				fileError.text = "Check file correctness:";
                fileError.informativeText = filePath;
                fileError.open();

                return;
            }

            main_window.imageData = readedData;
        }
    }

    FileDialog
    {
        id: openJsonFileDialog
		title: "Choose JSON file"
        folder: shortcuts.documents
		nameFilters: ["JSON-file (*.json)"]

        onAccepted:
        {
			var filePath = openJsonFileDialog.fileUrl.toString().replace("file://", "");
            var readedData = jsonTools.fromFile(filePath);

            if(readedData["shapes"].length <= 0 || readedData["width"] <= 0 || readedData["height"] <= 0)
            {
				fileError.title = "Error while opening JSON file";
				fileError.text = "Check file correctness:";
                fileError.informativeText = filePath;
                fileError.open();

                return;
            }

            main_window.imageData = readedData;
        }
    }

    FileDialog
    {
        id: openConfigDialog
		title: "Choose JSON configurations"
		nameFilters: ["JSON-file (*.json)"]

        onAccepted:
        {
			var filePath = openConfigDialog.fileUrl.toString().replace("file://", "");
            var readedData = jsonTools.fromFile(filePath);
            configurations = readedData;
        }
    }

    FileDialog
    {
        id: saveJsonFileDialog
		title: "Save as JSON file"
        nameFilters: ["JSON-файл (*.json)"]
        selectExisting: false

        onAccepted:
        {
			var filePath = saveJsonFileDialog.fileUrl.toString().replace("file://", "");
            jsonTools.toFile(main_window.imageData, filePath);
        }
    }

    FileDialog
    {
        id: saveConfigDialog
		title: "Save configurations to JSON file"
        selectExisting: false

        onAccepted:
        {
			var filePath = saveConfigDialog.fileUrl.toString().replace("file://", "");
            jsonTools.toFile(configurations, filePath);
        }
    }

    FileDialog
    {
        id: generateQmlDialog
		title: "Generate QML file"
        selectExisting: false

        onAccepted:
        {
			var filePath = generateQmlDialog.fileUrl.toString().replace("file://", "");
            var base = fileIO.read(":/QML_Generator_Base.txt");

            var fileName = filePath.split('/').pop();
            console.log(fileName);

            var qmlString = Helpers.generateQml(base, imageData["properties"]).replace("importingJsHere", "import './" + fileName + ".js' as Image");
            var jsString = Helpers.generateJS(imageData);

            fileIO.write(filePath + ".qml", qmlString);
            fileIO.write(filePath + ".js", jsString);
        }
    }

    MessageDialog
    {
        id: fileError
    }

    MessageDialog
    {
        id: defaultConfigMessage
		title: "Warning"
		text: "Are you sure you want to return to default configurations?"
        standardButtons: StandardButton.Yes | StandardButton.No

        onYes:
        {
            configurations = default_config;
        }
    }
}

