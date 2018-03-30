//
//  LoginViewController.swift
//  StrictIDtest
//
//  Created by Ghislain Leblanc on 2018-03-29.
//  Copyright © 2018 Leblanc, Ghislain. All rights reserved.
//

import UIKit
import Heimdallr

class LoginViewController: UIViewController {

    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var loginButton: UIButton!
    
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
    
    @IBAction private func login() {
//        guard let username = usernameTextField.text, let password = passwordTextField.text, username.count != 0, password.count != 0 else {
//            messageLabel.text = "Missing credentials."
//            return
//        }
//
//        messageLabel.text = ""
        
        let clientID = "B1rOxguwu7Aagg1X8GRDIrO1aAhapvzy2xDOvOJq"
        let secret = "ZEHNjy6K8Ao4lvHo9vvtBaEOBGVBxB9l3Km9RwKpyWqKe4hHw8K6DAxDHNqrVEPbFdlzGFG1fwh9c2yZ47nCGpo7HoqKu56KfGs9WYjCmOocKoqZz5lbMEJvJbfwFgLW"
        let credentials = OAuthClientCredentials(id: clientID, secret: secret)
        let tokenURL = URL(string: "http://strictid.bitcraft.com.pl/api/v2/oauth2/token/")!
        let heimdallr = Heimdallr(tokenURL: tokenURL, credentials: credentials)

        heimdallr.requestAccessToken(username: "ghisleb@me.com", password: "yikes1024") { result in
            switch result {
            case .success:
                print("success")
            case .failure(let error):
                print("failure: \(error.localizedDescription)\n\(error.localizedFailureReason!)")
            }
        }
        self.performSegue(withIdentifier: "Show Profile", sender: nil)
    }
}

