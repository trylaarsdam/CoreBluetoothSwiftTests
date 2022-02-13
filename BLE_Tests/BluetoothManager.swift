//
//  BluetoothManager.swift
//  BLE_Tests
//
//  Created by Todd Rylaarsdam on 2/10/22.
//

import Foundation
import CoreBluetooth
import UserNotifications



struct Peripheral: Identifiable, Equatable {
    let id: Int
    let name: String
    let rssi: Int
    let peripheral: CBPeripheral
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var initialized = false
    @Published var peripherals = [Peripheral]()
    @Published var scanning = false
    @Published var connected = false
    @Published var connectedPeripheral: CBPeripheral?
    @Published var discoveredServices = [CBService]()
    @Published var characteristicValues: [String: Data] = [:]
    var doNotReconnect = false
    
    let content = UNMutableNotificationContent()
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

    var BLEcentral: CBCentralManager!
    
    func connect(peripheral: Peripheral) {
        self.stopScanning()
        BLEcentral.connect(peripheral.peripheral, options: nil)
        doNotReconnect = false
    }
    
    func disconnect() {
        if let toBeDisconnected = connectedPeripheral {
            self.BLEcentral.cancelPeripheralConnection(toBeDisconnected)
        }
        doNotReconnect = true
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            initialized = true
        }
        else {
            initialized = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connected = true
        connectedPeripheral = peripheral
        peripheral.discoverServices(nil)
        content.title = "BLE Connected"
        content.subtitle = "Device \(peripheral.name ?? "Unknown Name") was connected"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func readValueForCharacteristic(characteristic: CBCharacteristic) {
        self.connectedPeripheral!.readValue(for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        characteristicValues[characteristic.uuid.uuidString] = characteristic.value
        print("")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        print("Discovered Services: \(services)")
        
        discoveredServices = services
    }
    
    func discoverCharacteristics (service: CBService) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error)
        // Handle error
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print(dict)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connected = false
        content.title = "BLE Disconnected"
        content.subtitle = "Device \(peripheral.name ?? "Unknown Name") was disconnected"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
        if(!doNotReconnect) {
            self.BLEcentral.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheral.delegate = self
        var peripheralName: String!
       
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else {
            peripheralName = "Unknown device"
        }
       
        let toBeAddedPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, peripheral: peripheral)
        // print(toBeAddedPeripheral)
        if(!peripherals.map{ $0.name }.contains(toBeAddedPeripheral.name)) {
            if(toBeAddedPeripheral.name != "Unknown device") {
                peripherals.append(toBeAddedPeripheral)
            }
        }
        else {
            if let toBeUpdatedPeripheralIndex = peripherals.map({$0.name}).firstIndex(of: toBeAddedPeripheral.name) {
                peripherals[toBeUpdatedPeripheralIndex] = toBeAddedPeripheral
            }
        }
    }
    
    func startScanning() {
        BLEcentral.scanForPeripherals(withServices: [CBUUID(string: "38FAE295-026C-43F5-AAA9-54064C4251E0"), CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")], options: nil)
        self.scanning = true
    }
    
    func stopScanning() {
        BLEcentral.stopScan()
        self.scanning = false
    }
    
    func toggleScanning() {
        if(scanning) {
            self.stopScanning()
            self.scanning = false
        }
        else {
            self.startScanning()
            self.scanning = true
        }
    }
    
    override init() {
        super.init()

        BLEcentral = CBCentralManager(delegate: self, queue: nil)
        BLEcentral.delegate = self
    }
}
