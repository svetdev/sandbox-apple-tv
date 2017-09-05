//
//  RegisterVC.swift
//  ZypeAppleTVBase
//
//  Created by Eric Chang on 7/20/17.
//  Copyright © 2017 Zype. All rights reserved.
//

import Foundation

class RegisterVC: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func onRegister(_ sender: UIButton) {
        guard self.validateFields() else { return }
        
        let consumer = ConsumerModel(name: emailTextField.text!,
                                     email: emailTextField.text!,
                                     password: passwordTextField.text!)
        
        ZypeAppleTVBase.sharedInstance.createConsumer(consumer) { (success, error) in
            
            if success {
                ZypeAppleTVBase.sharedInstance.login(consumer.emailString, passwd: consumer.passwordString, completion: { (loggedIn, error) in
                    if loggedIn {
                        UserDefaults.standard.set(true, forKey: kDeviceLinkedStatus)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kZypeReloadScreenNotification), object: nil)
                        
                        let presentingViewController = self.presentingViewController
                        self.dismiss(animated: false, completion: {
                            presentingViewController!.dismiss(animated: true)
                        })
                    }
                    else {
                        if let error = error?.localizedDescription {
                            self.presentAlertWithText(error)
                        }
                    }
                })
            }
            // could not create consumer
            else {
                if let error = error?.localizedDescription {
                    self.presentAlertWithText(error)
                }
                else {
                    self.presentAlertWithText("Oops! Something went wrong. Could not register.")
                }
            }
        }
    }
    
    // MARK: - Utilities
    
    fileprivate func validateFields() -> Bool {
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            guard !email.isEmpty else {
                self.presentAlertWithText("Please enter your email.")
                return false
            }
            guard isValid(email: email) else {
                self.presentAlertWithText("Please enter a valid email")
                return false
            }
            guard !password.isEmpty else {
                self.presentAlertWithText("Please create a password.")
                return false
            }
            
            return true
        }
        print("Field no valid")
        return false
    }
    
    fileprivate func presentAlertWithText(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let ignoreAction = UIAlertAction(title: "Ok", style: .cancel) { _ in }
        
        alertController.addAction(ignoreAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func isValid(email:String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
