//
//  TrackerDetector.swift
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

import Foundation

public class TrackerDetector {
    
    private var configuration: ContentBlockerConfigurationStore

    private var abp: ABPFilterLibWrapper
    
    private var disconnectTrackers: [Tracker]

    public init(configuration: ContentBlockerConfigurationStore = ContentBlockerConfigurationUserDefaults(), disconnectTrackers: [Tracker], abp: ABPFilterLibWrapper) {
        self.configuration = configuration
        self.disconnectTrackers = disconnectTrackers
        self.abp = abp
    }
        
    public func policy(forUrl url: URL, document documentUrl: URL) -> (tracker: Tracker?, block: Bool) {
        
        if isFirstParty(url, of: documentUrl) {
            return (nil, false)
        }
        
        guard let tracker = tracker(forUrl: url, documentUrl: documentUrl) else {
            return (nil, false)
        }
        
        if !configuration.enabled {
            return (tracker, false)
        }
        
        return (tracker, true)
    }
    
    private func tracker(forUrl url: URL, documentUrl: URL) -> Tracker? {
        
        if let tracker = disconnectTracker(forUrl: url, documentUrl: documentUrl) {
            Logger.log(items: "TrackerDetector detected DISCONNECT tracker", url.absoluteString)
            return tracker
        }
        
        if let tracker = easylistTracker(forUrl: url, documentUrl: documentUrl) {
            Logger.log(items: "TrackerDetector detected EASYLIST tracker", url.absoluteString)
            return tracker
        }
        
        return nil
    }
    
    private func disconnectTracker(forUrl url: URL, documentUrl: URL) -> Tracker? {
        
        guard let urlHost = url.host else {
            return nil
        }
        
        let banned = disconnectTrackers.filter(byCategory: Tracker.Category.banned)
        for tracker in banned {
            
            guard let trackerUrl = URL(string: URL.appendScheme(path: tracker.url)),
                let trackerHost = trackerUrl.host else {
                    continue
            }
            
            if isFirstParty(url, of: trackerUrl), urlHost.contains(trackerHost) {
                return tracker
            }
        }
        
        return nil
    }
    
    private func easylistTracker(forUrl url: URL, documentUrl: URL) -> Tracker? {
        if abp.isBlockedIgnoringType(url.absoluteString, mainDocumentUrl: documentUrl.absoluteString) {
            return Tracker(url: url.absoluteString, parentDomain: nil)
        }
        return nil
    }
    
    private func isFirstParty(_ childUrl: URL, of parentUrl: URL) -> Bool {
        if childUrl.absoluteString.starts(with: "/"), !childUrl.absoluteString.starts(with: "//") {
            return true
        }
        return childUrl.baseDomain == parentUrl.baseDomain
    }

}
