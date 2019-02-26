//
//  FlickrInteractorTest.swift
//  FlickrSearchTests
//
//  Created by Shweta Pande on 23/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import XCTest
@testable import FlickrSearch

class FlickrInteractorTest: XCTestCase {
    
    var flickrSearchInteractor :ImageSearchInteractor?
    
    override func setUp() {
        FlickrRequestConfig.apiKey = "96358825614a5d3b1a1c3fd87fca2b47"
        let imageData = ImageData(pageData: PageMetaData(currentPageNo: 1, totalPages: 1))
        let flickrApiService = FlickrAPIService()
        let flickrDataPresenter = FlickrSearchPresenter(model: imageData)
        flickrSearchInteractor = FlickrSearchInteractor(presenter: flickrDataPresenter, service: flickrApiService)
    }
    
    
    func testShouldGetDataFromFlickrAPIInteractor(){
        let searchString = "Kittens"
        let flickrSearchInteractor = self.flickrSearchInteractor!
        flickrSearchInteractor.searchImages(searchString: searchString, requestStatus: RequestStatus.load)
        let predicate = NSPredicate(block: { any, _ in
            guard let data = (any as? ImageData) else { return false }
            return data.responseStatus == ResponseStatus.successWithResults
        })
        _ = self.expectation(for: predicate, evaluatedWith: flickrSearchInteractor.imageData!, handler: .none)
        waitForExpectations(timeout: 10, handler: nil)
        let data = flickrSearchInteractor.imageData
        XCTAssertTrue(data!.imageList!.count > 0)
    }
    
    func testShouldSearchNotProceedWithEmptyString(){
        let searchString = ""
        let flickrSearchInteractor = self.flickrSearchInteractor!
        flickrSearchInteractor.searchImages(searchString: searchString, requestStatus: RequestStatus.load)
        let data = flickrSearchInteractor.imageData
        XCTAssertTrue(data!.requestStatus != RequestStatus.fulfilled)
    }
    
    func testShouldFailDataFromFlickrAPIInteractor(){
        let searchString = "Kittens"
        FlickrRequestConfig.apiKey = "abc"
        let flickrSearchInteractor = self.flickrSearchInteractor!
        flickrSearchInteractor.searchImages(searchString: searchString, requestStatus: RequestStatus.load)
        let predicate = NSPredicate(block: { any, _ in
            guard let data = (any as? ImageData) else { return false }
            return data.responseStatus
                == ResponseStatus.fail
        })
        _ = self.expectation(for: predicate, evaluatedWith: flickrSearchInteractor.imageData!, handler: .none)
        waitForExpectations(timeout: 10, handler: nil)
        let data = flickrSearchInteractor.imageData
        XCTAssertTrue(data!.imageList!.count == 0)
    }
    
    func testShouldGetNoDataForNoResults(){
        let searchString = "$%^43r3fdf#$%$#^#$FDsfsfs76598-=tgfdssdfs"
        
        flickrSearchInteractor!.searchImages(searchString: searchString, requestStatus: RequestStatus.load)
        let predicate = NSPredicate(block: { any, _ in
            guard let data = (any as? ImageData) else { return false }
            return data.responseStatus == ResponseStatus.successWithNoResults
        })
        _ = self.expectation(for: predicate, evaluatedWith: flickrSearchInteractor!.imageData!, handler: .none)
        
        waitForExpectations(timeout: 10, handler: nil)
        let data = flickrSearchInteractor!.imageData!
        XCTAssertTrue(data.imageList!.count == 0)
    }
    
    func testShouldIncrementPageNumberForLoadMore(){
        let searchString = "Kittens"
        let flickrSearchInteractor = self.flickrSearchInteractor!
        let data = flickrSearchInteractor.imageData
        flickrSearchInteractor.searchImages(searchString: searchString, requestStatus: RequestStatus.load)
        let predicate = NSPredicate(block: { any, _ in
            guard let data = (any as? ImageData) else { return false }
            return data.responseStatus == ResponseStatus.successWithResults
        })
        _ = self.expectation(for: predicate, evaluatedWith: flickrSearchInteractor.imageData!, handler: .none)
        
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(1,data!.pageData!.currentPageNo)
        
        flickrSearchInteractor.searchImages(searchString: searchString, requestStatus: RequestStatus.more)
        _ = self.expectation(for: predicate, evaluatedWith: flickrSearchInteractor.imageData!, handler: .none)
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(2,data!.pageData!.currentPageNo)
        
        flickrSearchInteractor.searchImages(searchString: searchString, requestStatus: RequestStatus.more)
        _ = self.expectation(for: predicate, evaluatedWith: flickrSearchInteractor.imageData!, handler: .none)
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(3,data!.pageData!.currentPageNo)
    }
    
}
