import LoopKit

public protocol TestingCGMManager: CGMManager, TestingDeviceManager {
    func injectGlucoseSamples(_ pastSamples: [NewGlucoseSample], futureSamples: [NewGlucoseSample])
}
