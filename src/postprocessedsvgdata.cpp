#include "postprocessedsvgdata.h"
#include "svgconverter.h"
#include <QDebug>

#include <float.h>

#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>

#define M_PI 3.14159

namespace SVGCONV
{
    const QStringList notNeededProps = {"bounds", "flags", "npts"};
}

PostProcessedSvgData::PostProcessedSvgData(const SvgConverter& copy) :
    m_conv(new SvgConverter(copy))
{
}

PostProcessedSvgData::~PostProcessedSvgData()
{
    delete m_conv;
}

PostProcessedSvgData::PostProcessedSvgData(const PostProcessedSvgData &copy)
{
    m_conv = copy.m_conv;
}

PostProcessedSvgData::PostProcessedSvgData()
{

}

void PostProcessedSvgData::setConvData(SvgConverter *conv)
{
    this->m_conv = conv;
}

void PostProcessedSvgData::process(const QString &filePath)
{
    //m_shapes = m_conv->m_svgData["shapes"].toList();

    m_conv = new SvgConverter();
    m_conv->parseImage(filePath);
    m_shapes = qvariant_cast<QVariantList>(m_conv->m_svgData["shapes"]);

    for(int i = 0; i < m_shapes.count(); ++i)
    {
        m_shape = m_shapes[i].toMap();
        m_xPoints = m_shape["xPoints"].toList();
        m_yPoints = m_shape["yPoints"].toList();
        QString itemKind = m_shape["type"].toString();

        if (itemKind == "rect")
        {
            processRectParams(i);
        }
        else if(itemKind == "ellipse" || itemKind == "circle")
        {
            processEllipseParams(i, itemKind);
        }
        else if(itemKind == "line")
        {
            processLineParams(i);
        }
        else if(itemKind == "polyline" || itemKind == "polygon")
        {
            processPoly(i);
        }

        for(int j = 0; j < SVGCONV::notNeededProps.length(); j++)
        {
            m_shape.remove(SVGCONV::notNeededProps[j]);

            m_shapes.replace(i, m_shape);
            m_conv->replaceShapesData(m_shapes);
        }


    }

}

QString PostProcessedSvgData::writeToJsonFile(const QString &filename)
{
    return m_conv->writeToJsonFile(filename);
}

void PostProcessedSvgData::processPoly(int num)
{
    QVariantList nuX;
    QVariantList nuY;

    for(int i = 0; i < m_xPoints.length(); i += 3)
    {
        nuX.push_back(m_xPoints[i].toFloat());
        nuY.push_back(m_yPoints[i].toFloat());
    }

    m_shape["xPoints"] = QVariant(nuX);
    m_shape["yPoints"] = QVariant(nuY);

    m_shapes.replace(num, m_shape);

    m_conv->replaceShapesData(m_shapes);

}

void PostProcessedSvgData::processRectParams(int num)
{
    //Rect bounds
    float minX = m_shape["bounds"].toList()[0].toFloat();
    float minY = m_shape["bounds"].toList()[1].toFloat();
    float maxX = m_shape["bounds"].toList()[2].toFloat();
    float maxY = m_shape["bounds"].toList()[3].toFloat();

    //Inverse angle and centre
    float theta = m_shape["angle"].toFloat() * M_PI / 180;
    float cx = (minX + maxX) / 2;
    float cy = (minY + maxY) / 2;

    //Rect corners
    float y_minx = m_yPoints.at(m_xPoints.indexOf(minX)).toFloat();
    float x_miny = m_xPoints.at(m_yPoints.indexOf(minY)).toFloat();
    float y_maxx = m_yPoints.at(m_xPoints.indexOf(maxX)).toFloat();
    float x_maxy = m_xPoints.at(m_yPoints.indexOf(maxY)).toFloat();

    float tempX, tempY, x1, x2, x3, x4, y1, y2, y3, y4;

    //Restored coords
    tempX = minX - cx;
    tempY = y_minx - cy;
    x1 = tempX * cos(theta) - tempY * sin(theta);
    y1 = tempX * sin(theta) + tempY * cos(theta);

    tempX = x_miny - cx;
    tempY = minY - cy;
    x2 = tempX * cos(theta) - tempY * sin(theta);
    y2 = tempX * sin(theta) + tempY * cos(theta);

    tempX = maxX - cx;
    tempY = y_maxx - cy;
    x3 = tempX * cos(theta) - tempY * sin(theta);
    y3 = tempX * sin(theta) + tempY * cos(theta);

    tempX = x_maxy - cx;
    tempY = maxY - cy;
    x4 = tempX * cos(theta) - tempY * sin(theta);
    y4 = tempX * sin(theta) + tempY * cos(theta);

    //Finding width & height
    float top, bottom, left, right;
    top = qMax(y1, qMax(y2, qMax(y3, y4)));
    bottom = qMin(y1, qMin(y2, qMin(y3, y4)));
    left = qMin(x1, qMin(x2, qMin(x3, x4)));
    right = qMax(x1, qMax(x2, qMax(x3, x4)));

    float width, height;
    width = right - left;
    height = top - bottom;

    //Write new prop-s
    m_shape["cx"] = cx;
    m_shape["cy"] = cy;
    m_shape["width"] = width;
    m_shape["height"] = height;

    m_shape.remove("xPoints");
    m_shape.remove("yPoints");

    m_shapes.replace(num, m_shape);

    m_conv->replaceShapesData(m_shapes);
}

void PostProcessedSvgData::processEllipseParams(int num, const QString &itemKind)
{
    //Ellipse bounds
    float minX = m_shape["bounds"].toList()[0].toFloat();
    float minY = m_shape["bounds"].toList()[1].toFloat();
    float maxX = m_shape["bounds"].toList()[2].toFloat();
    float maxY = m_shape["bounds"].toList()[3].toFloat();

    //Ellipse centre
    float cx = (maxX + minX)/2;
    float cy = (maxY + minY)/2;

//    float minR = FLT_MAX;
//    float maxR = 0;
//    float maxRX, maxRY;
//    float distance;

//   for(int i = 0; i < m_xPoints.count(); ++i)
//    {
//        distance = sqrt( pow(centreX - m_xPoints[i].toFloat(), 2) + pow(centreY - m_yPoints[i].toFloat(), 2) );

//        if(distance < minR)
//            minR = distance;

//        if(distance > maxR)
//        {
//            maxR = distance;
//            maxRX = m_xPoints[i].toFloat();
//            maxRY = m_yPoints[i].toFloat();
//        }
//    }

    //Number of path points
    int npts = m_shape["npts"].toInt();

    //Origin x's and y's
    QList<float> origX;
    QList<float> origY;

    //Angle
    float theta = m_shape["angle"].toFloat() * M_PI / 180;

    float tempX, tempY, rx, ry;

    //Getting origin restored points
    for(int i = 0; i < npts; i++)
    {
        tempX = m_xPoints[i].toFloat() - cx;
        tempY = m_yPoints[i].toFloat() - cy;

        origX << tempX * cos(theta) - tempY * sin(theta);
        origY << tempX * sin(theta) + tempY * cos(theta);
    }

    //Sort from min to max
    qSort(origX);
    qSort(origY);

    //X and Y radiuses
    rx = origX[npts - 1] - origX[0];
    ry = origY[npts - 1] - origY[0];

    //Write new prop-s
    m_shape["cx"] = cx;
    m_shape["cy"] = cy;

    if( itemKind == "ellipse" )
    {
        m_shape["rx"] = rx / 2;
        m_shape["ry"] = ry / 2;
    }
    else
    {
        m_shape["r"] = rx / 2;
    }

    m_shape.remove("xPoints");
    m_shape.remove("yPoints");

    m_shapes.replace(num, m_shape);

    m_conv->replaceShapesData(m_shapes);
}

void PostProcessedSvgData::processLineParams(int num)
{
    //Line bounds
    float minX = m_shape["bounds"].toList()[0].toFloat();
    float minY = m_shape["bounds"].toList()[1].toFloat();
    float maxX = m_shape["bounds"].toList()[2].toFloat();
    float maxY = m_shape["bounds"].toList()[3].toFloat();

    //Get rest coords for bounds
    float y_minx = m_yPoints.at(m_xPoints.indexOf(minX)).toFloat();
    float x_miny = m_xPoints.at(m_yPoints.indexOf(minY)).toFloat();
    float y_maxx = m_yPoints.at(m_xPoints.indexOf(maxX)).toFloat();
    float x_maxy = m_xPoints.at(m_yPoints.indexOf(maxY)).toFloat();

    //Write prop-s

    m_shape["x1"] = minX;
    m_shape["y1"] = y_minx;
    m_shape["x2"] = maxX;
    m_shape["y2"] = y_maxx;

    m_shape.remove("xPoints");
    m_shape.remove("yPoints");

    m_shapes.replace(num, m_shape);

    m_conv->replaceShapesData(m_shapes);
}
