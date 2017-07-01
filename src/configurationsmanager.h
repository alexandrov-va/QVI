#ifndef CONFIGURATIONSMANAGER_H
#define CONFIGURATIONSMANAGER_H

#include <QVariantMap>
#include "jsontools.h"

#include <QObject>


class ConfigurationsManager: public QObject
{
    Q_OBJECT
public:
    ConfigurationsManager();
    Q_INVOKABLE QVariantMap getInitConfig();
    Q_INVOKABLE QVariantMap getDefaultConfig();
private:
    QVariantMap m_defaultConfig;
    QVariantMap m_initConfig;
    JsonTools m_jsonTools;
};

#endif // CONFIGURATIONSMANAGER_H
