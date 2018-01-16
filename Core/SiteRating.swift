//
//  SiteRating.swift
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

public class SiteRating {
    
    public let protectionId: String
    public var url: URL
    
    public var hasOnlySecureContent: Bool = true {
        didSet {
            let cache = SiteRatingCache.shared
            if let cacheEntry = cache.get(url: url) {
                cache.update(url: url, with: cacheEntry.copy(hasOnlySecureContent: hasOnlySecureContent))
            }
            recalculateGrade()
        }
    }
    
    public var domain: String? {
        return url.host
    }
    public var finishedLoading = false
    public private (set) var trackersDetected = [DetectedTracker: Int]()
    public private (set) var trackersBlocked = [DetectedTracker: Int]()
    
    public private (set) var beforeGrade: SiteGrade = SiteGrade.a
    public private (set) var afterGrade: SiteGrade = SiteGrade.a

    private let termsOfServiceStore: TermsOfServiceStore
    let disconnectMeTrackers: [String: DisconnectMeTracker]
    let majorTrackerNetworkStore: MajorTrackerNetworkStore
    
    public init(url: URL, disconnectMeTrackers: [String: DisconnectMeTracker] = DisconnectMeStore().trackers, termsOfServiceStore: TermsOfServiceStore = EmbeddedTermsOfServiceStore(), majorTrackerNetworkStore: MajorTrackerNetworkStore = EmbeddedMajorTrackerNetworkStore()) {
        
        self.protectionId = UUID.init().uuidString
        self.url = url
        self.disconnectMeTrackers = disconnectMeTrackers
        self.termsOfServiceStore = termsOfServiceStore
        self.majorTrackerNetworkStore = majorTrackerNetworkStore
        self.hasOnlySecureContent = url.isHttps()
        
        let cache = SiteRatingCache.shared
        
        if let entry = cache.get(url: url) {
            afterGrade = SiteGrade.grade(fromScore: siteScore().after)
            beforeGrade = SiteGrade.grade(fromScore: entry.score)
        } else {
            recalculateGrade()
        }
    }
    
    public var https: Bool {
        return url.isHttps()
    }

    public var uniqueMajorTrackerNetworksDetected: Int {
        return uniqueMajorTrackerNetworks(trackers: trackersDetected)
    }

    public var uniqueMajorTrackerNetworksBlocked: Int {
        return uniqueMajorTrackerNetworks(trackers: trackersBlocked)
    }

    public var uniqueTrackerNetworksDetected: Int {
        return uniqueTrackerNetworks(trackers: trackersDetected)
    }

    public var uniqueTrackerNetworksBlocked: Int {
        return uniqueTrackerNetworks(trackers: trackersBlocked)
    }

    public var containsMajorTracker: Bool {
        return majorNetworkTrackersDetected.count > 0
    }

    public var containsIpTracker: Bool {
        return trackersDetected.contains(where: { $0.key.isIpTracker } )
    }
    
    public var termsOfService: TermsOfService? {
        guard let domain = self.domain else { return nil }
        if let tos = termsOfServiceStore.terms.first( where: { domain.hasSuffix($0.0) } )?.value {
            return tos
        }

        // if not TOS found for this site use the parent's (e.g. google.co.uk should use google.com)
        let storeDomain = associatedDomain(for: domain) ?? domain
        return termsOfServiceStore.terms.first( where: { storeDomain.hasSuffix($0.0) } )?.value
    }

    public func trackerDetected(_ tracker: DetectedTracker) {
        let detectedCount = trackersDetected[tracker] ?? 0
        trackersDetected[tracker] = detectedCount + 1
        
        if tracker.blocked {
            let blockCount = trackersBlocked[tracker] ?? 0
            trackersBlocked[tracker] = blockCount + 1
        }
        
        recalculateGrade()
    }
    
    public var uniqueTrackersDetected: Int {
        return trackersDetected.count
    }
    
    public var uniqueTrackersBlocked: Int {
        return trackersBlocked.count
    }
    
    public var totalTrackersDetected: Int {
        return trackersDetected.reduce(0) { $0 + $1.value }
    }
    
    public var totalTrackersBlocked: Int {
        return trackersBlocked.reduce(0) { $0 + $1.value }
    }

    public var majorNetworkTrackersDetected: [DetectedTracker: Int] {
        return trackersDetected.filter({ majorTrackerNetworkStore.network(forName: $0.key.networkName ?? "" ) != nil })
    }

    public var majorNetworkTrackersBlocked: [DetectedTracker: Int] {
        return trackersBlocked.filter({ majorTrackerNetworkStore.network(forName: $0.key.networkName ?? "" ) != nil })
    }

    public func associatedDomain(for domain: String) -> String? {
        let tracker = disconnectMeTrackers.first( where: { domain.hasSuffix($0.value.url) })?.value
        return tracker?.parentUrl?.host
    }

    private func uniqueMajorTrackerNetworks(trackers: [DetectedTracker: Int]) -> Int {
        return Set(trackers.keys.filter({ majorTrackerNetworkStore.network(forName: $0.networkName ?? "" ) != nil }).flatMap({ $0.networkName })).count
    }

    private func uniqueTrackerNetworks(trackers: [DetectedTracker: Int]) -> Int {
        return Set(trackers.keys.flatMap({ $0.networkName ?? $0.domain })).count
    }

    private func siteScore() -> ( before: Int, after: Int ) {
        
        var beforeScore = 1
        var afterScore = 1
        
        beforeScore += isMajorTrackerScore
        afterScore += isMajorTrackerScore
        
        if let tos = termsOfService {
            beforeScore += tos.derivedScore
            afterScore += tos.derivedScore
        }
        
        beforeScore += hasTrackerInMajorNetworkScore
        
        if !https || !hasOnlySecureContent {
            beforeScore += 1
            afterScore += 1
        }
        
        beforeScore += ipTrackerScore
        
        beforeScore += Int(ceil(Double(totalTrackersDetected) / 10))
        
        return ( beforeScore, afterScore )
    }
    
    private func recalculateGrade() {
        let score = siteScore()
        
        let entry = SiteRatingCache.CacheEntry(score: score.before,
                                               uniqueTrackerNetworksDetected: uniqueTrackerNetworksDetected,
                                               uniqueTrackerNetworksBlocked: uniqueTrackerNetworksBlocked,
                                               uniqueMajorTrackerNetworksDetected: uniqueMajorTrackerNetworksDetected,
                                               uniqueMajorTrackerNetworksBlocked: uniqueMajorTrackerNetworksDetected,
                                               hasOnlySecureContent: hasOnlySecureContent)
        
        _ = SiteRatingCache.shared.add(url: url, entry: entry)
        
        afterGrade = SiteGrade.grade(fromScore: score.after)
        beforeGrade = SiteGrade.grade(fromScore: score.before)
    }
    
    private func siteGrade() -> ( before: SiteGrade, after: SiteGrade ) {
        let score = siteScore()
        return ( SiteGrade.grade(fromScore: score.before), SiteGrade.grade(fromScore: score.after ))
    }
    
    private var httpsScore: Int {
        return https ? -1 : 0
    }
    
    private var hasTrackerInMajorNetworkScore: Int {
        return trackersDetected.keys.first(where: { $0.inMajorNetwork(disconnectMeTrackers, majorTrackerNetworkStore) }) != nil ? 1 : 0
    }
    
    private var isMajorTrackerScore: Int {
        guard let domain = domain else { return 0 }
        if let network = majorTrackerNetworkStore.network(forName: domain) { return network.score }
        if let network = majorTrackerNetworkStore.network(forDomain: domain) { return network.score }
        return 0
    }
    
    public var isMajorTrackerNetwork: Bool {
        return isMajorTrackerScore > 0
    }
    
    private var ipTrackerScore: Int {
        return containsIpTracker ? 1 : 0
    }
    
    public var termsOfServiceScore: Int {
        guard let termsOfService = termsOfService else {
            return 0
        }
        
        return termsOfService.derivedScore
    }
    
    public var scoreDict: [String : Any] {
        let grade = siteGrade()
        return [
            "score": [
                "domain": domain ?? "unknown",
                "hasHttps": https,
                "isAMajorTrackingNetwork": isMajorTrackerScore,
                "containsMajorTrackingNetwork": containsMajorTracker,
                "totalBlocked": totalTrackersBlocked,
                "hasObscureTracker": containsIpTracker,
                "tosdr": termsOfServiceScore
            ],
            "grade": [
                "before": grade.before.rawValue.uppercased(),
                "after": grade.after.rawValue.uppercased()
            ]
        ]
    }
    
    public var scoreDescription: String {
        let json = try! JSONSerialization.data(withJSONObject: scoreDict, options: .prettyPrinted)
        return String(data: json, encoding: .utf8)!
    }
    
    public func networkNameAndCategory(forDomain domain: String) -> ( networkName: String?, category: String? ) {
        let lowercasedDomain = domain.lowercased()
        if let tracker = disconnectMeTrackers.first(where: { lowercasedDomain == $0.key || lowercasedDomain.hasSuffix(".\($0.key)") } )?.value {
            return ( tracker.networkName, tracker.category?.rawValue )
        }
        
        if let majorNetwork = majorTrackerNetworkStore.network(forDomain: lowercasedDomain) {
            return ( majorNetwork.name, nil )
        }
        
        return ( nil, nil )
    }

    
    
}

fileprivate extension DetectedTracker {
    
    func inMajorNetwork(_ disconnectMeTrackers: [String: DisconnectMeTracker], _ majorTrackerNetworkStore: MajorTrackerNetworkStore) -> Bool {
        guard let domain = domain else { return false }
        guard let networkName = disconnectMeTrackers.first(where: { domain.hasSuffix($0.key) })?.value.networkName else { return false }
        return majorTrackerNetworkStore.network(forName: networkName) != nil
    }
    
}

