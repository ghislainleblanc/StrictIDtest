//
//  ProfileViewController.swift
//  StrictIDtest
//
//  Created by Ghislain Leblanc on 2018-03-29.
//  Copyright © 2018 Leblanc, Ghislain. All rights reserved.
//

import UIKit
import CoreBluetooth

class ProfileViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var sendButton: UIButton!
    
    var account: String?
    
    private var centralManager: CBCentralManager!
    private var sensor: CBPeripheral?
    private var discoveredDevices: Array<CBPeripheral> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction private func sendButtonAction() {
        guard let service = sensor?.services?.first else {
            return
        }
        
        guard let characteristic = service.characteristics?.first else {
            return
        }
        
        guard let data = account?.data(using: .utf8) else {
            return
        }

        print("sending:\n" + data.description)
        sensor?.writeValue(data, for: characteristic, type: .withoutResponse)
    }
}

extension ProfileViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverServices")
        sensor = peripheral
        
        guard let services = peripheral.services?.first else {
            return
        }
        
        peripheral.discoverCharacteristics([CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")], for: services)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsFor")
        sensor = peripheral
        
        guard let characteristic = sensor?.services?.first?.characteristics?.first else {
            return
        }
        peripheral.discoverDescriptors(for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("didDiscoverDescriptorsFor")
        sendButton.isEnabled = true
    }
}

extension ProfileViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var state = "n/a"
        
        switch central.state {
        case .poweredOn:
            state = "scanning..."
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        case .poweredOff:
            state = "Bluetooth on this device is currently powered off."
        case .unsupported:
            state = "This device does not support Bluetooth Low Energy."
        case .unauthorized:
            state = "This app is not authorized to use Bluetooth Low Energy."
        case .resetting:
            state = "The BLE Manager is resetting; a state update is pending."
        case .unknown:
            state = "The state of the BLE Manager is unknown."
        }
        
        print(state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (!discoveredDevices.contains(peripheral)) {
            discoveredDevices.append(peripheral)
            tableView.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect")
        sensor = peripheral
        sensor?.discoverServices([CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnect")
        sendButton.isEnabled = false
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Device Cell", for: indexPath)
        cell.textLabel?.text = discoveredDevices[indexPath.row].name?.count != 0 ? discoveredDevices[indexPath.row].name : discoveredDevices[indexPath.row].description
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sensor = discoveredDevices[indexPath.row]
        sensor?.delegate = self
        if (sensor != nil) {
            centralManager.connect(sensor!, options:nil)
        }
    }
}
