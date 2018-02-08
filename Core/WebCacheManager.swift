//
//  WebCacheManager.swift
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


import WebKit

public class WebCacheManager {

    private struct Constants {
        static let internalCache = "duckduckgo.com"
    }
    
    private static var allData: Set<String> = WKWebsiteDataStore.allWebsiteDataTypes()
    private static var ddgData: Set<String> = allData.subtracting([ WKWebsiteDataTypeCookies ])

    private static var dataStore: WKWebsiteDataStore {
        return WKWebsiteDataStore.default()
    }
    
    /**
     Clears the cache of all external (non-duckduckgo) data
     */
    public static func clear() {
        dataStore.fetchDataRecords(ofTypes: allData) { records in
            clearExternalRecords(records)
            clearDDGRecord(records)
        }
    }
    
    private static func clearDDGRecord(_ records: [WKWebsiteDataRecord]) {
        guard let record = records.first(where: { $0.displayName == Constants.internalCache }) else {
            Logger.log(text: "DDG cache not found")
            return
        }
        
        dataStore.removeData(ofTypes: ddgData, for: [record]) {
            Logger.log(text: "DDG cache cleared")
        }
    }
    
    private static func clearExternalRecords(_ records: [WKWebsiteDataRecord]) {
        let externalRecords = records.filter { $0.displayName != Constants.internalCache }
        dataStore.removeData(ofTypes: allData, for: externalRecords) {
            Logger.log(text: "External cache cleared")
        }
    }
}
