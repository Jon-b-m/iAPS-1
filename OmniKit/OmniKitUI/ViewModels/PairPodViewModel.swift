import LoopKit
import LoopKitUI
import OmniKit
import SwiftUI

class PairPodViewModel: ObservableObject, Identifiable {
    enum NavBarButtonAction {
        case cancel
        case discard

        var text: String {
            switch self {
            case .cancel:
                return LocalizedString("Cancel", comment: "Pairing interface navigation bar button text for cancel action")
            case .discard:
                return LocalizedString(
                    "Discard Pod",
                    comment: "Pairing interface navigation bar button text for discard pod action"
                )
            }
        }

        func color(using guidanceColors: GuidanceColors) -> Color? {
            switch self {
            case .discard:
                return guidanceColors.critical
            case .cancel:
                return nil
            }
        }
    }

    enum PairPodViewModelState {
        case ready
        case pairing
        case priming(finishTime: CFTimeInterval?)
        case error(OmnipodPairingError)
        case finished

        var instructionsDisabled: Bool {
            switch self {
            case .ready:
                return false
            case let .error(error):
                return !error.recoverable
            default:
                return true
            }
        }

        var actionButtonAccessibilityLabel: String {
            switch self {
            case .ready:
                return LocalizedString("Pair pod.", comment: "Pairing action button accessibility label while ready to pair")
            case .pairing:
                return LocalizedString("Pairing.", comment: "Pairing action button accessibility label while pairing")
            case .priming:
                return LocalizedString(
                    "Priming. Please wait.",
                    comment: "Pairing action button accessibility label while priming"
                )
            case let .error(error):
                return String(format: "%@ %@", error.errorDescription ?? "", error.recoverySuggestion ?? "")
            case .finished:
                return LocalizedString(
                    "Pod paired successfully. Continue.",
                    comment: "Pairing action button accessibility label when pairing succeeded"
                )
            }
        }

        var nextActionButtonDescription: String {
            switch self {
            case .ready:
                return LocalizedString("Pair Pod", comment: "Pod pairing action button text while ready to pair")
            case .error:
                return LocalizedString("Retry", comment: "Pod pairing action button text while showing error")
            case .pairing:
                return LocalizedString("Pairing...", comment: "Pod pairing action button text while pairing")
            case .priming:
                return LocalizedString("Priming...", comment: "Pod pairing action button text while priming")
            case .finished:
                return LocalizedString("Continue", comment: "Pod pairing action button text when paired")
            }
        }

        var navBarButtonAction: NavBarButtonAction {
            .cancel
        }

        var navBarVisible: Bool {
            if case let .error(error) = self {
                return error.recoverable
            }
            return true
        }

        var showProgressDetail: Bool {
            switch self {
            case .ready:
                return false
            default:
                return true
            }
        }

        var progressState: ProgressIndicatorState {
            switch self {
            case .error,
                 .ready:
                return .hidden
            case .pairing:
                return .indeterminantProgress
            case let .priming(finishTime):
                if let finishTime {
                    return .timedProgress(finishTime: finishTime)
                } else {
                    return .indeterminantProgress
                }
            case .finished:
                return .completed
            }
        }

        var isProcessing: Bool {
            switch self {
            case .pairing,
                 .priming:
                return true
            default:
                return false
            }
        }

        var isFinished: Bool {
            if case .finished = self {
                return true
            }
            return false
        }
    }

    var error: OmnipodPairingError? {
        if case let .error(error) = state {
            return error
        }
        return nil
    }

    @Published var state: PairPodViewModelState = .ready

    var podIsActivated: Bool {
        podPairer.podCommState != .noPod
    }

    var backButtonHidden: Bool {
        if case .pairing = state {
            return true
        }
        if podIsActivated {
            return true
        }
        return false
    }

    var didFinish: (() -> Void)?

    var didRequestDeactivation: (() -> Void)?

    var didCancelSetup: (() -> Void)?

    var podPairer: PodPairer

    var autoRetryAttempted: Bool

    init(podPairer: PodPairer) {
        self.podPairer = podPairer
        autoRetryAttempted = false

        // If resuming, don't wait for the button action
        if podPairer.podCommState == .activating {
            pairAndPrime()
        }
    }

    private func pairAndPrime() {
        if podPairer.podCommState == .noPod {
            state = .pairing
        } else {
            // Already paired, so resume with the prime
            state = .priming(finishTime: nil)
        }

        podPairer.pairAndPrimePod { status in
            DispatchQueue.main.async {
                switch status {
                case let .failure(error):
                    if self.podPairer.podCommState == .noPod {
                        let pairAndPrimeError = OmnipodPairingError.pumpManagerError(error)
                        self.state = .error(pairAndPrimeError)
                    } else if self.autoRetryAttempted {
                        self.autoRetryAttempted = false // allow for an auto retry on the next user attempt
                        let pairAndPrimeError = OmnipodPairingError.pumpManagerError(error)
                        self.state = .error(pairAndPrimeError)
                    } else {
                        self.autoRetryAttempted = true
                        let autoRetryPauseTime = TimeInterval(seconds: 3)
                        print(
                            "### pairAndPrimePod encountered error \(error.localizedDescription), retrying after \(autoRetryPauseTime) seconds"
                        )
                        DispatchQueue.global(qos: .utility).async {
                            Thread.sleep(forTimeInterval: autoRetryPauseTime)

                            self.pairAndPrime() // handles both pairing or priming failures
                        }
                    }
                case let .success(duration):

                    if duration > 0 {
                        self.state = .priming(finishTime: CACurrentMediaTime() + duration)
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            self.state = .finished
                        }
                    } else {
                        self.state = .finished
                    }
                }
            }
        }
    }

    public func continueButtonTapped() {
        switch state {
        case let .error(error):
            if !error.recoverable {
                didRequestDeactivation?()
            } else {
                // Retry
                pairAndPrime()
            }
        case .finished:
            didFinish?()
        default:
            pairAndPrime()
        }
    }
}

// Pairing recovery suggestions
enum OmnipodPairingError: LocalizedError {
    case pumpManagerError(PumpManagerError)

    var recoverySuggestion: String? {
        switch self {
        case let .pumpManagerError(error):
            return error.recoverySuggestion
        }
    }

    var errorDescription: String? {
        switch self {
        case let .pumpManagerError(error):
            return error.errorDescription
        }
    }

    var recoverable: Bool {
//        switch self {
//        case .pumpManagerError(let error):
        // TODO: check which errors are recoverable
        true
//        }
    }
}

public protocol PodPairer {
    func pairAndPrimePod(completion: @escaping (PumpManagerResult<TimeInterval>) -> Void)
    func discardPod(completion: @escaping (Bool) -> Void)
    var podCommState: PodCommState { get }
}

extension OmnipodPumpManager: PodPairer {
    public func discardPod(completion _: @escaping (Bool) -> Void) {}

    public func pairAndPrimePod(completion: @escaping (PumpManagerResult<TimeInterval>) -> Void) {
        pairAndPrime(completion: completion)
    }
}
