import LoopKit
import os.log
import TidepoolKit

public enum TidepoolServiceError: Error {
    case configuration
    case missingDataSetId
}

extension TidepoolServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .configuration: return LocalizedString(
                "Configuration Error",
                comment: "Error string for TidepoolServiceError.configuration"
            )
        case .missingDataSetId: return LocalizedString(
                "Missing DataSet Id",
                comment: "Error string for TidepoolServiceError.missingDataSetId"
            )
        }
    }
}

public protocol SessionStorage {
    func setSession(_ session: TSession?, for service: String) throws
    func getSession(for service: String) throws -> TSession?
}

public final class TidepoolService: Service, TAPIObserver, ObservableObject {
    public static let pluginIdentifier = "TidepoolService"

    public static let localizedTitle = LocalizedString("Tidepool", comment: "The title of the Tidepool service")

    public weak var serviceDelegate: ServiceDelegate? {
        didSet {
            hostIdentifier = serviceDelegate?.hostIdentifier
            hostVersion = serviceDelegate?.hostVersion
        }
    }

    public weak var stateDelegate: StatefulPluggableDelegate?

    public lazy var sessionStorage: SessionStorage = KeychainManager()

    public let tapi = TAPI(
        clientId: BuildDetails.default.tidepoolServiceClientId,
        redirectURL: BuildDetails.default.tidepoolServiceRedirectURL
    )

    public private(set) var error: Error?

    private let id: String

    private var lastControllerSettingsDatum: TControllerSettingsDatum?

    private var lastCGMSettingsDatum: TCGMSettingsDatum?

    private var lastPumpSettingsDatum: TPumpSettingsDatum?

    private var lastPumpSettingsOverrideDeviceEventDatum: TPumpSettingsOverrideDeviceEventDatum?

    private var hostIdentifier: String?
    private var hostVersion: String?

    private let log = OSLog(category: pluginIdentifier)
    private let tidepoolKitLog = OSLog(category: "TidepoolKit")

    public init(hostIdentifier: String, hostVersion: String) {
        id = UUID().uuidString
        self.hostIdentifier = hostIdentifier
        self.hostVersion = hostVersion

        Task {
            await tapi.setLogging(self)
            await tapi.addObserver(self)
        }
    }

    public init?(rawState: RawStateValue) {
        isOnboarded = true // Assume when restoring from state, that we're onboarded
        guard let id = rawState["id"] as? String else {
            return nil
        }
        do {
            self.id = id
            if let dataSetId = rawState["dataSetId"] as? String {
                dataSetIdCacheStatus = .fetched(dataSetId)
            }
            lastControllerSettingsDatum = (rawState["lastControllerSettingsDatum"] as? Data)
                .flatMap { try? Self.decoder.decode(TControllerSettingsDatum.self, from: $0) }
            lastCGMSettingsDatum = (rawState["lastCGMSettingsDatum"] as? Data)
                .flatMap { try? Self.decoder.decode(TCGMSettingsDatum.self, from: $0) }
            lastPumpSettingsDatum = (rawState["lastPumpSettingsDatum"] as? Data)
                .flatMap { try? Self.decoder.decode(TPumpSettingsDatum.self, from: $0) }
            lastPumpSettingsOverrideDeviceEventDatum = (rawState["lastPumpSettingsOverrideDeviceEventDatum"] as? Data)
                .flatMap { try? Self.decoder.decode(TPumpSettingsOverrideDeviceEventDatum.self, from: $0) }
            session = try sessionStorage.getSession(for: sessionService)
            Task {
                await tapi.setSession(session)
                await tapi.setLogging(self)
                await tapi.addObserver(self)
            }
        } catch {
            tidepoolKitLog.error("Error initializing TidepoolService %{public}@", error.localizedDescription)
            self.error = error
            return nil
        }
    }

    public var rawState: RawStateValue {
        var rawValue: RawStateValue = [:]
        rawValue["id"] = id
        if case let .fetched(dataSetId) = dataSetIdCacheStatus {
            rawValue["dataSetId"] = dataSetId
        }
        rawValue["lastControllerSettingsDatum"] = lastControllerSettingsDatum.flatMap { try? Self.encoder.encode($0) }
        rawValue["lastCGMSettingsDatum"] = lastCGMSettingsDatum.flatMap { try? Self.encoder.encode($0) }
        rawValue["lastPumpSettingsDatum"] = lastPumpSettingsDatum.flatMap { try? Self.encoder.encode($0) }
        rawValue["lastPumpSettingsOverrideDeviceEventDatum"] = lastPumpSettingsOverrideDeviceEventDatum
            .flatMap { try? Self.encoder.encode($0) }
        return rawValue
    }

    public var isOnboarded = false // No distinction between created and onboarded

    @Published public var session: TSession?

    public func apiDidUpdateSession(_ session: TSession?) {
        guard session != self.session else {
            return
        }

        // If userId changed, then current dataSetId is invalid
        if session?.userId != self.session?.userId {
            clearCachedDataSetId()
        }

        self.session = session

        do {
            try sessionStorage.setSession(session, for: sessionService)
        } catch {
            self.error = error
        }

        if session == nil {
            clearCachedDataSetId()
            let content = Alert.Content(
                title: LocalizedString(
                    "Tidepool Service Authorization",
                    comment: "The title for an alert generated when TidepoolService is no longer authorized."
                ),
                body: LocalizedString(
                    "Tidepool service is no longer authorized. Please navigate to Tidepool Service settings and reauthenticate.",
                    comment: "The body text for an alert generated when TidepoolService is no longer authorized."
                ),
                acknowledgeActionButtonLabel: LocalizedString("OK", comment: "Alert acknowledgment OK button")
            )
            serviceDelegate?.issueAlert(Alert(
                identifier: Alert.Identifier(
                    managerIdentifier: pluginIdentifier,
                    alertIdentifier: "authentication-needed"
                ),
                foregroundContent: content,
                backgroundContent: content,
                trigger: .immediate
            ))
        }
    }

    public func completeCreate() async throws {
        isOnboarded = true
    }

    public func completeUpdate() {
        stateDelegate?.pluginDidUpdateState(self)
    }

    public func deleteService() {
        Task {
            await self.tapi.logout()
        }
        stateDelegate?.pluginWantsDeletion(self)
    }

    private var sessionService: String { "org.tidepool.TidepoolService.\(id)" }

    private var userId: String? { session?.userId }

    private static var encoder: PropertyListEncoder = {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        return encoder
    }()

    private static var decoder = PropertyListDecoder()

    // MARK: - DataSetId

    enum DataSetIdCacheStatus {
        case inProgress(Task<String, Error>)
        case fetched(String)
    }

    private var dataSetIdCacheStatus: DataSetIdCacheStatus?

    private func clearCachedDataSetId() {
        dataSetIdCacheStatus = nil
    }

    // This is the main accessor for data set id. It will trigger a fetch or creation
    // of the Loop data set associated with the currently logged in account, and will
    // handle caching and minimizing the number of network requests.
    public func getCachedDataSetId() async throws -> String {
        if let fetchStatus = dataSetIdCacheStatus {
            switch fetchStatus {
            case let .fetched(dataSetId):
                return dataSetId
            case let .inProgress(task):
                return try await task.value
            }
        }

        let task: Task<String, Error> = Task {
            try await fetchDataSetId()
        }

        dataSetIdCacheStatus = .inProgress(task)
        let dataSetId = try await task.value
        dataSetIdCacheStatus = .fetched(dataSetId)
        return dataSetId
    }

    private func fetchDataSetId() async throws -> String {
        guard let clientName = hostIdentifier else {
            throw TidepoolServiceError.configuration
        }

        let dataSets = try await tapi.listDataSets(filter: TDataSet.Filter(clientName: clientName, deleted: false))

        if !dataSets.isEmpty {
            if dataSets.count > 1 {
                log.error("Found multiple matching data sets; expected zero or one")
            }

            guard let dataSetId = dataSets.first?.uploadId else {
                throw TidepoolServiceError.missingDataSetId
            }
            return dataSetId
        } else {
            let dataSet = try await createDataSet()
            guard let dataSetId = dataSet.id else {
                throw TidepoolServiceError.missingDataSetId
            }
            return dataSetId
        }
    }

    private func createDataSet() async throws -> TDataSet {
        guard let clientName = hostIdentifier, let clientVersion = hostVersion else {
            throw TidepoolServiceError.configuration
        }

        let dataSet = TDataSet(
            client: TDataSet.Client(name: clientName, version: clientVersion),
            dataSetType: .continuous,
            deduplicator: TDataSet.Deduplicator(name: .dataSetDeleteOrigin),
            deviceTags: [.bgm, .cgm, .insulinPump]
        )

        return try await tapi.createDataSet(dataSet)
    }
}

extension TidepoolService: TLogging {
    public func debug(_ message: String, function: StaticString, file: StaticString, line: UInt) {
        tidepoolKitLog.debug("%{public}@ %{public}@", message, location(function: function, file: file, line: line))
    }

    public func info(_ message: String, function: StaticString, file: StaticString, line: UInt) {
        tidepoolKitLog.info("%{public}@ %{public}@", message, location(function: function, file: file, line: line))
    }

    public func error(_ message: String, function: StaticString, file: StaticString, line: UInt) {
        tidepoolKitLog.error("%{public}@ %{public}@", message, location(function: function, file: file, line: line))
    }

    private func location(function: StaticString, file: StaticString, line: UInt) -> String {
        "[\(URL(fileURLWithPath: file.description).lastPathComponent):\(line):\(function)]"
    }
}

extension TidepoolService: RemoteDataService {
    public func uploadTemporaryOverrideData(
        updated _: [TemporaryScheduleOverride],
        deleted _: [TemporaryScheduleOverride],
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        // TODO: Implement
        completion(.success(true))
    }

    public var alertDataLimit: Int? { 1000 }

    public func uploadAlertData(_ stored: [SyncAlertObject], completion: @escaping (_ result: Result<Bool, Error>) -> Void) {
        guard let userId = userId, let hostIdentifier = hostIdentifier, let hostVersion = hostVersion else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }
        Task {
            do {
                let result = try await createData(
                    stored
                        .compactMap { $0.datum(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion) }
                )
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public var carbDataLimit: Int? { 1000 }

    public func uploadCarbData(
        created: [SyncCarbObject],
        updated: [SyncCarbObject],
        deleted: [SyncCarbObject],
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard let userId = userId, let hostIdentifier = hostIdentifier, let hostVersion = hostVersion else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }

        Task {
            do {
                let createdUploaded = try await createData(
                    created
                        .compactMap { $0.datum(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion) }
                )
                let updatedUploaded = try await updateData(
                    updated
                        .compactMap { $0.datum(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion) }
                )
                let deletedUploaded = try await deleteData(withSelectors: deleted.compactMap(\.selector))
                completion(.success(createdUploaded || updatedUploaded || deletedUploaded))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public var doseDataLimit: Int? { 1000 }

    public func uploadDoseData(
        created: [DoseEntry],
        deleted: [DoseEntry],
        completion: @escaping (_ result: Result<Bool, Error>) -> Void
    ) {
        guard let userId = userId, let hostIdentifier = hostIdentifier, let hostVersion = hostVersion else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }

        Task {
            do {
                let createdUploaded = try await createData(
                    created
                        .flatMap { $0.data(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion) }
                )
                let deletedUploaded = try await deleteData(withSelectors: deleted.flatMap(\.selectors))
                completion(.success(createdUploaded || deletedUploaded))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public var dosingDecisionDataLimit: Int? { 50 } // Each can be up to 20K bytes of serialized JSON, target ~1M or less

    public func uploadDosingDecisionData(
        _ stored: [StoredDosingDecision],
        completion: @escaping (_ result: Result<Bool, Error>) -> Void
    ) {
        guard let userId = userId, let hostIdentifier = hostIdentifier, let hostVersion = hostVersion else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }

        Task {
            do {
                let result =
                    try await createData(calculateDosingDecisionData(
                        stored,
                        for: userId,
                        hostIdentifier: hostIdentifier,
                        hostVersion: hostVersion
                    ))
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func calculateDosingDecisionData(
        _ stored: [StoredDosingDecision],
        for userId: String,
        hostIdentifier: String,
        hostVersion: String
    ) -> [TDatum] {
        var created: [TDatum] = []

        stored.forEach {
            let dosingDecisionDatum = $0.datumDosingDecision(
                for: userId,
                hostIdentifier: hostIdentifier,
                hostVersion: hostVersion
            )
            let controllerStatusDatum = $0.datumControllerStatus(
                for: userId,
                hostIdentifier: hostIdentifier,
                hostVersion: hostVersion
            )
            let pumpStatusDatum = $0.datumPumpStatus(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)

            var dosingDecisionAssociations: [TAssociation] = []
            var controllerStatusAssociations: [TAssociation] = []
            var pumpStatusAssociations: [TAssociation] = []

            if !dosingDecisionDatum.isEffectivelyEmpty {
                let association = TAssociation(type: .datum, id: dosingDecisionDatum.id!, reason: "dosingDecision")
                controllerStatusAssociations.append(association)
                pumpStatusAssociations.append(association)
            }
            if !controllerStatusDatum.isEffectivelyEmpty {
                let association = TAssociation(type: .datum, id: controllerStatusDatum.id!, reason: "controllerStatus")
                dosingDecisionAssociations.append(association)
                pumpStatusAssociations.append(association)
            }
            if !pumpStatusDatum.isEffectivelyEmpty {
                let association = TAssociation(type: .datum, id: pumpStatusDatum.id!, reason: "pumpStatus")
                dosingDecisionAssociations.append(association)
                controllerStatusAssociations.append(association)
            }

            dosingDecisionDatum.append(associations: dosingDecisionAssociations)
            controllerStatusDatum.append(associations: controllerStatusAssociations)
            pumpStatusDatum.append(associations: pumpStatusAssociations)

            if !dosingDecisionDatum.isEffectivelyEmpty {
                created.append(dosingDecisionDatum)
            }
            if !controllerStatusDatum.isEffectivelyEmpty {
                created.append(controllerStatusDatum)
            }
            if !pumpStatusDatum.isEffectivelyEmpty {
                created.append(pumpStatusDatum)
            }
        }

        return created
    }

    public var glucoseDataLimit: Int? { 1000 }

    public func uploadGlucoseData(_ stored: [StoredGlucoseSample], completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let userId = userId, let hostIdentifier = hostIdentifier, let hostVersion = hostVersion else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }

        Task {
            do {
                let result = try await createData(
                    stored
                        .compactMap { $0.datum(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion) }
                )
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public var pumpDataEventLimit: Int? { 1000 }

    public func uploadPumpEventData(
        _ stored: [PersistedPumpEvent],
        completion: @escaping (_ result: Result<Bool, Error>) -> Void
    ) {
        guard let userId = userId, let hostIdentifier = hostIdentifier, let hostVersion = hostVersion else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }

        Task {
            do {
                let result = try await createData(
                    stored
                        .flatMap { $0.data(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion) }
                )
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public var settingsDataLimit: Int? { 400 } // Each can be up to 2.5K bytes of serialized JSON, target ~1M or less

    public func uploadSettingsData(_ stored: [StoredSettings], completion: @escaping (_ result: Result<Bool, Error>) -> Void) {
        guard let userId = userId, let hostIdentifier = hostIdentifier, let hostVersion = hostVersion else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }

        let (
            created,
            updated,
            lastControllerSettingsDatum,
            lastCGMSettingsDatum,
            lastPumpSettingsDatum,
            lastPumpSettingsOverrideDeviceEventDatum
        ) = calculateSettingsData(stored, for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)

        Task {
            do {
                let createdUploaded = try await createData(created)
                let updatedUploaded = try await updateData(updated)
                self.lastControllerSettingsDatum = lastControllerSettingsDatum
                self.lastCGMSettingsDatum = lastCGMSettingsDatum
                self.lastPumpSettingsDatum = lastPumpSettingsDatum
                self.lastPumpSettingsOverrideDeviceEventDatum = lastPumpSettingsOverrideDeviceEventDatum
                self.completeUpdate()
                completion(.success(createdUploaded || updatedUploaded))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func calculateSettingsData(
        _ stored: [StoredSettings],
        for userId: String,
        hostIdentifier: String,
        hostVersion: String
    )
        -> (
            [TDatum],
            [TDatum],
            TControllerSettingsDatum?,
            TCGMSettingsDatum?,
            TPumpSettingsDatum?,
            TPumpSettingsOverrideDeviceEventDatum?
        )
    {
        var created: [TDatum] = []
        var updated: [TDatum] = []
        var lastControllerSettingsDatum = lastControllerSettingsDatum
        var lastCGMSettingsDatum = lastCGMSettingsDatum
        var lastPumpSettingsDatum = lastPumpSettingsDatum
        var lastPumpSettingsOverrideDeviceEventDatum = lastPumpSettingsOverrideDeviceEventDatum

        // A StoredSettings can generate a TPumpSettingsDatum and an optional TPumpSettingsOverrideDeviceEventDatum if there is an
        // enabled override. Only upload the TPumpSettingsDatum or TPumpSettingsOverrideDeviceEventDatum if they have CHANGED.
        // If the TPumpSettingsOverrideDeviceEventDatum has changed, then also re-upload the previous uploaded
        // TPumpSettingsOverrideDeviceEventDatum with an updated duration and potentially expected duration, but only if the
        // duration is calculated to be ended early.

        stored.forEach {
            // Calculate the data

            let controllerSettingsDatum = $0.datumControllerSettings(
                for: userId,
                hostIdentifier: hostIdentifier,
                hostVersion: hostVersion
            )
            let controllerSettingsDatumIsEffectivelyEquivalent = TControllerSettingsDatum.areEffectivelyEquivalent(
                old: lastControllerSettingsDatum,
                new: controllerSettingsDatum
            )

            let cgmSettingsDatum = $0.datumCGMSettings(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
            let cgmSettingsDatumIsEffectivelyEquivalent = TCGMSettingsDatum.areEffectivelyEquivalent(
                old: lastCGMSettingsDatum,
                new: cgmSettingsDatum
            )

            let pumpSettingsDatum = $0.datumPumpSettings(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
            let pumpSettingsDatumIsEffectivelyEquivalent = TPumpSettingsDatum.areEffectivelyEquivalent(
                old: lastPumpSettingsDatum,
                new: pumpSettingsDatum
            )

            let pumpSettingsOverrideDeviceEventDatum = $0.datumPumpSettingsOverrideDeviceEvent(
                for: userId,
                hostIdentifier: hostIdentifier,
                hostVersion: hostVersion
            )
            let pumpSettingsOverrideDeviceEventDatumIsEffectivelyEquivalent = TPumpSettingsOverrideDeviceEventDatum
                .areEffectivelyEquivalent(
                    old: lastPumpSettingsOverrideDeviceEventDatum,
                    new: pumpSettingsOverrideDeviceEventDatum
                )

            // Associate the data

            var controllerSettingsAssociations: [TAssociation] = []
            var cgmSettingsAssociations: [TAssociation] = []
            var pumpSettingsAssociations: [TAssociation] = []
            var pumpSettingsOverrideDeviceEventAssociations: [TAssociation] = []

            if let controllerSettingsDatum = controllerSettingsDatumIsEffectivelyEquivalent ? lastControllerSettingsDatum :
                controllerSettingsDatum
            {
                let association = TAssociation(type: .datum, id: controllerSettingsDatum.id!, reason: "controllerSettings")
                cgmSettingsAssociations.append(association)
                pumpSettingsAssociations.append(association)
            }
            if let cgmSettingsDatum = cgmSettingsDatumIsEffectivelyEquivalent ? lastCGMSettingsDatum : cgmSettingsDatum {
                let association = TAssociation(type: .datum, id: cgmSettingsDatum.id!, reason: "cgmSettings")
                controllerSettingsAssociations.append(association)
                pumpSettingsAssociations.append(association)
            }
            if let pumpSettingsDatum = pumpSettingsDatumIsEffectivelyEquivalent ? lastPumpSettingsDatum : pumpSettingsDatum {
                let association = TAssociation(type: .datum, id: pumpSettingsDatum.id!, reason: "pumpSettings")
                controllerSettingsAssociations.append(association)
                cgmSettingsAssociations.append(association)
                pumpSettingsOverrideDeviceEventAssociations.append(association)
            }

            controllerSettingsDatum.append(associations: controllerSettingsAssociations)
            cgmSettingsDatum.append(associations: cgmSettingsAssociations)
            pumpSettingsDatum.append(associations: pumpSettingsAssociations)
            pumpSettingsOverrideDeviceEventDatum?.append(associations: pumpSettingsOverrideDeviceEventAssociations)

            // Upload and update the data, if necessary

            if !controllerSettingsDatumIsEffectivelyEquivalent {
                created.append(controllerSettingsDatum)
                lastControllerSettingsDatum = controllerSettingsDatum
            }

            if !cgmSettingsDatumIsEffectivelyEquivalent {
                created.append(cgmSettingsDatum)
                lastCGMSettingsDatum = cgmSettingsDatum
            }

            if !pumpSettingsDatumIsEffectivelyEquivalent {
                created.append(pumpSettingsDatum)
                lastPumpSettingsDatum = pumpSettingsDatum
            }

            if !pumpSettingsOverrideDeviceEventDatumIsEffectivelyEquivalent {
                // If we need to update the duration of the last override, then do so
                if let lastPumpSettingsOverrideDeviceEventDatum = lastPumpSettingsOverrideDeviceEventDatum,
                   lastPumpSettingsOverrideDeviceEventDatum
                   .updateDuration(basedUpon: pumpSettingsOverrideDeviceEventDatum?.time ?? pumpSettingsDatum.time)
                {
                    // If it isn't already being created, then update it
                    if !created.contains(where: { $0 === lastPumpSettingsOverrideDeviceEventDatum }) {
                        updated.append(lastPumpSettingsOverrideDeviceEventDatum)
                    }
                }

                if let pumpSettingsOverrideDeviceEventDatum = pumpSettingsOverrideDeviceEventDatum {
                    created.append(pumpSettingsOverrideDeviceEventDatum)
                }
                lastPumpSettingsOverrideDeviceEventDatum = pumpSettingsOverrideDeviceEventDatum
            }
        }

        return (
            created,
            updated,
            lastControllerSettingsDatum,
            lastCGMSettingsDatum,
            lastPumpSettingsDatum,
            lastPumpSettingsOverrideDeviceEventDatum
        )
    }

    private func createData(_ data: [TDatum]) async throws -> Bool {
        if let error = error {
            throw error
        }

        let dataSetId = try await getCachedDataSetId()

        do {
            try await tapi.createData(data, dataSetId: dataSetId)
            return !data.isEmpty
        } catch {
            log.error("Failed to create data - %{public}@", error.localizedDescription)
            log.error("Failed data: %{public}@", String(describing: data))
            throw error
        }
    }

    private func updateData(_ data: [TDatum]) async throws -> Bool {
        if let error = error {
            throw error
        }

        let dataSetId = try await getCachedDataSetId()

        // TODO: This implementation is incorrect and will not record the correct history when data is updated. Currently waiting on
        // https://tidepool.atlassian.net/browse/BACK-815 for backend to support new API to capture full history of data changes.
        // This work will be covered in https://tidepool.atlassian.net/browse/LOOP-3943. For now just call createData with the
        // updated data as it will just overwrite the previous data with the updated data.
        do {
            try await tapi.createData(data, dataSetId: dataSetId)
            return !data.isEmpty
        } catch {
            log.error("Failed to update data - %{public}@", error.localizedDescription)
            throw error
        }
    }

    private func deleteData(withSelectors selectors: [TDatum.Selector]) async throws -> Bool {
        if let error = error {
            throw error
        }

        let dataSetId = try await getCachedDataSetId()

        do {
            try await tapi.deleteData(withSelectors: selectors, dataSetId: dataSetId)
            return !selectors.isEmpty
        } catch {
            log.error("Failed to delete data - %{public}@", error.localizedDescription)
            throw error
        }
    }

    public func uploadCgmEventData(_: [LoopKit.PersistedCgmEvent], completion: @escaping (Result<Bool, Error>) -> Void) {
        // TODO: Upload sensor/transmitter changes
        completion(.success(false))
    }

    public func remoteNotificationWasReceived(_: [String: AnyObject]) async throws {
        throw RemoteNotificationError.remoteCommandsNotSupported
    }

    enum RemoteNotificationError: LocalizedError {
        case remoteCommandsNotSupported
    }
}

extension KeychainManager: SessionStorage {
    public func setSession(_ session: TSession?, for service: String) throws {
        try deleteGenericPassword(forService: service)
        guard let session = session else {
            return
        }
        let sessionData = try JSONEncoder.tidepool.encode(session)
        try replaceGenericPassword(sessionData, forService: service)
    }

    public func getSession(for service: String) throws -> TSession? {
        let sessionData = try getGenericPasswordForServiceAsData(service)
        return try JSONDecoder.tidepool.decode(TSession.self, from: sessionData)
    }
}

private protocol EffectivelyEquivalent {
    func isEffectivelyEquivalent(to other: Self) -> Bool
    var isEffectivelyEmpty: Bool { get }
}

private extension EffectivelyEquivalent {
    static func areEffectivelyEquivalent(old: Self?, new: Self?) -> Bool {
        if let new = new {
            return old?.isEffectivelyEquivalent(to: new) ?? new.isEffectivelyEmpty // Prevents uploading effectively empty datum
        } else {
            return old == nil
        }
    }
}

extension TControllerSettingsDatum: EffectivelyEquivalent {
    // All TDatum properties can be ignored for this datum type
    func isEffectivelyEquivalent(to other: TControllerSettingsDatum) -> Bool {
        device == other.device &&
            notifications == other.notifications
    }

    var isEffectivelyEmpty: Bool {
        device == nil &&
            notifications == nil
    }
}

extension TCGMSettingsDatum: EffectivelyEquivalent {
    // All TDatum properties can be ignored for this datum type
    func isEffectivelyEquivalent(to other: TCGMSettingsDatum) -> Bool {
        firmwareVersion == other.firmwareVersion &&
            hardwareVersion == other.hardwareVersion &&
            manufacturers == other.manufacturers &&
            model == other.model &&
            name == other.name &&
            serialNumber == other.serialNumber &&
            softwareVersion == other.softwareVersion &&
            transmitterId == other.transmitterId &&
            units == other.units &&
            defaultAlerts == other.defaultAlerts &&
            scheduledAlerts == other.scheduledAlerts &&
            highAlertsDEPRECATED == other.highAlertsDEPRECATED &&
            lowAlertsDEPRECATED == other.lowAlertsDEPRECATED &&
            outOfRangeAlertsDEPRECATED == other.outOfRangeAlertsDEPRECATED &&
            rateOfChangeAlertsDEPRECATED == other.rateOfChangeAlertsDEPRECATED
    }

    // Ignore units as they are always specified
    var isEffectivelyEmpty: Bool {
        firmwareVersion == nil &&
            hardwareVersion == nil &&
            manufacturers == nil &&
            model == nil &&
            name == nil &&
            serialNumber == nil &&
            softwareVersion == nil &&
            transmitterId == nil &&
            defaultAlerts == nil &&
            scheduledAlerts == nil &&
            highAlertsDEPRECATED == nil &&
            lowAlertsDEPRECATED == nil &&
            outOfRangeAlertsDEPRECATED == nil &&
            rateOfChangeAlertsDEPRECATED == nil
    }
}

extension TPumpSettingsDatum: EffectivelyEquivalent {
    // All TDatum properties can be ignored for this datum type
    func isEffectivelyEquivalent(to other: TPumpSettingsDatum) -> Bool {
        activeScheduleName == other.activeScheduleName &&
            automatedDelivery == other.automatedDelivery &&
            basal == other.basal &&
            basalRateSchedule == other.basalRateSchedule &&
            basalRateSchedules == other.basalRateSchedules &&
            bloodGlucoseSafetyLimit == other.bloodGlucoseSafetyLimit &&
            bloodGlucoseTargetPhysicalActivity == other.bloodGlucoseTargetPhysicalActivity &&
            bloodGlucoseTargetPreprandial == other.bloodGlucoseTargetPreprandial &&
            bloodGlucoseTargetSchedule == other.bloodGlucoseTargetSchedule &&
            bloodGlucoseTargetSchedules == other.bloodGlucoseTargetSchedules &&
            bolus == other.bolus &&
            carbohydrateRatioSchedule == other.carbohydrateRatioSchedule &&
            carbohydrateRatioSchedules == other.carbohydrateRatioSchedules &&
            display == other.display &&
            firmwareVersion == other.firmwareVersion &&
            hardwareVersion == other.hardwareVersion &&
            insulinFormulation == other.insulinFormulation &&
            insulinModel == other.insulinModel &&
            insulinSensitivitySchedule == other.insulinSensitivitySchedule &&
            insulinSensitivitySchedules == other.insulinSensitivitySchedules &&
            manufacturers == other.manufacturers &&
            model == other.model &&
            name == other.name &&
            overridePresets == other.overridePresets &&
            scheduleTimeZoneOffset == other.scheduleTimeZoneOffset &&
            serialNumber == other.serialNumber &&
            softwareVersion == other.softwareVersion &&
            units == other.units
    }

    // Ignore units as they are always specified
    var isEffectivelyEmpty: Bool {
        activeScheduleName == nil &&
            automatedDelivery == nil &&
            basal == nil &&
            basalRateSchedule == nil &&
            basalRateSchedules == nil &&
            bloodGlucoseSafetyLimit == nil &&
            bloodGlucoseTargetPhysicalActivity == nil &&
            bloodGlucoseTargetPreprandial == nil &&
            bloodGlucoseTargetSchedule == nil &&
            bloodGlucoseTargetSchedules == nil &&
            bolus == nil &&
            carbohydrateRatioSchedule == nil &&
            carbohydrateRatioSchedules == nil &&
            display == nil &&
            firmwareVersion == nil &&
            hardwareVersion == nil &&
            insulinFormulation == nil &&
            insulinModel == nil &&
            insulinSensitivitySchedule == nil &&
            insulinSensitivitySchedules == nil &&
            manufacturers == nil &&
            model == nil &&
            name == nil &&
            overridePresets == nil &&
            scheduleTimeZoneOffset == nil &&
            serialNumber == nil &&
            softwareVersion == nil
    }
}

extension TPumpSettingsOverrideDeviceEventDatum: EffectivelyEquivalent {
    // All TDatum properties can be ignored EXCEPT time for this datum type
    // Time is gather from the actual scheduled override and NOT the StoredSettings so it is valid and necessary for comparison
    func isEffectivelyEquivalent(to other: TPumpSettingsOverrideDeviceEventDatum) -> Bool {
        time == other.time &&
            overrideType == other.overrideType &&
            overridePreset == other.overridePreset &&
            method == other.method &&
            duration == other.duration &&
            expectedDuration == other.expectedDuration &&
            bloodGlucoseTarget == other.bloodGlucoseTarget &&
            basalRateScaleFactor == other.basalRateScaleFactor &&
            carbohydrateRatioScaleFactor == other.carbohydrateRatioScaleFactor &&
            insulinSensitivityScaleFactor == other.insulinSensitivityScaleFactor &&
            units == other.units
    }

    var isEffectivelyEmpty: Bool {
        overrideType == nil &&
            overridePreset == nil &&
            method == nil &&
            duration == nil &&
            expectedDuration == nil &&
            bloodGlucoseTarget == nil &&
            basalRateScaleFactor == nil &&
            carbohydrateRatioScaleFactor == nil &&
            insulinSensitivityScaleFactor == nil &&
            units == nil
    }

    func updateDuration(basedUpon endTime: Date?) -> Bool {
        guard let endTime = endTime, let time = time, endTime > time else {
            return false
        }

        let updatedDuration = time.distance(to: endTime)
        guard duration == nil || updatedDuration < duration! else {
            return false
        }

        expectedDuration = duration
        duration = updatedDuration
        return true
    }
}

private extension TDosingDecisionDatum {
    // Ignore reason and units as they are always specified
    var isEffectivelyEmpty: Bool {
        originalFood == nil &&
            food == nil &&
            selfMonitoredBloodGlucose == nil &&
            carbohydratesOnBoard == nil &&
            insulinOnBoard == nil &&
            bloodGlucoseTargetSchedule == nil &&
            historicalBloodGlucose == nil &&
            forecastBloodGlucose == nil &&
            recommendedBasal == nil &&
            recommendedBolus == nil &&
            requestedBolus == nil &&
            warnings?.isEmpty != false &&
            errors?.isEmpty != false &&
            scheduleTimeZoneOffset == nil &&
            units == nil
    }
}

private extension TControllerStatusDatum {
    var isEffectivelyEmpty: Bool {
        battery == nil
    }
}

private extension TPumpStatusDatum {
    var isEffectivelyEmpty: Bool {
        basalDelivery == nil &&
            battery == nil &&
            bolusDelivery == nil &&
            deliveryIndeterminant == nil &&
            reservoir == nil
    }
}
