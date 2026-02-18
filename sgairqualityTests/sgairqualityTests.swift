//
//  sgairqualityTests.swift
//  sgairqualityTests
//
//  Created by Stuart Breckenridge on 18/02/2026.
//

import Testing
@testable import sgairquality

struct sgairqualityTests {

    @Test func apiKeyExists() async throws {
        let key = await Configuration.apiKey
        #expect(key != nil)
    }

}
