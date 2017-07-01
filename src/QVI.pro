TEMPLATE = app

QT += qml quick
CONFIG += c++11

SOURCES += main.cpp \
    svgconverter.cpp \
    postprocessedsvgdata.cpp \
    fileio.cpp \
    configurationsmanager.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    jsontools.h \
    svgconverter.h \
    nanosvg.h \
    postprocessedsvgdata.h \
    fileio.h \
    configurationsmanager.h

DISTFILES +=
