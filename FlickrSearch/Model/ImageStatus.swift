//
//  DataStatus.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 24/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import Foundation

enum RequestStatus {
    case initial
    case load
    case more
    case refresh
    case fulfilled
}

enum ResponseStatus {
    case pending
    case successWithResults
    case successWithNoResults
    case fail
}
