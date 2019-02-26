//
//  FlickrSearchInteractor.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 23/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import Foundation
import SwiftyJSON

class FlickrSearchInteractor: ImageSearchInteractor {
    
    weak var imageData: ImageData?
    var presenter: ImagePresenter
    var service: ImageSearchService
    
    
    init(presenter: ImagePresenter, service: ImageSearchService) {
        self.service = service
        self.presenter = presenter
        self.imageData = presenter.imageData
    }
    
    func searchImages(searchString: String, requestStatus: RequestStatus? = RequestStatus.load){
        guard !searchString.isEmpty else {
            return
        }
        presenter.initializeDataForLoad(requestStatus)
        let searchStr = searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let currentPageNumber = imageData?.pageData!.currentPageNo ?? 0 + 1
        let totalPages = imageData?.pageData!.totalPages ?? 0
        if(currentPageNumber <= totalPages){
            let request = FlickrRequest(searchString: searchStr, pageNumber: imageData!.pageData!.currentPageNo + 1)
            service.executeRequest(request: request, successHandler: successHandler, failureHandler: failureHandler)
        }
    }
    
    fileprivate func successHandler(_ json: JSON){
        presenter.loadImageData(data: json)
    }
    
    fileprivate func failureHandler(_ error: Error){
        presenter.loadFailedImageData(error: error)
    }
    
}
