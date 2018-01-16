//
//  SiteRatingCache.swift
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

public class SiteRatingCache {
    
    public struct CacheEntry {
        
        public let score: Int
        public let uniqueTrackerNetworksDetected: Int
        public let uniqueTrackerNetworksBlocked: Int
        public let uniqueMajorTrackerNetworksDetected: Int
        public let uniqueMajorTrackerNetworksBlocked: Int
        public let hasOnlySecureContent: Bool

        func copy(hasOnlySecureContent: Bool? = nil) -> CacheEntry {
            
            return CacheEntry(score: score,
                              uniqueTrackerNetworksDetected: uniqueTrackerNetworksDetected,
                              uniqueTrackerNetworksBlocked: uniqueMajorTrackerNetworksBlocked,
                              uniqueMajorTrackerNetworksDetected: uniqueMajorTrackerNetworksDetected,
                              uniqueMajorTrackerNetworksBlocked: uniqueMajorTrackerNetworksBlocked,
                              hasOnlySecureContent: hasOnlySecureContent ?? self.hasOnlySecureContent)
            
        }
        
    }
    
    public static let shared = SiteRatingCache()
    
    private var cache = [String: CacheEntry]()
    
    /**
     Adds a score to the cache. Only replaces a preexisting score if
     the new score is higher
     - returns: true if the cache was updated, otherwise false
     */
    func add(url: URL, entry: CacheEntry) -> Bool {
        return compareAndSet(url, entry)
    }

    /**
     Explicitly update an entry for the given the url.
     */
    func update(url: URL, with entry: CacheEntry) {
        let key = cacheKey(forUrl: url)
        cache[key] = entry
    }
    
    private func compareAndSet(_ url: URL, _ entry: CacheEntry) -> Bool {
        let key = cacheKey(forUrl: url)
        if let previous = cache[key], previous.score > entry.score {
            print("***", entry)
            return false
        }
        cache[key] = entry
        return true
    }
    
    public func get(url: URL) -> CacheEntry? {
        let key = cacheKey(forUrl: url)
        return cache[key]
    }
    
    func reset() {
        cache =  [String: CacheEntry]()
    }
    
    private func cacheKey(forUrl url: URL) -> String {
        guard let domain = url.host else {
            return url.absoluteString
        }
        let scheme = url.scheme ?? URL.URLProtocol.http.rawValue
        return "\(scheme)_\(domain)"
    }
}

