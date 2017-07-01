#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>

class FileIO: public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE  QString read(const QString& fileName);
    Q_INVOKABLE bool write(const QString& fileName, const QString& data);
    FileIO();
};

#endif // FILEIO_H
