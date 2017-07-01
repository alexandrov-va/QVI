#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFile>
#include <QVector>
#include <QDebug>
#include <QTextStream>
#include <QDir>
#include <QtQml>

#include "svgconverter.h"
#include "postprocessedsvgdata.h"
#include <jsontools.h>
#include "fileio.h"
#include "configurationsmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    SvgConverter* svgConverter = new SvgConverter();
    PostProcessedSvgData* ppData = new PostProcessedSvgData();
    JsonTools* jsonTools = new JsonTools();
    FileIO* fileIO = new FileIO();
    ConfigurationsManager* configManager = new ConfigurationsManager();

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("init_config", configManager->getInitConfig());
    engine.rootContext()->setContextProperty("default_config", configManager->getDefaultConfig());
    engine.rootContext()->setContextProperty("svgConverter", qobject_cast<QObject*>(svgConverter));
    engine.rootContext()->setContextProperty("postProcessedSvgData", qobject_cast<QObject*>(ppData));
    engine.rootContext()->setContextProperty("jsonTools", qobject_cast<QObject*>(jsonTools));
    engine.rootContext()->setContextProperty("fileIO", qobject_cast<QObject*>(fileIO));


    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

