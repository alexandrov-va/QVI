#include "fileio.h"
#include <QFile>
#include <QTextStream>

FileIO::FileIO()
{

}

QString FileIO::read(const QString &fileName)
{
    if(fileName.isEmpty())
    {
        return QString();
    }

    QFile file(fileName);
    QString fileContent;
    if(file.open(QFile::ReadOnly))
    {
        QString line;
        QTextStream t(&file);
        do
        {
            line = t.readLine();
            fileContent += line + '\n';
        }
        while (!line.isNull());

        file.close();
    }
    else
    {
        return QString();
    }

    return fileContent;
}


bool FileIO::write(const QString &fileName, const QString &data)
{
    if(fileName.isEmpty())
        return false;

    QFile file(fileName);

    if(!file.open(QFile::WriteOnly | QFile::Truncate))
        return false;

    QTextStream out(&file);
    out << data;

    file.close();

    return true;
}
