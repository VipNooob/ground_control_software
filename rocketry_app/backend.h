#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QtQml/qqml.h>
#include <QQmlEngine>
#include <QJSEngine>
#include <QDebug>
#include <QSerialPortInfo>
#include <QList>
#include <QSerialPort>
#include <QTimer>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <QVariant>


class Backend : public QObject
{
    Q_OBJECT

private:
    static Backend* m_instance;
    QSerialPort* currentSerialPort;
    QList<QSerialPortInfo> serialPortInfoList;
    QTimer *serialPortRefreshTimer;

public:
    explicit Backend(QObject* parent = nullptr);
    static QObject* createSingletonInstance(QQmlEngine* engine,  QJSEngine* scriptEngine);
    static Backend* getInstance(QObject* parent = nullptr);

signals:
    void sendSerialPortsInfo(QVariantList portsInfo);

public slots:
    void onOpenSerialPort();
    void onCloseSerialPort();
    void updateSerialPortsInfo();
};

#endif // BACKEND_H
