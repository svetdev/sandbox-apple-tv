//
//  ZypeTokenManager.swift
//  UIKitCatalog
//
//  Created by Ilya Sorokin on 10/7/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit

class ZypeTokenManager {
    
    fileprivate let kApiKey_AccessToken = "access_token"
    fileprivate let kApiKey_RefreshToken = "refresh_token"
    fileprivate let kApiKey_CreatedAt  = "created_at"
    fileprivate let kApiKey_ExpiresIn = "expires_in"
    
    let kTokenAcceptableBuffer:Int = 600
    
    var tokenModel = ZypeTokenModel()
    
    func accessToken(_ completion: @escaping (_ token: String) ->Void, update:(_ refreshToken:String, _ completion: @escaping(_ jsonDic: Dictionary<String, AnyObject>?, _ error: NSError?) -> Void) ->Void)
    {
        if tokenModel.refreshToken.isEmpty
        {
            ZypeLog.error("try to use emply refresh token")
            completion(tokenModel.accessToken)
        }
        else if isAccessTokenExpired() == false
        {
            print("isAccessTokenExpired() == false")
            completion(tokenModel.accessToken)
        }
        else
        {
              print("isAccessTokenExpired() UPDATING")
            update(tokenModel.refreshToken, {(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void in
                ZypeLog.assert(error == nil && jsonDic != nil, message: "error get new token")
                if jsonDic != nil
                {
                    if self.setAccessTokenData(jsonDic!) == false
                    {
                        ZypeLog.error("parse new token error")
                    }
                }
                completion(self.tokenModel.accessToken)
            })
        }
    }
    
    func setLoginAccessTokenData(_ data: Dictionary<String, AnyObject>) -> NSError?
    {
        if setAccessTokenData(data) == false
        {
            return  NSError(domain: kErrorDomaine, code: kErrorIncorrectLoginParameters, userInfo: data as! Dictionary<String, String>)
        }
        return nil
    }
    
    //private
    
    func isAccessTokenExpired() -> Bool
    {
        let currentDate = Int(Date().timeIntervalSince1970)
        print ("Token will expire in: \(tokenModel.expirationDate - currentDate)")
        return currentDate >= (tokenModel.expirationDate - kTokenAcceptableBuffer)
    }
    
    fileprivate func setAccessTokenData(_ data: Dictionary<String, AnyObject>) -> Bool?
    {
        do
        {
            let access = try SSUtils.stringFromDictionary(data, key: kApiKey_AccessToken)
            let refresh = try SSUtils.stringFromDictionary(data, key: kApiKey_RefreshToken)
            let createdAt = try SSUtils.intagerFromDictionary(data, key: kApiKey_CreatedAt)
            let expiresIn = try SSUtils.intagerFromDictionary(data, key: kApiKey_ExpiresIn)
            let expirationDate = createdAt + expiresIn
            tokenModel.accessToken = access
            tokenModel.refreshToken = refresh
            tokenModel.expirationDate = expirationDate
        }
        catch _
        {
            return false
        }
        return true
    }

}
