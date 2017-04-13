//
//  QueryRetrieveVideosInPlaylistModel.swift
//  ZypeAppleTVBase
//
//  Created by Ilya Sorokin on 10/28/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

open class QueryRetrieveVideosInPlaylistModel: QueryBaseModel {
    
    open var playlistID = ""
    
    public init(playlist: PlaylistModel? = nil)
    {
        if playlist != nil
        {
            self.playlistID = playlist!.ID
        }
    }
    
}
