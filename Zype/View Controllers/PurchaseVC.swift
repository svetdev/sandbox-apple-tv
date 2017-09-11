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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var selectedPlan: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for button in subscriptionButtons {
            let productID = Const.productIdentifiers[button.tag]
            if let product = InAppPurchaseManager.sharedInstance.products?[productID] {
                button.setTitle(String(format: localized("Subscription.ButtonFormat"), arguments: [product.localizedTitle, product.localizedPrice(), self.getDuration(productID)]), for: .normal)
            }
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(spinForPurchase),
                                               name: NSNotification.Name(rawValue: "kSpinForPurchase"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(unspinForPurchase),
                                               name: NSNotification.Name(rawValue: "kUnspinForPurchase"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(completePurchase),
                                               name: NSNotification.Name(rawValue: "kRegisterCompleted"),
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUserLogin()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "kDismissRegister"), object: nil)
        unspinForPurchase()
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
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(onPurchased),
                                                   name: NSNotification.Name(rawValue: InAppPurchaseManager.kPurchaseCompleted),
                                                   object: nil)

            self.selectedPlan = Const.productIdentifiers[sender.tag]

            ZypeUtilities.presentRegisterVC(self)
        }
        else {
            self.purchase(Const.productIdentifiers[sender.tag])
        }
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onPurchased),
                                               name: NSNotification.Name(rawValue: InAppPurchaseManager.kPurchaseCompleted),
                                               object: nil)
        ZypeUtilities.presentLoginMethodVC(self)
    }
    
    func purchase(_ productID: String) {
        InAppPurchaseManager.sharedInstance.purchase(productID)
    }

    func completePurchase() {
        self.purchase(self.selectedPlan)
    }
    
    func onPurchased() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func spinForPurchase() {
        self.activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        self.activityIndicator.startAnimating()
        
        for view in self.view.subviews {
            view.isUserInteractionEnabled = false
        }
    }
    
    func unspinForPurchase() {
        self.activityIndicator.stopAnimating()
        
        for view in self.view.subviews {
            view.isUserInteractionEnabled = true
        }
    }
}
