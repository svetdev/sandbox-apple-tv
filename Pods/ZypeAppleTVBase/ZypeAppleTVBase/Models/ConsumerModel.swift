//
//  ConsumerModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/14/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

open class ConsumerModel: NSObject {

    fileprivate (set) open var ID:String = ""
    fileprivate (set) open var emailString:String = ""
    fileprivate (set) open var nameString:String = ""
    fileprivate (set) internal var passwordString: String = ""
    
    public init(name: String = "", email: String = "", password: String = "")
    {
        super.init()
        self.nameString = name
        self.emailString = email
        self.passwordString = password
    }
    
    open var isLoggedIn: Bool {
        return ID.isEmpty == false
    }
    
    func setData(_ consumerId: String, email: String, name: String)
    {
        ID = consumerId
        emailString = email
        nameString = name
    }
    
    func reset()
    {
        ID = ""
        emailString = ""
        nameString = ""
    }
    
}
