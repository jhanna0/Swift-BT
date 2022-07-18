import Foundation
import CoreBluetooth

struct Peripheral: Identifiable {
    let id: Int
    let name: String
    let rssi: Int
    let periph: CBPeripheral
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    var connectedPeripheral: CBPeripheral!
    var targetChar: CBCharacteristic!
    var myCentral: CBCentralManager!
    var delegate: CBCentralManagerDelegate!
    var lastCheck: Double = 0
    
    @Published var data = "None"
    @Published var connected = false
    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()
    @Published var isScanning = false

    override init() {
        super.init()

        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
        }
        else {
            isSwitchedOn = false
        }
    }
    
    func startScanning() {
         print("startScanning")
        isScanning = true
         myCentral.scanForPeripherals(withServices: nil, options: nil)
     }
    
    func stopScanning() {
           print("stopScanning")
        isScanning = false
           myCentral.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName: String!
       
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
            let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, periph: peripheral)
            peripherals.append(newPeripheral)
            if(name.contains("Arduino")) {
                connect(periph: peripheral)
            }
        }
        else {
            peripheralName = "Unknown"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Successfully connected. Store reference to peripheral if not already done.
        self.connectedPeripheral = peripheral
        peripheral.delegate = self
        print(self.connectedPeripheral.name)
        discoverServices(peripheral: self.connectedPeripheral)
    }
    func connect(periph: CBPeripheral) {
        stopScanning()
        myCentral.connect(periph)
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // Handle error
    }
    
    func discoverServices(peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }

    // In CBPeripheralDelegate class/extension
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        discoverCharacteristics(peripheral: peripheral)
    }
    
    // Call after discovering services
    func discoverCharacteristics(peripheral: CBPeripheral) {
        guard let services = peripheral.services else {
            return
        }
        
        print("services", services)
        peripheral.discoverCharacteristics(nil, for: services[0])
    }
     
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
                
        for characteristic in characteristics {
            print("found: ", characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
        }
                
    }

    // In CBPeripheralDelegate class/extension
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error", error)
            return
        }
        readValue(characteristic: characteristic)
    }
    
    // In main class
    func readValue(characteristic: CBCharacteristic) {
        self.connectedPeripheral?.readValue(for: characteristic)
    }

    // In CBPeripheralDelegate class/extension
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error2", error)
            return
        }
        guard let value = characteristic.value else {
            return
        }
            
        if let string = String(bytes: value, encoding: .utf8) {
            let date = NSDate().timeIntervalSince1970 * 1000
            
            if((date - lastCheck) > 120) {
                self.connected = true
                self.data = string
                self.lastCheck = date
                
            }
        } else {
            print("not a valid UTF-8 sequence")
        }
    }
}
