#include "backend.h"

Backend *Backend::m_instance=nullptr;
Backend::Backend(QObject *parent) : QObject(parent), currentSerialPort(new QSerialPort), serialPortInfoList(QSerialPortInfo::availablePorts()),
    serialPortRefreshTimer(new QTimer)
{
    serialPortRefreshTimer->start(100);
    QObject::connect(serialPortRefreshTimer, SIGNAL(timeout()), this, SLOT(onUpdateSerialPortsTimerTimeout()));
}

QObject* Backend::createSingletonInstance(QQmlEngine *engine, QJSEngine *scriptEngine){
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);
    // Check whether the object exists or not
    if(m_instance){
        return m_instance;
    }
    // if the object does not exist, create it
    m_instance = new Backend();
    engine->setObjectOwnership(m_instance, QQmlEngine::CppOwnership);

    return m_instance;
}

Backend* Backend::getInstance(QObject* parent){
    if(m_instance)
        return  qobject_cast<Backend*>(Backend::m_instance);

    auto instance = new Backend(parent);
    m_instance = instance;
    return  instance;
}

void Backend::emitInitialSignals(){

    // Poll serial ports
    QList<QSerialPortInfo> updatedSerialPortsInfoList = QSerialPortInfo::availablePorts();

    // List containing each port info
    QVariantList portsInfo;

    for (auto portInfo: updatedSerialPortsInfoList){
        QVariantMap portMap;
        portMap["portName"] = portInfo.portName();
        portMap["systemLocation"] = portInfo.systemLocation();
        portMap["description"] = portInfo.description();
        portMap["manufacturer"] = portInfo.manufacturer();
        portMap["serialNumber"] = portInfo.serialNumber();
        portMap["vendorIdentifier"] = portInfo.vendorIdentifier();
        portMap["productIdentifier"] = portInfo.productIdentifier();
        portsInfo.append(portMap);
    }
    emit sendSerialPortsInfo(portsInfo);

    // Get all required initial backend data
    QList<qint32> temp_baudrates = QSerialPortInfo::standardBaudRates();
    QVariantList baudrates;

    for (auto start{temp_baudrates.begin()}; start < temp_baudrates.end(); start++) {
        baudrates.append(*start);
    }
    // send a signal that transmit initial data to the frontend part
    emit sendBaudRates(baudrates);
}

void Backend::onOpenSerialPort(){
    qDebug() << "Port has been opened!";
}

void Backend::onCloseSerialPort(){
    qDebug() << "Port has been closed!";
}

void Backend::onUpdateSerialPortsTimerTimeout(){
    // Poll serial ports
    QList<QSerialPortInfo> updatedSerialPortsInfoList = QSerialPortInfo::availablePorts();
    // Compare two lists
    // TODO

    // List containing each port info
    QVariantList portsInfo;

    for (auto portInfo: updatedSerialPortsInfoList){
        QVariantMap portMap;
        portMap["portName"] = portInfo.portName();
        portMap["systemLocation"] = portInfo.systemLocation();
        portMap["description"] = portInfo.description();
        portMap["manufacturer"] = portInfo.manufacturer();
        portMap["serialNumber"] = portInfo.serialNumber();
        portMap["vendorIdentifier"] = portInfo.vendorIdentifier();
        portMap["productIdentifier"] = portInfo.productIdentifier();
        portsInfo.append(portMap);
    }
    emit sendSerialPortsInfo(portsInfo);
}


