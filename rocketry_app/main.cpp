#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QApplication>
#include <QObject>
#include <QQuickItem>
#include <QQmlContext>
#include <QtQml/QQmlEngine>
#include <QDebug>
#include "backend.h"




int main(int argc, char *argv[])
{

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Register singleton instance in QML
    qmlRegisterSingletonType<Backend>("Backend", 1, 0, "Sinstance", Backend::createSingletonInstance);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    // Getting singleton's pointer in order to implement signal-slot functionality
    Backend* cppSingelton = Backend::getInstance();
    // Find required objects in QML
    QObject* mainWindowPointer = engine.rootObjects().first();
    QObject* openSerialPortButtonPointer = engine.rootObjects().first()->findChild<QQuickItem*>("open_serial_port_button");
    QObject* closeSerialPortButtonPointer = engine.rootObjects().first()->findChild<QQuickItem*>("close_serial_port_button");

    QObject::connect(openSerialPortButtonPointer, SIGNAL(openSerialPort()), cppSingelton, SLOT(onOpenSerialPort()));
    QObject::connect(closeSerialPortButtonPointer, SIGNAL(closeSerialPort()), cppSingelton, SLOT(onCloseSerialPort()));


    cppSingelton->emitInitialSignals();

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
