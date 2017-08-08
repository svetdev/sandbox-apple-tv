//
//  PurchaseVC.swift
//  AndreySandbox
//
//  Created by Eric Chang on 5/19/17.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

class PurchaseVC: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet var subscriptionButtons: [UIButton]!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for button in subscriptionButtons {
            let productID = Const.productIdentifiers[button.tag]
            if let product = InAppPurchaseManager.sharedInstance.products?[productID] {
                button.setTitle(String(format: localized("Subscription.ButtonFormat"), arguments: [product.localizedTitle, product.localizedPrice(), self.getDuration(productID)]), for: .normal)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUserLogin()
    }
    
    // MARK: - Get & Setup
    
    // since the duration for a SKProduct is not available
    // we need a custtom mapper function to handle that
    func getDuration(_ productID: String) -> String {
        var duration: String = "";
        
        if productID.range(of: "monthly") != nil {duration = "(monthly)"}
        if productID.range(of: " ") != nil {duration = "(yearly)"}
        
        return duration
    }
    
    fileprivate func setupUserLogin() {
        if ZypeUtilities.isDeviceLinked() {
            setupLoggedInUser()
        }
        else {
            setupLoggedOutUser()
        }
    }
    
    fileprivate func setupLoggedInUser() {
        let defaults = UserDefaults.standard
        let kEmail = defaults.object(forKey: kUserEmail)
        guard let email = kEmail else { return }
        
        let loggedInString = NSMutableAttributedString(string: "Logged in as: \(String(describing: email))", attributes: nil)
        let buttonRange = (loggedInString.string as NSString).range(of: "\(String(describing: email))")
        loggedInString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 38.0), range: buttonRange)
        
        accountLabel.attributedText = loggedInString
        accountLabel.textAlignment = .center
        
        loginButton.isHidden = true
    }
    
    fileprivate func setupLoggedOutUser() {
        accountLabel.attributedText = NSMutableAttributedString(string: "Already have an account?")
        loginButton.isHidden = false
    }
    
    // MARK: - Actions
    
    @IBAction func onPlanSelected(_ sender: UIButton) {
        if !ZypeUtilities.isDeviceLinked() {
            ZypeUtilities.presentRegisterVC(self)
        }
        
        self.purchase(Const.productIdentifiers[sender.tag])
    }
    
    @IBAction func onSignIn(_ sender: UIButton) {
        ZypeUtilities.presentLoginVC(self)
    }
    
    func purchase(_ productID: String) {
        InAppPurchaseManager.sharedInstance.purchase(productID)
    }
}
