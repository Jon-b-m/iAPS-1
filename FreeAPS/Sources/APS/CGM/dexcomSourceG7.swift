import Combine
import Foundation
import LoopKit
import LoopKitUI

final class PluginSource: GlucoseSource {
    private let processQueue = DispatchQueue(label: "DexcomSource.processQueue")
    private let glucoseStorage: GlucoseStorage!
    var glucoseManager: FetchGlucoseManager?

    var cgmManager: CGMManagerUI?

    var cgmHasValidSensorSession: Bool = false

    private var promise: Future<[BloodGlucose], Error>.Promise?

    init(glucoseStorage: GlucoseStorage, glucoseManager: FetchGlucoseManager) {
        self.glucoseStorage = glucoseStorage
        self.glucoseManager = glucoseManager

        cgmManager = glucoseManager.cgmManager
        cgmManager?.delegateQueue = processQueue
        cgmManager?.cgmManagerDelegate = self
    }

    func fetch(_: DispatchTimer?) -> AnyPublisher<[BloodGlucose], Never> {
 @@ -61,7 +55,7 @@ final class DexcomSourceG7: GlucoseSource {
    }
}

extension PluginSource: CGMManagerDelegate {
    func deviceManager(
        _: LoopKit.DeviceManager,
        logEventForDeviceIdentifier deviceIdentifier: String?,
 @@ -93,13 +87,14 @@ extension DexcomSourceG7: CGMManagerDelegate {
    func cgmManagerWantsDeletion(_ manager: CGMManager) {
        dispatchPrecondition(condition: .onQueue(processQueue))
        debug(.deviceManager, " CGM Manager with identifier \(manager.pluginIdentifier) wants deletion")
        // TODO:
        glucoseManager?.cgmGlucoseSourceType = nil
    }

    func cgmManager(_ manager: CGMManager, hasNew readingResult: CGMReadingResult) {
        dispatchPrecondition(condition: .onQueue(processQueue))
        processCGMReadingResult(manager, readingResult: readingResult) {
            debug(.deviceManager, "CGM PLUGIN - Direct return done")
        }
    }

 @@ -115,10 +110,13 @@ extension DexcomSourceG7: CGMManagerDelegate {
        return glucoseStorage.lastGlucoseDate()
    }

    func cgmManagerDidUpdateState(_: CGMManager) {
        dispatchPrecondition(condition: .onQueue(processQueue))
    }

    func credentialStoragePrefix(for _: CGMManager) -> String {
 @@ -139,18 +137,10 @@ extension DexcomSourceG7: CGMManagerDelegate {
        readingResult: CGMReadingResult,
        completion: @escaping () -> Void
    ) {
        debug(.deviceManager, "PLUGIN CGM - Process CGM Reading Result launched with \(readingResult)")
        switch readingResult {
        case let .newData(values):

            let bloodGlucose = values.compactMap { newGlucoseSample -> BloodGlucose? in
                let quantity = newGlucoseSample.quantity
                let value = Int(quantity.doubleValue(for: .milligramsPerDeciliter))
 @@ -164,14 +154,13 @@ extension DexcomSourceG7: CGMManagerDelegate {
                    filtered: nil,
                    noise: nil,
                    glucose: value,
                    type: "sgv"
                )
            }
            promise?(.success(bloodGlucose))
            completion()
        case .unreliableData:
 @@ -186,3 +175,9 @@ extension DexcomSourceG7: CGMManagerDelegate {
        }
    }
}

extension PluginSource {
    func sourceInfo() -> [String: Any]? {
        [GlucoseSourceKey.description.rawValue: "Plugin CGM source"]
    }
}
