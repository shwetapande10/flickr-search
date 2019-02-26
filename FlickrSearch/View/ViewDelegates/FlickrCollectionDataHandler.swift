//
//  FlickrCollectionHandler.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 23/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import UIKit
import AlamofireImage

class FlickrCollectionDataHandler: NSObject, ImageCollectionDataDelegate {
    
    private let flickrInteractor: ImageSearchInteractor
    var imageList:[ImageDetail]
    
    init(withInteractor: ImageSearchInteractor){
        self.flickrInteractor = withInteractor
        imageList = withInteractor.imageData?.imageList ?? []
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageViewCell
        let imageDetail = imageList[indexPath.item]
        guard !imageDetail.imageUrl.isEmpty else {
            return cell
        }
        return populatedCell(cell, imageDetail)
    }
    
    fileprivate func populatedCell(_ cell: ImageViewCell, _ imageDetail: ImageDetail) ->  ImageViewCell{
        let placeholderImage = UIImage(named: "placeholder")
        let url = URL(string: imageDetail.imageUrl)!
        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
            size: (cell.imageView.frame.size),
            radius: 5.0
        )
        cell.accessibilityLabel = imageDetail.imageTitle
        cell.imageTitle.text = imageDetail.imageTitle
        cell.imageView.af_setImage(withURL: url, placeholderImage: placeholderImage, filter: filter, imageTransition: .noTransition)
        return cell
    }
    
    func reloadImages(_ collectionView: UICollectionView){
        let imageData = flickrInteractor.imageData
        imageList = imageData?.imageList ?? []
        displayAppropriateMessage(collectionView, imageData!)
        collectionView.reloadData()
    }
    
    fileprivate func displayAppropriateMessage(_ collectionView: UICollectionView, _ imageData: ImageData) {
        let backgroundLabel = collectionView.backgroundView as! UILabel
        var messageText = Constants.Labels.Nothing
        if(imageList.isEmpty) {
            messageText = (imageData.requestStatus != RequestStatus.fulfilled) ? (LabelsMap.requestLabel[imageData.requestStatus!]!) : (LabelsMap.responseLabel[imageData.responseStatus!]!)
        }
        backgroundLabel.text = messageText;
    }
    
}
