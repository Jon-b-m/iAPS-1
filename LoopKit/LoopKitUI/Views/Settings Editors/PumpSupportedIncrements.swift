public struct PumpSupportedIncrements {
    let basalRates: [Double]
    let bolusVolumes: [Double]
    let maximumBolusVolumes: [Double]
    let maximumBasalScheduleEntryCount: Int
    public init(
        basalRates: [Double],
        bolusVolumes: [Double],
        maximumBolusVolumes: [Double],
        maximumBasalScheduleEntryCount: Int
    ) {
        self.basalRates = basalRates
        self.bolusVolumes = bolusVolumes
        self.maximumBolusVolumes = maximumBolusVolumes
        self.maximumBasalScheduleEntryCount = maximumBasalScheduleEntryCount
    }
}
