//
//  LoginVC.swift
//  AndreySandbox
//
//  Created by Eric Chang on 5/25/17.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

class LoginVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var loggedUserNameLabel: UILabel!
    @IBOutlet weak var restorePurchasesButton: UIButton!
    @IBOutlet weak var subscriptionStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameTextField.placeholder = localized("Login.UsernamePlaceholder")
        self.passwordTextField.placeholder = localized("Login.PasswordPlaceholder")
        self.loginButton.setTitle(localized("Login.LoginButton"), for: .normal)
        self.logoutButton.setTitle(localized("Login.LogoutButton"), for: .normal)
        self.registerButton.setTitle(localized("Login.RegisterButton"), for: .normal)
        self.refreshStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshStatus()
    }
    
    func refreshStatus(){
        if(ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn == true) {
            self.loginView.isHidden = true
            self.logoutView.isHidden = false
            self.loggedUserNameLabel.text = localized("Login.LoggedAs") + " " + ZypeAppleTVBase.sharedInstance.consumer!.emailString
        } else {
            self.loginView.isHidden = false
            self.logoutView.isHidden = true
        }
        self.titleLabel.text = localized(ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn == true ? "Login.LogoutTitle" : "Login.LoginTitle")
        InAppPurchaseManager.sharedInstance.checkSubscription({(isSubscripted, expirationDate, error) in
            if let _ = expirationDate, isSubscripted {
                self.subscriptionStatusLabel.text = String(format: localized("Subscription.ExpirationStatus"), arguments: [expirationDate!.description])
            } else if (error == nil) {
                self.subscriptionStatusLabel.text = localized("Subscription.NotSubscribed")
            } else {
                self.subscriptionStatusLabel.text = localized("Subscription.ExpirationInfoError")
            }
        })
    }
    
    @IBAction func onLogin(sender: AnyObject) {
        if let email = self.userNameTextField.text, let password = self.passwordTextField.text {
            if(email.isEmpty || password.isEmpty) {
                alert(localized("Login.CredentialsEmpty"))
            } else if(!isValidEmail(email)) {
                alert(localized("Login.EmailNotValid"))
            } else {
                showModalProgress(localized("Progress.Login"))
                ZypeAppleTVBase.sharedInstance.login(self.userNameTextField.text!, passwd: self.passwordTextField.text!, completion: {[unowned self] (LogedIn, error) -> Void in
                    hideModalProgress()
                    if(LogedIn) {
                        self.refreshStatus()
                    } else {
                        displayError(error)
                    }
                })
            }
        }
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        ZypeAppleTVBase.sharedInstance.logOut()
        self.refreshStatus()
    }
    
    @IBAction func onRestorePurchases(sender: AnyObject) {
        showModalProgress(localized("Login.RestoringPurchases"))
        InAppPurchaseManager.sharedInstance.restorePurchases({(success: Bool, error: NSError?) in
            hideModalProgress()
            if(success) {
                alert(localized("Login.PurchasesRestored"))
            } else {
                displayError(error)
            }
        })
    }
    
    @IBAction func onRegister(sender: AnyObject) {
        self.performSegue(withIdentifier: "Register", sender: nil)
    }
}
