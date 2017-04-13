//
//  CategoryValueModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/11/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

open class CategoryValueModel: BaseModel {

    fileprivate (set) internal weak var parent:CategoryModel?
    
    init(name: String, parent: CategoryModel)
    {
        super.init(ID: SSUtils.categoryToId(parent.titleString, categoryValue: name), title: name)
        self.parent = parent
    }
 
    open func getVideos(_ loadedSince: Date = Date(), completion:@escaping (_ videos: Array<VideoModel>?, _ error: NSError?) -> Void)
    {
        let videos = self.userData["videos"]
        if (videos != nil)
        {
            if(loadedSince.compare(self.userData["videos_date"] as! Date) == ComparisonResult.orderedAscending)
            {
                completion(videos as? Array<VideoModel>, nil)
                return
            }
        }
        ZypeAppleTVBase.sharedInstance.getVideos({ (videos, error) -> Void in
            self.userData["videos"] = videos as AnyObject?
            self.userData["videos_date"] = Date() as AnyObject?
            completion(videos, error)
        }, categoryValue: self)
    }
    
    open func getPlaylists(_ loadedSince: Date = Date(), completion:@escaping (_ playlists: Array<PlaylistModel>?, _ error: NSError?) -> Void)
    {
        let lists = self.userData["playlists"]
        if lists != nil
        {
            if(loadedSince.compare(self.userData["playlists_date"] as! Date) == ComparisonResult.orderedAscending)
            {
                completion(lists as? Array<PlaylistModel>, nil)
                return
            }
        }
        ZypeAppleTVBase.sharedInstance.getPlaylists(QueryPlaylistsModel(category: self), completion: { (playlists, error) -> Void in
            self.userData["playlists"] = playlists as AnyObject?
            self.userData["playlists_date"] = Date() as AnyObject?
            completion(playlists, error)
        })
    }

}
