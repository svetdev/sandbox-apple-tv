//
//  ZobjectTypeModel.swift
//  ZypeAppleTVBase
//
//  Created by Ilya Sorokin on 10/22/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

open class ZobjectTypeModel: BaseModel {
    
    fileprivate(set) open var keywords = Array<String>()
    fileprivate(set) open var createdAt: Date?
    fileprivate(set) open var updatedAt: Date?
    fileprivate(set) open var descriptionString = ""
    fileprivate(set) open var videosEnabled = true
    fileprivate(set) open var zobjectCount = 0
    fileprivate(set) open var siteIdString = ""
    fileprivate(set) open var zobjectAttributes: Array<AnyObject>?

    init(fromJson: Dictionary<String, AnyObject>)
    {
        super.init(json: fromJson)
        do
        {
            let keywords = fromJson[kJSON_Keywords]
            if (keywords != nil)
            {
                self.keywords = keywords as! Array<String>
            }
            self.createdAt = SSUtils.stringToDate(try SSUtils.stringFromDictionary(fromJson, key: kJSONCreatedAt))
            self.updatedAt = SSUtils.stringToDate(try SSUtils.stringFromDictionary(fromJson, key: kJSONUpdatedAt))
            self.descriptionString = try SSUtils.stringFromDictionary(fromJson, key: kJSONDescription)
            self.videosEnabled = try SSUtils.boolFromDictionary(fromJson, key: kJSONVideosEnabled)
            self.zobjectCount = try SSUtils.intagerFromDictionary(fromJson, key: kJSONZobjectCount)
            self.siteIdString = try SSUtils.stringFromDictionary(fromJson, key: kJSONSiteId)
            self.zobjectAttributes = fromJson[kJSONZobjectAttributes] as? Array<AnyObject>
        }
        catch _
        {
            ZypeLog.error("Exception: ZobjectTypeModel")
        }
    }
    
    open func getZobjects(_ loadedSince: Date = Date(), completion:@escaping (_ zobjects: Array<ZobjectModel>?, _ error: NSError?) -> Void)
    {
        let zobjects = self.userData["zobjects"]
        if zobjects != nil
        {
            if(loadedSince.compare(self.userData["zobjects_date"] as! Date) == ComparisonResult.orderedAscending)
            {
                completion(zobjects as? Array<ZobjectModel>, nil)
                return
            }
        }
        ZypeAppleTVBase.sharedInstance.getZobjects(QueryZobjectsModel(objectType: self), completion: { (objects, error) -> Void in
            self.userData["zobjects"] = objects as AnyObject?
            self.userData["zobjects_date"] = Date() as AnyObject?
            completion(objects, error)
        })
    }
    
}
