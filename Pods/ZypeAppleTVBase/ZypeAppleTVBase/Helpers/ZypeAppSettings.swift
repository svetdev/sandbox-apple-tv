//
//  AppSettings.swift
//  ZypeAppleTVBase
//
//  Created by Andrey Kasatkin on 5/11/16.
//  Copyright © 2016 Zype. All rights reserved.
//

import Foundation

public struct LimitLivestream {
    public var limit: Int = 0
    public var played: Int = 0
    public var message: String = ""
    public var refreshRate: Int = 0
    public var starts: TimeInterval = 0
    public var isSet = false
}

public struct DeviceLinking {
    public var isEnabled = false
    public var linkUrl: String = "Please update linkUrl in zObject settings"
}

private let sharedInstance = ZypeAppSettings()

open class ZypeAppSettings {
    
    open static let sharedInstance = ZypeAppSettings()
    
    open var appVersion = "1.0.0"
    
    open var limitLivestream = LimitLivestream()
    
    open var deviceLinking = DeviceLinking()
    
    fileprivate init() {
        
    }
    
    
    open func deviceId() -> String {
        var deviceID = UserDefaults().value(forKey: "device")
        
        if(deviceID == nil) {
            deviceID = UIDevice.current.identifierForVendor!.uuidString
            UserDefaults().setValue(deviceID, forKey: "device")
        }
        
        return deviceID as! String
    }
    
}
