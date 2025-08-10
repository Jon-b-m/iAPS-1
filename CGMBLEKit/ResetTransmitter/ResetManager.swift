import CGMBLEKit
import os.log

class ResetManager {
    enum State {
        case initialized
        case resetting(transmitter: Transmitter)
        case completed
    }

    private(set) var state: State {
        get {
            lockedState.value
        }
        set {
            let oldValue = state

            if case let .resetting(transmitter) = oldValue {
                transmitter.stayConnected = false
                transmitter.stopScanning()
                transmitter.delegate = nil
                transmitter.commandSource = nil
            }

            lockedState.value = newValue

            if case let .resetting(transmitter) = newValue {
                transmitter.delegate = self
                transmitter.commandSource = self
                transmitter.resumeScanning()
            }

            os_log(
                "State changed: %{public}@ -> %{public}@",
                log: log,
                type: .debug,
                String(describing: oldValue),
                String(describing: newValue)
            )
            delegate?.resetManager(self, didChangeStateFrom: oldValue)
        }
    }

    private let lockedState = Locked(State.initialized)

    private let log = OSLog(subsystem: "com.loopkit.CGMBLEKit", category: "ResetManager")

    weak var delegate: ResetManagerDelegate?
}

protocol ResetManagerDelegate: AnyObject {
    func resetManager(_ manager: ResetManager, didError error: Error)

    func resetManager(_ manager: ResetManager, didChangeStateFrom oldState: ResetManager.State)
}

extension ResetManager {
    func cancel() {
        guard case .resetting = state else {
            return
        }

        state = .initialized
    }

    func resetTransmitter(withID id: String) {
        guard id.count == 6 else {
            return
        }

        switch state {
        case .completed,
             .initialized:
            break
        case let .resetting(transmitter: transmitter):
            guard transmitter.ID != id else {
                return
            }
        }

        state = .resetting(transmitter: Transmitter(id: id, passiveModeEnabled: false))

        #if targetEnvironment(simulator)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                self.delegate?.resetManager(self, didError: TransmitterError.controlError("Simulated Error"))

                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                    if case .resetting = self.state {
                        self.state = .completed
                    }
                }
            }
        #endif
    }
}

extension ResetManager: TransmitterDelegate {
    func transmitter(_: Transmitter, didError error: Error) {
        os_log("Transmitter error: %{public}@", log: log, type: .error, String(describing: error))
        delegate?.resetManager(self, didError: error)
    }

    func transmitter(_: Transmitter, didRead _: Glucose) {
        // Not interested
    }

    func transmitter(_: Transmitter, didReadBackfill _: [Glucose]) {
        // Not interested
    }

    func transmitter(_: Transmitter, didReadUnknownData _: Data) {
        // Not interested
    }

    func transmitterDidConnect(_: Transmitter) {
        // Not interested
    }
}

extension ResetManager: TransmitterCommandSource {
    func dequeuePendingCommand(for _: Transmitter) -> Command? {
        if case .resetting = state {
            return .resetTransmitter
        }

        return nil
    }

    func transmitter(_: Transmitter, didFail _: Command, with error: Error) {
        os_log("Command error: %{public}@", log: log, type: .error, String(describing: error))
        delegate?.resetManager(self, didError: error)
    }

    func transmitter(_: Transmitter, didComplete command: Command) {
        if case .resetTransmitter = command {
            state = .completed
        }
    }
}
