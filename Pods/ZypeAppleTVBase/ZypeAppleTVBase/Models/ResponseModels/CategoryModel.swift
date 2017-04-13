//
//  CategoryModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/9/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

open class CategoryModel : BaseModel {
    
    open let keywords: Array<String>
    fileprivate(set) open var valuesArray: Array<CategoryValueModel>? = nil
        
    init(fromJson: Dictionary<String, AnyObject>)
    {
        keywords = CategoryModel.getKeywords(fromJson[kJSON_Keywords] as? Array<AnyObject>)
        super.init(json: fromJson)
        valuesArray = CategoryModel.getValues(fromJson[kJSONValues] as? Array<AnyObject>, parent: self)
    }
    
    open func valueByID(_ ID: String) -> CategoryValueModel?
    {
        let filteredArray = self.valuesArray!.filter({(item) -> Bool in return item.ID == ID})
        return filteredArray.first
    }
    
    fileprivate static func getKeywords(_ json: Array<AnyObject>?) -> Array<String>
    {
        if (json == nil)
        {
            return Array()
        }
        return json as! Array<String>
    }
    
    fileprivate static func getValues(_ json: Array<AnyObject>?, parent: CategoryModel) -> Array<CategoryValueModel>
    {
        var labels = Array<CategoryValueModel>()
        if (json != nil)
        {
            for value in json!
            {
                let title = value as! String
                labels.append(CategoryValueModel(name: title, parent: parent))
            }
        }
        return labels
    }

}
    

