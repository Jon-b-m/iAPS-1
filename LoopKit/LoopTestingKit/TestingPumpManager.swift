import LoopKit

public protocol TestingPumpManager: PumpManager, TestingDeviceManager {
    var reservoirFillFraction: Double { get set }
    func injectPumpEvents(_ pumpEvents: [NewPumpEvent])
}
