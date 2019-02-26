//
//  ImageData.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 23/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import Foundation
import SwiftyJSON

//view model
struct ImageDetail {
    
    let imageUrl: String
    let imageTitle: String
    
    init(url imageUrl:String="", title imageTile:String=""){
        self.imageUrl = imageUrl
        self.imageTitle = imageTile
    }
    
}
