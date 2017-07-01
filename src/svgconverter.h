#ifndef SVGCONVERTER_H
#define SVGCONVERTER_H

#include <QList>
#include <QVariant>
#include <QObject>

struct NSVGimage;
struct NSVGshape;
struct NSVGpath;
struct NSVGgradient;


class SvgConverter: public QObject
{
    Q_OBJECT
    //friend SvgConverter & operator =(SvgConverter &svgConverter);
    //friend class PostProcessedSvgData;
public:
    SvgConverter(const QString & filename);
    SvgConverter(const SvgConverter &copy);
    SvgConverter();

    SvgConverter & operator =(SvgConverter &svgConverter)
    {
        SvgConverter loc_svgConverter(svgConverter);
        return loc_svgConverter;
    }

    void replaceShapesData(QVariantList shapes);

    ~SvgConverter();

    QVariantMap m_svgData;

public slots:

    Q_INVOKABLE void parseImage(const QString & filename);

    Q_INVOKABLE QString writeToJsonFile(const QString & filename);

private:
  //  SvgConverter & operator =(const SvgConverter &svgConverter){}



    NSVGimage* m_image;
    NSVGshape* m_shape;
    NSVGpath* m_path;

    QList<QVariant> m_shapesList;

    void writeInGradient(QVariantMap& data, const NSVGgradient* const gradient);
    QVariantList getRgbFromHex(int color);



};



#endif // SVGCONVERTER_H
