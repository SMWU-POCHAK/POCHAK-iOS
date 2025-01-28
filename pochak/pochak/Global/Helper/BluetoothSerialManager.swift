//
//  BluetoothSerialManager.swift
//  pochak
//
//  Created by Suyeon Hwang on 1/21/25.
//

import UIKit
import CoreBluetooth


enum BluetoothMode: String {
    case advertisingMode = "advertisingMode"
    case scanningMode = "scanningMode"
}

protocol BluetoothSerialDelegate: AnyObject {
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber?)
    func serialDidConnectPeripheral(peripheral: CBPeripheral)
}

extension BluetoothSerialDelegate {
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber?) {}
    func serialDidConnectPeripheral(peripheral: CBPeripheral) {}
}

final class BluetoothSerialManager: NSObject {
    
    // MARK: - Properties
    
    static let shared = BluetoothSerialManager()
    static let tempUUID = "02DEA36D-2B26-484F-A1E8-FD85FC8C2658"  // TODO: 추후 수정?
    
    var delegate: BluetoothSerialDelegate?
    
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    private var currentMode: BluetoothMode!
    
    /// serviceUUID는 Peripheral이 가지고 있는 서비스의 UUID를 뜻 (커스텀함)
    private var serviceUUID = CBUUID(string: tempUUID)  // CBUUID(string: "FFE0")
    
    // MARK: - Init
    
    /// serial을 초기화할 떄 호출하여야합니다. 시리얼은 nil될 수 없기 때문에 항상 초기화후 사용해야 합니다.
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
//        peripheralManager.add(CBMutableService(type: serviceUUID, primary: true))
        self.currentMode = .scanningMode
    }
    
    // MARK: - Functions
    
    func setBluetoothModeAndStart(to mode: BluetoothMode) {
        switch mode {
        case .advertisingMode:
            if centralManager.isScanning {  // .poweredOn 일때만 해야함
                centralManager.stopScan()
            }
            currentMode = .advertisingMode
            self.startAdvertising()
        case .scanningMode:
            peripheralManager.stopAdvertising()
            currentMode = .scanningMode
            startScan()
        }
        print("[BluetoothSerialManager] Switched mode to \(currentMode.rawValue)")
    }
    
    /// 기기 검색 시작, 연결이 가능한 모든 주변기기를 serviceUUID를 통해 검색
    func startScan() {
        if centralManager.state == .poweredOn {
            if !centralManager.isScanning {
                print("[BluetoothSerialManager] startScan ===")
                // withService가 nil 이면 모든 종류의 기기 검색 / 입력하면 특정 serviceUUID를 가진 기기만 검색 -> 포착은 후자의 경우
                let options = [CBCentralManagerScanOptionAllowDuplicatesKey: false]  // 이미 스캔된 정보면 다시 스캔 안 하도록 false
                centralManager.scanForPeripherals(withServices: [serviceUUID], options: options)
            }
            else {
                print("![Error] Central manager is already scanning!")
            }
        }
        else {
            print("![Error] Central Manager cannot scan because state is not poweredOn! current state: \(centralManager.state)")
        }
    }
    
    func stopScan() {
        centralManager.stopScan()
    }
    
    /// periphalManager에 service를 추가한 후 advertise 시작하는 메소드
    func startAdvertising() {
        guard peripheralManager.state == .poweredOn else {
            print("[!] Error: Cannot start advertising, Peripheral manager state is \(peripheralManager.state)")
            return
        }
        peripheralManager.removeAllServices()
        peripheralManager.add(CBMutableService(type: serviceUUID, primary: true))
        peripheralManager.startAdvertising([
            CBAdvertisementDataLocalNameKey : "su.yeonn_",  // TODO: 추후 사용자 아이디로 변경
            CBAdvertisementDataServiceUUIDsKey: [self.serviceUUID]
        ])
    }
    
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }
}

// MARK: - Extension; 기기가 central로서의 역할을 할 때

extension BluetoothSerialManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("[BluetoothSerialManager] centralManagerDidUpdateState:")
        switch central.state {
        case .unknown:
            print(">> unknown")
        case .resetting:
            print(">> resetting")
        case .unsupported:
            print(">> unsupported")
        case .unauthorized:
            print(">> unauthorized")
        case .poweredOff:
            print(">> power Off")
        case .poweredOn:
            print(">> power on")
            if !centralManager.isScanning && currentMode == .scanningMode { startScan() }
        @unknown default:
            fatalError()
        }
    }
    
    // 기기가 검색될 때마다 호출, 여기서 커스텀한 service만 찾을 수 있도록
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        print("[BluetoothSerialManager] central manager did discover peripheral")
        print(">> name: \(peripheral.name ?? "UNKNOWN NAME")")
        print(">> uuid: \(peripheral.identifier.uuidString)")
        print(">> advertisementData, local name: \(localName)")
        print(">> advertisementData, service uuid: \(advertisementData[CBAdvertisementDataServiceUUIDsKey])")
        
        // advertisement data가 제대로 왔을 때에만 delegate 메소드 호출
        if localName != nil {
            delegate?.serialDidDiscoverPeripheral(peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI)
        }
    }
}

// MARK: - Extension; 기기가 peripheral로서의 역할을 할 때의 메소드

extension BluetoothSerialManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("[BluetoothSerialManager] peripheralManagerDidUpdateState:")
        switch peripheral.state {
        case .unknown:
            print(">> unknown")
        case .resetting:
            print(">> resetting")
        case .unsupported:
            print(">> unsupported")
        case .unauthorized:
            print(">> unauthorized")
        case .poweredOff:
            print(">> power Off")
        case .poweredOn:
            print(">> power on")
            if currentMode == .advertisingMode {
                startAdvertising()
            }
        @unknown default:
            fatalError()
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: (any Error)?) {
        print("[BluetoothSerialManager] peripheralManagerDidStartAdvertising:")
        print(">> \(peripheral.isAdvertising)")
        if let error = error {
            print("![Error] \(error.localizedDescription)")
        }
    }
}
