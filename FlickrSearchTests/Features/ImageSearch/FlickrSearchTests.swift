//
//  FlickrSearchTests.swift
//  FlickrSearchTests
//
//  Created by Shweta Pande on 23/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import XCTest
@testable import FlickrSearch

class FlickrSearchTests: XCTestCase {
    
    var window: UIWindow!
    var flickerSearchViewController: FlickrSearchViewController!
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setUpViewController()
        FlickrRequestConfig.apiKey = "96358825614a5d3b1a1c3fd87fca2b47"
    }
    
    override func tearDown() {
        window = nil
        flickerSearchViewController = nil
    }
    
    fileprivate func addViewToWindow(view: UIView)
    {
        window.addSubview(view)
        RunLoop.current.run(until: NSDate() as Date)
    }
    
    fileprivate func setUpViewController() {
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        flickerSearchViewController = (storyboard.instantiateViewController(withIdentifier: "FlickerSearchViewController") as? FlickrSearchViewController)
        let view = flickerSearchViewController.view!
        addViewToWindow(view:view)
    }
    
    fileprivate func getMockImageUrls() -> [String] {
        return ["https://farm8.static.flickr.com/7917/33300683078_7c895c0555.jpg", "https://farm8.static.flickr.com/7911/47175915441_1340c3783b.jpg", "https://farm8.static.flickr.com/7807/33300676048_f7299b74ba.jpg", "https://farm8.static.flickr.com/7851/32234151327_ebb2deea3b.jpg", "https://farm8.static.flickr.com/7907/33300667778_6b6021af8f.jpg", "https://farm8.static.flickr.com/7860/40211132413_dc400f6150.jpg", "https://farm8.static.flickr.com/7876/46261722825_e3b865cc47.jpg", "https://farm8.static.flickr.com/7813/46261719915_070af0ea3f.jpg"]
    }
    
    func testShouldCreateControllerWithConvinience(){
        let viewController = FlickrSearchViewController()
        XCTAssertNotNil(viewController)
    }
    
    func testViewControllerExists() {
        XCTAssertNotNil(flickerSearchViewController)
    }
    
    func testShouldHaveSearchBar(){
        let searchBar = flickerSearchViewController.searchBar
        XCTAssertNotNil(searchBar)
    }
    
    func testShouldHaveImageCollectionView(){
        let imageCollectionView = flickerSearchViewController.imageCollectionView
        XCTAssertNotNil(imageCollectionView)
    }
    
    func testShouldShowInitialInformationOnCollectionBackgroundView(){
        let imageCollectionView = flickerSearchViewController.imageCollectionView
        let backgroundText = imageCollectionView?.backgroundView as! UILabel
        let expectedText = "Search picture on Flickr \n (e.g. Kittens, vacation, etc.)"
        XCTAssertEqual(expectedText, backgroundText.text)
    }
    
    func testShouldHaveNoDataInitially(){
        let imageCollectionView = flickerSearchViewController.imageCollectionView
        let collectionData = flickerSearchViewController.collectionData!
        XCTAssertEqual(0,imageCollectionView?.numberOfItems(inSection: 0))
        XCTAssertEqual(0, collectionData.imageList.count)
    }
    
    func testShouldHoldItemsInCollectionForData() {
        let collectionData = flickerSearchViewController.collectionData!
        collectionData.imageList = [ImageDetail(),ImageDetail(),ImageDetail(),ImageDetail(),ImageDetail()]
        let imageCollectionView = flickerSearchViewController.imageCollectionView
        XCTAssertEqual(5,imageCollectionView?.numberOfItems(inSection: 0))
        XCTAssertEqual(5, collectionData.imageList.count)
        let imageCell = collectionData.collectionView(imageCollectionView!, cellForItemAt: IndexPath(row: 2, section: 0))
        XCTAssertNotNil(imageCell)
    }
    
    func testShouldShowDefaultImageItemsInCollectionForData() {
        let listData = [ImageDetail(),ImageDetail(),ImageDetail(),ImageDetail(),ImageDetail()]
        let collectionData = flickerSearchViewController.collectionData!
        collectionData.imageList = listData
        let imageCollectionView = flickerSearchViewController.imageCollectionView
        let imageCell = collectionData.collectionView(imageCollectionView!, cellForItemAt: IndexPath(row: 2, section: 0)) as! ImageViewCell
        let imageView = imageCell.imageView
        let expectedInitialImage = UIImage(named: "placeholder")
        XCTAssertNotNil(imageView)
        XCTAssertEqual(expectedInitialImage, imageView?.image)
    }
    
    func testShouldDownloadImageItemsInCollectionForData(){
        let mockUrls = getMockImageUrls()
        let listData = [ImageDetail(url:mockUrls[0]),ImageDetail(url:mockUrls[1]),ImageDetail(url:mockUrls[2]),ImageDetail(url:mockUrls[3]),ImageDetail(url:mockUrls[4])]
        let collectionData = flickerSearchViewController.collectionData!
        collectionData.imageList = listData
        let imageCollectionView = flickerSearchViewController.imageCollectionView
        let expectedInitialImage = UIImage(named: "placeholder")
        
        let predicate = NSPredicate(block: { any, _ in
            guard (any as? FlickrSearchViewController) != nil else { return false }
            let imageCell = collectionData.collectionView(imageCollectionView!, cellForItemAt: IndexPath(row: 2, section: 0)) as! ImageViewCell
            let actualImage = imageCell.imageView?.image?.pngData()
            return expectedInitialImage?.pngData()!.count != actualImage?.count
        })
        _ = self.expectation(for: predicate, evaluatedWith: flickerSearchViewController, handler: .none)
        
        waitForExpectations(timeout: 10, handler: nil)
        let imageCell = collectionData.collectionView(imageCollectionView!, cellForItemAt: IndexPath(row: 2, section: 0)) as! ImageViewCell
        let imageView = imageCell.imageView
        let actualImage = imageView?.image
        XCTAssertNotEqual(expectedInitialImage, actualImage)
    }
    
    func testShouldGetDataForImagesFromFlicker() {
        flickerSearchViewController.searchBar.text = "Kittens"
        let searchHandler = flickerSearchViewController.searchHandler
        let collectionData = flickerSearchViewController.collectionData!
        searchHandler!.searchBarSearchButtonClicked!(flickerSearchViewController.searchBar)
        let viewModel = flickerSearchViewController.flickrDataPresenter?.imageData!
        let predicate = NSPredicate(block: { any, _ in
            guard let data = (any as? ImageData) else { return false }
            return data.responseStatus == ResponseStatus.successWithResults
        })
        _ = self.expectation(for: predicate, evaluatedWith: viewModel!, handler: .none)
        
        waitForExpectations(timeout: 10, handler: nil)
        collectionData.reloadImages(flickerSearchViewController.imageCollectionView)
        XCTAssertTrue(collectionData.imageList.count>0)
    }
    
    func testShouldLoadSearchedDataOnView(){
        flickerSearchViewController.searchBar.text = "Kittens"
        let searchHandler = flickerSearchViewController.searchHandler
        let collectionData = flickerSearchViewController.collectionData!
        searchHandler!.searchBarSearchButtonClicked!(flickerSearchViewController.searchBar)
        let viewModel = flickerSearchViewController.flickrDataPresenter?.imageData!
        let predicate = NSPredicate(block: { any, _ in
            guard let data = (any as? ImageData) else { return false }
            return data.responseStatus == ResponseStatus.successWithResults
        })
        _ = self.expectation(for: predicate, evaluatedWith: viewModel!, handler: .none)
        
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(21,collectionData.collectionView(flickerSearchViewController.imageCollectionView, numberOfItemsInSection: 0))
    }
    
    func testShouldShowNoResultsFoundLabelForNonExistingResult(){
        flickerSearchViewController.searchBar.text = "$%^43r3fdf#$%$#^#$FDsfsfs76598-=tgfdssdfs"
        let searchHandler = flickerSearchViewController.searchHandler
        searchHandler!.searchBarSearchButtonClicked!(flickerSearchViewController.searchBar)
        let viewModel = flickerSearchViewController.flickrDataPresenter?.imageData!
        let predicate = NSPredicate(block: { any, _ in
            guard let data = (any as? ImageData) else { return false }
            return data.responseStatus == ResponseStatus.successWithNoResults
        })
        _ = self.expectation(for: predicate, evaluatedWith: viewModel!, handler: .none)
        
        waitForExpectations(timeout: 10, handler: nil)
        let backgroundText = flickerSearchViewController.imageCollectionView.backgroundView as! UILabel
        let expectedText = LabelsMap.responseLabel[ResponseStatus.successWithNoResults]
        XCTAssertEqual(expectedText, backgroundText.text)
    }
    
    func testShouldHaveRefreshControl(){
        XCTAssertNotNil(flickerSearchViewController.imageCollectionView.refreshControl)
    }
    
    func testShouldRefreshWhenRefreshControlTargetIsInvoked(){
        flickerSearchViewController.searchBar.text = "Kittens"
        let mockUrls = getMockImageUrls()
        let listData = [ImageDetail(url:mockUrls[0]),ImageDetail(url:mockUrls[1]),ImageDetail(url:mockUrls[2]),ImageDetail(url:mockUrls[3]),ImageDetail(url:mockUrls[4])]
        let collectionData = flickerSearchViewController.collectionData!
        collectionData.imageList = listData
        let imageCollectionView = flickerSearchViewController.imageCollectionView
        imageCollectionView?.reloadData()
        let viewModel = flickerSearchViewController.flickrDataPresenter?.imageData!
        
        let predicate = NSPredicate(block: { any, _ in
            guard let data = (any as? ImageData) else { return false }
            return data.responseStatus == ResponseStatus.successWithResults
        })
        flickerSearchViewController.refreshControlAction()
        _ = self.expectation(for: predicate, evaluatedWith: viewModel!, handler: .none)
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(21,collectionData.collectionView(flickerSearchViewController.imageCollectionView, numberOfItemsInSection: 0))
    }
    
    func testShouldNotRefreshForEmprtySearchString(){
        flickerSearchViewController.searchBar.text = ""
        let mockUrls = getMockImageUrls()
        let listData = [ImageDetail(url:mockUrls[0]),ImageDetail(url:mockUrls[1]),ImageDetail(url:mockUrls[2]),ImageDetail(url:mockUrls[3]),ImageDetail(url:mockUrls[4])]
        let collectionData = flickerSearchViewController.collectionData!
        collectionData.imageList = listData
        let imageCollectionView = flickerSearchViewController.imageCollectionView
        imageCollectionView?.reloadData()
        
        flickerSearchViewController.refreshControlAction()
        
        XCTAssertEqual(5,collectionData.collectionView(flickerSearchViewController.imageCollectionView, numberOfItemsInSection: 0))
    }
    
    func testViewShouldLoadMoreDataAfterScrollingToBottom() {
        flickerSearchViewController.searchBar.text = "Kittens"
        let searchHandler = flickerSearchViewController.searchHandler
        let collectionData = flickerSearchViewController.collectionData!
        searchHandler!.searchBarSearchButtonClicked!(flickerSearchViewController.searchBar)
        let viewModel = flickerSearchViewController.flickrDataPresenter?.imageData!
        let predicate = NSPredicate(block: { any, _ in
            guard let data = (any as? ImageData) else { return false }
            return data.responseStatus == ResponseStatus.successWithResults
        })
        _ = self.expectation(for: predicate, evaluatedWith: viewModel!, handler: .none)
        waitForExpectations(timeout: 10, handler: nil)
        
        flickerSearchViewController.imageCollectionView.scrollToItem(at: IndexPath(row: 20, section: 0), at: .bottom, animated: false)
        
        _ = self.expectation(for: predicate, evaluatedWith: viewModel!, handler: .none)
        waitForExpectations(timeout: 10, handler: nil)
        
        collectionData.reloadImages(flickerSearchViewController.imageCollectionView)
        XCTAssertLessThan(21,collectionData.collectionView(flickerSearchViewController.imageCollectionView, numberOfItemsInSection: 0))
    }
    
    func testViewShouldLoadThreePagesAfterScrollingThrice() {
        flickerSearchViewController.searchBar.text = "Kittens"
        let searchHandler = flickerSearchViewController.searchHandler
        let collectionData = flickerSearchViewController.collectionData!
        searchHandler!.searchBarSearchButtonClicked!(flickerSearchViewController.searchBar)
        let viewModel = flickerSearchViewController.flickrDataPresenter?.imageData!
        let predicate = NSPredicate(block: { any, _ in
            guard let data = (any as? ImageData) else { return false }
            return data.responseStatus == ResponseStatus.successWithResults
        })
        _ = self.expectation(for: predicate, evaluatedWith: viewModel!, handler: .none)
        waitForExpectations(timeout: 10, handler: nil)
        
        flickerSearchViewController.imageCollectionView.scrollToItem(at: IndexPath(row: 20, section: 0), at: .bottom, animated: false)
        
        _ = self.expectation(for: predicate, evaluatedWith: viewModel!, handler: .none)
        waitForExpectations(timeout: 10, handler: nil)
        
        collectionData.reloadImages(flickerSearchViewController.imageCollectionView)
        XCTAssertLessThan(21,collectionData.collectionView(flickerSearchViewController.imageCollectionView, numberOfItemsInSection: 0))
        
        flickerSearchViewController.imageCollectionView.scrollToItem(at: IndexPath(row: 40, section: 0), at: .bottom, animated: false)
        
        _ = self.expectation(for: predicate, evaluatedWith: viewModel!, handler: .none)
        waitForExpectations(timeout: 10, handler: nil)
        
        collectionData.reloadImages(flickerSearchViewController.imageCollectionView)
        XCTAssertLessThan(42,collectionData.collectionView(flickerSearchViewController.imageCollectionView, numberOfItemsInSection: 0))
        
        flickerSearchViewController.imageCollectionView.scrollToItem(at: IndexPath(row: 60, section: 0), at: .bottom, animated: false)
        
        _ = self.expectation(for: predicate, evaluatedWith: viewModel!, handler: .none)
        waitForExpectations(timeout: 10, handler: nil)
        
        collectionData.reloadImages(flickerSearchViewController.imageCollectionView)
        XCTAssertLessThan(63,collectionData.collectionView(flickerSearchViewController.imageCollectionView, numberOfItemsInSection: 0))
        
        XCTAssertEqual(4, viewModel!.pageData?.currentPageNo)
    }
    
    func testCancelButtonShouldBeDisplayedInitially(){
        XCTAssertTrue(flickerSearchViewController.searchBar.showsCancelButton)
    }
    
    func testCancelButtonShouldBeDisplayedWhenKeyboardIsShown(){
        flickerSearchViewController.searchBar.text = ""
        let searchHandler = flickerSearchViewController.searchHandler!
        
        flickerSearchViewController.searchBar.becomeFirstResponder()
        searchHandler.searchBarTextDidBeginEditing!(flickerSearchViewController.searchBar)
        
        XCTAssertTrue(flickerSearchViewController.searchBar.showsCancelButton)
    }
    
    func testCancelButtonShouldNotBeDisplayedAfterCancelButtonIsClicked(){
        flickerSearchViewController.searchBar.text = ""
        let searchHandler = flickerSearchViewController.searchHandler!
        flickerSearchViewController.searchBar.becomeFirstResponder()
        searchHandler.searchBarTextDidBeginEditing!(flickerSearchViewController.searchBar)
        
        searchHandler.searchBarCancelButtonClicked!(flickerSearchViewController.searchBar)
        
        XCTAssertFalse(flickerSearchViewController.searchBar.showsCancelButton)
    }
    
    func testShouldPerformNoActionOnEmptySearch(){
        flickerSearchViewController.searchBar.text = ""
        let searchHandler = flickerSearchViewController.searchHandler!
        flickerSearchViewController.searchBar.becomeFirstResponder()
        searchHandler.searchBarTextDidBeginEditing!(flickerSearchViewController.searchBar)
        
        searchHandler.searchBarSearchButtonClicked!(flickerSearchViewController.searchBar)
        
        XCTAssertTrue(flickerSearchViewController.searchBar.showsCancelButton)
    }
}
