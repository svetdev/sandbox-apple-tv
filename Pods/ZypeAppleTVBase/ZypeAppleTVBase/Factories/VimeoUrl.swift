//
//  VimeoUrl.swift
//  ZypeAppleTVBase
//
//  Created by Ilya Sorokin on 10/30/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

class VimeoUrl: BaseUrl, VideoUrl {
    
    // add check here to see if user is logged in and if he is change url with access token
    
    fileprivate var kPlayerGetVideo:String {
        if ((ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn) == true){
            return "%@/embed/%@.json?access_token=%@&dvr=false"
        } else {
            return "%@/embed/%@.json?app_key=%@&dvr=false"
        }
    }
    
    
    func getVideoObject(_ video: VideoModel, completion:@escaping (_ playerObject: VideoObjectModel, _ error: NSError?) -> Void)
    {
        if ((ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn) == true){
            //call with access token
            ZypeAppleTVBase.sharedInstance.getToken({
                (token: String?, error: NSError?) in
                let urlAsString = String(format: self.kPlayerGetVideo, self.controller!.keys.playerDomain, video.ID, token!)
                self.callVideoObject(urlAsString, completion: completion)
            })
        } else {
            //call with api key
            let urlAsString = String(format: kPlayerGetVideo, self.controller!.keys.playerDomain, video.ID, self.controller!.keys.appKey)
            callVideoObject(urlAsString, completion: completion)
        }
    }
    
    func callVideoObject(_ url: String, completion:@escaping (_ playerObject: VideoObjectModel, _ error: NSError?) -> Void)
    {
        _ = self.controller!.getQuery(url, withCompletion:{ (jsonDic, error) -> Void in
            let player = VideoObjectModel()
            player.json = jsonDic
            if let response = jsonDic?[kJSONResponse] as? NSDictionary
                
            {
                if let jsonBody = response[kJSONBody] as? NSDictionary {
                    let outputs = jsonBody[kJSONOutputs] as? Array <Dictionary<String, String> >
                    if outputs?.first != nil
                    {
                        player.videoURL = outputs!.first![kJSONUrl]!
                    }
                }
                
            }
            completion(player, error)
        })
    }
    
}
