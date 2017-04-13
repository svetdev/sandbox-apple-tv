//
//  ZypeDataManager.swift
//  UIKitCatalog
//
//  Created by Ilya Sorokin on 10/8/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit

class ZypeDataManager : NSObject {

    //private
    fileprivate let serviceController: ZypeRESTController

    //public
    internal let cacheManager = ZypeCacheManager()
    fileprivate(set) internal var tokenManager = ZypeTokenManager()
    fileprivate(set) internal var consumer = ConsumerModel()

    //MARK: initialize
    init(settings: SettingsModel)
    {
        serviceController = ZypeRESTController(settings: settings)
        super.init()
    }

    func initializeLoadCategories(_ load: Bool, error: NSError?, completion: @escaping (_ error: NSError?) ->Void)
    {
        if load == false || error != nil
        {
            completion(error)
        }
        else
        {
            self.getCategories(QueryCategoriesModel(), completion: { (_, error) -> Void in
                completion(error)
            })
        }
    }

    func initializeLoadPlaylists(_ load: Bool, error: NSError?, completion: @escaping (_ error: NSError?) ->Void)
    {
        if load == false || error != nil
        {
            completion(error)
        }
        else
        {
            self.getPlaylists(QueryPlaylistsModel(), completion: { (_, error) -> Void in
                completion(error)
            })
        }
    }

    //MARK: Login
    func logOut()
    {
        tokenManager.tokenModel.reset()
        consumer.reset()
        cacheManager.resetConsumer()
    }

    func login(_ username: String, passwd: String, completion:@escaping (_ logedIn: Bool, _ error: NSError?) -> Void)
    {
        serviceController.getTokenWithUsername(username, withPassword: passwd, withCompletion: {(data, error) -> Void in
            if (error != nil)
            {
                self.loginCompletion(false, error: error, completion: completion)
            }
            else if (data == nil)
            {
                self.loginCompletion(false, error: NSError(domain: kErrorDomaine, code: kErrorServiceError, userInfo: nil), completion: completion)
            }
            else
            {
                let error = self.tokenManager.setLoginAccessTokenData(data!)
                if (error != nil)
                {
                    self.loginCompletion(false, error: error, completion: completion)
                }
                else
                {
                    self.loadConsumer(completion)
                }
            }
       })
    }
    
    func login(_ deviceId: String, pin: String, completion:@escaping (_ logedIn: Bool, _ error: NSError?) -> Void)
    {
        serviceController.getTokenWithDeviceId(deviceId, withPin: pin, withCompletion:{(data, error) -> Void in
            if (error != nil)
            {
                self.loginCompletion(false, error: error, completion: completion)
            }
            else if (data == nil)
            {
                self.loginCompletion(false, error: NSError(domain: kErrorDomaine, code: kErrorServiceError, userInfo: nil), completion: completion)
            }
            else
            {
                let error = self.tokenManager.setLoginAccessTokenData(data!)
                if (error != nil)
                {
                    self.loginCompletion(false, error: error, completion: completion)
                }
                else
                {
                    self.loadConsumer(completion)
                }
            }
        })
    }

    func loadConsumer(_ completion:@escaping (_ success: Bool, _ error: NSError?) -> Void)
    {
        if (tokenManager.tokenModel.refreshToken.isEmpty)
        {
            self.loginCompletion(false, error: nil, completion:completion)
            return
        }
        tokenManager.accessToken({ (token) -> Void in
            self.serviceController.getConsumerIdWithToken(token, completion: { (jsonDic, error) -> Void in
                do
                {
                    let idString = try SSUtils.stringFromDictionary(jsonDic, key: kJSONResourceOwnerId)
                    if (idString.isEmpty == false)
                    {
                        self.serviceController.getConsumerInformationWithID(token, consumerId: idString, withCompletion: { (jsonDic, error) -> Void in
                            do
                            {
                                if (jsonDic != nil)
                                {
                                    let response = jsonDic![kJSONResponse] as! Dictionary <String, AnyObject>?
                                    if (response != nil)
                                    {
                                        let emailString = try SSUtils.stringFromDictionary(response, key: kJSONEmail)
                                        let nameString = try SSUtils.stringFromDictionary(response, key: kJSONName)
                                        DispatchQueue.main.sync(execute: {
                                            self.consumer.setData(idString, email: emailString, name: nameString)
                                        })
                                        self.loginCompletion(self.consumer.isLoggedIn, error: error, completion: completion)
                                        return
                                    }
                                }
                            }
                            catch _
                            {
                            }
                            self.loginCompletion(false, error: error, completion: completion)
                        })
                        return
                    }
                }
                catch _
                {
                }
                self.loginCompletion(false, error: error, completion: completion)
            })
        }, update: serviceController.refreshAccessTokenWithCompletionHandler)
    }

    func createConsumer(_ consumer: ConsumerModel, completion:@escaping (_ success: Bool, _ error: NSError?) -> Void)
    {
        self.serviceController.createConsumer(consumer) { (jsonDic, err) -> Void in
            var success = false
            var error = err
            if error == nil && jsonDic != nil
            {
                error = self.isServiceError(jsonDic!)
                if (error == nil)
                {
                    success = true
                }
            }
            DispatchQueue.main.sync(execute: {
                completion(_: success, err)
            })
        }
    }

    //MARK: Categories
    func getCategories(_ queryModel: QueryCategoriesModel,  toArray: Array<CategoryModel> = Array<CategoryModel>(),
        completion:@escaping (_ categories: Array<CategoryModel>, _ error: NSError?) -> Void)
    {
        var toArr = toArray
        serviceController.getCategories(queryModel, completion: { (jsonDic, error) -> Void in
            var err = error
            if (jsonDic != nil && error == nil)
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    let response = jsonDic![kJSONResponse]
                    let data = response as? Array <AnyObject>
                    if (data != nil)
                    {
                        for value in data!
                        {
                            let category  = CategoryModel(fromJson: value as! Dictionary<String, AnyObject>)
                            toArr.append(category)
                        }
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page = queryModel.page + 1
                        self.getCategories(queryModel, toArray: toArr, completion: completion)
                        return
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                completion(self.cacheManager.synchronizeCategories(toArr)!, err)
            })
        })
    }

    //MARK: Videos
    func getVideos(_ queryModel: QueryVideosModel, returnArray: Array<VideoModel> = Array<VideoModel>(),
        completion:@escaping ((_ videos: Array<VideoModel>?, _ error: NSError?) -> Void))
    {
        var returnArr = returnArray
        serviceController.getVideos(queryModel, completion:{ (jsonDic, error) -> Void in
           var err = error
            if jsonDic != nil
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    let videos = self.jsonToVideosArrayPrivate(jsonDic)
                    if (videos != nil)
                    {
                        returnArr.append(contentsOf: videos!)
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page = queryModel.page + 1
                        self.getVideos(queryModel, returnArray: returnArr, completion: completion)
                        return
                    }
                }
            }
            self.videoCompletion(returnArr, error: err, completion:completion)
        })
    }

    //TODO need  add subscriptions and test
    func getVideoObject(_ video: VideoModel, type: VideoUrlType, completion:@escaping (_ playerObject: VideoObjectModel?, _ error: NSError?) -> Void)
    {
        ZypeFactory.videoUrl(type, restController: serviceController)?.getVideoObject(video, completion: {(player, error) in
            DispatchQueue.main.async(execute: {
                completion(player, error)
            })
        })
    }

   //MARK: favorites
    func getFavorites(_ completion:(_ favorites: Array<FavoriteModel>?, _ error: NSError?) -> Void)
    {
        completion(cacheManager.favorites, nil)
    }

    func setFavorite(_ object: BaseModel, shouldSet: Bool, completion:@escaping (_ success: Bool, _ error: NSError?) -> Void)
    {
        let favoriteObject: FavoriteModel? = shouldSet == true ? nil : cacheManager.findFavoteForObject(object)
        if (shouldSet == false && favoriteObject == nil)
        {
            completion(false, NSError(domain: kErrorDomaine, code: kErrorItemNotInFavorites, userInfo: nil))
            return
        }
        tokenManager.accessToken({ (token) -> Void in
            if (shouldSet == true)
            {
                self.favoriteVideo(token, object: object, completion: completion)
            }
            else
            {
                self.unfavoriteVideo(token, favoriteObject: favoriteObject!, completion: completion)
            }
         }, update: serviceController.refreshAccessTokenWithCompletionHandler)
    }

    //MARK: MyLibrary
    func getMyLibrary(_ completion:@escaping (_ favorites: Array<FavoriteModel>?, _ error: NSError?) -> Void)
    {
     //taken shortcut - will only retrieve first 500 items
        tokenManager.accessToken({ (token) -> Void in
            self.serviceController.getMyLibrary(token, consumerId: self.consumer.ID, completion:{ (jsonDic, error) -> Void in
                var err = error
                if jsonDic != nil
                {
                    err = self.isServiceError(jsonDic!)
                    if (err == nil)
                    {
                        let favorites = self.jsonToFavoriteArrayPrivate(jsonDic)
                        DispatchQueue.main.async(execute: {
                            if (favorites != nil) {
                                completion(favorites!, nil)
                            } else {
                                completion(nil, nil)
                            }
                        })
                    }
                }
            })
        
            }, update: serviceController.refreshAccessTokenWithCompletionHandler)
        
        
    }
    
    
    //MARK: zobjects
    func getZobjectTypes(_ queryModel: QueryZobjectTypesModel, toArray: Array<ZobjectTypeModel> = Array<ZobjectTypeModel>(),
        completion:@escaping (_ objectTypes: Array<ZobjectTypeModel>, _ error: NSError?) -> Void)
    {
        var toArr = toArray
        self.serviceController.getZobjectTypes(queryModel) { (jsonDic, error) -> Void in
           var err = error
            if (jsonDic != nil)
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    let response = jsonDic![kJSONResponse]
                    for value in response as! Array<AnyObject>
                    {
                        toArr.append(ZobjectTypeModel(fromJson: value as! Dictionary<String, AnyObject>))
                    }
                }
            }
            if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
            {
                queryModel.page = queryModel.page + 1
                self.getZobjectTypes(queryModel, toArray: toArr, completion: completion)
                return
            }
            DispatchQueue.main.async(execute: {
                completion(self.cacheManager.synchronizeZobjectTypes(toArr)!, err)
            })
        }
    }

    func getZobjects(_ queryModel: QueryZobjectsModel, toArray: Array<ZobjectModel> = Array<ZobjectModel>(),
        completion:@escaping (_ objects: Array<ZobjectModel>, _ error: NSError?) -> Void)
    {
        var toArr = toArray
        self.serviceController.getZobjects(queryModel, completion: {(jsonDic, error) -> Void in
           var err = error
            if (jsonDic != nil)
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    let response = jsonDic![kJSONResponse]
                    for value in response as! Array<AnyObject>
                    {
                        toArr.append(ZobjectModel(fromJson: value as! Dictionary<String, AnyObject>))
                    }
                }
            }
            if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
            {
                queryModel.page = queryModel.page + 1
                self.getZobjects(queryModel, toArray: toArr, completion: completion)
                return
            }
            DispatchQueue.main.async(execute: {
                completion(self.cacheManager.synchronizeZobjects(toArr)!, err)
            })
        })
    }

    //MARK: Subscriptions
    //TODO need convert subscription from json to model
    func getSubscriptions(_ queryModel: QuerySubscriptionsModel, toArray: Array<SubscriptionModel> = Array<SubscriptionModel>(),
        completion:@escaping (_ subscriptions: Array<SubscriptionModel>, _ error: NSError?) -> Void)
    {
        var toArr = toArray
        self.serviceController.getSubscriptions(queryModel, completion: { (jsonDic, error) -> Void in
           var err = error
            if (jsonDic != nil)
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    let response = jsonDic![kJSONResponse]
                    for value in response as! Array<AnyObject>
                    {
                        toArr.append(SubscriptionModel(fromJson: value as! Dictionary<String, AnyObject>))
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page = queryModel.page + 1
                        self.getSubscriptions(queryModel, toArray: toArr, completion: completion)
                        return
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                completion(toArr, err)
            })
        })
    }

    //TODO need api not work
    func createSubscription(_ planID: String, completion:@escaping (_ subscription: SubscriptionModel?, _ error: NSError?) -> Void)
    {
        self.serviceController.createSubscription(self.consumer.ID, planID: planID, completion:{ (jsonDic, error) -> Void in
            var err = error
            var subscription: SubscriptionModel?
            if (jsonDic != nil)
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    subscription = SubscriptionModel(fromJson: jsonDic![kJSONResponse] as! Dictionary<String, AnyObject>)
                }
            }
            DispatchQueue.main.async(execute: {
                completion(subscription, err)
            })
        })
    }

    func retrieveSubscription(_ subscription: SubscriptionModel, completion:@escaping (_ subscription: SubscriptionModel?, _ error: NSError?) -> Void)
    {
        self.serviceController.retrieveSubscription(subscription.ID, completion:{ (jsonDic, error) -> Void in
            var err = error
            var subscription: SubscriptionModel?
            if (jsonDic != nil)
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    subscription = SubscriptionModel(fromJson: jsonDic![kJSONResponse] as! Dictionary<String, AnyObject>)
                }
            }
            DispatchQueue.main.async(execute: {
                completion(subscription, err)
            })
        })
    }

    func updateSubscription(_ planID: String, completion:@escaping (_ subscription: SubscriptionModel?, _ error: NSError?) -> Void)
    {
        self.serviceController.updateSubscription(self.consumer.ID, planID: planID, completion: {(jsonDic, error) -> Void in
            var err = error
            var subscription: SubscriptionModel?
            if (jsonDic != nil)
            {
                err = self.isServiceError(jsonDic!)
                if (err == nil)
                {
                    subscription = SubscriptionModel(fromJson: jsonDic![kJSONResponse] as! Dictionary<String, AnyObject>)
                }
            }
            DispatchQueue.main.async(execute: {
                completion(subscription, err)
            })
        })
    }

    func removeSubscription(_ subscription: SubscriptionModel, completion:@escaping (_ success: Bool, _ error: NSError?) -> Void)
    {
        self.serviceController.removeSubscription(subscription.ID, completion: { (jsonDic, error) -> Void in
            DispatchQueue.main.async(execute: {
                completion(false, error)
            })
        })
    }

    //MARK: play list
    func getPlaylists(_ queryModel: QueryPlaylistsModel, toArray: Array<PlaylistModel> = Array<PlaylistModel>(),
        completion:@escaping (_ playlists: Array<PlaylistModel>, _ error: NSError?) -> Void)
    {
        var toArr = toArray
        self.serviceController.getPlaylists(queryModel, completion: { (jsonDic, error) -> Void in
            var err = error
            if jsonDic != nil
            {
                err = self.isServiceError(jsonDic!)
                if err == nil
                {
                    for value in jsonDic![kJSONResponse] as! Array<AnyObject>
                    {
                        toArr.append(PlaylistModel(fromJson: value as! Dictionary<String, AnyObject>))
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page = queryModel.page + 1
                        self.getPlaylists(queryModel, toArray: toArr, completion: completion)
                        return
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                completion(self.cacheManager.synchronizePlaylists(toArr), err)
            })
        })
    }

    func retrieveVideosInPlaylist(_ queryModel: QueryRetrieveVideosInPlaylistModel, toArray: Array<VideoModel> = Array<VideoModel>(),
        completion:@escaping (_ videos: Array<VideoModel>?, _ error: NSError?) -> Void)
    {
        var toArr = toArray
        self.serviceController.retrieveVideosInPlaylist(queryModel, completion: { (jsonDic, error) -> Void in
            var err = error
            if jsonDic != nil
            {
                err = self.isServiceError(jsonDic!)
                if err == nil
                {
                    let videos = self.jsonToVideosArrayPrivate(jsonDic)
                    if (videos != nil)
                    {
                        toArr.append(contentsOf: videos!)
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page = queryModel.page + 1
                        self.retrieveVideosInPlaylist(queryModel, toArray: toArr, completion: completion)
                        return
                    }
                }
            }
            self.videoCompletion(toArr, error: err, completion:completion)
        })
    }
    
    //MARK: App Info
    func loadAppInfo(_ queryModel: QueryBaseModel, completion:@escaping (_ backgroundUrl: String?, _ featuredPlaylistId: String?, _ error: NSError?) -> Void)
    {
        self.serviceController.getAppInfo(queryModel, completion: { (jsonDic, error) -> Void in
            if jsonDic != nil {
                let response = jsonDic![kJSONResponse] as! NSDictionary
                let backgroundImageUrl = response .value(forKey: "background_url") as? String
                let featuredPlaylistId = response.value(forKey: "featured_playlist_id") as? String
                completion(backgroundImageUrl, featuredPlaylistId, nil)
                
            }
        })
    }
    
    //MARK: Device Linking
    func getDevicePin(_ device: String, completion:@escaping (_ devicepPin: String?, _ error: NSError?) -> Void)
    {
        self.serviceController.getDevicePin(device, completion: { (jsonDic, error) -> Void in
            if jsonDic != nil {
                let response = jsonDic![kJSONResponse] as! NSDictionary
                let devicepPin = response .value(forKey: "pin") as? String
                
                completion(devicepPin, nil)
                
            }
        })
    }

    func getLinkedStatus(_ device: String, completion:@escaping (_ linked: Bool?,_ pin: String?, _ error: NSError?) -> Void)
    {
        self.serviceController.getLinkedStatus(device, completion: { (jsonDic, error) -> Void in
            if jsonDic != nil {
                let message = jsonDic!["message"] as? String
                if (message == "Invalid Device Pin.") {
                    completion(false, nil, nil)
                } else {
                let response = jsonDic![kJSONResponse] as? NSDictionary
                let linkedStatus = response!.value(forKey: "linked") as? Bool
                let pin = response!.value(forKey: "pin") as? String
                    completion(linkedStatus, pin, nil)
                }
                
            }
        })
    }
    
    //MARK: Token
    func getToken(_ completion:@escaping (_ token: String?, _ error: NSError?) -> Void)
    {
        tokenManager.accessToken({ (token) -> Void in
            completion(token, nil)
            }, update: serviceController.refreshAccessTokenWithCompletionHandler)
    }
    
    //MARK: Private
    fileprivate func loadLibrary(_ page: Int = kApiFirstPage)
    {
        
    }
    
    
    fileprivate func loadFavorites(_ page: Int = kApiFirstPage)
    {
        tokenManager.accessToken({ (token) -> Void in
            self.serviceController.getFavorites(token, consumerId: self.consumer.ID, page: page, completion: { (jsonDic, error) -> Void in
                let favorites = self.jsonToFavoriteArrayPrivate(jsonDic)
                if (favorites != nil)
                {
                    DispatchQueue.main.async(execute: {
                        self.cacheManager.addFavoriteVideos(favorites)
                        
                    })
                } else {
                    
                }
                if (self.isLastPage(jsonDic) == false)
                {
                    self.loadFavorites(page + 1)
                }
            })
            }, update: serviceController.refreshAccessTokenWithCompletionHandler)
    }
    
    fileprivate func favoriteVideo(_ token: String, object: BaseModel, completion:@escaping (_ success: Bool, _ error: NSError?) -> Void)
    {
        self.serviceController.favoriteObject(token, consumerId: self.consumer.ID, objectID: object.ID, completion: { (jsonDic, error) -> Void in
            var err = error
            let favorites = self.jsonToFavoriteArrayPrivate(jsonDic)
            let success = favorites != nil && favorites?.isEmpty == false && favorites?.first?.objectID == object.ID
            if (success == false && jsonDic != nil)
            {
                 err = NSError(domain: kErrorDomaine, code: kErrorServiceError, userInfo: jsonDic as? Dictionary<String, String>)
            }
            DispatchQueue.main.async(execute: {
                if (success == true)
                {
                    self.cacheManager.addFavoriteVideos(favorites)
                }
                completion(success, err)
            })
        })
    }

    fileprivate func unfavoriteVideo(_ token: String, favoriteObject: FavoriteModel, completion:@escaping (_ success: Bool, _ error: NSError?) -> Void)
    {
        self.serviceController.unfavoriteObject(token, consumerId: self.consumer.ID, favoriteID: favoriteObject.ID, completion: { (statusCode, error) -> Void in
            DispatchQueue.main.async(execute: {
                if (statusCode == kHTTPCodeNoContent)
                {
                    self.cacheManager.removeFromFavorites(favoriteObject)
                }
                completion(statusCode == kHTTPCodeNoContent, error)
            })
        })
    }

    fileprivate func loginCompletion(_ logedIn: Bool, error: NSError?, completion:@escaping (_ logedIn: Bool, _ error: NSError?) -> Void)
    {
        DispatchQueue.main.async(execute: {
            completion(logedIn, error)
        })
        if (logedIn == true)
        {
            loadFavorites()
        }
    }

    fileprivate func videoCompletion(_ videos: Array<VideoModel>?, error: NSError? ,completion:@escaping (_ videos: Array<VideoModel>?, _ error: NSError?) -> Void)
    {
        DispatchQueue.main.async(execute: {
            completion(self.cacheManager.synchronizeVideos(videos), error)
        })
    }

    fileprivate func jsonToFavoriteArrayPrivate(_ jsonDic: Dictionary<String, AnyObject>?) -> Array<FavoriteModel>?
    {
        if (jsonDic != nil)
        {
            let response = jsonDic![kJSONResponse]
            if (response != nil)
            {
                var array = Array<FavoriteModel>()
                if (response as? Array<AnyObject> == nil)
                {
                     array.append(FavoriteModel(json: response as! Dictionary<String, AnyObject>))
                }
                else
                {
                    for value in response as! Array<AnyObject>
                    {
                        array.append(FavoriteModel(json: value as! Dictionary<String, AnyObject>))
                    }
                }
                return array
            }
        }
        return nil
    }

    fileprivate func jsonToVideosArrayPrivate(_ jsonDic: Dictionary<String, AnyObject>?) -> Array<VideoModel>?
    {
        if (jsonDic != nil)
        {
            let response = jsonDic![kJSONResponse]
            if (response != nil)
            {
                var dataArray = Array<VideoModel>()
                for value in (response as? Array<AnyObject>)!
                {
                    dataArray.append(VideoModel(fromJson: (value as? Dictionary<String, AnyObject>)!))
                }
                return dataArray
            }
        }
        return nil
    }

    fileprivate func isServiceError(_ jsonDic: Dictionary<String, AnyObject>, shouldContainsField: String = kJSONResponse) -> NSError?
    {
        let response = jsonDic[shouldContainsField]
        if (response != nil)
        {
            return nil
        }
        return NSError(domain: kErrorDomaine, code: kErrorServiceError, userInfo: jsonDic as? Dictionary<String, String>)
    }

    fileprivate func isLastPage(_ jsonDic:Dictionary<String, AnyObject>?) -> Bool
    {
        do
        {
            if (jsonDic != nil)
            {
                let pagination = jsonDic![kJSONPagination]
                if ((pagination) != nil)
                {
                    let pages = try SSUtils.intagerFromDictionary(pagination as? Dictionary<String, AnyObject>, key: kJSONPages)
                    let current = try SSUtils.intagerFromDictionary(pagination as? Dictionary<String, AnyObject>, key: kJSONCurrent)
                    if (current < pages)
                    {
                        return false
                    }
                }
            }
        }
        catch _
        {
        }
        return true
    }

}
