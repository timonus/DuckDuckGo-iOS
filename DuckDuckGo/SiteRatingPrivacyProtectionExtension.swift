//
//  SiteRatingPrivacyProtectionExtension.swift
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
import Core

extension SiteRating {

    static let practicesText: [TermsOfService.PrivacyPractices: String] = [
        .unknown: UserText.privacyProtectionTOSUnknown,
        .good: UserText.privacyProtectionTOSGood,
        .mixed: UserText.privacyProtectionTOSMixed,
        .poor: UserText.privacyProtectionTOSPoor
    ]

    private var cacheEntry: SiteRatingCache.CacheEntry? {
        return SiteRatingCache.shared.get(url: url)
    }
    
    func encryptedConnectionText() -> String {
        if !https {
            return UserText.privacyProtectionEncryptionBadConnection
        } else if let hasOnlySecureContent = cacheEntry?.hasOnlySecureContent, !hasOnlySecureContent {
            return UserText.privacyProtectionEncryptionMixedConnection
        } else {
            return UserText.privacyProtectionEncryptionGoodConnection
        }
    }

    func encryptedConnectionSuccess() -> Bool {
        return https && hasOnlySecureContent
    }

    func privacyPracticesText() -> String? {
        return SiteRating.practicesText[privacyPractices()]
    }

    func privacyPractices() -> TermsOfService.PrivacyPractices {
        guard let termsOfService = termsOfService else { return .unknown }
        return termsOfService.privacyPractices()
    }

    func majorNetworksText(contentBlocker: ContentBlockerConfigurationStore) -> String {
        return protecting(contentBlocker) ? majorNetworksBlockedText() : majorNetworksDetectedText()
    }

    func majorNetworksSuccess(contentBlocker: ContentBlockerConfigurationStore) -> Bool {
        return (protecting(contentBlocker) ? cacheEntry?.uniqueMajorTrackerNetworksBlocked ?? 0 : cacheEntry?.uniqueMajorTrackerNetworksDetected ?? 0) <= 0
    }

    func majorNetworksBlockedText() -> String {
        return String(format: UserText.privacyProtectionMajorTrackersBlocked, cacheEntry?.uniqueMajorTrackerNetworksBlocked ?? 0)
    }

    func majorNetworksDetectedText() -> String {
        return String(format: UserText.privacyProtectionMajorTrackersFound, cacheEntry?.uniqueMajorTrackerNetworksDetected ?? 0)
    }

    func networksText(contentBlocker: ContentBlockerConfigurationStore) -> String {
        return protecting(contentBlocker) ? networksBlockedText() : networksDetectedText()
    }

    func networksSuccess(contentBlocker: ContentBlockerConfigurationStore) -> Bool {
        return (protecting(contentBlocker) ? cacheEntry?.uniqueTrackerNetworksBlocked ?? 0 : cacheEntry?.uniqueTrackerNetworksDetected ?? 0) <= 0
    }

    func networksBlockedText() -> String {
        return String(format: UserText.privacyProtectionTrackersBlocked, cacheEntry?.uniqueTrackerNetworksBlocked ?? 0)
    }

    func networksDetectedText() -> String {
        return String(format: UserText.privacyProtectionTrackersFound, cacheEntry?.uniqueTrackerNetworksDetected ?? 0)
    }

    func protecting(_ contentBlocker: ContentBlockerConfigurationStore) -> Bool {
        guard let domain = domain else { return contentBlocker.enabled }
        return contentBlocker.enabled && !contentBlocker.domainWhitelist.contains(domain)
    }

    static let gradeImages: [SiteGrade: UIImage] = [
        .a: #imageLiteral(resourceName: "PP Inline A"),
        .b: #imageLiteral(resourceName: "PP Inline B"),
        .c: #imageLiteral(resourceName: "PP Inline C"),
        .d: #imageLiteral(resourceName: "PP Inline D")
    ]

    func siteGradeImages() -> (from: UIImage, to: UIImage) {
        
        return (SiteRating.gradeImages[beforeGrade]!, SiteRating.gradeImages[afterGrade]!)
    }

}
