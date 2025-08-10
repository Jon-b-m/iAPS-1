import Combine
import Foundation
import LoopKit
import LoopKitUI
import SwiftDate
import Swinject
import UIKit

protocol FetchGlucoseManager: SourceInfoProvider {
    func updateGlucoseStore(newBloodGlucose: [BloodGlucose]) async
    func refreshCGM() async
    func updateGlucoseSource(cgmGlucoseSourceType: CGMType, cgmGlucosePluginId: String, newManager: CGMManagerUI?)
    func deleteGlucoseSource()
    var glucoseSource: GlucoseSource! { get }
    var cgmGlucoseSourceType: CGMType? { get set }
    var settingsManager: SettingsManager! { get }
    var shouldSyncToRemoteService: Bool { get }
}

extension FetchGlucoseManager {
    func updateGlucoseSource(cgmGlucoseSourceType: CGMType, cgmGlucosePluginId: String) {
        updateGlucoseSource(cgmGlucoseSourceType: cgmGlucoseSourceType, cgmGlucosePluginId: cgmGlucosePluginId, newManager: nil)
    }
}

final class BaseFetchGlucoseManager: FetchGlucoseManager, Injectable {
    private let processQueue = DispatchQueue(label: "BaseGlucoseManager.processQueue")
    @Injected() var glucoseStorage: GlucoseStorage!
    @Injected() var nightscoutManager: NightscoutManager!
    @Injected() var apsManager: APSManager!
    @Injected() var settingsManager: SettingsManager!
    @Injected() var healthKitManager: HealthKitManager!
    @Injected() var deviceDataManager: DeviceDataManager!
    @Injected() var pluginCGMManager: PluginManager!

    private let coredataContext = CoreDataStack.shared.persistentContainer.viewContext
    private var lifetime = Lifetime()
    private let timer = DispatchTimer(timeInterval: 1.minutes.timeInterval)
    var cgmGlucoseSourceType: CGMType?
    
    var cgmGlucosePluginId: String?
    var cgmManager: CGMManagerUI? {
        didSet {
            rawCGMManager = cgmManager?.rawValue
        }
    }

    @PersistedProperty(key: "CGMManagerState") var rawCGMManager: CGMManager.RawValue?

    private lazy var simulatorSource = GlucoseSimulatorSource()

    var shouldSyncToRemoteService: Bool {


           guard let cgmManager = cgmManager else {
               return true
           }
           return cgmManager.shouldSyncToRemoteService
       }

       init(resolver: Resolver) {
           injectServices(resolver)
           updateGlucoseSource(
               cgmGlucoseSourceType: settingsManager.settings.cgm,
               cgmGlucosePluginId: settingsManager.settings.cgmPluginIdentifier
           )
           subscribe()
       }

       var glucoseSource: GlucoseSource!

       func deleteGlucoseSource() {
           cgmManager = nil
           updateGlucoseSource(
               cgmGlucoseSourceType: CGMType.none,
               cgmGlucosePluginId: ""
           )
       }

       func updateGlucoseSource(cgmGlucoseSourceType: CGMType, cgmGlucosePluginId: String, newManager: CGMManagerUI?) {
           self.cgmGlucoseSourceType = cgmGlucoseSourceType
           self.cgmGlucosePluginId = cgmGlucosePluginId

           // if not plugin, manager is not changed and stay with the "old" value if the user come back to previous cgmtype
           // if plugin, if the same pluginID, no change required because the manager is available
           // if plugin, if not the same pluginID, need to reset the cgmManager
           // if plugin and newManager provides, update cgmManager
           debug(.apsManager, "plugin : \(String(describing: cgmManager?.pluginIdentifier))")
           if let manager = newManager
           {
               cgmManager = manager
           } else if self.cgmGlucoseSourceType == .plugin, cgmManager == nil, let rawCGMManager = rawCGMManager {
               cgmManager = cgmManagerFromRawValue(rawCGMManager)
           }
   //        } else if self.cgmGlucoseSourceType == .plugin, self.cgmGlucosePluginId != , self.cgmGlucosePluginId != cgmManager?.pluginIdentifier  {
   //            cgmManager = nil
   //        }

           switch self.cgmGlucoseSourceType {
           case nil,
                .none?:
               glucoseSource = nil
           case .xdrip:
               glucoseSource = AppGroupSource(from: "xDrip", cgmType: .xdrip)
           case .nightscout:
               glucoseSource = nightscoutManager
           case .simulator:
               glucoseSource = simulatorSource
           case .glucoseDirect:
               glucoseSource = AppGroupSource(from: "GlucoseDirect", cgmType: .glucoseDirect)
           case .enlite:
               glucoseSource = deviceDataManager
           case .plugin:
               glucoseSource = PluginSource(glucoseStorage: glucoseStorage, glucoseManager: self)
           }
           // update the config
       }

       /// Upload cgmManager from raw value
       func cgmManagerFromRawValue(_ rawValue: [String: Any]) -> CGMManagerUI? {
           guard let rawState = rawValue["state"] as? CGMManager.RawStateValue,
                 let cgmGlucosePluginId = self.cgmGlucosePluginId,
                 let Manager = pluginCGMManager.getCGMManagerTypeByIdentifier(cgmGlucosePluginId)
           else {
               return nil
           }

           return Manager.init(rawState: rawState)
       }

       /// function called when a callback is fired by CGM BLE - no more used
    @@ -75,7 +136,8 @@ final class BaseFetchGlucoseManager: FetchGlucoseManager, Injectable {
       /// function to try to force the refresh of the CGM - generally provide by the pump heartbeat
       public func refreshCGM() {
           debug(.deviceManager, "refreshCGM by pump")
           // updateGlucoseSource(cgmGlucoseSourceType: settingsManager.settings.cgm, cgmGlucosePluginId: settingsManager.settings.cgmPluginIdentifier)

           Publishers.CombineLatest3(
               Just(glucoseStorage.syncDate()),
               healthKitManager.fetch(nil),
    @@ -170,8 +232,12 @@ final class BaseFetchGlucoseManager: FetchGlucoseManager, Injectable {
               .receive(on: processQueue)
               .flatMap { _ -> AnyPublisher<[BloodGlucose], Never> in
                   debug(.nightscout, "FetchGlucoseManager timer heartbeat")
                   // self.updateGlucoseSource(manager: nil)
                   if let glucoseSource = self.glucoseSource {
                       return glucoseSource.fetch(self.timer).eraseToAnyPublisher()
                   } else {
                       return Empty(completeImmediately: false).eraseToAnyPublisher()
                   }
               }
               .sink { glucose in
                   debug(.nightscout, "FetchGlucoseManager callback sensor")
    @@ -193,36 +259,20 @@ final class BaseFetchGlucoseManager: FetchGlucoseManager, Injectable {
               .store(in: &lifetime)
           timer.fire()
           timer.resume()
       }

       func sourceInfo() -> [String: Any]? {
           glucoseSource.sourceInfo()
       }
   }

   extension CGMManager {
       typealias RawValue = [String: Any]

       var rawValue: [String: Any] {
           [
               "managerIdentifier": pluginIdentifier,
               "state": rawState
           ]
       }
   }
