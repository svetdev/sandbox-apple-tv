//
//  QueryZobjectsModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/21/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

open class QueryZobjectsModel: QueryBaseModel {

    open var zobjectType = ""
    open var keywords = ""
    open var anyQueryString = ""
    
    public init () {
        super.init()
    }
    
    public init (objectType: ZobjectTypeModel? = nil)
    {
        super.init()
        if objectType != nil
        {
            self.zobjectType = objectType!.titleString
        }
    }
    
}
