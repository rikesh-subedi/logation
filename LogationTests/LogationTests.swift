//
//  LogationTests.swift
//  LogationTests
//
//  Created by Subedi, Rikesh on 10/03/21.
//

import XCTest
@testable import Logation

class LogationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLogEntryLowAccuracyLevel() throws {
        let logentry = LogEntry(lat: 0, long: 12, time: 12345, extras: "")
        let payload = logentry.convertToPayload(level: .low)
        assert(payload["lat"] as! Double == 0)
        assert(payload["long"] as! Double == 0)
    }

    func testLogEntryHighAccuracyLevel() throws {
        let logentry = LogEntry(lat: 0.5, long: 12, time: 12345, extras: "")
        let payload = logentry.convertToPayload(level: .high)
        assert(payload["lat"] as! Double == 0.5)
        assert(payload["long"] as! Double == 12)
    }

    func testLogCallback() throws {
       let logger = Logger(url: "")
        let expectation = self.expectation(description: "callback should be called")
        logger.log(lat: 10, long: 10) {_ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        assert(true)
    }


}
