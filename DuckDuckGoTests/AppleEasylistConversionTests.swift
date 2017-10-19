//
//  AppleEasylistConversionTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


import XCTest
import SwiftyJSON
@testable import Core

class AppleEasylistConversionTests: XCTestCase {
    
    func testNoIllegalCombinationsInEasylist() {
        checkForIllegalCombinationsIn(fileName: "easylist.json")
    }

    func testNoIllegalCombinationsInEasyPrivacy() {
        checkForIllegalCombinationsIn(fileName: "easyprivacy.json")
    }

    func checkForIllegalCombinationsIn(fileName: String) {
        let loader = JsonTestDataLoader()
        let data = loader.fromJsonFile(fileName, fromBundle: Bundle(for: EasylistStore.self))
        let json = try! JSON(data: data)
        let array = json.array!
        
        for (index, item) in array.enumerated() {
            let trigger = item["trigger"]
            if (trigger["if-top-url"].exists() || trigger["unless-top-url"].exists()) &&
               (trigger["if-domain"].exists() || trigger["unless-domain"].exists()) {
                XCTFail("\(fileName) contains illegal entry at index \(index)")
            }
        }
    }
}

