//
//  SSUtils.swift
//  UIKitCatalog
//
//  Created by Ilya Sorokin on 10/8/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit

enum UtilError: Error {
    case invalidArgument
}

internal let kApiDateFromeStringFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
internal let kApiDateToStringFormat = "yyyy-MM-dd"

open class SSUtils {
    
    open static func dateToString(_ date: Date?, format: String = kApiDateToStringFormat) -> String
    {
        if date == nil
        {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateString: String = dateFormatter.string(from: date!)
        return dateString
    }
    
    open static func stringToDate(_ string: String, format: String = kApiDateFromeStringFormat) -> Date?
    {
        if string.isEmpty
        {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }
    
    open static func stringFromDictionary(_ dic: Dictionary<String, AnyObject>?, key: String) throws -> String
    {
        if (dic == nil)
        {
            throw UtilError.invalidArgument
        }
        let value = dic![key]
        if (value == nil)
        {
            throw UtilError.invalidArgument
        }
        if ((value as? String) == nil)
        {
             throw UtilError.invalidArgument
        }
        return value as! String
    }
    
    open static func intagerFromDictionary(_ dic: Dictionary<String, AnyObject>?, key: String) throws -> Int
    {
        if (dic == nil)
        {
            throw UtilError.invalidArgument
        }
        let value = dic![key]
        if (value == nil)
        {
            throw UtilError.invalidArgument
        }
        if ((value as? Int) == nil)
        {
            throw UtilError.invalidArgument
        }
        return value as! Int
    }

    open static func doubleFromDictionary(_ dic: Dictionary<String, AnyObject>?, key: String) throws -> Double
    {
        if (dic == nil)
        {
            throw UtilError.invalidArgument
        }
        let value = dic![key]
        if (value == nil)
        {
            throw UtilError.invalidArgument
        }
        if ((value as? Double) == nil)
        {
            throw UtilError.invalidArgument
        }
        return value as! Double
    }
    
    open static func boolFromDictionary(_ dic: Dictionary<String, AnyObject>?, key: String) throws -> Bool
    {
        if (dic == nil)
        {
            throw UtilError.invalidArgument
        }
        let value = dic![key]
        if (value == nil)
        {
            throw UtilError.invalidArgument
        }
        if ((value as? Bool) == nil)
        {
            throw UtilError.invalidArgument
        }
        return value as! Bool
    }

    static func categoryToId(_ categoryKey: String, categoryValue: String) -> String
    {
        let categoryId = escapedString(categoryKey + categoryValue)
        return categoryId
    }
    
    //TODO refactoring remove stringByReplacingOccurrencesOfString
    static func escapedString(_ string: String) -> String
    {
        let value = string.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        return value!.replacingOccurrences(of: "&", with: "%26")
    }
    
}
