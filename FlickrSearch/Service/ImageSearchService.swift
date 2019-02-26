//
//  ImageSearchServiceManager.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 24/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ImageSearchService {
    
    func executeRequest(request: ImageRequest, successHandler: @escaping (_ json: JSON) -> Void, failureHandler:@escaping(_ error: Error) -> Void)
}
