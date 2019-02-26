//
//  FlickrAPIConfig.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 25/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import Foundation

struct FlickrRequestConfig {
    static var apiKey = "96358825614a5d3b1a1c3fd87fca2b47"
    static var pageSize = 21
    static let baseURL: String = "https://api.flickr.com/services/rest"
    static let flickrMethod: String = "flickr.photos.search"
    static let format: String = "json"
}

struct FlickrRequest:ImageRequest {
    
    private let searchString: String
    private let pageNumber: Int
    
    init(searchString: String, pageNumber:Int?=1){
        self.searchString = searchString
        self.pageNumber = pageNumber!
    }
    
    nonmutating func getRequestURL() -> String{
         return "\(FlickrRequestConfig.baseURL)/?method=\(FlickrRequestConfig.flickrMethod)&api_key=\(FlickrRequestConfig.apiKey)&text=\(searchString)&page=\(pageNumber)&per_page=\(FlickrRequestConfig.pageSize)&format=\(FlickrRequestConfig.format)&nojsoncallback=1"
    }
}
