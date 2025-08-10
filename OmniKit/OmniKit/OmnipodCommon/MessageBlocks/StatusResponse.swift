import Foundation

public struct StatusResponse: MessageBlock {
    public let blockType: MessageBlockType = .statusResponse
    public let length: UInt8 = 10
    public let deliveryStatus: DeliveryStatus
    public let podProgressStatus: PodProgressStatus
    public let timeActive: TimeInterval
    public let reservoirLevel: Double
    public let insulinDelivered: Double
    public let bolusNotDelivered: Double
    public let lastProgrammingMessageSeqNum: UInt8 // updated by pod for 03, 08, $11, $19, $1A, $1C, $1E & $1F command messages
    public let alerts: AlertSet

    public let data: Data

    public init(encodedData: Data) throws {
        if encodedData.count < length {
            throw MessageBlockError.notEnoughData
        }

        data = encodedData.prefix(upTo: Int(length))

        guard let deliveryStatus = DeliveryStatus(rawValue: encodedData[1] >> 4) else {
            throw MessageError.unknownValue(value: encodedData[1] >> 4, typeDescription: "DeliveryStatus")
        }
        self.deliveryStatus = deliveryStatus

        guard let podProgressStatus = PodProgressStatus(rawValue: encodedData[1] & 0xF) else {
            throw MessageError.unknownValue(value: encodedData[1] & 0xF, typeDescription: "PodProgressStatus")
        }
        self.podProgressStatus = podProgressStatus

        let minutes = ((Int(encodedData[7]) & 0x7F) << 6) + (Int(encodedData[8]) >> 2)
        timeActive = TimeInterval(minutes: Double(minutes))

        let highInsulinBits = Int(encodedData[2] & 0xF) << 9
        let midInsulinBits = Int(encodedData[3]) << 1
        let lowInsulinBits = Int(encodedData[4] >> 7)
        insulinDelivered = Double(highInsulinBits | midInsulinBits | lowInsulinBits) / Pod.pulsesPerUnit

        lastProgrammingMessageSeqNum = (encodedData[4] >> 3) & 0xF

        bolusNotDelivered = Double((Int(encodedData[4] & 0x3) << 8) | Int(encodedData[5])) / Pod.pulsesPerUnit

        alerts = AlertSet(rawValue: ((encodedData[6] & 0x7F) << 1) | (encodedData[7] >> 7))

        reservoirLevel = Double((Int(encodedData[8] & 0x3) << 8) + Int(encodedData[9])) / Pod.pulsesPerUnit
    }

    public init(
        deliveryStatus: DeliveryStatus,
        podProgressStatus: PodProgressStatus,
        timeActive: TimeInterval,
        reservoirLevel: Double,
        insulinDelivered: Double,
        bolusNotDelivered: Double,
        lastProgrammingMessageSeqNum: UInt8,
        alerts: AlertSet
    )
    {
        self.deliveryStatus = deliveryStatus
        self.podProgressStatus = podProgressStatus
        self.timeActive = timeActive
        self.reservoirLevel = reservoirLevel
        self.insulinDelivered = insulinDelivered
        self.bolusNotDelivered = bolusNotDelivered
        self.lastProgrammingMessageSeqNum = lastProgrammingMessageSeqNum
        self.alerts = alerts
        data = Data()
    }

    // convenience function to create a StatusResponse for a DetailedStatus
    public init(detailedStatus: DetailedStatus) {
        deliveryStatus = detailedStatus.deliveryStatus
        podProgressStatus = detailedStatus.podProgressStatus
        timeActive = detailedStatus.timeActive
        reservoirLevel = detailedStatus.reservoirLevel
        insulinDelivered = detailedStatus.totalInsulinDelivered
        bolusNotDelivered = detailedStatus.bolusNotDelivered
        lastProgrammingMessageSeqNum = detailedStatus.lastProgrammingMessageSeqNum
        alerts = detailedStatus.unacknowledgedAlerts
        data = Data()
    }
}

extension StatusResponse: CustomDebugStringConvertible {
    public var debugDescription: String {
        "StatusResponse(deliveryStatus:\(deliveryStatus.description), progressStatus:\(podProgressStatus), timeActive:\(timeActive.timeIntervalStr), reservoirLevel:\(reservoirLevel == Pod.reservoirLevelAboveThresholdMagicNumber ? "50+" : reservoirLevel.twoDecimals), insulinDelivered:\(insulinDelivered.twoDecimals), bolusNotDelivered:\(bolusNotDelivered.twoDecimals), lastProgrammingMessageSeqNum:\(lastProgrammingMessageSeqNum), alerts:\(alerts))"
    }
}
