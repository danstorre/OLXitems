//
//  olxItemsTests.swift
//  olxItemsTests
//
//  Created by Daniel Torres on 6/24/17.
//  Copyright © 2017 dansTeam. All rights reserved.
//

import XCTest
@testable import olxItems


class olxItemsTests: XCTestCase {
    
 
    func test_getItems_Items(){
        
        let getItemExpect = XCTestExpectation(description: "items get")
        
        
        ItemsManager.shared.getItems(item: "iphone", offset: 0) { (success, items, errorString) in
            if success{
                
                XCTAssert(true)
                getItemExpect.fulfill()
            }else{
                XCTFail("no items returned")
            }
        }
        
        wait(for: [getItemExpect], timeout: 10.0)
    }
    
}
