//
//  ZypeСacheManager.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/16/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class ZypeCacheManager: NSObject {
    
    fileprivate(set) internal var loadedVideos = Dictionary<String, VideoModel>()
    fileprivate(set) var favorites = Array<FavoriteModel>()
    fileprivate(set) internal var loadedPlaylists = Dictionary<String, PlaylistModel>()
    fileprivate(set) internal var loadedCategories = Dictionary<String, CategoryModel>()
    fileprivate(set) internal var loadedZobjectTypes = Dictionary<String, ZobjectTypeModel>()
    fileprivate(set) internal var loadedZobjects = Dictionary<String, ZobjectModel>()
    
    func resetConsumer()
    {
        favorites.removeAll()
    }
    
    func synchronizePlaylists(_ playlists: Array<PlaylistModel>) -> Array<PlaylistModel>
    {
        return self.synchronizeObjects(&loadedPlaylists, addObjects: playlists)!
    }
    
    func synchronizeVideos(_ videos: Array<VideoModel>?) -> Array<VideoModel>?
    {
       return self.synchronizeObjects(&loadedVideos, addObjects: videos)
    }
    
    func synchronizeCategories(_ categories: Array<CategoryModel>?) -> Array<CategoryModel>?
    {
        return self.synchronizeObjects(&loadedCategories, addObjects: categories)
    }
    
    func synchronizeZobjectTypes(_ zobjectType: Array<ZobjectTypeModel>?) -> Array<ZobjectTypeModel>?
    {
        return self.synchronizeObjects(&loadedZobjectTypes, addObjects: zobjectType)
    }
    
    func synchronizeZobjects(_ zobjects: Array<ZobjectModel>?) -> Array<ZobjectModel>?
    {
        return self.synchronizeObjects(&loadedZobjects, addObjects: zobjects)
    }
    
    func addFavoriteVideos(_ data: Array<FavoriteModel>?)
    {
        if (data != nil)
        {
            self.favorites.append(contentsOf: data!)
            //sync with user defaults
            let defaults = UserDefaults.standard
            var favorites = defaults.array(forKey: kFavoritesKey) as? Array<String> ?? [String]()
            for favorite in data! {
                if !favorites.contains(favorite.objectID){
                    favorites.append(favorite.objectID)
                }
            }
            defaults.set(favorites, forKey: kFavoritesKey)
            defaults.synchronize()
        }
    }
    
    func removeFromFavorites(_ favoriteObject: FavoriteModel)
    {
        ZypeLog.assert(favorites.contains(favoriteObject),message: "can not remove video from favorites")
        favorites.remove(at: favorites.index(of: favoriteObject)!)
        
        let defaults = UserDefaults.standard
        var locFavorites = defaults.array(forKey: kFavoritesKey) as? Array<String> ?? [String]()
        
            if locFavorites.contains(favoriteObject.objectID){
                locFavorites.remove(at: locFavorites.index(of: favoriteObject.objectID)!)
            }
        
        defaults.set(locFavorites, forKey: kFavoritesKey)
        defaults.synchronize()
    }
    
    func findFavoteForObject(_ object: BaseModel) -> FavoriteModel?
    {
        let filteredArray = favorites.filter({(item) -> Bool in
            return item.objectID == object.ID
        })
        return filteredArray.first
    }
    
    fileprivate func synchronizeObjects<T>(_ loaded: inout Dictionary<String, T>, addObjects: Array<T>?) -> Array<T>?
    {
        if addObjects != nil
        {
            var filteredArray = Array<T>()
            for value in addObjects!
            {
                let ID = (value as! BaseModel).ID
                let object = loaded[ID]
                if object == nil
                {
                    loaded[ID] = value
                    filteredArray.append(value)
                }
                else
                {
                    filteredArray.append(loaded[ID]!)
                }
            }
            return filteredArray
        }
        return nil
    }
    
}
