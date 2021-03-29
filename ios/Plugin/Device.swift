import Foundation
import CoreBluetooth
import CoreBluetooth

class Device: NSObject, CBPeripheralDelegate {
    typealias Callback = (_ success: Bool, _ value: String) -> Void
    typealias Callback = (_ success: Bool, _ value: String) -> Void


    private var peripheral: CBPeripheral!
    private var peripheral: CBPeripheral!
    private var callbackMap = [String: Callback]()
    private var callbackMap = [String: Callback]()
    private var timeoutMap = [String: DispatchWorkItem]()
    private var timeoutMap = [String: DispatchWorkItem]()
    private var servicesCount = 0
    private var servicesCount = 0
    private var servicesDiscovered = 0
    private var servicesDiscovered = 0


    init(_ peripheral: CBPeripheral) {
        init(_ peripheral: CBPeripheral) {
        super.init()
        super.init()
        self.peripheral = peripheral
        self.peripheral = peripheral
        self.peripheral.delegate = self
        self.peripheral.delegate = self
    }
    }

func getName() -> String? {
        return self.peripheral.name
        return self.peripheral.name
    }
    }

func getId() -> String {
            return self.peripheral.identifier.uuidString
            return self.peripheral.identifier.uuidString
        }
        }

func isConnected() -> Bool {
            return self.peripheral.state == CBPeripheralState.connected
            return self.peripheral.state == CBPeripheralState.connected
        }
        }

func getPeripheral() -> CBPeripheral {
    return self.peripheral
    return self.peripheral
}
}

func setOnConnected(_ callback: @escaping Callback) {
        let key = "connect"
        let key = "connect"
        self.callbackMap[key] = callback
        self.callbackMap[key] = callback
        self.setTimeout(key, "Connection timeout", connectionTimeout)
        self.setTimeout(key, "Connection timeout", connectionTimeout)
    }
    }

func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    print("didDiscoverServices")
    print("didDiscoverServices")
    if error != nil {
    if error != nil {
                print("Error", error!.localizedDescription)
                print("Error", error!.localizedDescription)
                return
                return
            }
            }
    self.servicesCount = peripheral.services?.count ?? 0
    self.servicesCount = peripheral.services?.count ?? 0
    self.servicesDiscovered = 0
    self.servicesDiscovered = 0
        for service in peripheral.services! {
    for service in peripheral.services! {
    peripheral.discoverCharacteristics(nil, for: service)
    peripheral.discoverCharacteristics(nil, for: service)
}
}
}
}

func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            self.servicesDiscovered += 1
            self.servicesDiscovered += 1
            print("didDiscoverCharacteristicsFor", self.servicesDiscovered, self.servicesCount)
            print("didDiscoverCharacteristicsFor", self.servicesDiscovered, self.servicesCount)
            if self.servicesDiscovered >= self.servicesCount {
            if self.servicesDiscovered >= self.servicesCount {
            self.resolve("connect", "Connection successful.")
            self.resolve("connect", "Connection successful.")
        }
        }
        }
        }

private func getCharacterisitic(_ serviceUUID: CBUUID, _ characteristicUUID: CBUUID) -> CBCharacteristic? {
        for service in peripheral.services ?? [] {
        for service in peripheral.services ?? [] {
        if service.uuid == serviceUUID {
        if service.uuid == serviceUUID {
        for characteristic in service.characteristics ?? [] {
        for characteristic in service.characteristics ?? [] {
                    if characteristic.uuid == characteristicUUID {
                    if characteristic.uuid == characteristicUUID {
                    return characteristic
                    return characteristic
                }
                }
                }
                }
    }
    }
    }
    }
            return nil
            return nil
}
}

func read(_ serviceUUID: CBUUID, _ characteristicUUID: CBUUID, _ callback: @escaping Callback) {
            let key = "read|\(serviceUUID.uuidString)|\(characteristicUUID.uuidString)"
            let key = "read|\(serviceUUID.uuidString)|\(characteristicUUID.uuidString)"
            self.callbackMap[key] = callback
            self.callbackMap[key] = callback
            guard let characteristic = self.getCharacterisitic(serviceUUID, characteristicUUID) else {
            guard let characteristic = self.getCharacterisitic(serviceUUID, characteristicUUID) else {
        self.reject(key, "Characteristic not found.")
        self.reject(key, "Characteristic not found.")
        return
        return
    }
    }
            print("Reading value")
            print("Reading value")
            self.peripheral.readValue(for: characteristic)
            self.peripheral.readValue(for: characteristic)
            self.setTimeout(key, "Read timeout.")
            self.setTimeout(key, "Read timeout.")
        }
        }

func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
                let key = self.getKey("read", characteristic)
                let key = self.getKey("read", characteristic)
                let notifyKey = self.getKey("notification", characteristic)
                let notifyKey = self.getKey("notification", characteristic)
                if error != nil {
                if error != nil {
                self.reject(key, error!.localizedDescription)
                self.reject(key, error!.localizedDescription)
                return
                return
            }
            }
                if characteristic.value == nil {
                if characteristic.value == nil {
            self.reject(key, "Characterisitc contains no value.")
            self.reject(key, "Characterisitc contains no value.")
            return
            return
        }
        }
                // reading
                // reading
        let valueString = dataToString(characteristic.value!)
        let valueString = dataToString(characteristic.value!)
        self.resolve(key, valueString)
        self.resolve(key, valueString)


// notifications
// notifications
let callback = self.callbackMap[notifyKey]
let callback = self.callbackMap[notifyKey]
if callback != nil {
        if callback != nil {
                        callback!(true, valueString)
                        callback!(true, valueString)
                    }
                    }
}
}

func write(_ serviceUUID: CBUUID, _ characteristicUUID: CBUUID, _ value: String, _ writeType: CBCharacteristicWriteType, _ callback: @escaping Callback) {
                    let key = "write|\(serviceUUID.uuidString)|\(characteristicUUID.uuidString)"
                    let key = "write|\(serviceUUID.uuidString)|\(characteristicUUID.uuidString)"
                    self.callbackMap[key] = callback
                    self.callbackMap[key] = callback
                    guard let characteristic = self.getCharacterisitic(serviceUUID, characteristicUUID) else {
                    guard let characteristic = self.getCharacterisitic(serviceUUID, characteristicUUID) else {
        self.reject(key, "Characteristic not found.")
        self.reject(key, "Characteristic not found.")
        return
        return
    }
    }
                    let data: Data = stringToData(value)
                    let data: Data = stringToData(value)
                    self.peripheral.writeValue(data, for: characteristic, type: writeType)
                    self.peripheral.writeValue(data, for: characteristic, type: writeType)
                    if writeType == CBCharacteristicWriteType.withResponse {
                    if writeType == CBCharacteristicWriteType.withResponse {
    self.setTimeout(key, "Write timeout.")
    self.setTimeout(key, "Write timeout.")
} else {
} else {
                self.resolve(key, "Successfully written value.")
                self.resolve(key, "Successfully written value.")
            }
            }
        }
}

func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
                let key = self.getKey("write", characteristic)
                let key = self.getKey("write", characteristic)
                if error != nil {
                if error != nil {
            self.reject(key, error!.localizedDescription)
            self.reject(key, error!.localizedDescription)
            return
            return
        }
        }
                self.resolve(key, "Successfully written value.")
                self.resolve(key, "Successfully written value.")
            }
            }

func setNotifications(
                _ serviceUUID: CBUUID,
                _ serviceUUID: CBUUID,
                _ characteristicUUID: CBUUID,
                _ characteristicUUID: CBUUID,
                _ enable: Bool,
                _ enable: Bool,
                _ notifyCallback: Callback?,
                _ notifyCallback: Callback?,
                _ callback: @escaping Callback
                _ callback: @escaping Callback
            ) {
            ) {
                let key = "setNotifications|\(serviceUUID.uuidString)|\(characteristicUUID.uuidString)"
                let key = "setNotifications|\(serviceUUID.uuidString)|\(characteristicUUID.uuidString)"
                let notifyKey = "notification|\(serviceUUID.uuidString)|\(characteristicUUID.uuidString)"
                let notifyKey = "notification|\(serviceUUID.uuidString)|\(characteristicUUID.uuidString)"
                self.callbackMap[key] = callback
                self.callbackMap[key] = callback
                if notifyCallback != nil {
                if notifyCallback != nil {
                    self.callbackMap[notifyKey] = notifyCallback
                    self.callbackMap[notifyKey] = notifyCallback
                }
                }
                guard let characteristic = self.getCharacterisitic(serviceUUID, characteristicUUID) else {
                guard let characteristic = self.getCharacterisitic(serviceUUID, characteristicUUID) else {
                    self.reject(key, "Characteristic not found.")
                    self.reject(key, "Characteristic not found.")
                    return
                    return
                }
                }
    print("Set notifications", enable)
    print("Set notifications", enable)
    self.peripheral.setNotifyValue(enable, for: characteristic)
    self.peripheral.setNotifyValue(enable, for: characteristic)
    self.setTimeout(key, "Set notifications timeout.")
    self.setTimeout(key, "Set notifications timeout.")
}
}

func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
                let key = self.getKey("setNotifications", characteristic)
                let key = self.getKey("setNotifications", characteristic)
                if error != nil {
                if error != nil {
                self.reject(key, error!.localizedDescription)
                self.reject(key, error!.localizedDescription)
                return
                return
            }
            }
                self.resolve(key, "Successfully set notifications.")
                self.resolve(key, "Successfully set notifications.")
            }
            }

private func getKey(_ prefix: String, _ characteristic: CBCharacteristic) -> String {
            var serviceUUIDString = characteristic.service.uuid.uuidString
            var serviceUUIDString = characteristic.service.uuid.uuidString
            if serviceUUIDString.count == 4 {
            if serviceUUIDString.count == 4 {
            serviceUUIDString = "0000\(serviceUUIDString)-0000-1000-8000-00805F9B34FB"
            serviceUUIDString = "0000\(serviceUUIDString)-0000-1000-8000-00805F9B34FB"
        }
        }
            var characteristicUUIDString = characteristic.uuid.uuidString
            var characteristicUUIDString = characteristic.uuid.uuidString
            if characteristicUUIDString.count == 4 {
            if characteristicUUIDString.count == 4 {
    characteristicUUIDString = "0000\(characteristicUUIDString)-0000-1000-8000-00805F9B34FB"
    characteristicUUIDString = "0000\(characteristicUUIDString)-0000-1000-8000-00805F9B34FB"
}
}
            return "\(prefix)|\(serviceUUIDString)|\(characteristicUUIDString)"
            return "\(prefix)|\(serviceUUIDString)|\(characteristicUUIDString)"
        }
        }

private func resolve(_ key: String, _ value: String) {
                        let callback = self.callbackMap[key]
                        let callback = self.callbackMap[key]
                        if callback != nil {
                        if callback != nil {
    print("Resolve", key, value)
    print("Resolve", key, value)
    callback!(true, value)
    callback!(true, value)
    self.callbackMap[key] = nil
    self.callbackMap[key] = nil
    self.timeoutMap[key]?.cancel()
    self.timeoutMap[key]?.cancel()
    self.timeoutMap[key] = nil
    self.timeoutMap[key] = nil
} else {
} else {
                        print("Resolve callback not registered for key: ", key)
                        print("Resolve callback not registered for key: ", key)
                    }
                    }
                    }
                    }

private func reject(_ key: String, _ value: String) {
            let callback = self.callbackMap[key]
            let callback = self.callbackMap[key]
            if callback != nil {
            if callback != nil {
        print("Reject", key, value)
        print("Reject", key, value)
        callback!(false, value)
        callback!(false, value)
        self.callbackMap[key] = nil
        self.callbackMap[key] = nil
        self.timeoutMap[key]?.cancel()
        self.timeoutMap[key]?.cancel()
        self.timeoutMap[key] = nil
        self.timeoutMap[key] = nil
    } else {
    } else {
                        print("Reject callback not registered for key: ", key)
                        print("Reject callback not registered for key: ", key)
                    }
                    }
        }
        }

private func setTimeout(_ key: String, _ message: String, _ timeout: Double = defaultTimeout) {
    let workItem = DispatchWorkItem {
    let workItem = DispatchWorkItem {
                    self.reject(key, message)
                    self.reject(key, message)
                }
                }
    self.timeoutMap[key] = workItem
    self.timeoutMap[key] = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: workItem)
    DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: workItem)
}
}
}
}







































