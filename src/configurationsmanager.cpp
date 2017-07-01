#include "configurationsmanager.h"

ConfigurationsManager::ConfigurationsManager()
{
    m_defaultConfig["rightbar_width"] = 300;
    m_defaultConfig["leftbar_width"] = 300;
    m_defaultConfig["toolbar_height"] = 40;
    m_defaultConfig["settingsbar_height"] = 40;
    m_defaultConfig["grid_enabled"] = false;
    m_defaultConfig["grid_step"] = 10;
    m_defaultConfig["selection_enabled"] = true;
    m_defaultConfig["window_width"] = 1024;
    m_defaultConfig["window_height"] = 480;

    m_initConfig = m_jsonTools.fromFile("current_config.json");

    if(m_initConfig.keys().length() != m_defaultConfig.keys().length())
    {
        m_initConfig = m_defaultConfig;
    }

    m_jsonTools.toFile(m_initConfig, "current_config.json");
}

QVariantMap ConfigurationsManager::getInitConfig()
{
    return m_initConfig;
}

QVariantMap ConfigurationsManager::getDefaultConfig()
{
    return m_defaultConfig;
}
