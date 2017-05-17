//
//  AdProtocolDelegate.swift
//  AndreySandbox
//
//  Created by Eric Chang on 5/16/17.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import ZypeAppleTVBase

protocol AdHelperProtocol: class {
    func playAds(adsArray: NSMutableArray, url: NSURL)
    func addAdLabel(player: DVPlayerView)
    func getAdsFromResponse(_ playerObject: VideoObjectModel?) -> NSMutableArray
    func adTimerDidFire()
    func removeAdTimer()
    func nextAdPlayer()
    func removeAdPlayer()
}

class AdHelper {
    
    weak var delegate: AdHelperProtocol?
    
    func playAds(adsArray: NSMutableArray, url: NSURL) {
        delegate?.playAds(adsArray: adsArray, url: url)
    }
    
    func addAdLabel(player: DVPlayerView) {
        delegate?.addAdLabel(player: player)
    }

    func getAdsFromResponse(_ playerObject: VideoObjectModel?) -> NSMutableArray {
        return (delegate?.getAdsFromResponse(playerObject))!
    }
    
    func adTimerDidFire() {
        delegate?.adTimerDidFire()
    }
    
    func removeAdTimer() {
        delegate?.removeAdTimer()
    }
    
    func nextAdPlayer() {
        delegate?.nextAdPlayer()
    }
    
    func removeAdPlayer() {
        delegate?.removeAdPlayer()
    }
}


extension PlayerVC: AdHelperProtocol {
    
    func playAds(adsArray: NSMutableArray, url: NSURL) {
        self.adPlayer = DVIABPlayer()
        
        let screenSize = UIScreen.main.bounds
        self.playerView = DVPlayerView(frame: CGRect(x: 0,y: 0,width: screenSize.width, height: screenSize.height))
        
        self.adPlayer!.playerLayer = self.playerView?.layer as! AVPlayerLayer
        (self.playerView?.layer as! AVPlayerLayer).player = self.adPlayer
        self.view.addSubview(self.playerView!)
        
        let adPlaylist = DVVideoMultipleAdPlaylist()
        
        adPlaylist.playBreaks = NSArray(array: adsArray.copy() as! [AnyObject]) as [AnyObject]
        self.adPlayer!.adPlaylist = adPlaylist
        self.adPlayer!.delegate = self
        
        self.playerItem = AVPlayerItem(url: url as URL)
        self.playerItem.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        self.adPlayer!.contentPlayerItem = self.playerItem
        self.adPlayer!.replaceCurrentItem(with: self.playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerVC.setupAdTimer), name: NSNotification.Name(rawValue: "setupAdTimer"), object: nil)
        
        removeAdTimer()
        
        if let player = self.playerView {
            addAdLabel(player: player)
        }
        
        //this is called when there are ad tags, but they don't return any ads
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerVC.removeAdsAndPlayVideo), name: NSNotification.Name(rawValue: "noAdsToPlay"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerVC.contentDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.adPlayer!.contentPlayerItem)
    }
    
    
    func addAdLabel(player: DVPlayerView) {
        let screenSize = UIScreen.main.bounds
        let skipView = UIView(frame: CGRect(x: screenSize.width-250,
                                            y: 30,
                                            width: 250,
                                            height: 40))
        skipView.tag = 1002
        skipView.backgroundColor = UIColor.black
        skipView.alpha = 0.7
        let skipLabel = UILabel(frame: CGRect(x: 0,
                                              y: 0,
                                              width: 100,
                                              height: 40))
        skipLabel.text = "Ad"
        skipLabel.font = UIFont.systemFont(ofSize: 30)
        skipLabel.textColor = UIColor.white
        skipLabel.textAlignment = .center
        skipView.addSubview(skipLabel)
        player.addSubview(skipView)
    }
    
    
    func getAdsFromResponse(_ playerObject: VideoObjectModel?) -> NSMutableArray {
        var adsArray = NSMutableArray()
        if let body = playerObject?.json?["response"]?["body"] as? NSDictionary {
            if let advertising = body["advertising"] as? NSDictionary{
                let schedule = advertising["schedule"] as? NSArray
                
                self.adsData = [adObject]()
                
                if (schedule != nil) {
                    for i in 0..<schedule!.count {
                        let adDict = schedule![i] as! NSDictionary
                        let ad = adObject(offset: adDict["offset"] as? Double, tag:adDict["tag"] as? String)
                        self.adsData.append(ad)
                    }
                }
            }
        }
        
        if self.adsData.count > 0 {
            
            for i in 0..<self.adsData.count {
                let ad = self.adsData[i]
                
                if ad.offset == 0 {
                    print(ad.tag!)
                    adsArray.add(DVVideoPlayBreak.playBreakBeforeStart(withAdTemplateURL: URL(string: ad.tag!)!))
                }
            }
        }
        else {
            adsArray = NSMutableArray()
        }
        return adsArray
    }
    
    
    func removeAdTimer() {
        self.isSkippable = false
        
        if let viewWithTag = self.view.viewWithTag(1001) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002) {
            viewWithTag.removeFromSuperview()
        }
        if self.adTimer != nil {
            self.adTimer.invalidate()
        }
    }
    
    
    func nextAdPlayer() {
        self.isSkippable = false
        if let viewWithTag = self.view.viewWithTag(1001) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002) {
            viewWithTag.removeFromSuperview()
        }
        
        // this
        if (self.adPlayer?.adsQueue.count)! > 0 {
            self.adPlayer?.finishCurrentInlineAd(self.adPlayer?.currentInlineAdPlayerItem)
        }
        else {
            self.removeAdPlayer()
            self.setupVideoPlayer()
        }
    }
    
    
    func removeAdPlayer() {
        self.isSkippable = false
        if let viewWithTag = self.view.viewWithTag(1001) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002) {
            viewWithTag.removeFromSuperview()
        }
        
        self.playerItem.removeObserver(self, forKeyPath: "status", context: nil)
        self.adPlayer!.pause()
        self.playerLayer.removeFromSuperlayer()
        self.adPlayer!.adPlaylist = DVVideoMultipleAdPlaylist()
        self.adPlayer!.contentPlayerItem = nil
        self.adPlayer?.replaceCurrentItem(with: nil)
        self.adPlayer = nil
        self.playerItem = nil
        self.playerView!.removeFromSuperview()
        self.playerView = nil
        NotificationCenter.default.removeObserver(self)
    }
}

struct adObject {
    var offset: Double?
    var tag: String?
}
