//
//  VideoObjectModel.swift
//  ZypeAppleTVBase
//
//  Created by Ilya Sorokin on 11/5/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

open class VideoObjectModel: NSObject {

    internal(set) open var videoURL = ""
    
     internal(set) open var videoId = ""
    
    internal(set) open var json: Dictionary <String, AnyObject>?
    
    
}
