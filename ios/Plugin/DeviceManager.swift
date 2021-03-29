import Foundation
import CoreBluetooth
import CoreBluetooth

let defaultTimeout: Double = 5
let connectionTimeout: Double = 10
let connectionTimeout: Double = 10

class DeviceManager: NSObject, CBCentralManagerDelegate {
    typealias Callback = (_ success: Bool, _ message: String) -> Void
    typealias Callback = (_ success: Bool, _ message: String) -> Void
    typealias StateReceiver = (_ enabled: Bool) -> Void
    typealias StateReceiver = (_ enabled: Bool) -> Void
    typealias ScanResultCallback = (_ device: Device, _ advertisementData: [String: Any], _ rssi: NSNumber) -> Void
    typealias ScanResultCallback = (_ device: Device, _ advertisementData: [String: Any], _ rssi: NSNumber) -> Void


    private var centralManager: CBCentralManager!
    private var centralManager: CBCentralManager!
    private var viewController: UIViewController?
    private var viewController: UIViewController?
    private var displayStrings: [String: String]!
    private var displayStrings: [String: String]!
    private var callbackMap = [String: Callback]()
    private var callbackMap = [String: Callback]()
    private var scanResultCallback: ScanResultCallback?
    private var scanResultCallback: ScanResultCallback?
    private var stateReceiver: StateReceiver?
    private var stateReceiver: StateReceiver?
    private var timeoutMap = [String: DispatchWorkItem]()
    private var timeoutMap = [String: DispatchWorkItem]()
    private var stopScanWorkItem: DispatchWorkItem?
    private var stopScanWorkItem: DispatchWorkItem?
    private var alertController: UIAlertController?
    private var alertController: UIAlertController?
    private var discoveredDevices = [String: Device]()
    private var discoveredDevices = [String: Device]()
    private var deviceNameFilter: String?
    private var deviceNameFilter: String?
    private var deviceNamePrefixFilter: String?
    private var deviceNamePrefixFilter: String?
    private var shouldShowDeviceList = false
    private var shouldShowDeviceList = false
    private var allowDuplicates = false
    private var allowDuplicates = false


    init(_ viewController: UIViewController?, _ displayStrings: [String: String], _ callback: @escaping Callback) {
        init(_ viewController: UIViewController?, _ displayStrings: [String: String], _ callback: @escaping Callback) {
        super.init()
        super.init()
        self.viewController = viewController
        self.viewController = viewController
        self.displayStrings = displayStrings
        self.displayStrings = displayStrings
        self.callbackMap["initialize"] = callback
        self.callbackMap["initialize"] = callback
        self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    }

// initialize
func centralManagerDidUpdateState(_ central: CBCentralManager) {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let initializeKey = "initialize"
        let initializeKey = "initialize"
        switch central.state {
    switch central.state {
    case .poweredOn:
    case .poweredOn:
    self.resolve(initializeKey, "BLE powered on")
    self.resolve(initializeKey, "BLE powered on")
    self.emitState(enabled: true)
    self.emitState(enabled: true)
    case .poweredOff:
    case .poweredOff:
    self.stopScan()
    self.stopScan()
    self.resolve(initializeKey, "BLE powered off")
    self.resolve(initializeKey, "BLE powered off")
    self.emitState(enabled: false)
    self.emitState(enabled: false)
    case .resetting:
    case .resetting:
    self.emitState(enabled: false)
    self.emitState(enabled: false)
    case .unauthorized:
    case .unauthorized:
    self.reject(initializeKey, "BLE permission denied")
    self.reject(initializeKey, "BLE permission denied")
    self.emitState(enabled: false)
    self.emitState(enabled: false)
    case .unsupported:
    case .unsupported:
    self.reject(initializeKey, "BLE unsupported")
    self.reject(initializeKey, "BLE unsupported")
    self.emitState(enabled: false)
    self.emitState(enabled: false)
    case .unknown:
    case .unknown:
    self.emitState(enabled: false)
    self.emitState(enabled: false)
    default: break
    default: break
    }
    }
    }
}

func getEnabled() -> Bool {
    return self.centralManager.state == CBManagerState.poweredOn
    return self.centralManager.state == CBManagerState.poweredOn
}
}

func registerStateReceiver( _ stateReceiver: @escaping StateReceiver) {
            self.stateReceiver = stateReceiver
            self.stateReceiver = stateReceiver
        }
        }

func unregisterStateReceiver() {
        self.stateReceiver = nil
        self.stateReceiver = nil
    }
    }

func emitState(enabled: Bool) {
        guard let stateReceiver = self.stateReceiver else { return }
        guard let stateReceiver = self.stateReceiver else { return }
        stateReceiver(enabled)
        stateReceiver(enabled)
    }
    }

func startScanning(
        _ serviceUUIDs: [CBUUID],
        _ serviceUUIDs: [CBUUID],
        _ name: String?,
        _ name: String?,
        _ namePrefix: String?,
        _ namePrefix: String?,
        _ allowDuplicates: Bool,
        _ allowDuplicates: Bool,
        _ shouldShowDeviceList: Bool,
        _ shouldShowDeviceList: Bool,
        _ scanDuration: Double?,
        _ scanDuration: Double?,
    _ callback: @escaping Callback,
    _ callback: @escaping Callback,
    _ scanResultCallback: @escaping ScanResultCallback
        _ scanResultCallback: @escaping ScanResultCallback
    ) {
        ) {
        self.callbackMap["startScanning"] = callback
        self.callbackMap["startScanning"] = callback
        self.scanResultCallback = scanResultCallback
        self.scanResultCallback = scanResultCallback


        if self.centralManager.isScanning == false {
        if self.centralManager.isScanning == false {
        self.discoveredDevices = [String: Device]()
        self.discoveredDevices = [String: Device]()
        self.shouldShowDeviceList = shouldShowDeviceList
        self.shouldShowDeviceList = shouldShowDeviceList
        self.allowDuplicates = allowDuplicates
        self.allowDuplicates = allowDuplicates
        self.deviceNameFilter = name
        self.deviceNameFilter = name
        self.deviceNamePrefixFilter = namePrefix
        self.deviceNamePrefixFilter = namePrefix


        if shouldShowDeviceList {
        if shouldShowDeviceList {
        self.showDeviceList()
        self.showDeviceList()
    }
    }


        if scanDuration != nil {
        if scanDuration != nil {
        self.stopScanWorkItem = DispatchWorkItem {
        self.stopScanWorkItem = DispatchWorkItem {
        self.stopScan()
        self.stopScan()
    }
    }
        DispatchQueue.main.asyncAfter(deadline: .now() + scanDuration!, execute: self.stopScanWorkItem!)
        DispatchQueue.main.asyncAfter(deadline: .now() + scanDuration!, execute: self.stopScanWorkItem!)
    }
    }
        self.centralManager.scanForPeripherals(withServices: serviceUUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey: allowDuplicates])
        self.centralManager.scanForPeripherals(withServices: serviceUUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey: allowDuplicates])


        if shouldShowDeviceList == false {
        if shouldShowDeviceList == false {
        self.resolve("startScanning", "Scan started.")
        self.resolve("startScanning", "Scan started.")
    }
    }
    } else {
    } else {
    self.stopScan()
    self.stopScan()
    self.reject("startScanning", "Already scanning. Stopping now.")
    self.reject("startScanning", "Already scanning. Stopping now.")
}
}
    }
}

func stopScan() {
            print("Stop scanning.")
            print("Stop scanning.")
            self.centralManager.stopScan()
            self.centralManager.stopScan()
            self.stopScanWorkItem?.cancel()
            self.stopScanWorkItem?.cancel()
            self.stopScanWorkItem = nil
            self.stopScanWorkItem = nil
            DispatchQueue.main.async { [weak self] in
            DispatchQueue.main.async { [weak self] in
            if self?.discoveredDevices.count == 0 {
            if self?.discoveredDevices.count == 0 {
            self?.alertController?.title = self?.displayStrings["noDeviceFound"] ?? "No device found"
            self?.alertController?.title = self?.displayStrings["noDeviceFound"] ?? "No device found"
        } else {
        } else {
            self?.alertController?.title = self?.displayStrings["availableDevices"] ?? "Available devices"
            self?.alertController?.title = self?.displayStrings["availableDevices"] ?? "Available devices"
        }
        }
        }
        }
    }
}

// didDiscover
func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {


            guard peripheral.state != CBPeripheralState.connected else {
            guard peripheral.state != CBPeripheralState.connected else {
            print("found connected device", peripheral.name ?? "Unknown")
            print("found connected device", peripheral.name ?? "Unknown")
            // make sure we do not touch connected devices
            // make sure we do not touch connected devices
            return
            return
        }
        }


            let isNew = self.discoveredDevices[peripheral.identifier.uuidString] == nil
            let isNew = self.discoveredDevices[peripheral.identifier.uuidString] == nil
            guard isNew || self.allowDuplicates else { return }
            guard isNew || self.allowDuplicates else { return }


            guard self.passesNameFilter(peripheralName: peripheral.name) else { return }
            guard self.passesNameFilter(peripheralName: peripheral.name) else { return }
            guard self.passesNamePrefixFilter(peripheralName: peripheral.name) else { return }
            guard self.passesNamePrefixFilter(peripheralName: peripheral.name) else { return }


    let device = Device(peripheral)
    let device = Device(peripheral)
    print("New device found: ", device.getName() ?? "Unknown")
    print("New device found: ", device.getName() ?? "Unknown")
    self.discoveredDevices[device.getId()] = device
    self.discoveredDevices[device.getId()] = device


            if shouldShowDeviceList {
            if shouldShowDeviceList {
            DispatchQueue.main.async { [weak self] in
            DispatchQueue.main.async { [weak self] in
            self?.alertController?.addAction(UIAlertAction(title: device.getName() ?? "Unknown", style: UIAlertAction.Style.default, handler: { (_) -> Void in
            self?.alertController?.addAction(UIAlertAction(title: device.getName() ?? "Unknown", style: UIAlertAction.Style.default, handler: { (_) -> Void in
            print("Selected device")
            print("Selected device")
            self?.stopScan()
            self?.stopScan()
            self?.resolve("startScanning", device.getId())
            self?.resolve("startScanning", device.getId())
        }))
        }))
        }
        }
        } else {
        } else {
            if self.scanResultCallback != nil {
            if self.scanResultCallback != nil {
            self.scanResultCallback!(device, advertisementData, RSSI)
            self.scanResultCallback!(device, advertisementData, RSSI)
        }
        }
        }
        }
}
}

func showDeviceList() {
            DispatchQueue.main.async { [weak self] in
            DispatchQueue.main.async { [weak self] in
            self?.alertController = UIAlertController(title: self?.displayStrings["scanning"] ?? "Scanning...", message: nil, preferredStyle: UIAlertController.Style.alert)
            self?.alertController = UIAlertController(title: self?.displayStrings["scanning"] ?? "Scanning...", message: nil, preferredStyle: UIAlertController.Style.alert)
            self?.alertController?.addAction(UIAlertAction(title: self?.displayStrings["cancel"] ?? "Cancel", style: UIAlertAction.Style.cancel, handler: { (_) -> Void in
            self?.alertController?.addAction(UIAlertAction(title: self?.displayStrings["cancel"] ?? "Cancel", style: UIAlertAction.Style.cancel, handler: { (_) -> Void in
            print("Cancelled request device.")
            print("Cancelled request device.")
            self?.stopScan()
            self?.stopScan()
            self?.reject("startScanning", "requestDevice cancelled.")
            self?.reject("startScanning", "requestDevice cancelled.")
        }))
        }))
            self?.viewController?.present((self?.alertController)!, animated: true, completion: nil)
            self?.viewController?.present((self?.alertController)!, animated: true, completion: nil)
        }
        }
        }
        }

func getDevice(_ deviceId: String) -> Device? {
            return self.discoveredDevices[deviceId]
            return self.discoveredDevices[deviceId]
        }
        }

func connect(_ device: Device, _ callback: @escaping Callback) {
        let key = "connect|\(device.getId())"
        let key = "connect|\(device.getId())"
        self.callbackMap[key] = callback
        self.callbackMap[key] = callback
        print("Connecting to peripheral", device.getPeripheral())
        print("Connecting to peripheral", device.getPeripheral())
        self.centralManager.connect(device.getPeripheral(), options: nil)
        self.centralManager.connect(device.getPeripheral(), options: nil)
        self.setConnectionTimeout(key, "Connection timeout.", device)
        self.setConnectionTimeout(key, "Connection timeout.", device)
    }
    }

// didConnect
func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            print("Connected to device", peripheral)
            print("Connected to device", peripheral)
            let key = "connect|\(peripheral.identifier.uuidString)"
            let key = "connect|\(peripheral.identifier.uuidString)"
            peripheral.discoverServices(nil)
            peripheral.discoverServices(nil)
            self.resolve(key, "Successfully connected.")
            self.resolve(key, "Successfully connected.")
            // will wait for services in plugin call
            // will wait for services in plugin call
        }
        }

// didFailToConnect
func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let key = "connect|\(peripheral.identifier.uuidString)"
        let key = "connect|\(peripheral.identifier.uuidString)"
        if error != nil {
        if error != nil {
        self.reject(key, error!.localizedDescription)
        self.reject(key, error!.localizedDescription)
        return
        return
    }
    }
        self.reject(key, "Failed to connect.")
        self.reject(key, "Failed to connect.")
    }
    }

func setOnDisconnected(_ device: Device, _ callback: @escaping Callback) {
                let key = "onDisconnected|\(device.getId())"
                let key = "onDisconnected|\(device.getId())"
                self.callbackMap[key] = callback
                self.callbackMap[key] = callback
            }
            }

func disconnect(_ device: Device, _ callback: @escaping Callback) {
                let key = "disconnect|\(device.getId())"
                let key = "disconnect|\(device.getId())"
                self.callbackMap[key] = callback
                self.callbackMap[key] = callback
                print("Disconnecting from peripheral", device.getPeripheral())
                print("Disconnecting from peripheral", device.getPeripheral())
                self.centralManager.cancelPeripheralConnection(device.getPeripheral())
                self.centralManager.cancelPeripheralConnection(device.getPeripheral())
                self.setTimeout(key, "Disconnection timeout.")
                self.setTimeout(key, "Disconnection timeout.")
            }
            }

// didDisconnectPeripheral
func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
            let key = "disconnect|\(peripheral.identifier.uuidString)"
            let key = "disconnect|\(peripheral.identifier.uuidString)"
            let keyOnDisconnected = "onDisconnected|\(peripheral.identifier.uuidString)"
            let keyOnDisconnected = "onDisconnected|\(peripheral.identifier.uuidString)"
            self.resolve(keyOnDisconnected, "Disconnected.")
            self.resolve(keyOnDisconnected, "Disconnected.")
            if error != nil {
            if error != nil {
            print(error!.localizedDescription)
            print(error!.localizedDescription)
            self.reject(key, error!.localizedDescription)
            self.reject(key, error!.localizedDescription)
            return
            return
        }
        }
            self.resolve(key, "Successfully disconnected.")
            self.resolve(key, "Successfully disconnected.")
        }
        }

private func passesNameFilter(peripheralName: String?) -> Bool {
    guard let nameFilter = self.deviceNameFilter else { return true }
    guard let nameFilter = self.deviceNameFilter else { return true }
    guard let name = peripheralName else { return false }
    guard let name = peripheralName else { return false }
    return name == nameFilter
    return name == nameFilter
}
}

private func passesNamePrefixFilter(peripheralName: String?) -> Bool {
                guard let prefix = self.deviceNamePrefixFilter else { return true }
                guard let prefix = self.deviceNamePrefixFilter else { return true }
                guard let name = peripheralName else { return false }
                guard let name = peripheralName else { return false }
                return name.hasPrefix(prefix)
                return name.hasPrefix(prefix)
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

private func setConnectionTimeout(_ key: String, _ message: String, _ device: Device, _ timeout: Double = connectionTimeout) {
                let workItem = DispatchWorkItem {
                let workItem = DispatchWorkItem {
            // do not call onDisconnnected, which is triggered by cancelPeripheralConnection
            // do not call onDisconnnected, which is triggered by cancelPeripheralConnection
            let key = "onDisconnected|\(device.getId())"
            let key = "onDisconnected|\(device.getId())"
            self.callbackMap[key] = nil
            self.callbackMap[key] = nil
            self.centralManager.cancelPeripheralConnection(device.getPeripheral())
            self.centralManager.cancelPeripheralConnection(device.getPeripheral())
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

















































