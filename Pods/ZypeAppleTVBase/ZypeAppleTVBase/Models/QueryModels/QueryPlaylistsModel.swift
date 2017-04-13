//
//  QueryPlaylistsModel.swift
//  ZypeAppleTVBase
//
//  Created by Ilya Sorokin on 10/28/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

open class QueryPlaylistsModel: QueryBaseModel {
    
    open var categoryKey: String = ""
    open var categoryValue: String = ""
    open var active: Bool = true
    open var keyword: String = ""
    open var parentId: String = ""
    open var ordering: String = "asc"
    
    public init(category: CategoryValueModel? = nil,
        active: Bool = true,
        keyword: String = "")
    {
        super.init()
        if (category != nil)
        {
            self.categoryKey = category!.parent!.titleString
            self.categoryValue = category!.titleString
        }
        self.active = active
        self.keyword = keyword
    }
    
}
