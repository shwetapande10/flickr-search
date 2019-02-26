//
//  LabelsMap.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 24/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import Foundation

struct LabelsMap {
    
    static let requestLabel: [RequestStatus:String] = [
        .load:Constants.Labels.Loading,
        .initial:Constants.Labels.InitialSearchHint,
        .more:Constants.Labels.Nothing,
        .refresh:Constants.Labels.Nothing,
        .fulfilled:Constants.Labels.Nothing
    ]
    
    static let responseLabel: [ResponseStatus:String] = [
        .successWithResults:Constants.Labels.Nothing,
        .successWithNoResults:Constants.Labels.NoResultsFound,
        .fail:Constants.Labels.FetchError
    ]
}
