//
//  ZobjectModel.swift
//  ZypeAppleTVBase
//
//  Created by Ilya Sorokin on 10/22/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

open class ZobjectModel: BaseModel {

    fileprivate(set) open var json: Dictionary<String, AnyObject>
    
    open var descriptionString: String
    {
       return self.getStringValue(kJSONDescription)
    }
    open var keywords:Array<String>
    {
        return self.json[kJSONKeywords] as! Array<String>
    }
    open var active:Bool
    {
        return self.getBoolValue(kJSONActive)
    }
    fileprivate(set) open var createdAt: Date?
    fileprivate(set) open var updatedAt: Date?
    open var siteID:String
    {
        return self.getStringValue(kJSONSiteId)
    }
    open var videoIds: Array<String>?
    {
        return self.json[kJSONVideoIds] as? Array<String>
    }
    open var zobjectTypeId: String
    {
        return self.getStringValue(kJSONZobjectTypeId)
    }
    open var zobjectTypeTitle: String
    {
        return self.getStringValue(kJSONZobjectTypeTitle)
    }

    fileprivate(set) open var pictures = Array<ContentModel>()
    
    init(fromJson: Dictionary<String, AnyObject>)
    {
        self.json = fromJson
        super.init(json: fromJson)
        do
        {
            self.createdAt = SSUtils.stringToDate(try SSUtils.stringFromDictionary(fromJson, key: kJSONCreatedAt))
            self.updatedAt = SSUtils.stringToDate(try SSUtils.stringFromDictionary(fromJson, key: kJSONUpdatedAt))
            let pictures = self.json[kJSONPictures]
            if pictures != nil
            {
                for value in pictures as! Array<AnyObject>
                {
                    self.pictures.append(ContentModel(json: value as! Dictionary<String, AnyObject>))
                }
            }
        }
        catch _
        {
            ZypeLog.error("Exception: ZobjectModel")
        }
    }
    
    open func getStringValue(_ key: String) -> String
    {
        do
        {
            return try SSUtils.stringFromDictionary(json, key: key)
        }
        catch _
        {
            ZypeLog.error("Exception: ZobjectModel")
        }
        return ""
    }
    
    open func getBoolValue(_ key: String) -> Bool
    {
        do
        {
            return try SSUtils.boolFromDictionary(json, key: key)
        }
        catch _
        {
            ZypeLog.error("Exception: ZobjectModel")
        }
        return false
    }
    
}
