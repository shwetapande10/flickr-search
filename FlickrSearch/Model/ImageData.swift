//
//  ImageMetaData.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 23/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import Foundation
import ReactiveSwift

class ImageData {
        var pageData: PageMetaData?
        var imageList:[ImageDetail]? = [ImageDetail]()
        var requestStatus: RequestStatus? = RequestStatus.initial
        var responseStatus: ResponseStatus?
    
        init(pageData: PageMetaData){
            self.pageData = pageData
        }
}

struct NoError: Error{
    
}
