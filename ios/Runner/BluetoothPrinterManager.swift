import Flutter
import UIKit
import CoreBluetooth
import ExternalAccessory

// MARK: - Bluetooth Printer Manager
class BluetoothPrinterManager: NSObject {
    static let shared = BluetoothPrinterManager()
    
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    private var discoveredDevices: [CBPeripheral] = []
    private var scanCompletion: (([[String: String]]) -> Void)?
    private var connectCompletion: ((Bool, String?) -> Void)?
    private var writeCompletion: ((Bool, String?) -> Void)?
    private var dataToSend: Data?
    private var currentDataOffset = 0
    private var canSendData = true
    private var chunksInFlight = 0
    private let maxChunksInFlight = 5 // Pipeline multiple chunks
    
    private let serviceUUID = CBUUID(string: "49535343-FE7D-4AE5-8FA9-9FAFD205E455")
    private let writeCharacteristicUUID = CBUUID(string: "49535343-8841-43F4-A8D4-ECBE34729BB3")
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    func scanForDevices(timeout: TimeInterval = 10, completion: @escaping ([[String: String]]) -> Void) {
        print("🔍 Starting Bluetooth scan...")
        discoveredDevices.removeAll()
        scanCompletion = completion
        
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [weak self] in
                self?.stopScan()
            }
        } else {
            print("❌ Bluetooth is not powered on")
            completion([])
        }
    }
    
    func stopScan() {
        centralManager.stopScan()
        print("ℹ️ Stopped scanning. Found \(discoveredDevices.count) devices")
        
        let devices = discoveredDevices.map { peripheral -> [String: String] in
            return [
                "name": peripheral.name ?? "Unknown",
                "address": peripheral.identifier.uuidString
            ]
        }
        
        scanCompletion?(devices)
        scanCompletion = nil
    }
    
    func connect(address: String, completion: @escaping (Bool, String?) -> Void) {
        connectCompletion = completion
        
        guard let peripheral = discoveredDevices.first(where: { $0.identifier.uuidString == address }) else {
            let uuid = UUID(uuidString: address)
            if let uuid = uuid {
                let peripherals = centralManager.retrievePeripherals(withIdentifiers: [uuid])
                if let peripheral = peripherals.first {
                    print("🔗 Connecting to known device: \(peripheral.name ?? "Unknown")")
                    connectedPeripheral = peripheral
                    peripheral.delegate = self
                    centralManager.connect(peripheral, options: nil)
                    return
                }
            }
            
            print("❌ Device not found: \(address)")
            completion(false, "Device not found")
            return
        }
        
        print("🔗 Connecting to: \(peripheral.name ?? "Unknown")")
        connectedPeripheral = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        guard let peripheral = connectedPeripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
        print("🔌 Disconnected from printer")
    }
    
    func isConnected() -> Bool {
        return connectedPeripheral?.state == .connected
    }
    
    func getConnectionStatus() -> String {
        guard let peripheral = connectedPeripheral else {
            return "disconnected"
        }
        
        switch peripheral.state {
        case .connected:
            return "connected"
        case .connecting:
            return "connecting"
        case .disconnecting:
            return "disconnecting"
        case .disconnected:
            return "disconnected"
        @unknown default:
            return "unknown"
        }
    }
    
    func sendData(_ data: Data, completion: @escaping (Bool, String?) -> Void) {
        guard let peripheral = connectedPeripheral,
              let characteristic = writeCharacteristic else {
            print("❌ Printer not connected")
            completion(false, "Printer not connected")
            return
        }
        
        // Check if characteristic supports writeWithoutResponse
        let supportsNoResponse = characteristic.properties.contains(.writeWithoutResponse)
        
        writeCompletion = completion
        dataToSend = data
        currentDataOffset = 0
        canSendData = true
        chunksInFlight = 0
        
        print("📤 Sending \(data.count) bytes to printer... (mode: \(supportsNoResponse ? "fast" : "safe"))")
        
        // Start pipeline
        if supportsNoResponse {
            sendMultipleChunksNoResponse()
        } else {
            sendNextChunk()
        }
    }
    
    // FAST MODE: Send multiple chunks without waiting for response
    private func sendMultipleChunksNoResponse() {
        guard let data = dataToSend,
              let peripheral = connectedPeripheral,
              let characteristic = writeCharacteristic else {
            return
        }
        
        let chunkSize = 512
        var sentCount = 0
        
        while currentDataOffset < data.count && sentCount < 10 { // Send 10 chunks at once
            let remainingBytes = data.count - currentDataOffset
            if remainingBytes <= 0 { break }
            
            let bytesToSend = min(chunkSize, remainingBytes)
            let chunk = data.subdata(in: currentDataOffset..<(currentDataOffset + bytesToSend))
            
            peripheral.writeValue(chunk, for: characteristic, type: .withoutResponse)
            
            currentDataOffset += bytesToSend
            sentCount += 1
            
            // Progress update
            let progress = Float(currentDataOffset) / Float(data.count) * 100
            if Int(progress) % 20 == 0 {
                print("  → Progress: \(String(format: "%.0f", progress))%")
            }
        }
        
        // Check if done
        if currentDataOffset >= data.count {
            print("✅ All data sent successfully")
            writeCompletion?(true, nil)
            writeCompletion = nil
            dataToSend = nil
            currentDataOffset = 0
        } else {
            // Continue sending after small delay to avoid overwhelming the printer
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                self?.sendMultipleChunksNoResponse()
            }
        }
    }
    
    // SAFE MODE: Send with response (slower but more reliable)
    private func sendNextChunk() {
        guard let data = dataToSend,
              let peripheral = connectedPeripheral,
              let characteristic = writeCharacteristic else {
            return
        }
        
        let chunkSize = 512
        let remainingBytes = data.count - currentDataOffset
        
        if remainingBytes <= 0 {
            print("✅ All data sent successfully")
            writeCompletion?(true, nil)
            writeCompletion = nil
            dataToSend = nil
            currentDataOffset = 0
            return
        }
        
        // Pipeline: send multiple chunks before waiting
        while chunksInFlight < maxChunksInFlight && currentDataOffset < data.count {
            let bytesToSend = min(chunkSize, remainingBytes)
            let chunk = data.subdata(in: currentDataOffset..<(currentDataOffset + bytesToSend))
            
            peripheral.writeValue(chunk, for: characteristic, type: .withResponse)
            chunksInFlight += 1
            currentDataOffset += bytesToSend
            
            // Progress update
            let progress = Float(currentDataOffset) / Float(data.count) * 100
            if Int(progress) % 20 == 0 {
                print("  → Progress: \(String(format: "%.0f", progress))%")
            }
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothPrinterManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("✅ Bluetooth is powered on")
        case .poweredOff:
            print("❌ Bluetooth is powered off")
        case .unauthorized:
            print("❌ Bluetooth is unauthorized")
        case .unsupported:
            print("❌ Bluetooth is not supported")
        default:
            print("⚠️ Bluetooth state: \(central.state.rawValue)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
            print("📱 Found device: \(peripheral.name ?? "Unknown") - \(peripheral.identifier)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to: \(peripheral.name ?? "Unknown")")
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❌ Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
        connectCompletion?(false, error?.localizedDescription)
        connectCompletion = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("🔌 Disconnected from printer")
        connectedPeripheral = nil
        writeCharacteristic = nil
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        // Called when printer is ready for more data (fast mode)
        if dataToSend != nil && currentDataOffset < (dataToSend?.count ?? 0) {
            sendMultipleChunksNoResponse()
        }
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothPrinterManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("❌ Error discovering services: \(error.localizedDescription)")
            connectCompletion?(false, error.localizedDescription)
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("🔍 Discovered service: \(service.uuid)")
            peripheral.discoverCharacteristics([writeCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("❌ Error discovering characteristics: \(error.localizedDescription)")
            connectCompletion?(false, error.localizedDescription)
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("🔍 Discovered characteristic: \(characteristic.uuid)")
            if characteristic.uuid == writeCharacteristicUUID {
                writeCharacteristic = characteristic
                
                let hasWriteNoResponse = characteristic.properties.contains(.writeWithoutResponse)
                let hasWrite = characteristic.properties.contains(.write)
                
                print("✅ Found write characteristic (NoResponse: \(hasWriteNoResponse), WithResponse: \(hasWrite))")
                connectCompletion?(true, nil)
                connectCompletion = nil
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ Write error: \(error.localizedDescription)")
            writeCompletion?(false, error.localizedDescription)
            writeCompletion = nil
            return
        }
        
        // Decrement in-flight counter
        chunksInFlight -= 1
        
        // Continue sending next chunks
        sendNextChunk()
    }
}
