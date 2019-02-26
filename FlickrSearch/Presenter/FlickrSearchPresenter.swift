//
//  FlickrSearchPresenter.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 26/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import Foundation
import SwiftyJSON
import ReactiveSwift

class FlickrSearchPresenter: ImagePresenter {
    
    var imageData: ImageData?
    var pipeTuple: (Signal<ResponseStatus, NoError>, Signal<ResponseStatus, NoError>.Observer)?
    
    init(model imageData : ImageData?){
        self.imageData = imageData
        pipeTuple = Signal<ResponseStatus, NoError>.pipe()
    }
    
    func initializeDataForLoad(_ status: RequestStatus?) {
        let imageData = self.imageData!
        if(status == RequestStatus.load || status == RequestStatus.refresh) {
            imageData.requestStatus = status
            imageData.pageData?.currentPageNo = 0
            if(status == RequestStatus.load){
                imageData.imageList?.removeAll()
            }
        }
        imageData.responseStatus = ResponseStatus.pending
        sendNotificationToView()
    }
    
    func loadImageData(data: JSON?) {
        let imageData = self.imageData!
        imageData.pageData!.totalPages = data!["photos"]["pages"].intValue
        if(imageData.pageData!.totalPages == 0)
        {
            imageData.imageList?.removeAll()
            imageData.responseStatus = ResponseStatus.successWithNoResults
        }
        else {
            loadImageDataResults(data!)
        }
        fulfillRequest()
    }
    
    func loadFailedImageData(error: Error?) {
        self.imageData!.responseStatus = ResponseStatus.fail
        fulfillRequest()
    }
    
    fileprivate func loadImageDataResults(_ data: JSON) {
        let imageData = self.imageData!
        let picturesList = data["photos"]["photo"].arrayValue
        if(imageData.requestStatus == RequestStatus.refresh){
            imageData.imageList?.removeAll()
        }
        var imageList = imageData.imageList
        for picData in picturesList {
            let (imageUrl, imageTitle) = self.getFlickrImageDetail(picData)
            imageList?.append(ImageDetail(url:imageUrl,title:imageTitle))
        }
        imageData.imageList = imageList
        imageData.pageData!.currentPageNo = imageData.pageData!.currentPageNo + 1
        imageData.responseStatus = ResponseStatus.successWithResults
    }
    
    fileprivate func getFlickrImageDetail(_ json: JSON!) -> (String, String) {
        var imageTitle = "", imageUrl = ""
        if(json != nil){
            let data = json!
            imageTitle = data["title"].string!
            imageUrl = "https://farm\(data["farm"]).static.flickr.com/\(data["server"])/\(data["id"])_\(data["secret"]).jpg"
        }
        return (imageUrl, imageTitle)
    }
    
    fileprivate func fulfillRequest() {
        imageData!.requestStatus = RequestStatus.fulfilled
        sendNotificationToView()
    }
    
    func sendNotificationToView() {
        self.pipeTuple!.1.send(value: (imageData?.responseStatus)!)
    }
    
}
