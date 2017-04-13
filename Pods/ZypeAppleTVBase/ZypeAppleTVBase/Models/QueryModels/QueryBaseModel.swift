//
//  QueryBaseModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/21/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

open class QueryBaseModel: NSObject  {

    public init(page: Int = kApiFirstPage,
        perPage: Int = 0)
    {
        super.init()
        self.page = page
        self.perPage = perPage
    }
    
    open var page: Int = kApiFirstPage
    open var perPage: Int = 0
    
}
