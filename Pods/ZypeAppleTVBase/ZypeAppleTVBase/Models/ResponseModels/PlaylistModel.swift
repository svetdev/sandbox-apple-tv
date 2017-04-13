//
//  PlaylistModel.swift
//  ZypeAppleTVBase
//
//  Created by Ilya Sorokin on 10/28/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

open class PlaylistModel: BaseModel {
    
    fileprivate(set) open var pId = ""
    fileprivate(set) open var descriptionString = ""
    fileprivate(set) open var keywords = Array<String>()
    fileprivate(set) open var active = false
    fileprivate(set) open var priority = 0
    fileprivate(set) open var createdAt: Date?
    fileprivate(set) open var updatedAt: Date?
    fileprivate(set) open var playlistItemCount = 0
    fileprivate(set) open var siteID = ""
    fileprivate(set) open var relatedVideoIDs = Array<String>()
    fileprivate(set) open var parentId = ""
    
    fileprivate(set) open var thumbnails = Array<ThumbnailModel>()
    fileprivate(set) open var images = Array<ThumbnailModel>()
    
    public init(fromJson: Dictionary<String, AnyObject>)
    {
        super.init(json: fromJson)
        do {
            self.pId = try SSUtils.stringFromDictionary(fromJson, key: kJSON_Id)
        }
        catch _ {
            ZypeLog.error("Exception: PlaylistModel - pId")
        }
        
        do {
            self.descriptionString = try SSUtils.stringFromDictionary(fromJson, key: kJSONDescription)
            
        }
        catch _ {
            ZypeLog.error("Exception: PlaylistModel - Description")
        }
        
        self.keywords = fromJson[kJSON_Keywords] as! Array<String>
       
        do {
            self.active = try SSUtils.boolFromDictionary(fromJson, key: kJSONActive)
        }
        catch _ {
            ZypeLog.error("Exception: PlaylistModel - Active")
        }
        
        do {
            self.priority = try SSUtils.intagerFromDictionary(fromJson, key: kJSONPriority)
        }
        catch _ {
            ZypeLog.error("Exception: PlaylistModel - priority")
        }
        
        do {
            self.createdAt = SSUtils.stringToDate(try SSUtils.stringFromDictionary(fromJson, key: kJSONCreatedAt))
        }
        catch _ {
            ZypeLog.error("Exception: PlaylistModel - created At")
        }
        
        do {
            self.updatedAt = SSUtils.stringToDate(try SSUtils.stringFromDictionary(fromJson, key: kJSONUpdatedAt))
        }
        catch _ {
            ZypeLog.error("Exception: PlaylistModel - updated At")
        }
        
        do {
            self.playlistItemCount = try SSUtils.intagerFromDictionary(fromJson, key: kJSONPlaylistItemCount)
        }
        catch _ {
            ZypeLog.error("Exception: PlaylistModel - Playlist Item Content")
        }
        
        do {
            self.siteID = try SSUtils.stringFromDictionary(fromJson, key: kJSONSiteId)
        }
        catch _ {
            ZypeLog.error("Exception: PlaylistModel - site Id")
        }
        
        self.relatedVideoIDs = fromJson[kJSONRelatedVideoIds] as! Array <String>
        
        do {
            self.parentId = try SSUtils.stringFromDictionary(fromJson, key: kJSONParentId)
        }
        catch _ {
            ZypeLog.error("Exception: PlaylistModel - Parent Id")
        }
        
        self.loadThumbnails(fromJson[kJSONThumbnails] as? Array<AnyObject>)
        self.loadImages(fromJson[kJSONImages] as? Array<AnyObject>)
    }
    
    open func getVideos(_ loadedSince: Date = Date(), completion:@escaping (_ videos: Array<VideoModel>?, _ error: NSError?) -> Void)
    {
        let videos = self.userData["videos"]
        if (videos != nil)
        {
            if(loadedSince.compare(self.userData["date"] as! Date) == ComparisonResult.orderedAscending)
            {
                completion(videos as? Array<VideoModel>, nil)
                return
            }
        }
        ZypeAppleTVBase.sharedInstance.retrieveVideosInPlaylist(QueryRetrieveVideosInPlaylistModel(playlist: self), completion:{(videos, error) -> Void in
            self.userData["videos"] = videos as AnyObject?
            self.userData["date"] = Date() as AnyObject?
            completion(videos, error)
        })
    }
    
    fileprivate func loadThumbnails(_ thumbnails: Array<AnyObject>?)
    {
        do
        {
            if (thumbnails != nil)
            {
                for value in thumbnails!
                {
                    let height = try SSUtils.intagerFromDictionary(value as? Dictionary<String, AnyObject>, key: kJSONHeight)
                    let width = try SSUtils.intagerFromDictionary(value as? Dictionary<String, AnyObject>, key: kJSONWidth)
                    let url = try SSUtils.stringFromDictionary(value as? Dictionary<String, AnyObject>, key: kJSONUrl)
                    let nameValue = value[kJSONName]
                    let name = ((nameValue as? String) != nil) ? (nameValue as! String) : ""
                    self.thumbnails.append(ThumbnailModel(height: height, width: width, url: url, name: name))
                }
            }
        }
        catch _
        {
            ZypeLog.error("Exception: PlaylistModel | Load Thumbnails")
        }
    }
    
    
    fileprivate func loadImages(_ images: Array<AnyObject>?)
    {
        do
        {
            if (images != nil)
            {
                for value in images!
                {
                    let url = try SSUtils.stringFromDictionary(value as? Dictionary<String, AnyObject>, key: kJSONUrl)
                    let nameValue = value[kJSONTitle]
                    let name = ((nameValue as? String) != nil) ? (nameValue as! String) : ""
                    self.images.append(ThumbnailModel(height: 0, width: 0, url: url, name: name))
                }
            }
        }
        catch _
        {
            ZypeLog.error("Exception: PlaylistModel | Load Images")
        }
    }
}

