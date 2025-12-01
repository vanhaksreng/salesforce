//
//
//
//import Flutter
//import UIKit
//import CoreBluetooth
//import ExternalAccessory
//
//class BluetoothPrinterManager: NSObject {
//    static let shared = BluetoothPrinterManager()
//    
//    private var centralManager: CBCentralManager!
//    private var connectedPeripheral: CBPeripheral?
//    private var writeCharacteristic: CBCharacteristic?
//    private var discoveredDevices: [CBPeripheral] = []
//    private var scanCompletion: (([[String: String]]) -> Void)?
//    private var connectCompletion: ((Bool, String?) -> Void)?
//    private var writeCompletion: ((Bool, String?) -> Void)?
//    private var dataToSend: Data?
//    private var currentDataOffset = 0
//    private var chunksInFlight = 0
//    private let maxChunksInFlight = 3
//    
//    private let serviceUUID = CBUUID(string: "49535343-FE7D-4AE5-8FA9-9FAFD205E455")
//    private let writeCharacteristicUUID = CBUUID(string: "49535343-8841-43F4-A8D4-ECBE34729BB3")
//    
//    private override init() {
//        super.init()
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//    }
//    
//    func scanForDevices(timeout: TimeInterval = 10, completion: @escaping ([[String: String]]) -> Void) {
//        discoveredDevices.removeAll()
//        scanCompletion = completion
//        
//        if centralManager.state == .poweredOn {
//            centralManager.scanForPeripherals(withServices: nil, options: nil)
//            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [weak self] in
//                self?.stopScan()
//            }
//        } else {
//            completion([])
//        }
//    }
//    
//    func stopScan() {
//        centralManager.stopScan()
//        let devices = discoveredDevices.map { ["name": $0.name ?? "Unknown", "address": $0.identifier.uuidString] }
//        scanCompletion?(devices)
//        scanCompletion = nil
//    }
//    
//    func connect(address: String, completion: @escaping (Bool, String?) -> Void) {
//        connectCompletion = completion
//        
//        if let peripheral = discoveredDevices.first(where: { $0.identifier.uuidString == address }) {
//            connectedPeripheral = peripheral
//            peripheral.delegate = self
//            centralManager.connect(peripheral, options: nil)
//        } else if let uuid = UUID(uuidString: address),
//                  let peripheral = centralManager.retrievePeripherals(withIdentifiers: [uuid]).first {
//            connectedPeripheral = peripheral
//            peripheral.delegate = self
//            centralManager.connect(peripheral, options: nil)
//        } else {
//            completion(false, "Device not found")
//        }
//    }
//    
//    func disconnect() {
//        guard let peripheral = connectedPeripheral else { return }
//        centralManager.cancelPeripheralConnection(peripheral)
//    }
//    
//    func getConnectionStatus() -> String {
//        guard let peripheral = connectedPeripheral else { return "disconnected" }
//        switch peripheral.state {
//        case .connected: return "connected"
//        case .connecting: return "connecting"
//        case .disconnecting: return "disconnecting"
//        case .disconnected: return "disconnected"
//        @unknown default: return "unknown"
//        }
//    }
//    
//    func sendData(_ data: Data, completion: @escaping (Bool, String?) -> Void) {
//        guard let peripheral = connectedPeripheral,
//              let characteristic = writeCharacteristic else {
//            completion(false, "Printer not connected")
//            return
//        }
//        
//        writeCompletion = completion
//        dataToSend = data
//        currentDataOffset = 0
//        chunksInFlight = 0
//        
//        print("📤 Sending \(data.count) bytes...")
//        
//        if characteristic.properties.contains(.writeWithoutResponse) {
//            sendChunksNoResponse()
//        } else {
//            sendChunksWithResponse()
//        }
//    }
//    
//    private func sendChunksNoResponse() {
//        guard let data = dataToSend,
//              let peripheral = connectedPeripheral,
//              let characteristic = writeCharacteristic else { return }
//        
//        // Dynamic chunk size based on MTU
//        let mtu = peripheral.maximumWriteValueLength(for: .withoutResponse)
//        let chunkSize = mtu > 20 && mtu < 512 ? mtu : 512
//        
//        // Adaptive batch size - send more chunks per cycle
//        let batchSize = 10 // Increased from 15
//        var sent = 0
//        
//        // Send batch of chunks without blocking
//        while currentDataOffset < data.count && sent < batchSize {
//            let remaining = data.count - currentDataOffset
//            if remaining <= 0 { break }
//            
//            let size = min(chunkSize, remaining)
//            let chunk = data.subdata(in: currentDataOffset..<(currentDataOffset + size))
//            
//            // Check if peripheral can accept more data
//            if !peripheral.canSendWriteWithoutResponse {
//                print("⏸️ Printer buffer full, waiting...")
//                // Will resume in peripheralIsReady(toSendWriteWithoutResponse:)
//                return
//            }
//            
//            peripheral.writeValue(chunk, for: characteristic, type: .withoutResponse)
//            currentDataOffset += size
//            sent += 1
//        }
//        
//        if currentDataOffset >= data.count {
//            // All data sent - wait a bit for printer to process
//            print("✅ All data sent (\(data.count) bytes)")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
//                self?.writeCompletion?(true, nil)
//                self?.cleanup()
//            }
//        } else {
//            // Continue sending - minimal delay for smoothness
//            // Reduced from 8ms to 5ms for even smoother flow
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.015) { [weak self] in
//                self?.sendChunksNoResponse()
//            }
//        }
//    }
//    
//    private func sendChunksWithResponse() {
//        guard let data = dataToSend,
//              let peripheral = connectedPeripheral,
//              let characteristic = writeCharacteristic else { return }
//        
//        // Dynamic chunk size
//        let mtu = peripheral.maximumWriteValueLength(for: .withResponse)
//        let chunkSize = mtu > 20 && mtu < 512 ? mtu : 512
//        
//        if currentDataOffset >= data.count {
//            print("✅ All data sent with response (\(data.count) bytes)")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
//                self?.writeCompletion?(true, nil)
//                self?.cleanup()
//            }
//            return
//        }
//        
//        // Send multiple chunks up to max in-flight limit
//        while chunksInFlight < maxChunksInFlight && currentDataOffset < data.count {
//            let size = min(chunkSize, data.count - currentDataOffset)
//            let chunk = data.subdata(in: currentDataOffset..<(currentDataOffset + size))
//            
//            peripheral.writeValue(chunk, for: characteristic, type: .withResponse)
//            chunksInFlight += 1
//            currentDataOffset += size
//            
//            print("📨 Sent chunk (\(size) bytes), in-flight: \(chunksInFlight)")
//        }
//    }
//    
//    private func cleanup() {
//        writeCompletion = nil
//        dataToSend = nil
//        currentDataOffset = 0
//        chunksInFlight = 0
//    }
//}
//
//// MARK: - CBCentralManagerDelegate
//extension BluetoothPrinterManager: CBCentralManagerDelegate {
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        print("📶 Bluetooth state: \(central.state.rawValue)")
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
//            
//            if (peripheral.name == nil) {
//                return;
//            }
//            
//            discoveredDevices.append(peripheral)
//            
////            print(peripheral.name);
//            
//            //print("📱 Found: \(peripheral.name ?? "Unknown") (RSSI: \(RSSI))")
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        print("✅ Connected to \(peripheral.name ?? "Unknown")")
//        peripheral.discoverServices([serviceUUID])
//    }
//    
//    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        print("❌ Connection failed: \(error?.localizedDescription ?? "Unknown")")
//        connectCompletion?(false, error?.localizedDescription)
//        connectCompletion = nil
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        print("🔌 Disconnected")
//        connectedPeripheral = nil
//        writeCharacteristic = nil
//    }
//    
//    // CRITICAL: This callback resumes sending when printer buffer is ready
//    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
//        print("✅ Printer buffer ready, resuming...")
//        // Resume sending when buffer is ready
//        if dataToSend != nil && currentDataOffset < (dataToSend?.count ?? 0) {
//            sendChunksNoResponse()
//        }
//    }
//}
//
//// MARK: - CBPeripheralDelegate
//extension BluetoothPrinterManager: CBPeripheralDelegate {
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        if let error = error {
//            print("❌ Service discovery failed: \(error.localizedDescription)")
//            connectCompletion?(false, error.localizedDescription)
//            return
//        }
//        
//        print("🔍 Discovering characteristics...")
//        peripheral.services?.forEach { service in
//            peripheral.discoverCharacteristics([writeCharacteristicUUID], for: service)
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        if let error = error {
//            print("❌ Characteristic discovery failed: \(error.localizedDescription)")
//            connectCompletion?(false, error.localizedDescription)
//            return
//        }
//        
//        service.characteristics?.forEach { characteristic in
//            if characteristic.uuid == writeCharacteristicUUID {
//                writeCharacteristic = characteristic
//                
//                // Log characteristic properties
//                var properties: [String] = []
//                if characteristic.properties.contains(.write) { properties.append("write") }
//                if characteristic.properties.contains(.writeWithoutResponse) { properties.append("writeWithoutResponse") }
//                if characteristic.properties.contains(.notify) { properties.append("notify") }
//                
//                print("✅ Write characteristic found with properties: \(properties.joined(separator: ", "))")
//                print("📏 MTU: \(peripheral.maximumWriteValueLength(for: .withoutResponse)) bytes")
//                
//                connectCompletion?(true, nil)
//                connectCompletion = nil
//            }
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        if let error = error {
//            print("❌ Write failed: \(error.localizedDescription)")
//            writeCompletion?(false, error.localizedDescription)
//            cleanup()
//            return
//        }
//        
//        chunksInFlight -= 1
//        print("✓ Chunk acknowledged, in-flight: \(chunksInFlight)")
//        
//        // Continue sending more chunks
//        sendChunksWithResponse()
//    }
//    
//    // Optional: Monitor notification updates if printer sends status
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        if let value = characteristic.value {
//            print("📩 Received notification: \(value.map { String(format: "%02X", $0) }.joined(separator: " "))")
//        }
//    }
//}
