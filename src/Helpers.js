var shape_params = {
    "line": ["x1", "x2", "y1", "y2", "opacity", "fillPaintColor", "strokePaintColor"],
    "rect": ["cx", "cy", "width", "height", "angle", "opacity", "fillPaintColor", "strokePaintColor"],
    "circle": ["cx", "cy", "r", "opacity", "fillPaintColor", "strokePaintColor"],
    "ellipse": ["cx", "cy", "rx", "ry", "angle", "opacity", "fillPaintColor", "strokePaintColor"],
    "polygon": ["xPoints", "yPoints", "opacity", "fillPaintColor", "strokePaintColor"],
    "polyline": ["xPoints", "yPoints", "opacity", "fillPaintColor", "strokePaintColor"],
    "path": ["xPoints", "yPoints", "opacity", "fillPaintColor", "strokePaintColor"]
};

var prop_types = ["int", "real", "variant", "color"];

var ignoredProps = ["type", "functions", "additionalProperties"];

function generateQml(base, props)
{
    var properties = "";

    for(var propname in props)
    {
        if(props[propname]["type"] === "color")
        {
            properties += "\t\tproperty " + props[propname]["type"] + " " + propname + ": " +
                    "Qt.rgba(" + props[propname]["value"]["r"] + ", " + props[propname]["value"]["g"] + ", " + props[propname]["value"]["b"] + ", 1)\n";

            continue;
        }

        properties += "\t\tproperty " + props[propname]["type"] + " " + propname + ": " +
                (props[propname]["type"] === "variant"? JSON.stringify(props[propname]["value"]) + '\n': props[propname]["value"] + '\n');
    }

    for(var propname in props)
    {
		properties += "\t\ton" + capitalizeFirstLetter(propname) + "Changed: {\n";
		properties += "\t\t\tcanvas.requestPaint();\n"
		properties += "\t}\n";
    }

    var res = base.replace("importingPropsHere", properties);

    return res;
}

function generateJS(imageData)
{
    var copy = JSON.parse(JSON.stringify(imageData));

    delete copy["properties"];

    var res = "var data = " + JSON.stringify(copy) + ";";

    return res;
}

function capitalizeFirstLetter(string)
{
    return string.charAt(0).toUpperCase() + string.slice(1);
}

/*function drawPath(ctx, currentShape, closed)
{
	var xPoints = currentShape["xPoints"];
	var yPoints = currentShape["yPoints"];

	var derivativeX = [];
	var derivativeY = [];

	for(var j = 0; j < xPoints.length; j++)
	{
		var prevX = xPoints[Math.max(j - 1, 0)];
		var prevY = yPoints[Math.max(j - 1, 0)];
		var nextX = xPoints[Math.min(j + 1, xPoints.length  -1)];
		var nextY = yPoints[Math.min(j + 1, yPoints.length  -1)];

		derivativeX[j] = (nextX - prevX) / 2;
		derivativeY[j] = (nextY - prevY) / 2;
	}

	ctx.beginPath();

	for(var i = 0; i < xPoints.length; i++)
	{
		if(i == 0)
		{
			ctx.moveTo(xPoints[i], yPoints[i]);
		}
		else
		{
			var endX = xPoints[i];
			var endY = yPoints[i];

			var cx1 = xPoints[i - 1] + derivativeX[i - 1] / 2;
			var cy1 = yPoints[i - 1] + derivativeY[i - 1] / 2;

			var cx2 = xPoints[i] + derivativeX[i] / 2;
			var cy2 = yPoints[i] + derivativeY[i] / 2;

			ctx.bezierCurveTo(cx1, cy1, cx2, cy2, endX, endY);
		}
	}

	ctx.closePath();

	ctx.stroke();
	if(closed)
		ctx.fill();
}*/

function drawPath(ctx, currentShape, tension, closed)
{
    var ptsa = [];

	for(var i = 0; i < currentShape["xPoints"].length; i++)
	{
		ptsa[i * 2] = currentShape["xPoints"][i];
		ptsa[i * 2 + 1] = currentShape["yPoints"][i];
	}

	ctx.beginPath();

	drawLines(ctx, getCurvePoints(ptsa, tension, closed));

	//ctx.closePath();

	ctx.stroke();
	if(closed)
        ctx.fill();
}

function getCurvePoints(pts, tension, isClosed, numOfSegments) {

  // use input value if provided, or use a default value
  tension = (typeof tension != 'undefined') ? tension : 0.5;
  isClosed = isClosed ? isClosed : false;
  numOfSegments = numOfSegments ? numOfSegments : 16;

  var _pts = [], res = [],	// clone array
	  x, y,			// our x,y coords
	  t1x, t2x, t1y, t2y,	// tension vectors
	  c1, c2, c3, c4,		// cardinal points
	  st, t, i;		// steps based on num. of segments

  // clone array so we don't change the original
  //
  _pts = pts.slice(0);

  // The algorithm require a previous and next point to the actual point array.
  // Check if we will draw closed or open curve.
  // If closed, copy end points to beginning and first points to end
  // If open, duplicate first points to befinning, end points to end
  if (isClosed) {
	_pts.unshift(pts[pts.length - 1]);
	_pts.unshift(pts[pts.length - 2]);
	_pts.unshift(pts[pts.length - 1]);
	_pts.unshift(pts[pts.length - 2]);
	_pts.push(pts[0]);
	_pts.push(pts[1]);
  }
  else {
	_pts.unshift(pts[1]);	//copy 1. point and insert at beginning
	_pts.unshift(pts[0]);
	_pts.push(pts[pts.length - 2]);	//copy last point and append
	_pts.push(pts[pts.length - 1]);
  }

  // ok, lets start..

  // 1. loop goes through point array
  // 2. loop goes through each segment between the 2 pts + 1e point before and after
  for (var i=2; i < (_pts.length - 4); i+=2) {
	for (var t=0; t <= numOfSegments; t++) {

	  // calc tension vectors
	  t1x = (_pts[i+2] - _pts[i-2]) * tension;
	  t2x = (_pts[i+4] - _pts[i]) * tension;

	  t1y = (_pts[i+3] - _pts[i-1]) * tension;
	  t2y = (_pts[i+5] - _pts[i+1]) * tension;

	  // calc step
	  st = t / numOfSegments;

	  // calc cardinals
	  c1 =   2 * Math.pow(st, 3) 	- 3 * Math.pow(st, 2) + 1;
	  c2 = -(2 * Math.pow(st, 3)) + 3 * Math.pow(st, 2);
	  c3 = 	   Math.pow(st, 3)	- 2 * Math.pow(st, 2) + st;
	  c4 = 	   Math.pow(st, 3)	- 	  Math.pow(st, 2);

	  // calc x and y cords with common control vectors
	  x = c1 * _pts[i]	+ c2 * _pts[i+2] + c3 * t1x + c4 * t2x;
	  y = c1 * _pts[i+1]	+ c2 * _pts[i+3] + c3 * t1y + c4 * t2y;

	  //store points in array
	  res.push(x);
	  res.push(y);

	}
  }

  return res;
}

function drawLines(ctx, pts) {
  ctx.moveTo(pts[0], pts[1]);
  for(var i=2;i<pts.length-1;i+=2) ctx.lineTo(pts[i], pts[i+1]);
}
