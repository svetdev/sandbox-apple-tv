//
//  LogoutVC.swift
//  ZypeAppleTVBase
//
//  Created by Andrey Kasatkin on 10/03/16.
//  Copyright © 2016 Zype. All rights reserved.
//

import Foundation

open class LogoutVC: UIViewController {

 
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var logoutTitle: UILabel!
    
    @IBOutlet weak var logoutFooter: UILabel!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        //self.configureView()
        self.setupText()
    }

    func setupText() {
        let pageHeaderText = UserDefaults.standard.object(forKey: kLogoutPageHeader)
        if (pageHeaderText != nil) {
           self.logoutTitle.text = pageHeaderText as? String
        }
        let pageFooterText = UserDefaults.standard.object(forKey: kLogoutPageFooter)
        if (pageFooterText != nil) {
            self.logoutFooter.text = pageFooterText as? String
        }

    }
    
    @IBAction func logoutClicked(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: kDeviceLinkedStatus)
        ZypeAppleTVBase.sharedInstance.logOut()
        
        UserDefaults.standard.removeObject(forKey: kUserEmail)
        UserDefaults.standard.removeObject(forKey: kUserPassword)
        
        let defaults = UserDefaults.standard
        let favorites = [String]()
        defaults.set(favorites, forKey: kFavoritesKey)
        defaults.synchronize()
        
         NotificationCenter.default.post(name: Notification.Name(rawValue: kZypeReloadScreenNotification), object: nil)
    }
}
