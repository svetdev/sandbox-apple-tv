//
//  AdProtocolDelegate.swift
//  AndreySandbox
//
//  Created by Eric Chang on 5/16/17.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import ZypeAppleTVBase

protocol AdHelperProtocol: class {
    func getAdsFromResponse(_ playerObject: VideoObjectModel?) -> NSMutableArray
    func playAds(adsArray: NSMutableArray, url: NSURL)
    func adTimerDidFire()
    func addAdLabel(player: DVPlayerView)
    func nextAdPlayer()
    func removeAdTimer()
    func removeAdPlayer()
}

extension PlayerVC: AdHelperProtocol {
    
}

struct adObject {
    var offset: Double?
    var tag: String?
}
