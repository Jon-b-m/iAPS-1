public enum MessageType: UInt8 {
    case alert = 0x01
    case alertCleared = 0x02
    case deviceTest = 0x03
    case mySentryPumpStatus = 0x04
    case pumpAck = 0x06
    case pumpBackfill = 0x08
    case findDevice = 0x09
    case deviceLink = 0x0A
    case errorResponse = 0x15
    case writeGlucoseHistoryTimestamp = 0x28

    case setBasalProfileA = 0x30 // CMD_SET_A_PROFILE
    case setBasalProfileB = 0x31 // CMD_SET_B_PROFILE

    case changeTime = 0x40
    case setMaxBolus = 0x41 // CMD_SET_MAX_BOLUS
    case bolus = 0x42

    case PumpExperiment_OP67 = 0x43
    case PumpExperiment_OP68 = 0x44
    case PumpExperiment_OP69 = 0x45 // CMD_SET_VAR_BOLUS_ENABLE

    case selectBasalProfile = 0x4A

    case changeTempBasal = 0x4C
    case suspendResume = 0x4D

    case PumpExperiment_OP80 = 0x50
    case setRemoteControlID = 0x51 // CMD_SET_RF_REMOTE_ID
    case PumpExperiment_OP82 = 0x52 // CMD_SET_BLOCK_ENABLE
    case setLanguage = 0x53
    case PumpExperiment_OP84 = 0x54 // CMD_SET_ALERT_TYPE
    case PumpExperiment_OP85 = 0x55 // CMD_SET_PATTERNS_ENABLE
    case PumpExperiment_OP86 = 0x56
    case setRemoteControlEnabled = 0x57 // CMD_SET_RF_ENABLE
    case PumpExperiment_OP88 = 0x58 // CMD_SET_INSULIN_ACTION_TYPE
    case PumpExperiment_OP89 = 0x59
    case PumpExperiment_OP90 = 0x5A

    case buttonPress = 0x5B

    case PumpExperiment_OP92 = 0x5C

    case powerOn = 0x5D

    case setBolusWizardEnabled1 = 0x61
    case setBolusWizardEnabled2 = 0x62
    case setBolusWizardEnabled3 = 0x63
    case setBolusWizardEnabled4 = 0x64
    case setBolusWizardEnabled5 = 0x65
    case setAlarmClockEnable = 0x67

    case setMaxBasalRate = 0x6E // CMD_SET_MAX_BASAL
    case setBasalProfileStandard = 0x6F // CMD_SET_STD_PROFILE

    case readTime = 0x70
    case getBattery = 0x72
    case readRemainingInsulin = 0x73
    case readFirmwareVersion = 0x74
    case readErrorStatus = 0x75
    case readRemoteControlIDs = 0x76 // CMD_READ_REMOTE_CTRL_IDS

    case getHistoryPage = 0x80
    case getPumpModel = 0x8D
    case readProfileSTD512 = 0x92
    case readProfileA512 = 0x93
    case readProfileB512 = 0x94
    case readTempBasal = 0x98
    case getGlucosePage = 0x9A
    case readCurrentPageNumber = 0x9D
    case readSettings = 0xC0
    case readCurrentGlucosePage = 0xCD
    case readPumpStatus = 0xCE

    case unknown_e2 =
        0xE2 // a7594040e214190226330000000000021f99011801e00103012c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    case unknown_e6 =
        0xE6 // a7594040e60200190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    case settingsChangeCounter =
        0xEC // Body[3] increments by 1 after changing certain settings 0200af0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

    case readOtherDevicesIDs = 0xF0
    case readCaptureEventEnabled =
        0xF1 // Body[1] encodes the bool state 0101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    case changeCaptureEventEnable = 0xF2
    case readOtherDevicesStatus = 0xF3

    var decodeType: DecodableMessageBody.Type {
        switch self {
        case .alert:
            return MySentryAlertMessageBody.self
        case .alertCleared:
            return MySentryAlertClearedMessageBody.self
        case .mySentryPumpStatus:
            return MySentryPumpStatusMessageBody.self
        case .pumpAck:
            return PumpAckMessageBody.self
        case .readSettings:
            return ReadSettingsCarelinkMessageBody.self
        case .readTempBasal:
            return ReadTempBasalCarelinkMessageBody.self
        case .readTime:
            return ReadTimeCarelinkMessageBody.self
        case .findDevice:
            return FindDeviceMessageBody.self
        case .deviceLink:
            return DeviceLinkMessageBody.self
        case .buttonPress:
            return ButtonPressCarelinkMessageBody.self
        case .getPumpModel:
            return GetPumpModelCarelinkMessageBody.self
        case .readProfileSTD512:
            return DataFrameMessageBody.self
        case .readProfileA512:
            return DataFrameMessageBody.self
        case .readProfileB512:
            return DataFrameMessageBody.self
        case .getHistoryPage:
            return GetHistoryPageCarelinkMessageBody.self
        case .getBattery:
            return GetBatteryCarelinkMessageBody.self
        case .readRemainingInsulin:
            return ReadRemainingInsulinMessageBody.self
        case .readPumpStatus:
            return ReadPumpStatusMessageBody.self
        case .readCurrentGlucosePage:
            return ReadCurrentGlucosePageMessageBody.self
        case .readCurrentPageNumber:
            return ReadCurrentPageNumberMessageBody.self
        case .getGlucosePage:
            return GetGlucosePageMessageBody.self
        case .errorResponse:
            return PumpErrorMessageBody.self
        case .readOtherDevicesIDs:
            return ReadOtherDevicesIDsMessageBody.self
        case .readOtherDevicesStatus:
            return ReadOtherDevicesStatusMessageBody.self
        case .readRemoteControlIDs:
            return ReadRemoteControlIDsMessageBody.self
        case .readFirmwareVersion:
            return GetPumpFirmwareVersionMessageBody.self
        default:
            return UnknownMessageBody.self
        }
    }
}
