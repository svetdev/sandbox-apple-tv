//
//  ZypeTokenModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/20/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

open class ZypeTokenModel: NSObject {

    fileprivate let kDefaultsKeyAccessToken = "kDefaultsKeyAccessToken"
    fileprivate let kDefaultsKeyRefreshToken = "kDefaultsKeyRefreshToken"
    fileprivate let kDefaultsKeyExpirationDate = "kDefaultsKeyExpirationDate"
    
    open var refreshToken: String {
        set  {
            UserDefaults.standard.setValue(newValue, forKey: kDefaultsKeyRefreshToken)
            UserDefaults.standard.synchronize()
        }
        get {
            let token = UserDefaults.standard.value(forKey: kDefaultsKeyRefreshToken)
            if (token == nil)
            {
                return ""
            }
            return token as! String
        }
    }
    
    open var expirationDate: Int {
            set {
                UserDefaults.standard.setValue(newValue, forKey: kDefaultsKeyExpirationDate)
                UserDefaults.standard.synchronize()
            }
            get {
            let date = UserDefaults.standard.value(forKey: kDefaultsKeyExpirationDate)
            if (date == nil)
            {
                return 0
            }
            return date as! Int
        }
    }
    
    open var accessToken: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kDefaultsKeyAccessToken)
            UserDefaults.standard.synchronize()
        }
        get {
            let token = UserDefaults.standard.value(forKey: kDefaultsKeyAccessToken)
            if (token == nil)
            {
                return ""
            }
            return token as! String
        }
    }
    
    override init() {
        super.init()
    }
    
    func reset()
    {
        refreshToken = ""
        accessToken = ""
        expirationDate = 0
    }
    
}
