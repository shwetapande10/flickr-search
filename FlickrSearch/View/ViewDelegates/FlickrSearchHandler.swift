//
//  FlickrSearchHandler.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 23/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import UIKit

class FlickrSearchHandler: NSObject, UISearchBarDelegate {

    private let flickrInteractor: ImageSearchInteractor
    private var oldSearchString: String?
    
    init(withInteractor:ImageSearchInteractor) {
        self.flickrInteractor = withInteractor
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        guard let searchStr = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchStr.isEmpty else {
            return
        }
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        if(oldSearchString != searchStr){
            self.flickrInteractor.searchImages(searchString: searchStr,requestStatus: RequestStatus.load)
        }
        oldSearchString = searchStr
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resignResponder(searchBar)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        searchBar.showsCancelButton = true
    }
    
    fileprivate func resignResponder(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }

}
