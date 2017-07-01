# QVI: QML-based-on-Vector-Image generator
Hello there! 

This program generates **QML file** (+ **JS file**, that contains JSON-data about given image) out of **SVG image**. 

Additionaly, you can give *properties to image*, which will be represented as properties for your QML-file!

And also, you can write *functional dependencies* for certain properties of every shape on image. Their main task will be linkage between shapes and image properties.

**Let's look at example of using of this programm to help you to understand what is it.**

# Example
We want that image to be an QML component:

![svg example](/screenshots/Selection_001.jpg)

1) _Open it in propgramm via "File->'Open SVG image...'";_

![opened svg image](/screenshots/Screenshot1.png)

2) _Add new property 'hoodColor';_

Let's imagine, that we want in our future QML-component a property, that will change color of a hood.

In lower-left section of a window we're adding new property with name *'hoodColor'*, with type *'color'*, and the value would be *blue color*.

![adding new property](/screenshots/Selection_002.jpg)

3) _Add functional dependency to the shape of a hood._

To link our recently added property to the hood of a girl, we need to write *functional dependency* for shape of a hood.

  a) Enable 'Mark selected shape' in lower section of a window;

  b) Search and select needed shape in ;

  c) Select parameter 'fillPaintColor' in upper-left section of a window;

  d) Write this function in textbox: 'return getProperty('hoodColor');'

  e) Click 'Apply function'.

![linking new property to image](/screenshots/Screenshot3.png)

4) _Generate and save QML-component in the dummy project._

*'File->Generate QML file'* will generate for us two files: **'Girl.qml'** and **'Girl.js'**. (component and image data respectively)

Create dummy project and save generated files to the root of the project.

![generated files in dummy project](/screenshots/Selection_003.jpg)

5) _Check generated QML-component in dummy project._

If we'll call new Component (**'Girl'**) like so:

``` QML
import QtQuick 2.6
import QtQuick.Window 2.2

Window {
	visible: true
	width: 640
	height: 480
	title: qsTr("Hello World")

	Girl
	{
		anchors.centerIn: parent
		hoodColor: "red"
	}
}
```
...we will change color of a hood to the red.

Here's the prove:

![calling our qml component](/screenshots/Screenshot4.png)

That's it! We got ourselves QML-component as we wanted!
