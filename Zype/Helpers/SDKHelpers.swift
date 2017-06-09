//
//  SDKHelpers.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/21/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//


import UIKit
import ZypeAppleTVBase

extension VideoModel {
    
    func thumbnailURL() -> NSURL? {
        if(self.thumbnails.count > 0){
            for thumbnail in thumbnails {
                if thumbnail.width > 250 {
                    let url = thumbnail.imageURL
                    return NSURL(string: url)
                }
            }
        }
        return  NSURL(string: "")
    }
    
    func posterURL() -> NSURL? {
        if let model = self.getThumbnailByHeight(720) {
            return NSURL(string: model.imageURL)
        }
        return nil
    }
    
    func isInFavorites() -> Bool{
        let defaults = UserDefaults.standard
        if let favorites = defaults.array(forKey: Const.kFavoritesKey) as? Array<String> {
            return favorites.contains(self.ID)
        }
        return false
    }
    
    func toggleFavorite() {
        let defaults = UserDefaults.standard
        var favorites = defaults.array(forKey: Const.kFavoritesKey) as? Array<String> ?? [String]()
        if(self.isInFavorites()) {
            favorites.remove(at: favorites.index(of: self.ID)!)
        } else {
            favorites.append(self.ID)
        }
        defaults.set(favorites, forKey: Const.kFavoritesKey)
        defaults.synchronize()
    }
    
}

/// Returns a custom banner image for a playlist of playists. If it is a playlist of videos or there is no custom banner image, returns the thumbnail image if available. If both of the previous do not apply, returns a place holder image if network connection is available.
///
/// - Parameter model: PlaylistModel
/// - Returns: URL for an imageURL
func getThumbnailOrBannerImageURL(with model: PlaylistModel, banner: Bool) -> URL {
    let playlistBanner = model.images.filter { $0.name == "appletv_playlist_banner" }
    
    if banner {
        if !playlistBanner.isEmpty {
            return URL(string: playlistBanner[0].imageURL)!
        }
    }
    
    if model.thumbnails.count > 0 {
        return URL(string: model.thumbnails[0].imageURL)!
    }
    else {
        return URL(string: "http://placehold.it/1740x700")!
    }
}
