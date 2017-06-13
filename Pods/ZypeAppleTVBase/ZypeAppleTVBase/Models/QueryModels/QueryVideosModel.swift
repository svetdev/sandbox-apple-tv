//
//  QueryVideosModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/21/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

open class QueryVideosModel: QueryBaseModel {

    open var categoryKey: String = ""
    open var categoryValue: String = ""
    open var exceptCategoryKey: String = ""
    open var exceptCategoryValue: String = ""
    open var searchString: String = ""
    open var keyword: String = ""
    open var active: Bool = true
    open var status: String = ""
    open var type: String = ""
    open var videoID: String = ""
    open var exceptVideoID: String = ""
    open var zObjectID: String = ""
    open var exceptZObjectID: String = ""
    open var createdDate: Date? = nil
    open var publishedDate: Date? = nil
    open var dpt: Bool = true
//    public var sortBy: String = ""
    open var onAir: String = ""
    open var sort: String?
    open var ascending: Bool = false
    open var anyQueryString: String = "" //something like &category[video_type]=Film
    
    public init(categoryValue: CategoryValueModel? = nil,
        exceptCategoryValue: CategoryValueModel? = nil,
        searchString: String = "",
        page: Int = kApiFirstPage,
        perPage: Int = 0)
    {
        super.init(page: page, perPage: perPage)
        if (categoryValue != nil)
        {
            self.categoryKey = categoryValue!.parent!.titleString
            self.categoryValue = categoryValue!.titleString
        }
        if (exceptCategoryValue != nil)
        {
            self.exceptCategoryKey = exceptCategoryValue!.parent!.titleString
            self.exceptCategoryValue = exceptCategoryValue!.titleString
        }
        self.searchString = searchString
    }
    
}
