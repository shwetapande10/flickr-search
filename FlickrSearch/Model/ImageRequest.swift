//
//  ImageRequest.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 25/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import Foundation

protocol ImageRequest {
    func getRequestURL() -> String
}
