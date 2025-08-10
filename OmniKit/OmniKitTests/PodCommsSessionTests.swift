import Foundation

@testable import OmniKit
import XCTest

class PodCommsSessionTests: XCTestCase {
    let address: UInt32 = 521_580_830
    var podState: PodState!
    var mockTransport: MockMessageTransport!
    var lastPodStateUpdate: PodState?

    override func setUp() {
        podState = PodState(
            address: address,
            pmVersion: "2.7.0",
            piVersion: "2.7.0",
            lot: 43620,
            tid: 560_313,
            insulinType: .novolog,
            initialDeliveryStatus: .scheduledBasal
        )
        mockTransport = MockMessageTransport(address: podState.address, messageNumber: 5)
    }

    func testNonceResync() {
        // From https://raw.githubusercontent.com/wiki/openaps/openomni/Full-life-of-a-pod-(omni-flo).md

        // 2018-05-25T13:03:51.765792 pod Message(ffffffff seq:01 [OmniKitPacketParser.VersionResponse(blockType: OmniKitPacketParser.MessageBlockType.versionResponse, lot: 43620, tid: 560313, address: Optional(521580830), pmVersion: 2.7.0, piVersion: 2.7.0, data: 23 bytes)])

        do {
            // 2018-05-26T09:11:08.580347 pod Message(1f16b11e seq:06 [OmniKitPacketParser.ErrorResponse(blockType: OmniKitPacketParser.MessageBlockType.errorResponse, errorReponseType: OmniKitPacketParser.ErrorResponse.ErrorReponseType.badNonce, nonceSearchKey: 43492, data: 5 bytes)])
            mockTransport.addResponse(try ErrorResponse(encodedData: Data(hexadecimalString: "060314a9e403f5")!))
            mockTransport.addResponse(try StatusResponse(encodedData: Data(hexadecimalString: "1d5800d1a8140012e3ff8018")!))
            // These responses are for session.bolus() which verifies that the pod is not bolusing before sending a bolus command
            mockTransport
                .addResponse(try StatusResponse(encodedData: Data(hexadecimalString: "1d180160a800001cd3ff001e")!)) // not bolusing
            mockTransport
                .addResponse(try StatusResponse(encodedData: Data(hexadecimalString: "1d580160e014001cd7ff81ce")!)) // bolus successfully started
        } catch {
            XCTFail("message decoding threw error: \(error)")
            return
        }

        let session = PodCommsSession(podState: podState, transport: mockTransport, delegate: self)

        // 2018-05-26T09:11:07.984983 pdm Message(1f16b11e seq:05 [SetInsulinScheduleCommand(nonce:2232447658, bolus(units: 1.0, timeBetweenPulses: 2.0)), OmniKitPacketParser.BolusExtraCommand(blockType: OmniKitPacketParser.MessageBlockType.bolusExtra, completionBeep: false, programReminderInterval: 0.0, units: 1.0, timeBetweenPulses: 2.0, extendedUnits: 0.0, extendedDuration: 0.0)])
        let sentCommand = SetInsulinScheduleCommand(nonce: 2_232_447_658, units: 1.0)

        do {
            let status: StatusResponse = try session.send([sentCommand])

            XCTAssertEqual(2, mockTransport.sentMessages.count)

            let bolusTry1 = mockTransport.sentMessages[0].messageBlocks[0] as! SetInsulinScheduleCommand
            XCTAssertEqual(2_232_447_658, bolusTry1.nonce)

            let bolusTry2 = mockTransport.sentMessages[1].messageBlocks[0] as! SetInsulinScheduleCommand
            XCTAssertEqual(1_521_036_535, bolusTry2.nonce)

            XCTAssert(status.deliveryStatus.bolusing)
        } catch {
            XCTFail("message sending error: \(error)")
        }

        // Try sending another bolus command: nonce should be 545302454
        XCTAssertEqual(545_302_454, lastPodStateUpdate!.currentNonce)

        _ = session.bolus(units: 2, automatic: false)
        let lastSentMessageIndex = mockTransport.sentMessages.endIndex - 1
        let bolusTry3 = mockTransport.sentMessages[lastSentMessageIndex].messageBlocks[0] as! SetInsulinScheduleCommand
        XCTAssertEqual(545_302_454, bolusTry3.nonce)
    }

    func testUnacknowledgedBolus() {
        let session = PodCommsSession(podState: podState, transport: mockTransport, delegate: self)

        mockTransport.throwSendMessageError = PodCommsError.unacknowledgedMessage(
            sequenceNumber: 5,
            error: PodCommsError.noResponse
        )

        _ = session.bolus(units: 3)

        XCTAssertNotNil(lastPodStateUpdate?.unacknowledgedCommand)
    }

    func testBolusFinishedEarlyOnPodIsMarkedNonMutable() {
        let mockStart = Date()
        podState.unfinalizedBolus = UnfinalizedDose(
            bolusAmount: 4.45,
            startTime: mockStart,
            scheduledCertainty: .certain,
            insulinType: .novolog
        )
        let session = PodCommsSession(podState: podState, transport: mockTransport, delegate: self)

        // Simulate a status request a bit before the bolus is expected to finish
        let statusRequestTime = podState.unfinalizedBolus!.finishTime!.addingTimeInterval(-5)
        session.mockCurrentDate = statusRequestTime

        let statusResponse = StatusResponse(
            deliveryStatus: .scheduledBasal,
            podProgressStatus: .aboveFiftyUnits,
            timeActive: .minutes(10),
            reservoirLevel: Pod.reservoirLevelAboveThresholdMagicNumber,
            insulinDelivered: 25,
            bolusNotDelivered: 0,
            lastProgrammingMessageSeqNum: 5,
            alerts: AlertSet(slots: [])
        )

        mockTransport.addResponse(statusResponse)

        _ = try! session.getStatus()

        XCTAssertEqual(1, lastPodStateUpdate!.finalizedDoses.count)

        let finalizedBolus = lastPodStateUpdate!.finalizedDoses[0]

        XCTAssertTrue(finalizedBolus.isFinished(at: statusRequestTime))
        XCTAssertFalse(finalizedBolus.isMutable(at: statusRequestTime))
    }

    func testSuccessfulBolus() {
        let session = PodCommsSession(podState: podState, transport: mockTransport, delegate: self)

        let statusResponse = StatusResponse(
            deliveryStatus: .bolusInProgress,
            podProgressStatus: .aboveFiftyUnits,
            timeActive: .minutes(10),
            reservoirLevel: Pod.reservoirLevelAboveThresholdMagicNumber,
            insulinDelivered: 25,
            bolusNotDelivered: 0,
            lastProgrammingMessageSeqNum: 5,
            alerts: AlertSet(slots: [])
        )

        mockTransport.addResponse(statusResponse)

        _ = session.bolus(units: 3)

        XCTAssertNil(lastPodStateUpdate?.unacknowledgedCommand)
        XCTAssertNotNil(lastPodStateUpdate?.unfinalizedBolus)
    }
}

extension PodCommsSessionTests: PodCommsSessionDelegate {
    func podCommsSession(_: PodCommsSession, didChange state: PodState) {
        lastPodStateUpdate = state
    }
}

class MockMessageTransport: MessageTransport {
    var delegate: MessageTransportDelegate?

    var messageNumber: Int

    var responseMessageBlocks = [MessageBlock]()
    public var sentMessages = [Message]()

    var throwSendMessageError: Error?

    var address: UInt32

    var sentMessageHandler: ((Message) -> Void)?

    init(address: UInt32, messageNumber: Int) {
        self.address = address
        self.messageNumber = messageNumber
    }

    func sendMessage(_ message: Message) throws -> Message {
        sentMessages.append(message)

        if let error = throwSendMessageError {
            throw error
        }

        if responseMessageBlocks.isEmpty {
            throw PodCommsError.noResponse
        }
        return Message(address: address, messageBlocks: [responseMessageBlocks.removeFirst()], sequenceNum: messageNumber)
    }

    func addResponse(_ messageBlock: MessageBlock) {
        responseMessageBlocks.append(messageBlock)
    }

    func assertOnSessionQueue() {
        // Do nothing in tests
    }
}
