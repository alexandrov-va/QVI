#ifndef POSTPROCESSEDSVGDATA_H
#define POSTPROCESSEDSVGDATA_H


#include <QList>
#include <QVariant>
#include <QObject>

class SvgConverter;


class PostProcessedSvgData: public QObject
{
    Q_OBJECT
public:

    PostProcessedSvgData(const SvgConverter& conv);
    PostProcessedSvgData(const PostProcessedSvgData& copy);
    PostProcessedSvgData();
    ~PostProcessedSvgData();

public slots:
    Q_INVOKABLE void setConvData(SvgConverter *conv);
    Q_INVOKABLE void process(const QString &filePath);

    Q_INVOKABLE QString writeToJsonFile(const QString & filename);

private:
    SvgConverter* m_conv;
    QVariantMap m_shape;
    QList<QVariant> m_xPoints;
    QList<QVariant> m_yPoints;
    QList<QVariant> m_shapes;

    void processRectParams(int num);

    void processEllipseParams(int num, const QString & itemKind);
    void processLineParams(int num);
    void processPoly(int num);
    float getBoundingBoxAngle(float, float, float, float);
};

#endif // POSTPROCESSEDSVGDATA_H
