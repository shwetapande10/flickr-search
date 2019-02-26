//
//  ImagePresenter.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 26/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import Foundation
import SwiftyJSON
import ReactiveSwift

protocol ImagePresenter {
    
    var imageData : ImageData? {get set}
    var pipeTuple: (Signal<ResponseStatus, NoError>, Signal<ResponseStatus, NoError>.Observer)? {get set}
    
    func initializeDataForLoad(_ status : RequestStatus?)
    func loadImageData(data : JSON?)
    func loadFailedImageData(error: Error?)
    func sendNotificationToView()
}
