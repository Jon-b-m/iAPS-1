import HealthKit

public struct NewFavoriteFood: FavoriteFood {
    public var name: String
    public var carbsQuantity: HKQuantity
    public var foodType: String
    public var absorptionTime: TimeInterval

    public init(name: String, carbsQuantity: HKQuantity, foodType: String, absorptionTime: TimeInterval) {
        self.name = name
        self.carbsQuantity = carbsQuantity
        self.foodType = foodType
        self.absorptionTime = absorptionTime
    }
}
