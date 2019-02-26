//
//  FlickrCollectionScrollHandler.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 24/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import UIKit

class FlickrCollectionScrollHandler: NSObject, UICollectionViewDelegate, UIScrollViewDelegate {
    
    private let flickrInteractor: ImageSearchInteractor
    private var imageData: ImageData
    private var fetchMoreData: Bool = false
    private weak var searchBar: UISearchBar?
    
    init(withInteractor: ImageSearchInteractor, andSearchBar: UISearchBar){
        self.flickrInteractor = withInteractor
        imageData = withInteractor.imageData!
        searchBar = andSearchBar
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height - scrollView.frame.height * 0.3 {
            if !fetchMoreData {
                fetchMoreData = true
                loadMoreImages()
            }
        }
    }
    
    func loadMoreImages(){
        imageData.requestStatus = RequestStatus.more
        flickrInteractor.searchImages(searchString: searchBar?.text ?? "",requestStatus: RequestStatus.more)
    }
    
    func resetFetching(){
        fetchMoreData = false
    }
    
}
