//
//  ThumbnailModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/21/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

open class ThumbnailModel: NSObject {
    
    open let height: Int
    open let width: Int
    open let imageURL: String
    open let name: String
    
    init(height: Int, width: Int, url:String, name: String) {
        self.height = height
        self.width = width
        self.imageURL = url
        self.name = name
        super.init()
    }

}
