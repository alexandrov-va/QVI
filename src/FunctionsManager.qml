import QtQuick 2.0
import QtQuick.Controls 1.4

Item
{
    property int currentShapeIndex: main_window.currentShapeIndex
    property variant functionsArray
    property string currentParam
    property int comboBoxHeight: 20
    property int execButtonHeight: 20
    property int headerHeight: 20

    property int prevIndex: 0
    property int curIndex: 0

    function updateManager()
    {
        functionsArray = [];
        var functionsHash = main_window.imageData["shapes"][currentShapeIndex]["functions"];

        for(var funcname in functionsHash)
        {
            functionsArray.push(funcname);
        }

        prevIndex = funcComboBox.currentIndex;
        funcComboBox.model = functionsArray;
        funcComboBox.currentIndex = (prevIndex > functionsArray.length - 1? 0: prevIndex);
    }

    function updateTextEdit()
    {
        if(currentParam === "")
            return;

        textEditBody.text = main_window.imageData["shapes"][currentShapeIndex]["functions"][currentParam];
    }

    onCurrentShapeIndexChanged:
    {
        updateManager();
        updateTextEdit();
    }

    onCurrentParamChanged:
    {
        updateTextEdit();
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
				text: "<b>Shape functions:</b>"
                clip: true
                anchors.fill: parent
            }
        }

        Row
        {
            Text
            {
				text: "Parameter: "
            }

            ComboBox
            {
                id: funcComboBox
				width: functionsManager.width - 70
                height: comboBoxHeight
                model: functionsArray

                onCurrentTextChanged:
                {
                    currentParam = currentText;
                }

                /*onCurrentIndexChanged:
                {
                    prevIndex = curIndex;
                    curIndex = currentIndex;
                }

                onModelChanged:
                {
                    currentIndex = prevIndex;
                }*/
            }
        }

        Rectangle
        {
            width: parent.width
            height: parent.height - comboBoxHeight - execButtonHeight - headerHeight
            color: "white"
            border.width: 1
            border.color: "black"

            TextArea
            {
                id: textEditBody
                anchors.fill: parent
                anchors.margins: 1
                wrapMode: TextEdit.WordWrap
                horizontalAlignment: TextInput.AlignLeft
                verticalAlignment: TextInput.AlignTop
                tabChangesFocus: false
            }
        }

        Button
        {
            width: parent.width
            height: execButtonHeight
			text: "Apply function"

            onClicked:
            {
                main_window.imageData["shapes"][currentShapeIndex]["functions"][currentParam] = textEditBody.text;
                main_window.updateCauseImageData("canvas");
                main_window.updateCauseImageData("funcMan");
            }
        }
    }
}

