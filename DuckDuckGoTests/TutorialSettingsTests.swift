//
//  TutorialSettingsTests.swift
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

@testable import DuckDuckGo

class TutorialSettingsTests: XCTestCase {

    static let testSuiteName = "com.duckduckgo.tutorials.tests"

    private var testee: TutorialSettings!

    override func setUp() {
        let userDefaults = UserDefaults(suiteName: TutorialSettingsTests.testSuiteName)!
        userDefaults.removePersistentDomain(forName: TutorialSettingsTests.testSuiteName)
        testee = TutorialSettings(userDefaults: userDefaults)
    }

    func testWhenOnboardingHasBeenSeenAnd3DaysHavePassedAndPrivacyGradeHasBeenSeenThenPrivacyGradeTutorialShouldNotBeSeen() {
        testee.hasSeenOnboarding = true
        testee.hasSeenPrivacyGradeTutorial = true
        let date = Date(timeIntervalSinceNow: 60 * 60 * 24 * 3)
        XCTAssertFalse(testee.shouldSeePrivacyGradeTutorial(date: date))
    }

    func testWhenOnboardingHasBeenSeenAnd3DaysHavePassedAndPrivacyGradeHasBeenUsedThenPrivacyGradeTutorialShouldNotBeSeen() {
        testee.hasSeenOnboarding = true
        testee.privacyGradeUsageCount += 1
        let date = Date(timeIntervalSinceNow: 60 * 60 * 24 * 3)
        XCTAssertFalse(testee.shouldSeePrivacyGradeTutorial(date: date))
    }

    func testWhenOnboardingHasBeenSeenAnd3DaysHavePassedAndPrivacyGradeHasntBeenUsedThenPrivacyGradeTutorialShouldBeSeen() {
        testee.hasSeenOnboarding = true
        let date = Date(timeIntervalSinceNow: 60 * 60 * 24 * 3)
        XCTAssertTrue(testee.shouldSeePrivacyGradeTutorial(date: date))
    }

    func testWhenOnboardingHasBeenSeenAnd2DaysHavePassedAndPrivacyGradeHasntBeenUsedThenPrivacyGradeTutorialShouldBeNotSeen() {
        testee.hasSeenOnboarding = true
        let date = Date(timeIntervalSinceNow: 60 * 60 * 24 * 2)
        XCTAssertFalse(testee.shouldSeePrivacyGradeTutorial(date: date))
    }

    func testWhenOnboardingHasBeenSeenAnd0DaysHavePassedAndPrivacyGradeHasntBeenUsedThenPrivacyGradeTutorialShouldBeNotSeen() {
        testee.hasSeenOnboarding = true
        XCTAssertFalse(testee.shouldSeePrivacyGradeTutorial())
    }

    func testWhenOnboardingHasNotBeenSeenPrivacyGradeTutorialShouldNotBeSeen() {
        XCTAssertFalse(testee.shouldSeePrivacyGradeTutorial())
    }

    func testWhenOnboardingHasBeenSeenAnd3DaysHavePassedAndFireButtonTutorialHasBeenSeenThenFireButtonTutorialShouldNotBeSeen() {
        testee.hasSeenOnboarding = true
        testee.hasSeenFireButtonTutorial = true
        let date = Date(timeIntervalSinceNow: 60 * 60 * 24 * 3)
        XCTAssertFalse(testee.shouldSeeFireButtonTutorial(date: date))
    }

    func testWhenOnboardingHasBeenSeenAnd3DaysHavePassedAndFireButtonHasBeenBeenUsedThenFireButtonTutorialShouldNotBeSeen() {
        testee.hasSeenOnboarding = true
        testee.fireButtonUsageCount += 1
        let date = Date(timeIntervalSinceNow: 60 * 60 * 24 * 3)
        XCTAssertFalse(testee.shouldSeeFireButtonTutorial(date: date))
    }

    func testWhenOnboardingHasBeenSeenAnd3DaysHavePassedAndFireButtonHasntBeenNotBeenUsedThenFireButtonTutorialShouldBeSeen() {
        testee.hasSeenOnboarding = true
        let date = Date(timeIntervalSinceNow: 60 * 60 * 24 * 3)
        XCTAssertTrue(testee.shouldSeeFireButtonTutorial(date: date))
    }

    func testWhenOnboardingHasBeenSeenAnd2DaysHavePassedAndFireButtonHasntBeenNotBeenUsedThenFireButtonTutorialShouldNotBeSeen() {
        testee.hasSeenOnboarding = true
        let date = Date(timeIntervalSinceNow: 60 * 60 * 24 * 2)
        XCTAssertFalse(testee.shouldSeeFireButtonTutorial(date: date))
    }

    func testWhenOnboardingHasBeenSeenAnd0DaysHavePassedAndFireButtonHasntBeenUsedThenFireButtonTutorialShouldBeNotSeen() {
        testee.hasSeenOnboarding = true
        testee.fireButtonUsageCount += 1
        XCTAssertFalse(testee.shouldSeeFireButtonTutorial())
    }

    func testWhenOnboardingHasNotBeenSeenFireTutorialShouldNotBeSeen() {
        XCTAssertFalse(testee.shouldSeeFireButtonTutorial())
    }

    func testWhenOnboardingHasBeenSeenItHasBeenSeen() {
        testee.hasSeenOnboarding = true
        XCTAssertTrue(testee.hasSeenOnboarding)
    }

    func testWhenNewOnboardingHasNotBeenSeen() {
        XCTAssertFalse(testee.hasSeenOnboarding)
    }

}
