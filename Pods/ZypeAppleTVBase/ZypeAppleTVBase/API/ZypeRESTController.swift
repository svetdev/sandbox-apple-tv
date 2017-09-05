//
//  ZypeRESTController.swift
//  UIKitCatalog
//
//  Created by Ilya Sorokin on 10/6/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit

class ZypeRESTController: NSObject, URLSessionDelegate {
    //
    // constants
    //

    //favorites
    fileprivate let kGetFavorites = "%@/consumers/%@/video_favorites/?access_token=%@&page=%d"
    fileprivate let kPostFavorite = "%@/consumers/%@/video_favorites/?access_token=%@&video_id=%@"
    fileprivate let kDeleteFavorite = "%@/consumers/%@/video_favorites/%@/?access_token=%@"
    
    //MyLibary
    fileprivate let kGetMyLibrary = "%@/consumer/videos/?access_token=%@&page=1&per_page=500"

    //Zobjects
    fileprivate let kGetZobjectTypes = "%@/zobject_types?app_key=%@&page=%d&per_page=%d&keywords=%@"
    fileprivate let kGetZobjects = "%@/zobjects/?app_key=%@&zobject_type=%@&page=%d&per_page=%d&keywords=%@%@"

    //Subscriptions
    fileprivate let kGetSubscriptions = "%@/subscriptions/?app_key=%@&page=%d&per_page=%d&q=%@&id=%@&id!=%@"
    fileprivate let kCreateSubscription = "%@/subscriptions/?app_key=%@&subscription[%@]=&@"

    //playlists
    fileprivate let kGetPlaylist = "%@/playlists/%@?app_key=%@"
    fileprivate let kGetPlaylists = "%@/playlists?app_key=%@&page=%d&per_page=%d&active=%@&keyword=%@&category[%@]=%@&sort=priority&order=%@&parent_id=%@"
    fileprivate let kGetRetrieveVideosInPlaylist = "%@/playlists/%@/videos?app_key=%@&page=%d&per_page=%d"

    //OAut
    fileprivate let kOAuth_GetToken = "%@/oauth/token"
    fileprivate let kAPIConsumerInformation = "%@/consumers/%@/?access_token=%@"

    fileprivate let kOAuth_GetTokenByLogin = "username=%@&password=%@&client_id=%@&client_secret=%@&grant_type=password"
     fileprivate let kOAuth_GetTokenByByLoginWithDeviceIdAndPin = "linked_device_id=%@&pin=%@&client_id=%@&client_secret=%@&grant_type=password"
    fileprivate let kOAuth_UpdateTokenByRefreshToken = "refresh_token=%@&client_id=%@&client_secret=%@&grant_type=refresh_token"
//    private let kOAuth_PostUpdateTokenByRefreshToken = "%@/oauth/token/?client_id=%@&client_secret=%@&refresh_token=%@&grant_type=refresh_token"
    fileprivate let kOAuth_GetTokenInfo = "%@/oauth/token/info?access_token=%@"
    fileprivate let kOAuth_CreateConsumer = "%@/consumers?app_key=%@&consumer[email]=%@&consumer[name]=%@&consumer[password]=%@"

    //get content
    fileprivate let kApiGetCategories = "%@/categories?app_key=%@&page=%d&per_page=%d"
    fileprivate let kApiGetListVideos = "%@/videos?app_key=%@&active=%@&on_air=%@&page=%d&per_page=%d" +
        "&category[%@]=%@&category![%@]=%@" +
        "&q=%@&keyword=%@&id=%@&id!=%@&status=%@" +
        "&zobject_id=%@&zobject_id!=%@" +
    "&created_at=%@&published_at=%@&dpt=%@%@"

    //get app info
    fileprivate let kApiGetAppInfo = "%@/app?app_key=%@"
    
    //device linking
    fileprivate let kApiGetDevicePin = "%@/pin/acquire?app_key=%@"
     fileprivate let kGetDevicePinParameters = "linked_device_id=%@"
     fileprivate let kApiGetLinkedStatus = "%@/pin/status?app_key=%@&linked_device_id=%@"
    //
    //variables
    //
    fileprivate var session: Foundation.URLSession?

    let keys: SettingsModel

    init(settings: SettingsModel)
    {
        self.keys = settings
        super.init()
        let sessionConfiguration = URLSessionConfiguration.default
        session = keys.allowAllCertificates ? Foundation.URLSession(configuration: sessionConfiguration, delegate: self,  delegateQueue: nil) :
            Foundation.URLSession(configuration: sessionConfiguration)
    }

    // MARK: OAuth API

    func getTokenWithUsername(_ username: String, withPassword password: String, withCompletion completion: @escaping (Dictionary<String, AnyObject>?,NSError?) -> Void)
    {
        let escapedPassword = SSUtils.escapedString(password)
        let bodyString = String(format: kOAuth_GetTokenByLogin, username, escapedPassword, keys.clientId, keys.clientSecret)
        let URLString = String(format: kOAuth_GetToken, self.keys.tokenDomain)
        postQuery(URLString, bodyAsString: bodyString, withCompletion: completion)
    }
    
    func getTokenWithDeviceId(_ deviceId: String, withPin pin: String, withCompletion completion: @escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let bodyString = String(format: kOAuth_GetTokenByByLoginWithDeviceIdAndPin, deviceId, pin, keys.clientId, keys.clientSecret)
        let URLString = String(format: kOAuth_GetToken, self.keys.tokenDomain)
        postQuery(URLString, bodyAsString: bodyString, withCompletion: completion)
    }

    func getConsumerIdWithToken(_ accessToken:String, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
       if (accessToken.isEmpty)
       {
            completion(nil, nil)
            return
        }
        let urlAsString = String(format: kOAuth_GetTokenInfo, self.keys.tokenDomain, accessToken)
        self.getQuery(urlAsString, withCompletion: completion)

    }

    func getConsumerInformationWithID(_ token: String, consumerId: String, withCompletion completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let urlAsString = String(format: kAPIConsumerInformation, self.keys.apiDomain, consumerId, token)
        self.getQuery(urlAsString, withCompletion: completion)
    }

    func refreshAccessTokenWithCompletionHandler(_ refreshToken:String, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        // Prepare parameters
        if (refreshToken.isEmpty) {
            ZypeLog.write("Invalid refreshToken")
            return;
        }
        let bodyString = String(format: kOAuth_UpdateTokenByRefreshToken , refreshToken, keys.clientId, keys.clientSecret)
        let URLString = String(format: kOAuth_GetToken, self.keys.tokenDomain)
//        let URLString = String(format: kOAuth_PostUpdateTokenByRefreshToken, self.keys.apiDomain, keys.clientId, keys.clientSecret, refreshToken)
        postQuery(URLString, bodyAsString: bodyString, withCompletion: completion)
    }

    func createConsumer(_ consumer: ConsumerModel, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let urlAsString = String(format: kOAuth_CreateConsumer, self.keys.apiDomain, keys.appKey,
            SSUtils.escapedString(consumer.emailString), SSUtils.escapedString(consumer.nameString), SSUtils.escapedString(consumer.passwordString))
        self.postQuery(urlAsString, bodyAsString: "", withCompletion: completion)
    }

    //MARK: Video API

    func getCategories(_ query: QueryCategoriesModel, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let perPage = query.perPage == 0 ? kApiMaxItems : query.perPage
        let urlAsString = String(format: kApiGetCategories, self.keys.apiDomain, keys.appKey, query.page, perPage);
        getQuery(urlAsString, withCompletion: completion)
    }

    func getVideos(_ query: QueryVideosModel, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let categoryKey:String = SSUtils.escapedString(query.categoryKey)
        let categoryValue:String = SSUtils.escapedString(query.categoryValue)
        let exceptCategoryKey:String = SSUtils.escapedString(query.exceptCategoryKey)
        let exceptCategoryValue:String = SSUtils.escapedString(query.exceptCategoryValue)
        let search:String = SSUtils.escapedString(query.searchString)
        let keyword:String = SSUtils.escapedString(query.keyword)
        let perPage:Int = query.perPage == 0 ? kApiMaxItems : query.perPage
        let status:String = SSUtils.escapedString(query.status)
        let createdDate:String = SSUtils.dateToString(query.createdDate)
        let publishedDate:String = SSUtils.dateToString(query.publishedDate)
        let anyQueryString:String = query.anyQueryString
        var urlAsString:String = String(format: kApiGetListVideos, self.keys.apiDomain, keys.appKey, String(query.active), String(query.onAir), query.page, perPage,
            categoryKey, categoryValue, exceptCategoryKey, exceptCategoryValue,
            search, keyword, query.videoID, query.exceptVideoID, status, query.zObjectID, query.exceptZObjectID,
            createdDate, publishedDate, String(query.dpt),anyQueryString);
        if let _ = query.sort {
          urlAsString = String(format: "%@&sort=%@&order=%@", urlAsString, query.sort!, query.ascending ? "asc" : "desc")
        }
        getQuery(urlAsString, withCompletion: completion)
    }

    //MARK:  Favorite API
    func getFavorites(_ accessToken: String,consumerId: String, page: Int, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let urlAsString = String(format: kGetFavorites, self.keys.apiDomain, consumerId, accessToken, page)
        getQuery(urlAsString, withCompletion: completion)
    }

    func favoriteObject(_ accessToken: String,consumerId: String, objectID: String, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let urlAsString = String(format: kPostFavorite, self.keys.apiDomain, consumerId, accessToken, objectID)
        postQuery(urlAsString, bodyAsString: "", withCompletion: completion)
    }

    func unfavoriteObject(_ accessToken: String,consumerId: String, favoriteID: String, completion:@escaping (Int, NSError?) -> Void)
    {
        let urlAsString = String(format: kDeleteFavorite, self.keys.apiDomain, consumerId, favoriteID, accessToken)
        deleteQuery(urlAsString, withCompletion: {(statusCode: Int, jsonDic: Dictionary<String, AnyObject>?, error: NSError?) in
            completion(statusCode, error)

        })
    }
    
    //MARK:  Library API
    func getMyLibrary(_ accessToken: String,consumerId: String, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        print(accessToken)
        let urlAsString = String(format: kGetMyLibrary, self.keys.apiDomain, accessToken)
        getQuery(urlAsString, withCompletion: completion)
    }

    //MARK:  Zobjects
    func getZobjectTypes(_ queryModel: QueryZobjectTypesModel, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let perPage = queryModel.perPage == 0 ? kApiMaxItems : queryModel.perPage
        let keywords = SSUtils.escapedString(queryModel.keywords)
        let urlAsString = String(format: kGetZobjectTypes, self.keys.apiDomain, keys.appKey, queryModel.page, perPage, keywords)
        getQuery(urlAsString, withCompletion: completion)
    }

    func getZobjects(_ queryModel: QueryZobjectsModel, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let perPage = queryModel.perPage == 0 ? kApiMaxItems : queryModel.perPage
        let type = SSUtils.escapedString(queryModel.zobjectType)
        let keywords = SSUtils.escapedString(queryModel.keywords)
        let urlAsString = String(format: kGetZobjects, self.keys.apiDomain, keys.appKey, type, queryModel.page, perPage, keywords, queryModel.anyQueryString)
        getQuery(urlAsString, withCompletion: completion)
    }

    //MARK: Subscription
    func getSubscriptions(_ queryModel: QuerySubscriptionsModel, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let perPage = queryModel.perPage == 0 ? kApiMaxItems : queryModel.perPage
        let search = SSUtils.escapedString(queryModel.searchString)
        let urlAsString = String(format: kGetSubscriptions, self.keys.apiDomain, keys.appKey, queryModel.page, perPage, search, queryModel.ID, queryModel.exceptID)
        getQuery(urlAsString, withCompletion: completion)
    }

    func createSubscription(_ consumerID: String, planID: String, completion:(Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        completion(nil, NSError(domain: kErrorDomaine, code: kErrorNotImplemented, userInfo: nil))
//        let urlAsString = String(format: kCreateSubscription, self.keys.apiDomain, keys.appKey, consumerID, SSUtils.escapedString(consumerID))
//        postQuery(urlAsString, bodyAsString: "", withCompletion: completion)
    }

    func retrieveSubscription(_ ID: String, completion:(Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        completion(nil, NSError(domain: kErrorDomaine, code: kErrorNotImplemented, userInfo: nil))
    }

    func updateSubscription(_ consumerID: String, planID: String, completion:(Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        completion(nil, NSError(domain: kErrorDomaine, code: kErrorNotImplemented, userInfo: nil))
    }

    func removeSubscription(_ ID: String, completion:(Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        completion(nil, NSError(domain: kErrorDomaine, code: kErrorNotImplemented, userInfo: nil))
    }

    //MARK: Playlist
    func getPlaylist(with id: String, completion: @escaping ([String : AnyObject]?, NSError?) -> Void) {
        let urlAsString = String(format: kGetPlaylist, self.keys.apiDomain, id, keys.appKey)
        print("\n\n\n -- URL: \(urlAsString) -- \n\n\n")
        getQuery(urlAsString, withCompletion: completion)
    }
    
    func getPlaylists(_ queryModel: QueryPlaylistsModel, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let perPage = queryModel.perPage == 0 ? kApiMaxItems : queryModel.perPage
        let urlAsString = String(format: kGetPlaylists, self.keys.apiDomain, keys.appKey, queryModel.page, perPage,
            String(queryModel.active),  SSUtils.escapedString(queryModel.keyword),
            SSUtils.escapedString(queryModel.categoryKey), SSUtils.escapedString(queryModel.categoryValue),queryModel.ordering, queryModel.parentId)
        getQuery(urlAsString, withCompletion: completion)
    }

    func retrieveVideosInPlaylist(_ queryModel: QueryRetrieveVideosInPlaylistModel, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let perPage = queryModel.perPage == 0 ? kApiMaxItems : queryModel.perPage
        let urlAsString = String(format: kGetRetrieveVideosInPlaylist, self.keys.apiDomain, queryModel.playlistID, keys.appKey, queryModel.page, perPage)
        getQuery(urlAsString, withCompletion: completion)
    }
    
    //MARK: App Info
    func getAppInfo(_ queryModel: QueryBaseModel, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let urlAsString = String(format: kApiGetAppInfo, self.keys.apiDomain, keys.appKey);
        getQuery(urlAsString, withCompletion: completion)
    }
    
    //MARK: Device Linking
    func getDevicePin(_ device: String, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let bodyString = String(format: kGetDevicePinParameters, device)
        let urlAsString = String(format: kApiGetDevicePin, self.keys.apiDomain, keys.appKey);
        postQuery(urlAsString, bodyAsString: bodyString, withCompletion: completion)
    }
    
    func getLinkedStatus(_ device: String, completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)
    {
        let urlAsString = String(format: kApiGetLinkedStatus, self.keys.apiDomain, keys.appKey, device);
        getQuery(urlAsString, withCompletion: completion)
    }

    
    //private
    @discardableResult fileprivate func deleteQuery(_ urlAsString: String,
        withCompletion completion:@escaping (Int, Dictionary<String, AnyObject>?, NSError?) -> Void)  -> URLSessionDataTask
    {
        return query("DELETE", urlAsString: urlAsString, bodyAsString: "", withCompletion: completion)
    }

    @discardableResult func getQuery(_ urlAsString: String,
        withCompletion completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)  -> URLSessionDataTask
    {
        return query("GET", urlAsString: urlAsString, bodyAsString: "",
            withCompletion: {(statusCode, jsonDic, error) in
            completion(jsonDic, error)
        })
    }

    @discardableResult fileprivate func postQuery(_ urlAsString: String, bodyAsString: String,
        withCompletion completion:@escaping (Dictionary<String, AnyObject>?, NSError?) -> Void)  -> URLSessionDataTask
    {
        return query("POST", urlAsString: urlAsString, bodyAsString: bodyAsString,
            withCompletion: {(statusCode, jsonDic, error) in
            completion(jsonDic, error)
        })
    }

    fileprivate func query(_ method: String, urlAsString: String, bodyAsString: String,
        withCompletion completion:@escaping (Int, Dictionary<String, AnyObject>?, NSError?) -> Void) -> URLSessionDataTask
    {
        ZypeLog.write("\(method) Query: \(urlAsString) \(bodyAsString)")
        let request = NSMutableURLRequest(url: URL(string: urlAsString)!)
        request.httpMethod = method
        request.httpBody = bodyAsString.data(using: String.Encoding.utf8)
        if self.keys.userAgent.isEmpty == false
        {
            request.setValue(self.keys.userAgent, forHTTPHeaderField:"User-Agent")
        }
    
        let task = session!.dataTask(with: request as URLRequest, completionHandler: {
            ( data, response, error) in
            var err = error
            ZypeLog.assert(error == nil, message: "http error: \(String(describing: err))")
            var statusCode = 0
            if response != nil
            {
                statusCode = (response as! HTTPURLResponse).statusCode
            }
            var jsonDic: Dictionary<String, AnyObject>?
            if data != nil && data!.count != 0
            {
                do
                {
                    jsonDic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary <String, AnyObject>
                }
                catch _
                {
                    let dataString = String(data:data!, encoding:String.Encoding.utf8)
                    ZypeLog.error("JSON Parse Error \(String(describing: dataString))")
                    err = NSError(domain: kErrorDomaine, code: kErrorJSONParsing, userInfo: ["data" : dataString!])
                }
            }
            completion(statusCode, jsonDic, err as NSError?)
        }) 
        task.resume()
        return task
    }

    //delegate
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = URLCredential(trust:challenge.protectionSpace.serverTrust!)
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, credential);
    }

}
