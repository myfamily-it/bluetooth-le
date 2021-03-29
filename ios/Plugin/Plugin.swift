import Foundation
import Capacitor
import Capacitor
import CoreBluetooth
import CoreBluetooth

@objc(BluetoothLe)
public class BluetoothLe: CAPPlugin {
    public class BluetoothLe: CAPPlugin {
    private var deviceManager: DeviceManager?
    private var deviceManager: DeviceManager?
    private var deviceMap = [String: Device]()
    private var deviceMap = [String: Device]()


    @objc func initialize(_ call: CAPPluginCall) {
        @objc func initialize(_ call: CAPPluginCall) {
        let displayStrings = getConfigValue("displayStrings") as? [String: String] ?? [String: String]()
        let displayStrings = getConfigValue("displayStrings") as? [String: String] ?? [String: String]()
        self.deviceManager = DeviceManager(self.bridge?.viewController, displayStrings, {(success, message) -> Void in
        self.deviceManager = DeviceManager(self.bridge?.viewController, displayStrings, {(success, message) -> Void in
        if success {
        if success {
        call.resolve()
        call.resolve()
    } else {
    } else {
        call.reject(message)
        call.reject(message)
    }
    }
    })
    })
    }
}


    @objc func getEnabled(_ call: CAPPluginCall) {
            @objc func getEnabled(_ call: CAPPluginCall) {
            guard let deviceManager = self.getDeviceManager(call) else { return }
            guard let deviceManager = self.getDeviceManager(call) else { return }
            let enabled: Bool = deviceManager.getEnabled()
            let enabled: Bool = deviceManager.getEnabled()
            call.resolve(["value": enabled])
            call.resolve(["value": enabled])
        }
        }


    @objc func startEnabledNotifications(_ call: CAPPluginCall) {
        @objc func startEnabledNotifications(_ call: CAPPluginCall) {
            guard let deviceManager = self.getDeviceManager(call) else { return }
            guard let deviceManager = self.getDeviceManager(call) else { return }
        deviceManager.registerStateReceiver({(enabled) -> Void in
            deviceManager.registerStateReceiver({(enabled) -> Void in
        self.notifyListeners("onEnabledChanged", data: ["value": enabled])
        self.notifyListeners("onEnabledChanged", data: ["value": enabled])
        })
        })
        call.resolve()
        call.resolve()
    }
    }


    @objc func stopEnabledNotifications(_ call: CAPPluginCall) {
        @objc func stopEnabledNotifications(_ call: CAPPluginCall) {
        guard let deviceManager = self.getDeviceManager(call) else { return }
        guard let deviceManager = self.getDeviceManager(call) else { return }
    deviceManager.unregisterStateReceiver()
    deviceManager.unregisterStateReceiver()
    call.resolve()
    call.resolve()
}
    }


    @objc func requestDevice(_ call: CAPPluginCall) {
                @objc func requestDevice(_ call: CAPPluginCall) {
                guard let deviceManager = self.getDeviceManager(call) else { return }
                guard let deviceManager = self.getDeviceManager(call) else { return }
                let serviceUUIDs = self.getServiceUUIDs(call)
                let serviceUUIDs = self.getServiceUUIDs(call)
                let name = call.getString("name")
                let name = call.getString("name")
                let namePrefix = call.getString("namePrefix")
                let namePrefix = call.getString("namePrefix")


                deviceManager.startScanning(
            deviceManager.startScanning(
        serviceUUIDs,
        serviceUUIDs,
            name,
            name,
            namePrefix,
            namePrefix,
            false,
            false,
            true,
            true,
            30, {(success, message) -> Void in
                30, {(success, message) -> Void in
            // selected a device
            // selected a device
                if success {
            if success {
            guard let device = deviceManager.getDevice(message) else {
            guard let device = deviceManager.getDevice(message) else {
            call.reject("Device not found.")
            call.reject("Device not found.")
            return
            return
        }
            }
            self.deviceMap[device.getId()] = device
            self.deviceMap[device.getId()] = device
                let bleDevice = self.getBleDevice(device)
                let bleDevice = self.getBleDevice(device)
                call.resolve(bleDevice)
                call.resolve(bleDevice)
            } else {
    } else {
        call.reject(message)
        call.reject(message)
    }
        }
            }, {(_, _, _) -> Void in
            }, {(_, _, _) -> Void in


    }
            }
                )
                )
            }
            }


    @objc func requestLEScan(_ call: CAPPluginCall) {
        @objc func requestLEScan(_ call: CAPPluginCall) {
        guard let deviceManager = self.getDeviceManager(call) else { return }
        guard let deviceManager = self.getDeviceManager(call) else { return }
        let serviceUUIDs = self.getServiceUUIDs(call)
        let serviceUUIDs = self.getServiceUUIDs(call)
        let name = call.getString("name")
        let name = call.getString("name")
        let namePrefix = call.getString("namePrefix")
        let namePrefix = call.getString("namePrefix")
        let allowDuplicates = call.getBool("allowDuplicates", false)
        let allowDuplicates = call.getBool("allowDuplicates", false)


        deviceManager.startScanning(
        deviceManager.startScanning(
                    serviceUUIDs,
                    serviceUUIDs,
                    name,
                    name,
                    namePrefix,
                    namePrefix,
                    allowDuplicates,
                    allowDuplicates,
                    false,
                    false,
                    nil, {(success, message) -> Void in
                    nil, {(success, message) -> Void in
                    if success {
                    if success {
                    call.resolve()
                    call.resolve()
                } else {
                } else {
                    call.reject(message)
                    call.reject(message)
                }
                }
                }, {(device, advertisementData, rssi) -> Void in
                }, {(device, advertisementData, rssi) -> Void in
            self.deviceMap[device.getId()] = device
            self.deviceMap[device.getId()] = device
                let data = self.getScanResult(device, advertisementData, rssi)
                let data = self.getScanResult(device, advertisementData, rssi)
                self.notifyListeners("onScanResult", data: data)
                self.notifyListeners("onScanResult", data: data)
            }
                }
        )
        )
    }
    }


    @objc func stopLEScan(_ call: CAPPluginCall) {
                @objc func stopLEScan(_ call: CAPPluginCall) {
                guard let deviceManager = self.getDeviceManager(call) else { return }
                guard let deviceManager = self.getDeviceManager(call) else { return }
                deviceManager.stopScan()
                deviceManager.stopScan()
                call.resolve()
                call.resolve()
            }
            }


    @objc func connect(_ call: CAPPluginCall) {
                @objc func connect(_ call: CAPPluginCall) {
                    guard self.getDeviceManager(call) != nil else { return }
                    guard self.getDeviceManager(call) != nil else { return }
                guard let device = self.getDevice(call, checkConnection: false) else { return }
                guard let device = self.getDevice(call, checkConnection: false) else { return }
                device.setOnConnected({(success, message) -> Void in
                device.setOnConnected({(success, message) -> Void in
                if success {
                if success {
                // only resolve after service discovery
                // only resolve after service discovery
                call.resolve()
                call.resolve()
            } else {
            } else {
                call.reject(message)
                call.reject(message)
            }
            }
            })
            })
                self.deviceManager?.setOnDisconnected(device, {(_, _) -> Void in
                self.deviceManager?.setOnDisconnected(device, {(_, _) -> Void in
                let key = "disconnected|\(device.getId())"
                let key = "disconnected|\(device.getId())"
                self.notifyListeners(key, data: nil)
                self.notifyListeners(key, data: nil)
            })
            })
                self.deviceManager?.connect(device, {(success, message) -> Void in
                self.deviceManager?.connect(device, {(success, message) -> Void in
                    if success {
                    if success {
                print("Connected to peripheral. Waiting for service discovery.")
                print("Connected to peripheral. Waiting for service discovery.")
                } else {
            } else {
            call.reject(message)
            call.reject(message)
    }
                }
                })
                })


            }
            }


    @objc func disconnect(_ call: CAPPluginCall) {
                @objc func disconnect(_ call: CAPPluginCall) {
                guard self.getDeviceManager(call) != nil else { return }
                guard self.getDeviceManager(call) != nil else { return }
                guard let device = self.getDevice(call) else { return }
                guard let device = self.getDevice(call) else { return }
                self.deviceManager?.disconnect(device, {(success, message) -> Void in
        self.deviceManager?.disconnect(device, {(success, message) -> Void in
                    if success {
                    if success {
                    call.resolve()
                    call.resolve()
                } else {
                } else {
                call.reject(message)
                call.reject(message)
            }
            }
            })
    })
            }
}


    @objc func read(_ call: CAPPluginCall) {
            @objc func read(_ call: CAPPluginCall) {
            guard self.getDeviceManager(call) != nil else { return }
            guard self.getDeviceManager(call) != nil else { return }
            guard let device = self.getDevice(call) else { return }
            guard let device = self.getDevice(call) else { return }
            guard let characteristic = self.getCharacteristic(call) else { return }
            guard let characteristic = self.getCharacteristic(call) else { return }
            device.read(characteristic.0, characteristic.1, {(success, value) -> Void in
            device.read(characteristic.0, characteristic.1, {(success, value) -> Void in
            if success {
            if success {
            call.resolve([
            call.resolve([
            "value": value
                            "value": value
        ])
        ])
        } else {
        } else {
            call.reject(value)
            call.reject(value)
        }
        }
        })
        })
        }
}


    @objc func write(_ call: CAPPluginCall) {
                        @objc func write(_ call: CAPPluginCall) {
                        guard self.getDeviceManager(call) != nil else { return }
                        guard self.getDeviceManager(call) != nil else { return }
                        guard let device = self.getDevice(call) else { return }
                        guard let device = self.getDevice(call) else { return }
                        guard let characteristic = self.getCharacteristic(call) else { return }
                        guard let characteristic = self.getCharacteristic(call) else { return }
                        guard let value = call.getString("value") else {
                        guard let value = call.getString("value") else {
                        call.reject("value must be provided")
                        call.reject("value must be provided")
                        return
                        return
                    }
                    }
                        let writeType = CBCharacteristicWriteType.withResponse
                        let writeType = CBCharacteristicWriteType.withResponse
                        device.write(characteristic.0, characteristic.1, value, writeType, {(success, value) -> Void in
                        device.write(characteristic.0, characteristic.1, value, writeType, {(success, value) -> Void in
                        if success {
                        if success {
                        call.resolve()
                        call.resolve()
                    } else {
                    } else {
                        call.reject(value)
                        call.reject(value)
                    }
                    }
                    })
                    })
                    }
}


    @objc func writeWithoutResponse(_ call: CAPPluginCall) {
                        @objc func writeWithoutResponse(_ call: CAPPluginCall) {
                    guard self.getDeviceManager(call) != nil else { return }
                    guard self.getDeviceManager(call) != nil else { return }
                        guard let device = self.getDevice(call) else { return }
                        guard let device = self.getDevice(call) else { return }
                        guard let characteristic = self.getCharacteristic(call) else { return }
                        guard let characteristic = self.getCharacteristic(call) else { return }
                        guard let value = call.getString("value") else {
                    guard let value = call.getString("value") else {
                call.reject("value must be provided")
                call.reject("value must be provided")
                    return
                    return
                }
                }
                        let writeType = CBCharacteristicWriteType.withoutResponse
                        let writeType = CBCharacteristicWriteType.withoutResponse
                        device.write(characteristic.0, characteristic.1, value, writeType, {(success, value) -> Void in
                    device.write(characteristic.0, characteristic.1, value, writeType, {(success, value) -> Void in
                    if success {
                    if success {
                call.resolve()
                call.resolve()
                } else {
            } else {
            call.reject(value)
            call.reject(value)
                }
                }
                })
                })
                    }
}


    @objc func startNotifications(_ call: CAPPluginCall) {
        @objc func startNotifications(_ call: CAPPluginCall) {
        guard self.getDeviceManager(call) != nil else { return }
        guard self.getDeviceManager(call) != nil else { return }
        guard let device = self.getDevice(call) else { return }
        guard let device = self.getDevice(call) else { return }
        guard let characteristic = self.getCharacteristic(call) else { return }
        guard let characteristic = self.getCharacteristic(call) else { return }
        device.setNotifications(
        device.setNotifications(
                    characteristic.0,
                    characteristic.0,
                    characteristic.1,
                    characteristic.1,
                    true, {(_, value) -> Void in
                    true, {(_, value) -> Void in
                    let key = "notification|\(device.getId())|\(characteristic.0.uuidString.lowercased())|\(characteristic.1.uuidString.lowercased())"
                    let key = "notification|\(device.getId())|\(characteristic.0.uuidString.lowercased())|\(characteristic.1.uuidString.lowercased())"
                    self.notifyListeners(key, data: ["value": value])
                    self.notifyListeners(key, data: ["value": value])
                }, {(success, value) -> Void in
            }, {(success, value) -> Void in
        if success {
        if success {
        call.resolve()
        call.resolve()
    } else {
    } else {
                    call.reject(value)
                    call.reject(value)
    }
            }
                })
                })
    }
}


    @objc func stopNotifications(_ call: CAPPluginCall) {
                    @objc func stopNotifications(_ call: CAPPluginCall) {
                    guard self.getDeviceManager(call) != nil else { return }
                    guard self.getDeviceManager(call) != nil else { return }
                    guard let device = self.getDevice(call) else { return }
                    guard let device = self.getDevice(call) else { return }
                    guard let characteristic = self.getCharacteristic(call) else { return }
                    guard let characteristic = self.getCharacteristic(call) else { return }
                    device.setNotifications(
                    device.setNotifications(
                    characteristic.0,
                    characteristic.0,
                    characteristic.1,
                    characteristic.1,
                    false,
                    false,
                    nil, {(success, value) -> Void in
                    nil, {(success, value) -> Void in
                if success {
                if success {
                    call.resolve()
                    call.resolve()
            } else {
                } else {
                call.reject(value)
                call.reject(value)
                }
            }
                })
                })
                }
}


    private func getDeviceManager(_ call: CAPPluginCall) -> DeviceManager? {
                    private func getDeviceManager(_ call: CAPPluginCall) -> DeviceManager? {
                    guard let deviceManager = self.deviceManager else {
                    guard let deviceManager = self.deviceManager else {
                    call.reject("Bluetooth LE not initialized.")
                    call.reject("Bluetooth LE not initialized.")
                    return nil
                    return nil
                }
                }
                    return deviceManager
                    return deviceManager
                }
                }


    private func getServiceUUIDs(_ call: CAPPluginCall) -> [CBUUID] {
                    private func getServiceUUIDs(_ call: CAPPluginCall) -> [CBUUID] {
                        let services = call.getArray("services", String.self) ?? []
                        let services = call.getArray("services", String.self) ?? []
                    let serviceUUIDs = services.map({(service) -> CBUUID in
                        let serviceUUIDs = services.map({(service) -> CBUUID in
                    return CBUUID(string: service)
                    return CBUUID(string: service)
                    })
                    })
                    return serviceUUIDs
                    return serviceUUIDs
                }
                }


    private func getDevice(_ call: CAPPluginCall, checkConnection: Bool = true) -> Device? {
                private func getDevice(_ call: CAPPluginCall, checkConnection: Bool = true) -> Device? {
        guard let deviceId = call.getString("deviceId") else {
        guard let deviceId = call.getString("deviceId") else {
                    call.reject("deviceId required.")
                    call.reject("deviceId required.")
        return nil
        return nil
    }
            }
                guard let device = self.deviceMap[deviceId] else {
                guard let device = self.deviceMap[deviceId] else {
                    call.reject("Device not found. Call 'requestDevice' or 'requestLEScan' first.")
                    call.reject("Device not found. Call 'requestDevice' or 'requestLEScan' first.")
                    return nil
                    return nil
                }
                }
                if checkConnection {
                if checkConnection {
        guard device.isConnected() else {
        guard device.isConnected() else {
        call.reject("Not connected to device.")
        call.reject("Not connected to device.")
        return nil
        return nil
    }
    }
            }
            }
                return device
                return device
            }
            }


    private func getCharacteristic(_ call: CAPPluginCall) -> (CBUUID, CBUUID)? {
                    private func getCharacteristic(_ call: CAPPluginCall) -> (CBUUID, CBUUID)? {
                        guard let service = call.getString("service") else {
                        guard let service = call.getString("service") else {
                        call.reject("Service UUID required.")
                        call.reject("Service UUID required.")
                        return nil
                        return nil
                    }
        }
                    let serviceUUID = CBUUID(string: service)
                    let serviceUUID = CBUUID(string: service)


            guard let characteristic = call.getString("characteristic") else {
                    guard let characteristic = call.getString("characteristic") else {
                    call.reject("Characteristic UUID required.")
                    call.reject("Characteristic UUID required.")
                    return nil
                    return nil
                }
                }
                    let characteristicUUID = CBUUID(string: characteristic)
                    let characteristicUUID = CBUUID(string: characteristic)
            return (serviceUUID, characteristicUUID)
            return (serviceUUID, characteristicUUID)
        }
                }


    private func getBleDevice(_ device: Device) -> [String: Any] {
    private func getBleDevice(_ device: Device) -> [String: Any] {
        var bleDevice = [
        var bleDevice = [
        "deviceId": device.getId()
        "deviceId": device.getId()
    ]
        ]
        if device.getName() != nil {
                if device.getName() != nil {
                bleDevice["name"] = device.getName()
                bleDevice["name"] = device.getName()
            }
            }
    return bleDevice
    return bleDevice
    }
}


    private func getScanResult(_ device: Device, _ advertisementData: [String: Any], _ rssi: NSNumber) -> [String: Any] {
                private func getScanResult(_ device: Device, _ advertisementData: [String: Any], _ rssi: NSNumber) -> [String: Any] {
                var data = [
                var data = [
                "device": self.getBleDevice(device),
                "device": self.getBleDevice(device),
                "rssi": rssi,
                "rssi": rssi,
                "txPower": advertisementData[CBAdvertisementDataTxPowerLevelKey] ?? 127,
                "txPower": advertisementData[CBAdvertisementDataTxPowerLevelKey] ?? 127,
                "uuids": (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] ?? []).map({(uuid) -> String in
                "uuids": (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] ?? []).map({(uuid) -> String in
                return cbuuidToString(uuid)
                return cbuuidToString(uuid)
                })
            })
                ]
                ]


                let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
                let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
                if localName != nil {
            if localName != nil {
                data["localName"] = localName
                data["localName"] = localName
        }
        }


                let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
                let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
                if manufacturerData != nil {
            if manufacturerData != nil {
            data["manufacturerData"] = self.getManufacturerData(data: manufacturerData!)
            data["manufacturerData"] = self.getManufacturerData(data: manufacturerData!)
        }
        }


                let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data]
                let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data]
                if serviceData != nil {
        if serviceData != nil {
        data["serviceData"] = self.getServiceData(data: serviceData!)
        data["serviceData"] = self.getServiceData(data: serviceData!)
    }
    }
                return data
                return data
            }
            }


    private func getManufacturerData(data: Data) -> [String: String] {
                            private func getManufacturerData(data: Data) -> [String: String] {
                            var company = 0
                            var company = 0
                            var rest = ""
                            var rest = ""
                            for (index, byte) in data.enumerated() {
                            for (index, byte) in data.enumerated() {
                            if index == 0 {
                            if index == 0 {
                            company += Int(byte)
                            company += Int(byte)
                        } else if index == 1 {
                        } else if index == 1 {
                            company += Int(byte) * 256
                            company += Int(byte) * 256
                        } else {
                        } else {
                        rest += String(format: "%02hhx ", byte)
                        rest += String(format: "%02hhx ", byte)
                        }
                        }
                        }
                        }
                            return [String(company): rest]
                            return [String(company): rest]
                        }
                        }


    private func getServiceData(data: [CBUUID: Data]) -> [String: String] {
                            private func getServiceData(data: [CBUUID: Data]) -> [String: String] {
                            var result: [String: String] = [:]
                            var result: [String: String] = [:]
                            for (key, value) in data {
                            for (key, value) in data {
                            result[cbuuidToString(key)] = dataToString(value)
                            result[cbuuidToString(key)] = dataToString(value)
                        }
                        }
                            return result
                            return result
                        }
                        }
}
}



