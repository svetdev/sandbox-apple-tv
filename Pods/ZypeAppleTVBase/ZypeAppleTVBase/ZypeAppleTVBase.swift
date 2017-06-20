//
//  ZypeAppleTVBase.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/20/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

open class ZypeAppleTVBase: NSObject {

    open static let sharedInstance = ZypeAppleTVBase()
    open static var debug = true
    
    fileprivate var dataManager: ZypeDataManager?
    
    open var consumer: ConsumerModel? {
        return dataManager?.consumer
    }
    
    override init() {
        super.init()
    }
    
    open func initialize(_ settings: SettingsModel = SettingsModel(),
        loadCategories: Bool = false,
        loadPlaylists: Bool = false,
        completion:@escaping (_ error: NSError?) -> Void)
    {
        dataManager = ZypeDataManager(settings: settings)
        dataManager!.initializeLoadCategories(loadCategories, error: nil) { (error) -> Void in
            self.dataManager!.initializeLoadPlaylists(loadPlaylists, error: error, completion:completion)
        }
    }
    
    open func reset()
    {
        self.dataManager = nil
    }
    
    //MARK:login
    open func login(_ username: String, passwd: String, completion:@escaping ((_ logedIn: Bool, _ error: NSError?) -> Void), token: ZypeTokenModel = ZypeTokenModel())
    {
        dataManager?.tokenManager.tokenModel = token
        dataManager == nil ? completion(false, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
        dataManager?.login(username, passwd: passwd, completion: completion)
    }
    
    open func login(_ deviceId: String, pin: String, completion:@escaping ((_ logedIn: Bool, _ error: NSError?) -> Void), token: ZypeTokenModel = ZypeTokenModel())
    {
        dataManager?.tokenManager.tokenModel = token
        dataManager == nil ? completion(false, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
        dataManager?.login(deviceId, pin: pin, completion: completion)
        
    }
    
    open func login(_ completion:@escaping ((_ logedIn: Bool, _ error: NSError?) -> Void), token: ZypeTokenModel = ZypeTokenModel())
    {
        dataManager?.tokenManager.tokenModel = token
        dataManager == nil ? completion(false, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
        dataManager?.loadConsumer(completion)
    }
    
    open func createConsumer(_ consumer: ConsumerModel, completion:@escaping (_ success: Bool, _ error: NSError?) -> Void)
    {
        dataManager == nil ? completion(false, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
            dataManager?.createConsumer(consumer, completion: completion)
    }
    
    open func logOut()
    {
        dataManager?.logOut()
    }
    
    // MARK:Category
    open func getCategories(_ queryModel: QueryCategoriesModel = QueryCategoriesModel(), completion:@escaping (_ catgories: Array<CategoryModel>?, _ error: NSError?) -> Void)
    {
        dataManager == nil ? completion(nil, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
        dataManager?.getCategories(queryModel, completion: completion)
    }
    
    open func getStoredCategories() -> Array<CategoryModel>?
    {
        return dataManager == nil ? nil :
            Array(dataManager!.cacheManager.loadedCategories.values)
    }
    
    // MARK:Video
    open func getVideos(_ queryModel: QueryVideosModel, completion:@escaping (_ videos: Array<VideoModel>?, _ error: NSError?) -> Void)
    {
        dataManager == nil ? completion(nil, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
        dataManager?.getVideos(queryModel, completion: completion)
    }
    
    open func getVideos(_ completion:@escaping ((_ videos: Array<VideoModel>?, _ error: NSError?) -> Void),
        categoryValue: CategoryValueModel? = nil,
        searchString: String = "",
        keyword: String = "",
        active: Bool = true,
        page: Int = kApiFirstPage,
        perPage: Int = 0)
    {
        let queryModel = QueryVideosModel(categoryValue: categoryValue)
        queryModel.searchString = searchString
        queryModel.keyword = keyword
        queryModel.active = active
        queryModel.page = page
        queryModel.perPage = perPage
        self.getVideos(queryModel, completion: completion)
    }
    
    open func getStoredVideos() -> Array<VideoModel>?
    {
        return dataManager == nil ? nil :
            Array(dataManager!.cacheManager.loadedVideos.values)
    }
    
    internal func getVideoObject(_ video: VideoModel,  type: VideoUrlType, completion:@escaping (_ playerObject: VideoObjectModel?, _ error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(nil, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
//        }  else if self.consumer!.isLoggedIn == false {
//            completion(url: "", error: NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.getVideoObject(video, type: type, completion: completion)
        }
    }
    
     // MARK: Favorite
    open func getFavorites(_ completion:(_ favorites: Array<FavoriteModel>?, _ error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(nil, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
        }  else if self.consumer!.isLoggedIn == false {
            completion(nil, NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.getFavorites(completion)
        }
    }
    
    open func getVideoByFavoriteModel(_ favorite: FavoriteModel, completion:@escaping ((_ video: VideoModel?, _ error: NSError?) -> Void),
        active: Bool = true)
    {
        let queryModel = QueryVideosModel()
        queryModel.perPage = 1
        queryModel.videoID = favorite.objectID
        self.getVideos(queryModel, completion:{(videos, error) in
                completion(videos?.first, error)
        })
    }
    
    open func setFavorite(_ object: BaseModel, shouldSet: Bool, completion:@escaping (_ success: Bool, _ error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(false, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
        }  else if self.consumer!.isLoggedIn == false {
            completion(false, NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.setFavorite(object, shouldSet: shouldSet, completion: completion)
        }
    }
    
    open func getFavoriteModel(_ object: BaseModel) -> FavoriteModel?
    {
        return dataManager?.cacheManager.findFavoteForObject(object)
    }
    
    // MARK: MyLibrary
    open func getMyLibrary(_ completion:@escaping (_ favorites: Array<FavoriteModel>?, _ error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(nil, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
        }  else if self.consumer!.isLoggedIn == false {
            completion(nil, NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.getMyLibrary(completion)
        }
    }
    
    
    // MARK: Zobjects
    open func getZobjectTypes(_ queryModel: QueryZobjectTypesModel = QueryZobjectTypesModel(), completion:@escaping (_ objectTypes: Array<ZobjectTypeModel>?, _ error: NSError?) -> Void)
    {
        dataManager == nil ? completion(nil, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
        dataManager?.getZobjectTypes(queryModel, completion: completion)
    }
    
    open func getStoredZobjectTypes() -> Array<ZobjectTypeModel>?
    {
        return dataManager == nil ? nil :
            Array(dataManager!.cacheManager.loadedZobjectTypes.values)
    }

    open func getZobjects(_ queryModel: QueryZobjectsModel = QueryZobjectsModel(), completion:@escaping (_ objects: Array<ZobjectModel>?, _ error: NSError?) -> Void)
    {
        dataManager == nil ? completion(nil, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
        dataManager?.getZobjects(queryModel, completion: completion)
    }
    
    open func getStoredZobjects() -> Array<ZobjectModel>?
    {
        return dataManager == nil ? nil :
            Array(dataManager!.cacheManager.loadedZobjects.values)
    }
    
    //MARK: Subscriptions
    open func getSubscriptions(_ queryModel: QuerySubscriptionsModel = QuerySubscriptionsModel(), completion:@escaping (_ subscriptions: Array<SubscriptionModel>?, _ error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(nil, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
        }  else if self.consumer!.isLoggedIn == false {
            completion(nil, NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.getSubscriptions(queryModel, completion: completion)
        }
    }
    
    open func createSubscription(_ planID: String, completion:@escaping (_ subscription: SubscriptionModel?, _ error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(nil, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
        }  else if self.consumer!.isLoggedIn == false {
            completion(nil, NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.createSubscription(planID, completion: completion)
        }
    }
    
    open func retrieveSubscription(_ subscription: SubscriptionModel, completion:@escaping (_ subscription: SubscriptionModel?, _ error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(nil, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
        }  else if self.consumer!.isLoggedIn == false {
            completion(nil, NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.retrieveSubscription(subscription, completion: completion)
        }
    }
    
    open func updateSubscription(_ planID: String, completion:@escaping (_ subscription: SubscriptionModel?, _ error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(nil, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
        }  else if self.consumer!.isLoggedIn == false {
            completion(nil, NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.updateSubscription(planID, completion: completion)
        }
    }
    
    open func removeSubscription(_ subscription: SubscriptionModel, completion:@escaping (_ success: Bool, _ error: NSError?) -> Void)
    {
        dataManager == nil ? completion(false, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
            dataManager?.removeSubscription(subscription, completion: completion)
    }
    
    //MARK: play list
    open func getPlaylist(with id: String, completion: @escaping (_ playlist: [PlaylistModel]?, _ error: NSError?) -> Void) {
        dataManager == nil ? completion(nil, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
            dataManager?.getPlaylist(with: id, completion: completion)
    }
    
    open func getPlaylists(_ queryModel: QueryPlaylistsModel = QueryPlaylistsModel(), completion:@escaping (_ playlists: Array<PlaylistModel>?, _ error: NSError?) -> Void)
    {
        dataManager == nil ? completion(nil, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
            dataManager?.getPlaylists(queryModel, completion: completion)
    }
    
    open func retrieveVideosInPlaylist(_ queryModel: QueryRetrieveVideosInPlaylistModel, completion:@escaping (_ videos: Array<VideoModel>?, _ error: NSError?) -> Void)
    {
        dataManager == nil ? completion(nil, NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
            dataManager?.retrieveVideosInPlaylist(queryModel, completion: completion)
    }
    
    open func getStoredPlaylists() -> Array<PlaylistModel>?
    {
        return dataManager == nil ? nil :
            Array(dataManager!.cacheManager.loadedPlaylists.values)
    }
    
    open func getStoredPlaylist(_ playlistID: String) -> PlaylistModel?
    {
        return dataManager == nil ? nil :
            dataManager!.cacheManager.loadedPlaylists[playlistID]
    }
    
    //MARK: get app info
    open func getAppInfo(_ queryModel: QueryBaseModel,  completion:@escaping (_ backgroundUrl: String?,_ featuredPlaylistId: String?, _ error: NSError?) -> Void) {
        dataManager?.loadAppInfo(queryModel, completion: completion)
    }
    
    //MARK:Device Linking
    open func createDevicePin(_ device: String,  completion:@escaping (_ devicepPin: String?, _ error: NSError?) -> Void) {
        dataManager?.getDevicePin(device, completion: completion)
    }
    
    open func getLinkedStatus(_ device: String,  completion:@escaping (_ linked: Bool?, _ pin: String?, _ error: NSError?) -> Void) {
        dataManager?.getLinkedStatus(device, completion: completion)
    }
    
    //MARK: Token
    open func getToken(_ completion:@escaping (_ token: String?, _ error: NSError?) -> Void) {
        let tokenManager = dataManager?.tokenManager
        if (!tokenManager!.isAccessTokenExpired()){
            completion(tokenManager?.tokenModel.accessToken, nil)
        } else {
            print("Check if this is returns a new token..")
             dataManager?.getToken(completion)
        }
    }
}
