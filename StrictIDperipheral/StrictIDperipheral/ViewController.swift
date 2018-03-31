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
    @IBOutlet private weak var statusLabel: UILabel!
    
    private var peripheral: CBPeripheralManager!
    private var receiveCharacteristic: CBMutableCharacteristic!
    
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
        let properties: CBCharacteristicProperties = [.writeWithoutResponse]
        let permissions: CBAttributePermissions = [.writeable]
        receiveCharacteristic = CBMutableCharacteristic(type: CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4"),
                                                       properties: properties,
                                                       value: nil,
                                                       permissions: permissions)
        
        
        let service = CBMutableService(type: CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961"), primary: true)
        service.characteristics = [receiveCharacteristic]
        
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
        print("advertising...")
        statusLabel.text = "Advertising..."
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        var advertisement: [String : Any] = [:]

        advertisement[CBAdvertisementDataServiceUUIDsKey] = [CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")]
        
        peripheral.startAdvertising(advertisement)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("didSubscribeTo")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("didUnsubscribeFrom")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("didReceiveRead")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("didReceiveWrite")
        guard let data = requests.first?.value, let string = String(data: data, encoding: .utf8) else {
            return
        }
        firstLabel.text = string
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("peripheralManagerIsReady")
    }
}
