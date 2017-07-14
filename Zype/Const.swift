//
//  Const.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/9/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//
// GIT DESCRIPTION: 1.0-54-g41f2866

import UIKit
import ZypeAppleTVBase

class Const: NSObject {
    
    static var productIdentifiers = ["monthly_subscription", "yearly_subscription"]
    
    //    static var appstorePassword = "f3abb52578a34a03a9ff5130beb95239" // the film detective
    //static var appstorePassword = "2c9105ca20204085a01673bbdc42ace6" // hooplakidz
    static var appstorePassword = "ead5fc19c42045cfa783e24d6e5a2325" // testing - zype
    
    static let sdkSettings = SettingsModel(clientID: "b3589bcfffad139cd61be701ce30928c118c12730af3c462c5c1e884e8944e03",
                                           secret: "3da57d2c71655d9309811d2f4bfc0191d15d33659f7a84e02f87d15edc60a372",
                                           appKey: "IKuC8xERY-oYRxQfE6c1HSeRrxKcpCwcsPr614RfaxCkYsJLgwpBkpkEo88EsyWr",
                                           apiDomain:"https://api.zype.com",
                                           tokenDomain: "https://login.zype.com",
                                           userAgent: "zype tvos")
    
    static let kNativeSubscriptionEnabled = false
    static let kStoreURL = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
    //static let kStoreURL = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")! // for testing only
    static let kLimitLivestreamEnabled = false
    static var kFavoritesViaAPI = false
    static let kAppStyleLight = true
    
    static let kBaseSectionInsets: UIEdgeInsets = UIEdgeInsets(top: 50, left: 90, bottom: 50, right: 90)
    static let kCollectionCellSize: CGSize = CGSize(width: 308, height: 220)
    static let kShowCellHeight: CGFloat = 310
    static let kCollectionHorizontalSpacing: CGFloat = 50.0
    static let kCollectionVerticalSpacing: CGFloat = 50.0
    static let kCollectionSectionHeaderHeight: CGFloat = 45.0
    static let kCollectionPagerCellSize: CGSize = CGSize(width: 1920, height: 700) //1450 x 630 or 1740 x 490
    
    static let kCollectionPagerVCBottomMargin: CGFloat = 70.0
    static let kCollectionSectionHeaderBottomMargin: CGFloat = 25.0
    static let kCollectionPagerHorizontalSpacing: CGFloat = 20.0
    static let kScrollableTextVCMaskInsets: UIEdgeInsets = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
    static let kFavoritesKey = "Favorites"
    
    static let kDefaultsRootPlaylistId = "root_playlist_id"
    static let kDefaultsBackgroundUrl = "background_url"
    
    // Segues
    static let kShowTabBarSegueId = "ShowTabBar"
    
    // Version
    static let kcurrentVersion = "v1.1.1"
}
