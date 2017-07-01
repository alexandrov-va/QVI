#include "svgconverter.h"
#include "nanosvg.h"
#include "jsontools.h"
#include <exception>

#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>

#define M_PI 3.14159


SvgConverter::SvgConverter(const QString & filename)
{
    this->m_image = nsvgParseFromFile(filename.toStdString().c_str(), "mm", 100);
}

//SvgConverter::SvgConverter(const SvgConverter &copy)
//{/*
//    this->shapesList = copy.shapesList;
//    this->image = new NSVGimage()*/
//}

SvgConverter::~SvgConverter()
{
    delete m_image;
    delete m_shape;
    delete m_path;
}

SvgConverter::SvgConverter(const SvgConverter &copy)
{
    m_image = new NSVGimage;
    m_shape = new NSVGshape;
    m_path = new NSVGpath;

    *m_image = *copy.m_image;
    //*m_shape = *copy.m_shape;
    //*m_path = *copy.m_path;
    m_shapesList = copy.m_shapesList;
    m_svgData = copy.m_svgData;
}

SvgConverter::SvgConverter()
{

}

void SvgConverter::replaceShapesData(QVariantList shapes)
{
    m_svgData["shapes"] = QVariant(shapes);
}

void SvgConverter::parseImage(const QString & filename)
{
    this->m_image = nsvgParseFromFile(filename.toStdString().c_str(), "px", 100);

    for(m_shape = m_image->shapes; m_shape; m_shape = m_shape->next)
    {
        QVariantMap m_shapeData;
        m_path = m_shape->paths;
        m_shapeData["npts"] = m_path->npts;
        m_shapeData["type"] = QString::fromUtf8(m_shape->itemKind.c_str());
        m_shapeData["id"] = m_shape->id;
        m_shapeData["opacity"] = m_shape->opacity;

        QList<QVariant> boundsList;
        for(int i = 0; i < 4; ++i)
        {
            boundsList.push_back(m_shape->bounds[i]);
        }
        m_shapeData["bounds"] = boundsList;
        m_shapeData["strokeWidth"] = QVariant(m_shape->strokeWidth);
        m_shapeData["strokeDashOffset"] = m_shape->strokeDashOffset;

        QList<QVariant> xFormList;
        for(int i = 0; i < 6; i++)
            xFormList.push_back(m_shape->xform[i]);

        float cos = m_shape->xform[0];
        float sin = m_shape->xform[2];

        float angle = (cos == 0? 0: atan(sin/cos));

//        if(sin >= 0 && cos < 0)
//            angle += M_PI/2;
//        else if(sin < 0 && cos < 0)
//            angle -= M_PI/2;

        m_shapeData["angle"] = angle * 180 / M_PI;

        QList<QVariant> strokeDashList;
        for(int i = 0; i < 8; ++i)
        {
            strokeDashList.push_back(m_shape->strokeDashArray[i]);
        }

        m_shapeData["strokeDashArray"] = QVariant(strokeDashList);

        m_shapeData["strokeDashCount"] = m_shape->strokeDashCount;
        m_shapeData["strokeLineJoin"] = m_shape->strokeLineJoin;
        m_shapeData["strokeLineCap"] = m_shape->strokeLineCap;
        m_shapeData["fillRule"] = (m_shape->fillRule == 0? "nonzero": "evenodd");
        m_shapeData["flags"] = m_shape->flags;

        QVariantMap rgbColor;
        QVariantList listColor;
        rgbColor["r"] = 0;
        rgbColor["g"] = 0;
        rgbColor["b"] = 0;

        m_shapeData["fillPaintType"] = "none";
        m_shapeData["fillPaintColor"] = rgbColor;

        switch(m_shape->fill.type)
        {
        case NSVG_PAINT_COLOR:
            m_shapeData["fillPaintType"] = "color";
            listColor = getRgbFromHex(m_shape->fill.color);
            rgbColor["r"] = QVariant(listColor[0].toFloat() / 255.0f);
            rgbColor["g"] = QVariant(listColor[1].toFloat() / 255.0f);
            rgbColor["b"] = QVariant(listColor[2].toFloat() / 255.0f);
            m_shapeData["fillPaintColor"] = QVariant(rgbColor);
            break;
        case NSVG_PAINT_LINEAR_GRADIENT:
            m_shapeData["fillPaintType"] = "color";
            listColor = getRgbFromHex(m_shape->fill.gradient->stops[0].color);
            rgbColor["r"] = QVariant(listColor[0].toFloat() / 255.0f);
            rgbColor["g"] = QVariant(listColor[1].toFloat() / 255.0f);
            rgbColor["b"] = QVariant(listColor[2].toFloat() / 255.0f);
            m_shapeData["fillPaintColor"] = QVariant(rgbColor);
            break;
        case NSVG_PAINT_RADIAL_GRADIENT:
            m_shapeData["fillPaintType"] = "color";
            listColor = getRgbFromHex(m_shape->fill.gradient->stops[0].color);
            rgbColor["r"] = QVariant(listColor[0].toFloat() / 255.0f);
            rgbColor["g"] = QVariant(listColor[1].toFloat() / 255.0f);
            rgbColor["b"] = QVariant(listColor[2].toFloat() / 255.0f);
            m_shapeData["fillPaintColor"] = QVariant(rgbColor);
            break;
        }

        rgbColor["r"] = 0;
        rgbColor["g"] = 0;
        rgbColor["b"] = 0;

        m_shapeData["strokePaintType"] = "none";
        m_shapeData["strokePaintColor"] = rgbColor;

        switch(m_shape->stroke.type)
        {
        case NSVG_PAINT_COLOR:
            m_shapeData["strokePaintType"] = "color";
            listColor = getRgbFromHex(m_shape->stroke.color);
            rgbColor["r"] = QVariant(listColor[0].toFloat() / 255.0f);
            rgbColor["g"] = QVariant(listColor[1].toFloat() / 255.0f);
            rgbColor["b"] = QVariant(listColor[2].toFloat() / 255.0f);
            m_shapeData["strokePaintColor"] = QVariant(rgbColor);
            break;
        case NSVG_PAINT_LINEAR_GRADIENT:
            m_shapeData["strokePaintType"] = "color";
            listColor = getRgbFromHex(m_shape->stroke.gradient->stops[0].color);
            rgbColor["r"] = QVariant(listColor[0].toFloat() / 255.0f);
            rgbColor["g"] = QVariant(listColor[1].toFloat() / 255.0f);
            rgbColor["b"] = QVariant(listColor[2].toFloat() / 255.0f);
            m_shapeData["fillPaintColor"] = QVariant(rgbColor);
            break;
        case NSVG_PAINT_RADIAL_GRADIENT:
            m_shapeData["strokePaintType"] = "color";
            listColor = getRgbFromHex(m_shape->stroke.gradient->stops[0].color);
            rgbColor["r"] = QVariant(listColor[0].toFloat() / 255.0f);
            rgbColor["g"] = QVariant(listColor[1].toFloat() / 255.0f);
            rgbColor["b"] = QVariant(listColor[2].toFloat() / 255.0f);
            m_shapeData["fillPaintColor"] = QVariant(rgbColor);
            break;
        }

        QList<QVariant> xPoints;
        QList<QVariant> yPoints;
        for(int i = 0; i < m_path->npts; ++i)
        {
            xPoints.push_back(QVariant(m_path->pts[i*2 + 0]));
            yPoints.push_back(QVariant(m_path->pts[i*2 + 1]));
        }

        m_shapeData["xPoints"] = QVariant(xPoints);
        m_shapeData["yPoints"] = QVariant(yPoints);
        m_shapeData["isPathClosed"] = QVariant(m_path->closed == 1);

        m_shapesList.push_back(QVariant(m_shapeData));
    }

    m_svgData["width"] = m_image->width;
    m_svgData["height"] = m_image->height;
    m_svgData["shapes"] = QVariant(m_shapesList);
}


QString SvgConverter::writeToJsonFile(const QString &filename)
{
    QJsonObject jsonData = QJsonObject::fromVariantMap(m_svgData);
    QJsonDocument jsonDocument = QJsonDocument(jsonData);

    return QString(jsonDocument.toJson());
//    QFile jsonFile(filename);
//    jsonFile.open(QFile::WriteOnly);
//    jsonFile.write(jsonDocument.toJson());

//    jsonFile.close();
//    qDebug () << m_svgData << filename;

//    JsonTools::toFile(m_svgData, filename);
}

void SvgConverter::writeInGradient(QVariantMap& data, const NSVGgradient* const gradient)
{
    QList<QVariant> xFormList;
    for(int i = 0; i < 6; ++i)
    {
        xFormList.push_back(gradient->xform[i]);
    }
    data["xform"] = QVariant(xFormList);

    data["spread"] = gradient->spread;
    data["fx"] = gradient->fx;
    data["fy"] = gradient->fy;
    data["nstops"] = gradient->nstops;

    QVariantMap gradientStopData;
    gradientStopData["color"] = gradient->stops[0].color;
    gradientStopData["offset"] = gradient->stops[0].offset;

    data["gradientStop"] = gradientStopData;
}

QVariantList SvgConverter::getRgbFromHex(int color)
{
    QVariantList rgbList;
    for(int i = 0; i < 3; i++)
    {
        rgbList.push_back((color >> 8*i) & 0xFF);
    }

    return rgbList;
}
