//
//  ViewController.swift
//  StrictIDperipheral
//
//  Created by Ghislain Leblanc on 2018-03-30.
//  Copyright © 2018 Leblanc, Ghislain. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    @IBOutlet private weak var firstLabel: UILabel!
    @IBOutlet private weak var secondLabel: UILabel!
    @IBOutlet private weak var thirdLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    
    private var peripheral: CBPeripheralManager!
    private var receiveCharacteristic: CBMutableCharacteristic!
    private var transmitCharacteristic: CBMutableCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        peripheral = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    fileprivate func addService() {
        var properties: CBCharacteristicProperties = [.notify, .read]
        let permissions: CBAttributePermissions = [.readable, .writeable]
        
        transmitCharacteristic = CBMutableCharacteristic(type: CBUUID(string: "C9D7271A-1B8C-4F17-9756-F7EB36B18A2B"),
                                                         properties: properties,
                                                         value: nil,
                                                         permissions: permissions)
        
        properties = [.write]
        receiveCharacteristic = CBMutableCharacteristic(type: CBUUID(string: "8CED9D9F-9EAD-4CE8-964C-0EAC13467236"),
                                                       properties: properties,
                                                       value: nil,
                                                       permissions: permissions)
        
        
        let service = CBMutableService(type: CBUUID(string: "64B777E4-1F94-4388-B098-665DC9F26881"), primary: true)
        service.characteristics = [receiveCharacteristic, transmitCharacteristic]
        
        peripheral.add(service)
    }
}

extension ViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            addService()
        default:
            statusLabel.text = "Error..."
            break
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("Status advertising...")
        statusLabel.text = "Advertising..."
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        var advertisement: [String : Any] = [:]
        
        advertisement[CBAdvertisementDataServiceUUIDsKey] = ["64B777E4-1F94-4388-B098-665DC9F26881"]
        advertisement[CBAdvertisementDataLocalNameKey] = "Test"
        
        peripheral.startAdvertising(advertisement)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {

    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
    }
}
