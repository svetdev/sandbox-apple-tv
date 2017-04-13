//
//  SubscriptionModel.swift
//  ZypeAppleTVBase
//
//  Created by Ilya Sorokin on 10/26/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//


open class SubscriptionModel: NSObject {

    fileprivate(set) open var ID: String = ""
    
    init(fromJson: Dictionary<String, AnyObject>)
    {
        super.init()
    }
}
