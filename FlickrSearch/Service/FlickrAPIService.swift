//
//  FlickerService.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 23/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class FlickrAPIService: NSObject, ImageSearchService {
    
    func executeRequest(request: ImageRequest, successHandler: @escaping (_ json: JSON) -> Void, failureHandler:@escaping (_ error: Error) -> Void) {
        Alamofire.request(request.getRequestURL(), method: .get).responseJSON{response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.validateAndHandleResponse(json, successHandler, failureHandler)
            case .failure( let error):
                failureHandler(error)
            }
        }
    }
    
    fileprivate func validateAndHandleResponse(_ json: JSON,_ successHandler: @escaping (_ json: JSON) -> Void, _ failureHandler:@escaping (_ error: Error) -> Void) {
        let error = checkError(json)
        (error == nil) ? successHandler(json) : failureHandler(error!)
    }
    
    fileprivate func checkError(_ json: JSON) -> NSError? {
        if(json["stat"].string == "fail"){
            let error = NSError(domain:json["message"].string!, code:json["code"].intValue, userInfo:nil)
            return error
        }
        return nil
    }
    
}
