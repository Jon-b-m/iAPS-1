//
//  AcknowledgeAlertsTests.swift
//  OmniKitTests
//
//  Created by Eelke Jager on 18/09/2018.
//  Copyright © 2018 Pete Schwamb. All rights reserved.
//
import Foundation

@testable import OmniKit
import XCTest

class AcknowledgeAlertsTests: XCTestCase {
    func testAcknowledgeLowReservoirAlert() {
        // 11 05 2f9b5b2f 10
        do {
            // Encode
            let encoded = AcknowledgeAlertCommand(nonce: 0x2F9B_5B2F, alerts: AlertSet(rawValue: 0x10))
            XCTAssertEqual("11052f9b5b2f10", encoded.data.hexadecimalString)

            // Decode
            let cmd = try AcknowledgeAlertCommand(encodedData: Data(hexadecimalString: "11052f9b5b2f10")!)
            XCTAssertEqual(.acknowledgeAlert, cmd.blockType)
            XCTAssertEqual(0x2F9B_5B2F, cmd.nonce)
            XCTAssert(cmd.alerts.contains(.slot4LowReservoir))
        } catch {
            XCTFail("message decoding threw error: \(error)")
        }
    }
}
