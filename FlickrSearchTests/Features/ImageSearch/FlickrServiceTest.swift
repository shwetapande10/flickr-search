//
//  FlickrServiceTest.swift
//  FlickrSearchTests
//
//  Created by Shweta Pande on 26/2/19.
//  Copyright © 2019 sap. All rights reserved.
//

import XCTest
@testable import FlickrSearch

class FlickrServiceTest: XCTestCase {

    var service: FlickrAPIService?
    
    override func setUp() {
        service = FlickrAPIService()
    }

    func testShouldReturnErrorForNonEncodedSearchString() {
        let request = FlickrRequest(searchString: "big cats", pageNumber: 1)
        var error:Error?
        let predicate = NSPredicate(block: { any, _ in
            return error != nil
        })
        var failedResponse = false
        service!.executeRequest(request: request, successHandler: { _ in
            failedResponse = false
        }, failureHandler: { (err) in
                error = err
                failedResponse = true
        })
        _ = self.expectation(for: predicate, evaluatedWith: error as Any, handler: .none)
        waitForExpectations(timeout: 100, handler: nil)
        XCTAssertTrue(failedResponse)
    }

}
