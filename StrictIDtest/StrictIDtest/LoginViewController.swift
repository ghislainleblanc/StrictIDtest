//
//  LoginViewController.swift
//  StrictIDtest
//
//  Created by Ghislain Leblanc on 2018-03-29.
//  Copyright © 2018 Leblanc, Ghislain. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        usernameTextField.addTarget(self, action: #selector(self.textFieldDidEnd(textField:)), for: UIControlEvents.editingDidEndOnExit)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidEnd(textField:)), for: UIControlEvents.editingDidEndOnExit)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func textFieldDidEnd(textField: UITextField) {
        let text = textField.text
        if text?.count != 0 {
            switch textField {
            case usernameTextField:
                passwordTextField.becomeFirstResponder()
            case passwordTextField:
                passwordTextField.resignFirstResponder()
                login()
            default:
                break
            }
        }
    }
    
    private func login() {
        guard let username = usernameTextField.text, let password = passwordTextField.text, username.count != 0, password.count != 0 else {
            messageLabel.text  = "Missing login information."
            return
        }
        
        messageLabel.text = ""
    }
}

