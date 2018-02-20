//
//  SpeedTests.swift
//  SpeedTests
//
//  Created by Chris Brind on 20/02/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import XCTest

@testable import DuckDuckGo
@testable import Core

class SpeedTests: XCTestCase {
    
    private var results = [Any]()
    private var mainController: MainViewController!
    
    struct Filename {
        static let sites = "speed_test_sites.json"
        static let report = "speed_test_results_\(SpeedTests.dateString()).json"
    }
    
    struct Timeout {
        static let pageLoad = 20.0
    }
    
    override func setUp() {
        loadBlockingLists()
        TabsModel.clear()
        loadStoryboard()
    }
    
    override func tearDown() {
        saveResults()
        TabsModel.clear()
    }
    
    func loadBlockingLists() {
        let blocker = DispatchSemaphore(value: 0)
        BlockerListsLoader().start { newData in
            blocker.signal()
        }
        blocker.wait()
    }
    
    func test() {
        let data = try! FileLoader().load(fileName: Filename.sites, fromBundle: Bundle(for: SpeedTests.self))
        let sites = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [[String: String]]
        
        for site in sites {
            guard let url = site["url"] else { continue }
            
            let time = evalulate(url)
            results.append([ "url": url, "time": time ])
            waitFor(seconds: 2)
        }
        
        saveResults()
    }
    
    func waitFor(seconds: TimeInterval) {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: seconds))
    }
    
    func evalulate(_ url: String) -> TimeInterval {
        if let siteRating = mainController.siteRating {
            siteRating.finishedLoading = false
        }
        
        mainController.loadUrl(URL(string: url)!)
        let start = Date()
        waitForPageLoad()
        return Date().timeIntervalSince(start)
    }
    
    func waitForPageLoad() {
        let pageTimeout = Date(timeIntervalSinceNow: Timeout.pageLoad)
        while (mainController.siteRating == nil || !mainController.siteRating!.finishedLoading) && Date() < pageTimeout {
            waitFor(seconds: 0.001)
        }
    }
    
    func loadStoryboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        mainController = storyboard.instantiateInitialViewController() as! MainViewController
        UIApplication.shared.keyWindow!.rootViewController = mainController
        XCTAssertNotNil(mainController.view)
    }
    
    func saveResults() {
        let fileName = Filename.report
        let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent(fileName)
        let jsonResults = try! JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)
        var stringResults = String(data: jsonResults, encoding: .utf8)!
        stringResults = stringResults.replacingOccurrences(of: "\\/", with: "/")
        try! stringResults.write(to: fileUrl, atomically: true, encoding: .utf8)
        print("Saving results to \(fileUrl)")
    }
    
    static func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return formatter.string(from: Date())
    }
    
}
