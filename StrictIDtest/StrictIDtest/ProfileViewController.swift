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
    
    private var centralManager: CBCentralManager!
    private var sensorTag: CBPeripheral?
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
}

extension ProfileViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var state = "N/A"
        
        switch central.state {
        case .poweredOn:
            state = "Scanning..."
            centralManager.scanForPeripherals(withServices: [], options: nil)
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
        
        print("State: " + state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name else {
            return
        }
        
        if (!discoveredDevices.contains(peripheral) && !name.isEmpty) {
            discoveredDevices.append(peripheral)
            tableView.reloadData()
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Device Cell", for: indexPath)
        cell.textLabel?.text = discoveredDevices[indexPath.row].name
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendButton.isEnabled = true
    }
}
