//
//  Interactor.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 24/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import Foundation

protocol ImageSearchInteractor {
    
    var imageData: ImageData? {get set}
    var presenter: ImagePresenter {get set}
    var service: ImageSearchService {get set}
    
    func searchImages(searchString: String,requestStatus: RequestStatus?)
}
