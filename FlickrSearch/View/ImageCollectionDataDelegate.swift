//
//  ImageCollectionDataDelegate.swift
//  FlickrSearch
//
//  Created by Shweta Pande on 24/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import Foundation
import UIKit

protocol ImageCollectionDataDelegate: UICollectionViewDataSource {
    var imageList: [ImageDetail] {get set}
    func reloadImages(_ collectionView: UICollectionView)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
}
