public enum MySentryAlertType: UInt8 {
    case noDelivery = 0x04
    case maxHourlyBolus = 0x33
    case lowReservoir = 0x52
    case highGlucose = 0x65
    case lowGlucose = 0x66
    case meterBGNow = 0x68
    case meterBGSoon = 0x69
    case calibrationError = 0x6A
    case sensorEnd = 0x6B
    case weakSignal = 0x70
    case lostSensor = 0x71
    case highPredicted = 0x72
    case lowPredicted = 0x73
}
