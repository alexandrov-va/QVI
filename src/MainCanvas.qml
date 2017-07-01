import QtQuick 2.0
import QtQuick.Dialogs 1.2
import "./Helpers.js" as Helpers

Flickable
{
	property int scaleSliderValue: main_window.scaleSliderValue
    contentWidth: (isEmpty(main_window.imageData)? width: main_window.imageData["width"] * scaleSliderValue / 100)
    contentHeight: (isEmpty(main_window.imageData)? height: main_window.imageData["height"] * scaleSliderValue / 100)
	clip: true


    function updateCauseImageData()
    {
		canvas.requestPaint();
    }

    function updateCauseConfig()
    {
        canvas.requestPaint();
    }

    function isEmpty(obj)
    {

        // null and undefined are "empty"
        if (obj == null) return true;

        // Assume if it has a length property with a non-zero value
        // that that property is correct.
        if (obj.length > 0)    return false;
        if (obj.length === 0)  return true;

        // If it isn't an object at this point
        // it is empty, but it can't be anything *but* empty
        // Is it empty?  Depends on your application.
        if (typeof obj !== "object") return true;

        // Otherwise, does it have any properties of its own?
        // Note that this doesn't handle
        // toString and valueOf enumeration bugs in IE < 9
        for (var key in obj) {
            if (obj.hasOwnProperty(key)) return false;
        }

        return true;
    }

	Canvas
	{
		id: canvas
		width: contentWidth
		height: contentHeight

		property int scaleSliderValue: main_window.scaleSliderValue
        property int currentShapeIndex: main_window.currentShapeIndex
		property color clearColor
		property variant shapesOrder
		property color backgroundColor: "gray"
        property int selectionRadius: 800 / scaleSliderValue //(main_window.imageData["width"] + main_window.imageData["height"]) / (2 * 100)

        function getProperty(propname)
        {
            return main_window.imageData["properties"][propname]["value"];
        }

		function getFunctionResult(propname, shapeIndex)
		{
            var shape = main_window.imageData["shapes"][shapeIndex];

            try
            {
                return (shape["functions"][propname] !== "empty")?
                            (new Function("shapes", "getFunctionResult", "getProperty", "currentShape", shape["functions"][propname]))(main_window.imageData["shapes"], getFunctionResult, getProperty, JSON.parse(JSON.stringify(shape)))
                          : shape[propname];
            }
            catch(err)
            {
				messageDialog.text = "There is error in the function for shape with number " + shapeIndex + " for property " + propname;
                messageDialog.detailedText = err.name + ":\t" + err.message;
				messageDialog.informativeText = "For now this property will become an original value";
                messageDialog.open();
                return shape[propname];
            }
		}

        onCurrentShapeIndexChanged:
        {
            requestPaint();
        }

		onPaint:
		{
			var ctx = canvas.getContext('2d');

            ctx.reset();
			console.log(width + "\t" + height);

            ctx.clearRect(0, 0, canvas.width, canvas.height);

            if(isEmpty(main_window.imageData))
            {
                var fontSize = (canvas.width < 200? 10: canvas.width / 20);
                ctx.fillStyle = "white";
                ctx.fillRect(0, 0, canvas.width, canvas.height);

                ctx.font = fontSize + "px sans-serif";
                ctx.fillStyle = "black";
				ctx.text("Open an vector image", 0, fontSize);
				ctx.text("(SVG or saved JSON-data)", 0, fontSize * 2);
				ctx.text("in the 'File' menu", 0, fontSize * 3);
                ctx.fill();

                return;
            }

            var imageWidth = main_window.imageData["width"] * scaleSliderValue / 100;
            var imageHeight = main_window.imageData["height"] * scaleSliderValue / 100;

			//ctx.fillStyle = backgroundColor;
			//ctx.fillRect(0, 0, canvas.width, canvas.height);

            //ctx.translate((canvas.width - main_window.imageData["width"]) / 2, (canvas.height - main_window.imageData["height"]) / 2);
			//ctx.translate(offsetX, offsetY);

			ctx.fillStyle = "white";
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            if (main_window.imageData == null)
				return;

			ctx.scale(scaleSliderValue / 100, scaleSliderValue / 100);

			ctx.lineWidth = 2;

            console.log(main_window.imageData["shapes"].length + " shapes, order: " + main_window.imageData["order"]);

            for(var i = 0; i < main_window.imageData["shapes"].length; ++i)
			{
                var num = main_window.imageData["order"][i];
                var currentShape = main_window.imageData["shapes"][num];

                var opacity = getFunctionResult("opacity", num);
                var fillPaintColor = getFunctionResult("fillPaintColor", num);
                var strokePaintColor = getFunctionResult("strokePaintColor", num);

				ctx.lineWidth = currentShape["strokeWidth"];
                ctx.strokeStyle = (currentShape["strokePaintType"] === "none" || currentShape["strokeWidth"] === 0) ? "transparent"
                                :Qt.rgba(strokePaintColor["r"], strokePaintColor["g"],
                                          strokePaintColor["b"], opacity);

                ctx.fillStyle = (currentShape["fillPaintType"] === "none") ? "transparent"
                          :Qt.rgba(fillPaintColor["r"], fillPaintColor["g"],
                                        fillPaintColor["b"], opacity);

                if(currentShape["type"] === "rect")
				{
					ctx.beginPath();
					drawRect(ctx, currentShape, num);
				}
                else if(currentShape["type"] === "circle")
				{
					ctx.beginPath();
                    drawCircle(ctx, currentShape, num);
				}
                else if(currentShape["type"] === "ellipse")
				{
					ctx.beginPath();
					drawEllipse(ctx, currentShape, num);
				}
                else if(currentShape["type"] === "line")
				{
                    ctx.beginPath();
					drawLine(ctx, currentShape, num);
				}
                else if(currentShape["type"] === "polygon" || currentShape["type"] === "polyline")
				{
                    drawPoly(ctx, currentShape, currentShape["isPathClosed"], num);
				}
				else
				{
                    drawPath(ctx, currentShape, currentShape["isPathClosed"], num);
				}


                if(main_window.configurations["selection_enabled"] && currentShapeIndex === num)
                {
                    drawSelection(ctx, currentShape, num);
                }

                if(main_window.configurations["grid_enabled"])
                {
                    drawGrid();
                }
			}

            function drawPath(ctx, currentShape, closed, num)
			{
                var xPoints = getFunctionResult("xPoints", num);
                var yPoints = getFunctionResult("yPoints", num);

				/*if(closed)
                {
                    xPoints.push(xPoints[0]);
                    yPoints.push(yPoints[0]);
				}*/

                ctx.beginPath();

				ctx.moveTo(xPoints[0], yPoints[0]);
                for(var i = 0; i < xPoints.length; i += 3)
                {
                    ctx.bezierCurveTo(xPoints[i + 1], yPoints[i + 1], xPoints[i + 2], yPoints[i + 2], xPoints[i + 3], yPoints[i + 3]);
                }

                if(closed)
				{
					ctx.lineTo(xPoints[0], yPoints[0]);
				}

				ctx.fill();
				ctx.stroke();
			}

            function drawPoly(ctx, currentShape, closed, num) {

                var xPoints = getFunctionResult("xPoints", num);
                var yPoints = getFunctionResult("yPoints", num);

				ctx.beginPath();

                ctx.moveTo(xPoints[0], yPoints[0]);

                for (var k = 1; k < xPoints.length; ++k) {
                    ctx.lineTo(xPoints[k], yPoints[k]);
				}

				if (closed)
                    ctx.lineTo(xPoints[0], yPoints[0]);

				ctx.moveTo(0, 0);


				ctx.fill();

				ctx.stroke();
			}

			function drawRect(ctx, rect, num)
			{
				var cx = getFunctionResult("cx", num);
				var cy = getFunctionResult("cy", num);
				var width = getFunctionResult("width", num);
				var height = getFunctionResult("height", num);
				var angle = getFunctionResult("angle", num);

				ctx.save();

				ctx.translate(cx, cy);
				ctx.rotate(-angle * Math.PI / 180);
				ctx.fillRect(-width / 2, -height / 2, width, height);
				ctx.strokeRect(-width / 2, -height / 2, width, height);

				ctx.restore();
			}

            function drawCirlce(ctx, circle, num)
            {
                var cx = getFunctionResult("cx", num);
                var cy = getFunctionResult("cy", num);
                var r = getFunctionResult("r", num);
                var angle = getFunctionResult("angle", num);

                ctx.save();

                ctx.translate(cx, cy);
                ctx.rotate(-angle * Math.PI / 180);
                ctx.ellipse(-r, -r, r * 2, r * 2);
                ctx.stroke();
                ctx.fill();

                ctx.restore();
            }

			function drawEllipse(ctx, ellipse, num)
			{
				var cx = getFunctionResult("cx", num);
				var cy = getFunctionResult("cy", num);
				var rx = getFunctionResult("rx", num);
				var ry = getFunctionResult("ry", num);
				var angle = getFunctionResult("angle", num);

				ctx.save();

				ctx.translate(cx, cy);
				ctx.rotate(-angle * Math.PI / 180);
				ctx.ellipse(-rx, -ry, rx * 2, ry * 2);
				ctx.stroke();
				ctx.fill();

				ctx.restore();
			}

			function drawLine(ctx, line, num)
			{
				var x1 = getFunctionResult("x1", num);
				var y1 = getFunctionResult("y1", num);
				var x2 = getFunctionResult("x2", num);
				var y2 = getFunctionResult("y2", num);

				ctx.moveTo(x1, y1);
				ctx.lineTo(x2, y2);
				ctx.moveTo(0, 0);

				ctx.stroke();
			}

            function drawSelection(ctx, shape, num)
            {
                ctx.lineWidth = 200 / scaleSliderValue;
                ctx.strokeStyle = "black";
                ctx.font = (selectionRadius * 2) + "px sans-serif";
                ctx.beginPath();

                switch(shape["type"])
                {
                case "polygon":
                case "path":
                case "polyline":
                    var xPoints = getFunctionResult("xPoints", num);
                    var yPoints = getFunctionResult("yPoints", num);

                    for(var i = 0; i < xPoints.length; i++)
                    {
                        ctx.ellipse(xPoints[i] - selectionRadius, yPoints[i] - selectionRadius, selectionRadius * 2, selectionRadius * 2);
                        ctx.text(i, xPoints[i] + selectionRadius, yPoints[i] + selectionRadius);
                    }

                    break;
                case "ellipse":
                    var cx = getFunctionResult("cx", num);
                    var cy = getFunctionResult("cy", num);
                    var rx = getFunctionResult("rx", num);
                    var ry = getFunctionResult("ry", num);
                    var angle = getFunctionResult("angle", num);

                    var cos = Math.cos(-angle * Math.PI / 180);
                    var sin = Math.sin(-angle * Math.PI / 180);
                    var tx, ty;

                    for(var i = 0; i < 4; i++)
                    {
                        tx = rx * Math.cos(2 * Math.PI * i / 4);
                        ty = ry * Math.sin(2 * Math.PI * i / 4);
                        ctx.ellipse(cx + (tx * cos - ty * sin) - selectionRadius, cy + (tx * sin + ty * cos) - selectionRadius,
                                    selectionRadius * 2, selectionRadius * 2);
                    }

                    ctx.ellipse(cx - selectionRadius, cy - selectionRadius, selectionRadius * 2, selectionRadius * 2);

                    break;
                case "circle":

                    var cx = getFunctionResult("cx", num);
                    var cy = getFunctionResult("cy", num);
                    var r = getFunctionResult("r", num);
                    var angle = getFunctionResult("angle", num);

                    var cos = Math.cos(-angle * Math.PI / 180);
                    var sin = Math.sin(-angle * Math.PI / 180);
                    var tx, ty;

                    for(var i = 0; i < 4; i++)
                    {
                        tx = r * Math.cos(2 * Math.PI * i / 4);
                        ty = r * Math.sin(2 * Math.PI * i / 4);
                        ctx.ellipse(cx + (tx * cos - ty * sin) - selectionRadius, cy + (tx * sin + ty * cos) - selectionRadius,
                                    selectionRadius * 2, selectionRadius * 2);
                    }

                    ctx.ellipse(cx - selectionRadius, cy - selectionRadius, selectionRadius * 2, selectionRadius * 2);
                    break;
                case "rect":
                    var cx = getFunctionResult("cx", num);
                    var cy = getFunctionResult("cy", num);
                    var width = getFunctionResult("width", num);
                    var height = getFunctionResult("height", num);
                    var angle = getFunctionResult("angle", num);

                    var corners = new Array;
                    var cos = Math.cos(-angle * Math.PI / 180);
                    var sin = Math.sin(-angle * Math.PI / 180);

                    var hw = -width / 2;
                    var hh = -height / 2;
                    corners[0] = [cx + (hw * cos - hh*sin),
                                  cy + (hw * sin + hh * cos)];

                    hw = -width / 2;
                    hh = height / 2;
                    corners[1] = [cx + (hw * cos - hh*sin),
                                  cy + (hw * sin + hh * cos)];

                    hw = width / 2;
                    hh = height / 2;
                    corners[2] = [cx + (hw * cos - hh*sin),
                                  cy + (hw * sin + hh * cos)];

                    hw = width / 2;
                    hh = -height / 2;
                    corners[3] = [cx + (hw * cos - hh*sin),
                                  cy + (hw * sin + hh * cos)];

                    for(var i = 0; i < 4; i++)
                    {
                        ctx.ellipse(corners[i][0] - selectionRadius, corners[i][1] - selectionRadius, selectionRadius * 2, selectionRadius * 2);
                    }

                    ctx.ellipse(cx - selectionRadius, cy - selectionRadius, selectionRadius * 2, selectionRadius * 2);
                    break;

                case "line":
                    var x1 = getFunctionResult("x1", num);
                    var y1 = getFunctionResult("y1", num);
                    var x2 = getFunctionResult("x2", num);
                    var y2 = getFunctionResult("y2", num);

                    ctx.ellipse(x1 - selectionRadius, y1 - selectionRadius, selectionRadius * 2, selectionRadius * 2);
                    ctx.ellipse(x2 - selectionRadius, y2 - selectionRadius, selectionRadius * 2, selectionRadius * 2);
                }

                ctx.stroke();
            }

            function drawGrid()
            {
                var step = main_window.configurations["grid_step"];
                var width = main_window.imageData["width"];
                var height = main_window.imageData["height"];
                var color = "black";

                ctx.strokeStyle = color;
                ctx.lineWidth = 0.1;

                ctx.beginPath();

                for(var i = 0; i < width; i += step)
                {
                    ctx.moveTo(i, 0);
                    ctx.lineTo(i, height);
                }

                for(var i = 0; i < height; i += step)
                {
                    ctx.moveTo(0, i);
                    ctx.lineTo(width, i);
                }

                ctx.stroke();

                ctx.lineWidth = 5;

                ctx.beginPath();

                ctx.moveTo(0, 0);
                ctx.lineTo(0, height);
                ctx.moveTo(0, 0);
                ctx.lineTo(width, 0);
                ctx.ellipse(-5, -5, 10, 10);
                ctx.moveTo(0, height);
                ctx.lineTo(5, height - 10);
                ctx.moveTo(width, 0);
                ctx.lineTo(width - 10, 5);

                ctx.stroke();
            }
		}

        MessageDialog
        {
            id: messageDialog
			title: "Function error"
        }
	}

    MouseArea
    {
        anchors.fill: parent
        cursorShape: Qt.OpenHandCursor
        hoverEnabled: true

        onPressed:
        {
            cursorShape = Qt.ClosedHandCursor;
        }

        onReleased:
        {
            cursorShape = Qt.OpenHandCursor;
        }
    }
}
