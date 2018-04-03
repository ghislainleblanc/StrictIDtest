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
        usernameTextField.addTarget(self, action: #selector(textFieldDidEnd(textField:)), for: UIControlEvents.editingDidEndOnExit)
        passwordTextField.addTarget(self, action: #selector(textFieldDidEnd(textField:)), for: UIControlEvents.editingDidEndOnExit)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? ProfileViewController else {
            return
        }
        
        destination.account = usernameTextField.text
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
    
    @objc private func loginSuccess() {
        self.performSegue(withIdentifier: "Show Profile", sender: nil)
    }
    
    @objc private func loginFailure() {
        self.messageLabel.text = "Bad login."
    }
    
    @IBAction private func login() {
        guard let username = usernameTextField.text, let password = passwordTextField.text, username.count != 0, password.count != 0 else {
            messageLabel.text = "Missing credentials."
            return
        }

        guard isValidEmail(testStr: username) else {
            messageLabel.text = "Username should be valid email."
            return
        }

        messageLabel.text = ""

        let clientID = "htuwMXDUXRSVUs4wQOlVV8DLBV6u8fisSyM4nCz2"
        let secret = "A348L12SbD9jOqw3Vry3aBbLnYzi3rRlspZubRqACI9bymFTR9MBkXxvapRtkne6xEunawgcSprWIICIpI98BGWL8xDq0DkLszIOtRTQDl2T06Ielx46uPiGhk3t2Eyq"
        let credentials = OAuthClientCredentials(id: clientID, secret: secret)
        let tokenURL = URL(string: "https://api-strictid.bitcraft.com.pl/api/v2/oauth2/token/")!
        let heimdallr = Heimdallr(tokenURL: tokenURL, credentials: credentials)

        heimdallr.requestAccessToken(username: username, password: password) { result in
            switch result {
            case .success:
                print("success")
                self.performSelector(onMainThread: #selector(self.loginSuccess), with: nil, waitUntilDone: false)
            case .failure(let error):
                print("failure: \(error.localizedDescription)")
                self.performSelector(onMainThread: #selector(self.loginFailure), with: nil, waitUntilDone: false)
            }
        }
    }
    
    private func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}

