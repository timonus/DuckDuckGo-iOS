//
//  TutorialSettings.swift
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

struct TutorialSettings {
    
    private struct Keys {
        static let suiteName = "com.duckduckgo.tutorials"

        // Set the build number of the last build that didn't force them to appear to force them to appear.
        static let lastBuildWithoutForcePop = 1
        static let onboardingSeenDate = "com.duckduckgo.tutorials.onboarding.seen.\(lastBuildWithoutForcePop)"
        static let fireButtonUsageCount = "com.duckduckgo.tutorials.firebutton.used.\(lastBuildWithoutForcePop)"
        static let privacyGradeUsageCount = "com.duckduckgo.tutorials.privacygrade.used.\(lastBuildWithoutForcePop)"
        static let fireButtonTutorialSeenDate = "com.duckduckgo.tutorials.firebutton.seen.\(lastBuildWithoutForcePop)"
        static let privacyGradeTutorialSeenDate = "com.duckduckgo.tutorials.privacygrade.seen.\(lastBuildWithoutForcePop)"
    }

    var userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults(suiteName: Keys.suiteName)!) {
        self.userDefaults = userDefaults
    }

    public var hasSeenOnboarding: Bool {
        get {
            return userDefaults.double(forKey: Keys.onboardingSeenDate) > 0
        }
        set(newValue) {
            if newValue {
                userDefaults.set(Date().timeIntervalSince1970, forKey: Keys.onboardingSeenDate)
            } else {
                userDefaults.removeObject(forKey: Keys.onboardingSeenDate)
            }
        }
    }

    public var hasSeenPrivacyGradeTutorial: Bool {
        get {
            return userDefaults.double(forKey: Keys.privacyGradeTutorialSeenDate) > 0
        }
        set(newValue) {
            if newValue {
                userDefaults.set(Date().timeIntervalSince1970, forKey: Keys.privacyGradeTutorialSeenDate)
            } else {
                userDefaults.removeObject(forKey: Keys.privacyGradeTutorialSeenDate)
            }
        }
    }

    public var hasSeenFireButtonTutorial: Bool {
        get {
            return userDefaults.double(forKey: Keys.fireButtonTutorialSeenDate) > 0
        }
        set(newValue) {
            if newValue {
                userDefaults.set(Date().timeIntervalSince1970, forKey: Keys.fireButtonTutorialSeenDate)
            } else {
                userDefaults.removeObject(forKey: Keys.fireButtonTutorialSeenDate)
            }
        }
    }

    public func shouldSeePrivacyGradeTutorial(date: Date = Date()) -> Bool {
        guard hasSeenOnboarding else { return false }
        guard privacyGradeUsageCount == 0 else { return false }
        guard !hasSeenPrivacyGradeTutorial else { return false }
        let onboardingSeen = userDefaults.double(forKey: Keys.onboardingSeenDate)
        return date.timeIntervalSince(Date(timeIntervalSince1970: onboardingSeen)) / 60 / 60 / 24 > 3
    }

    public func shouldSeeFireButtonTutorial(date: Date = Date()) -> Bool {
        guard hasSeenOnboarding else { return false }
        guard fireButtonUsageCount == 0 else { return false }
        guard !hasSeenFireButtonTutorial else { return false }
        let onboardingSeen = userDefaults.double(forKey: Keys.onboardingSeenDate)
        return date.timeIntervalSince(Date(timeIntervalSince1970: onboardingSeen)) / 60 / 60 / 24 > 3
    }

    public var fireButtonUsageCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.fireButtonUsageCount)
        }

        set {
            userDefaults.set(newValue, forKey: Keys.fireButtonUsageCount)
        }
    }

    public var privacyGradeUsageCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.privacyGradeUsageCount)
        }

        set {
            userDefaults.set(newValue, forKey: Keys.privacyGradeUsageCount)
        }
    }

}
