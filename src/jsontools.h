#ifndef JSONTOOLS
#define JSONTOOLS

#include <QVariantMap>
#include <QFile>
#include <QSaveFile>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QObject>

#include <QDebug>

class JsonTools: public QObject
{
    Q_OBJECT
public:
    template <typename T>
    static QVariantList toQVariantListFromTypeList(const QList<T> &list)
    {
       QVariantList variantList;
       for (int i = 0; i < list.size(); ++i) {
           variantList.push_back(qvariant_cast<QVariant>(list[i]));
       }
       return variantList;
    }

    template <typename T>
    static T toTypeListFromQVariantList(const QVariantList &list) {
        QList<T> typeList;
        for (int i = 0; i < list.size(); ++i) {
            typeList.push_back(qvariant_cast<T>(list[i]));
        }
        return typeList;
    }

public slots:

    Q_INVOKABLE static QVariantMap fromFile(const QString& path)
    {
        QVariantMap result;

        QFile file(path);

        if (file.open(QFile::ReadOnly))
        {
            QJsonParseError parseError;
            QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &parseError);

            if (parseError.error == QJsonParseError::NoError)
                result = doc.toVariant().value<QVariantMap>();
            else
                qWarning() << QString("can't parse %1: %2").arg(file.fileName(), parseError.errorString()).toUtf8().constData();
        }
        else
            qWarning() << QString("can't open %1 for reading: %2").arg(file.fileName(), file.errorString()).toUtf8().constData();

        return result;
    }

    Q_INVOKABLE static bool toFile(const QVariantMap& data, const QString& path)
    {
        bool result = false;

        QSaveFile file(path);

        if (file.open(QFile::WriteOnly))
        {
            file.write(QJsonDocument::fromVariant(data).toJson());
            result = file.commit();

            if (!result)
                qWarning() << QString("can't commit %1: %2").arg(file.fileName(), file.errorString()).toUtf8().constData();
        }
        else
            qWarning() << QString("can't open %1 for writing: %2").arg(file.fileName(), file.errorString()).toUtf8().constData();

        return result;
    }
};

#endif // JSONTOOLS

