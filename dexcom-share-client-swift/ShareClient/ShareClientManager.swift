import HealthKit
import LoopKit

public class ShareClientManager: CGMManager {
    public static let pluginIdentifier = "DexShareClient"

    public init() {
        shareService = ShareService(keychainManager: keychain)
    }

    public required convenience init?(rawState _: CGMManager.RawStateValue) {
        self.init()
    }

    public var rawState: CGMManager.RawStateValue {
        [:]
    }

    public let isOnboarded = true // No distinction between created and onboarded

    private let keychain = KeychainManager()

    public var shareService: ShareService {
        didSet {
            try! keychain.setDexcomShareUsername(shareService.username, password: shareService.password, url: shareService.url)
        }
    }

    public let localizedTitle = LocalizedString("Dexcom Share", comment: "Title for the CGMManager option")

    public let appURL: URL? = nil

    public var cgmManagerDelegate: CGMManagerDelegate? {
        get {
            delegate.delegate
        }
        set {
            delegate.delegate = newValue
        }
    }

    public var delegateQueue: DispatchQueue! {
        get {
            delegate.queue
        }
        set {
            delegate.queue = newValue
        }
    }

    public let delegate = WeakSynchronizedDelegate<CGMManagerDelegate>()

    public let providesBLEHeartbeat = false

    public let shouldSyncToRemoteService = false

    public var glucoseDisplay: GlucoseDisplayable? {
        latestBackfill
    }

    public var cgmManagerStatus: CGMManagerStatus {
        CGMManagerStatus(hasValidSensorSession: hasValidSensorSession, device: device)
    }

    public var hasValidSensorSession: Bool {
        shareService.isAuthorized
    }

    public let managedDataInterval: TimeInterval? = nil

    public private(set) var latestBackfill: ShareGlucose?

    public func fetchNewDataIfNeeded(_ completion: @escaping (CGMReadingResult) -> Void) {
        guard let shareClient = shareService.client else {
            completion(.noData)
            return
        }

        // If our last glucose was less than 4.5 minutes ago, don't fetch.
        if let latestGlucose = latestBackfill, latestGlucose.startDate.timeIntervalSinceNow > -TimeInterval(minutes: 4.5) {
            completion(.noData)
            return
        }

        shareClient.fetchLast(6) { error, glucose in
            if let error = error {
                completion(.error(error))
                return
            }
            guard let glucose = glucose else {
                completion(.noData)
                return
            }

            // Ignore glucose values that are up to a minute newer than our previous value, to account for possible time shifting in Share data
            let startDate = self.delegate.call { (delegate) -> Date? in
                delegate?.startDateToFilterNewData(for: self)?.addingTimeInterval(TimeInterval(minutes: 1))
            }
            let newGlucose = glucose.filterDateRange(startDate, nil)
            let newSamples = newGlucose.filter({ $0.isStateValid }).map {
                NewGlucoseSample(
                    date: $0.startDate,
                    quantity: $0.quantity,
                    condition: $0.condition,
                    trend: $0.trendType,
                    trendRate: $0.trendRate,
                    isDisplayOnly: false,
                    wasUserEntered: false,
                    syncIdentifier: "\(Int($0.startDate.timeIntervalSince1970))",
                    device: self.device
                )
            }

            self.latestBackfill = newGlucose.first

            if !newSamples.isEmpty {
                completion(.newData(newSamples))
            } else {
                completion(.noData)
            }
        }
    }

    public var device: HKDevice?

    public var debugDescription: String {
        [
            "## ShareClientManager",
            "latestBackfill: \(String(describing: latestBackfill))",
            ""
        ].joined(separator: "\n")
    }
}

// MARK: - AlertResponder implementation

public extension ShareClientManager {
    func acknowledgeAlert(alertIdentifier _: Alert.AlertIdentifier, completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
}

// MARK: - AlertSoundVendor implementation

public extension ShareClientManager {
    func getSoundBaseURL() -> URL? { nil }
    func getSounds() -> [Alert.Sound] { [] }
}
