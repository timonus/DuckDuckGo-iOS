//
//  HTTPSUprgadePerformanceTests.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 10/01/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import Foundation

import XCTest
@testable import Core

class HTTPSUpgradePerformanceTests: XCTestCase {

    func test50() {
        let testDomains = ingest(50)
        guard !testDomains.isEmpty else { XCTFail(); return }
        checkDomains(testDomains)
    }
    
    func test2800() {
        let testDomains = ingest(2800)
        guard !testDomains.isEmpty else { XCTFail(); return }
        checkDomains(testDomains)
    }
    
    func test200k() {
        let size = 200000
        let testDomains = ingest(size)
        guard testDomains.count == size else { XCTFail(); return }
        checkDomains(testDomains)
    }
    
    func test500k() {
        let testDomains = ingest(500000)
        guard !testDomains.isEmpty else { XCTFail(); return }
        checkDomains(testDomains)
    }
    
    private func checkDomains(_ domains: [String]) {
        let https = CoreDataHTTPSUpgradePersistence()
        var start = Date()
        for index in 0 ..< domains.count {
            let domain = domains[index]
            _ = https.hasDomain(domain)
            
            if (index % 100) == 0 {
                print("***", Date().timeIntervalSince(start), index, domain)
                start = Date()
            }
        }
    }
    
    private func ingest(_ count: Int) -> [String] {
        guard let fileUrl = Bundle(for: HTTPSUpgradePerformanceTests.self).url(forResource: "click-domains", withExtension: "txt") else { return [] }
        print("***", fileUrl)
        
        guard let fileData = try? String(contentsOf: fileUrl) else {
            print("***", "fileData")
            return []
        }
        
        let lines = fileData.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        print("***", "lines read", lines.count)
        
        let https = CoreDataHTTPSUpgradePersistence()
        https.reset()
        https.persist(domains: Array<String>(lines[0 ..< count]), wildcardDomains: [])
        return Array<String>(lines[count ..< (count * 2)])
    }
    
}
